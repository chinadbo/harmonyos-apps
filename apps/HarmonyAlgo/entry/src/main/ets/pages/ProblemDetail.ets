import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { Database } from '../model/Database';
import { Problem } from '../model/Problem';
import { STATUS_DONE, STATUS_MASTERED, statusLabel } from '../model/Record';
import { CodeView } from '../highlight/CodeView';
import { DiffBadge } from '../components/DiffBadge';
import { Theme } from '../common/Theme';

interface DetailParams {
  problemId: number;
}

@Entry
@Component
struct ProblemDetail {
  @State problem: Problem = new Problem(0, '', '', 1, '', '', '', '', '');
  @State hasProblem: boolean = false;
  @State status: number = 0;
  @State favorite: boolean = false;
  @State note: string = '';
  @State lang: string = 'arkts';
  private problemId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as DetailParams;
    if (params !== undefined && params !== null && params.problemId !== undefined) {
      this.problemId = params.problemId;
    }
    this.load();
  }

  async load(): Promise<void> {
    const db = Database.getInstance();
    await db.init(getContext(this) as common.UIAbilityContext);
    const p = await db.getProblemById(this.problemId);
    if (p !== null) {
      this.problem = p;
      this.hasProblem = true;
    }
    await this.refreshStatus();
    this.favorite = await db.isFavorite(this.problemId);
    this.note = await db.getNote(this.problemId);
  }

  async refreshStatus(): Promise<void> {
    const db = Database.getInstance();
    const record = await db.getRecord(this.problemId);
    this.status = record === null ? 0 : record.status;
  }

  currentCode(): string {
    return this.lang === 'arkts' ? this.problem.codeArkts : this.problem.codePython;
  }

  async markDone(): Promise<void> {
    const db = Database.getInstance();
    const ok = await db.setStatus(this.problemId, STATUS_DONE);
    if (ok) {
      await this.refreshStatus();
      promptAction.showToast({ message: '已标记为「已做」' });
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  async markMastered(): Promise<void> {
    const db = Database.getInstance();
    const ok = await db.setStatus(this.problemId, STATUS_MASTERED);
    if (ok) {
      await this.refreshStatus();
      promptAction.showToast({ message: '已标记为「已掌握」' });
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  async markWrong(): Promise<void> {
    const db = Database.getInstance();
    const ok = await db.addWrong(this.problemId);
    if (ok) {
      await this.refreshStatus();
      promptAction.showToast({ message: '已加入错题本' });
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  async toggleFavorite(): Promise<void> {
    const db = Database.getInstance();
    const ok = await db.toggleFavorite(this.problemId);
    if (ok) {
      this.favorite = await db.isFavorite(this.problemId);
      promptAction.showToast({ message: this.favorite ? '已收藏' : '已取消收藏' });
    } else {
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  async saveNote(): Promise<void> {
    const db = Database.getInstance();
    const ok = await db.saveNote(this.problemId, this.note);
    promptAction.showToast({ message: ok ? '笔记已保存' : '保存失败，请重试' });
  }

  statusColor(): string {
    if (this.status === STATUS_MASTERED) {
      return Theme.success;
    }
    if (this.status === STATUS_DONE) {
      return Theme.warning;
    }
    return Theme.subText;
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor(Theme.text)
      .width('100%')
      .margin({ bottom: 10 })
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(Theme.text)
          .width(36)
          .textAlign(TextAlign.Start)
          .onClick(() => {
            router.back();
          })
        Text('题目详情')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.text)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(this.favorite ? '★' : '☆')
          .fontSize(24)
          .fontColor(this.favorite ? Theme.star : Theme.subText)
          .width(36)
          .textAlign(TextAlign.End)
          .onClick(() => {
            this.toggleFavorite();
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 12, right: 16 })
      .backgroundColor(Theme.card)

      if (this.hasProblem) {
        Scroll() {
          Column() {
            // 标题与元信息
            Text(this.problem.title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.text)
              .width('100%')

            Row() {
              DiffBadge({ difficulty: this.problem.difficulty })
              Text(this.problem.category)
                .fontSize(12)
                .fontColor(Theme.subText)
                .margin({ left: 8 })
              Blank()
              Text(statusLabel(this.status))
                .fontSize(12)
                .fontColor(this.statusColor())
            }
            .width('100%')
            .margin({ top: 10 })

            // 操作按钮
            Row({ space: 10 }) {
              Text('标记已做')
                .fontSize(13)
                .fontColor(Theme.warning)
                .backgroundColor('#FFF3E0')
                .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                .borderRadius(10)
                .onClick(() => {
                  this.markDone();
                })
              Text('标记掌握')
                .fontSize(13)
                .fontColor(Theme.success)
                .backgroundColor('#E7F9EF')
                .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                .borderRadius(10)
                .onClick(() => {
                  this.markMastered();
                })
              Text('记错题')
                .fontSize(13)
                .fontColor(Theme.danger)
                .backgroundColor('#FFEAEA')
                .padding({ left: 14, right: 14, top: 9, bottom: 9 })
                .borderRadius(10)
                .onClick(() => {
                  this.markWrong();
                })
            }
            .width('100%')
            .margin({ top: 16 })

            // 题目描述
            Column() {
              this.SectionTitle('题目描述')
              Text(this.problem.description)
                .fontSize(14)
                .fontColor('#3A3E4D')
                .lineHeight(22)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card)
            .borderRadius(14)
            .margin({ top: 16 })

            // 解题思路
            Column() {
              this.SectionTitle('解题思路')
              Text(this.problem.analysis)
                .fontSize(14)
                .fontColor('#3A3E4D')
                .lineHeight(22)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card)
            .borderRadius(14)
            .margin({ top: 12 })

            // 参考代码
            Column() {
              Row() {
                Text('参考代码')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.text)
                Blank()
                Row({ space: 8 }) {
                  Text('ArkTS')
                    .fontSize(12)
                    .fontColor(this.lang === 'arkts' ? '#FFFFFF' : Theme.subText)
                    .backgroundColor(this.lang === 'arkts' ? Theme.primary : '#F0F2F7')
                    .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                    .borderRadius(8)
                    .onClick(() => {
                      this.lang = 'arkts';
                    })
                  Text('Python')
                    .fontSize(12)
                    .fontColor(this.lang === 'python' ? '#FFFFFF' : Theme.subText)
                    .backgroundColor(this.lang === 'python' ? Theme.primary : '#F0F2F7')
                    .padding({ left: 12, right: 12, top: 5, bottom: 5 })
                    .borderRadius(8)
                    .onClick(() => {
                      this.lang = 'python';
                    })
                }
              }
              .width('100%')

              CodeView({ code: this.currentCode(), language: this.lang })
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card)
            .borderRadius(14)
            .margin({ top: 12 })

            // 我的笔记
            Column() {
              this.SectionTitle('我的笔记')
              TextArea({ text: this.note, placeholder: '记录你的思路、易错点与心得……' })
                .fontSize(13)
                .fontColor(Theme.text)
                .placeholderColor('#B4B9C6')
                .backgroundColor('#F5F6FA')
                .borderRadius(10)
                .width('100%')
                .height(120)
                .onChange((value: string) => {
                  this.note = value;
                })
              Button('保存笔记')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor(Theme.primary)
                .width('100%')
                .height(42)
                .margin({ top: 12 })
                .onClick(() => {
                  this.saveNote();
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.card)
            .borderRadius(14)
            .margin({ top: 12, bottom: 24 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      } else {
        Column() {
          Text('加载中…')
            .fontSize(14)
            .fontColor(Theme.subText)
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.bg)
  }
}
