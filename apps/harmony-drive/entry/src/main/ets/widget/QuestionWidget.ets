/**
 * FormExtensionAbility：每日一题卡片数据提供
 */
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility'
import formBindingData from '@ohos.app.form.formBindingData'
import formProvider from '@ohos.app.form.formProvider'
import Want from '@ohos.app.ability.Want'
import common from '@ohos.app.ability.common'
import util from '@ohos.util'
import hilog from '@ohos.hilog'
import { Question } from '../data/Question'

const TAG = 'QuestionWidget'
const DOMAIN = 0x0002

interface DailyPayload {
  stem: string
  options: string
  chapter: string
  subject: number
}

function loadDaily(context: common.Context): DailyPayload {
  const rm = context.resourceManager
  const empty: DailyPayload = { stem: '今日份驾考题', options: '打开 App 开始刷题', chapter: '驾考通', subject: 1 }
  try {
    // 与应用内"每日一题"同种子，保证同一天内容一致
    const now = new Date()
    const seed = now.getFullYear() * 372 + (now.getMonth() + 1) * 31 + now.getDate()
    const decoder = util.TextDecoder.create('utf-8')
    const banks: Question[] = []
    const files = ['bank_subject1.json', 'bank_subject4.json']
    for (const f of files) {
      const raw = rm.getRawFileContentSync(f)
      const text = decoder.decodeWithStream(raw)
      const arr = JSON.parse(text) as Question[]
      banks.push(...arr)
    }
    if (banks.length === 0) {
      return empty
    }
    const q = banks[seed % banks.length]
    return {
      stem: `【${q.chapter}】${q.stem}`,
      options: q.options.join(' ｜ '),
      chapter: q.subject === 1 ? '科目一' : '科目四',
      subject: q.subject
    }
  } catch (err) {
    hilog.error(DOMAIN, TAG, `load daily failed: ${JSON.stringify(err)}`)
    return empty
  }
}

export default class QuestionWidget extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const payload = loadDaily(this.context)
    return formBindingData.createFormBindingData({
      stem: payload.stem,
      options: payload.options,
      chapter: payload.chapter,
      subject: payload.subject
    })
  }

  onUpdateForm(formId: string): void {
    const payload = loadDaily(this.context)
    const bindingData = formBindingData.createFormBindingData({
      stem: payload.stem,
      options: payload.options,
      chapter: payload.chapter,
      subject: payload.subject
    })
    formProvider.updateForm(formId, bindingData).catch((err: Object) => {
      hilog.error(DOMAIN, TAG, `updateForm failed: ${JSON.stringify(err)}`)
    })
  }

  onCastToNormalForm(formId: string): void {
    formProvider.updateForm(formId,
      formBindingData.createFormBindingData({ stem: '每日一题已转为普通卡片' }))
  }
}
