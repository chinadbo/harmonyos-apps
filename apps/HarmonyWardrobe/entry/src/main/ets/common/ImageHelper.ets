import photoAccessHelper from '@ohos.file.photoAccessHelper'
import fs from '@ohos.file.fs'
import common from '@ohos.app.ability.common'

export class ImageHelper {
  static async pickAndCopyToSandbox(context: common.UIAbilityContext): Promise<string> {
    const picker = new photoAccessHelper.PhotoViewPicker()
    const options = new photoAccessHelper.PhotoSelectOptions()
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    options.maxSelectNumber = 1
    const result: photoAccessHelper.PhotoSelectResult = await picker.select(options)
    if (result.photoUris.length === 0) {
      return ''
    }
    const srcUri = result.photoUris[0]
    const wardrobeDir = `${context.filesDir}/wardrobe`
    if (!fs.accessSync(wardrobeDir)) {
      fs.mkdirSync(wardrobeDir, true)
    }
    const fileName = `wardrobe_${Date.now()}.jpg`
    const destPath = `${wardrobeDir}/${fileName}`
    const srcFile = fs.openSync(srcUri, fs.OpenMode.READ_ONLY)
    try {
      fs.copyFileSync(srcFile.fd, destPath)
    } finally {
      fs.closeSync(srcFile)
    }
    return destPath
  }
}
