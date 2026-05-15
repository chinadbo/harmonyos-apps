import common from '@ohos.app.ability.common'
import pasteboard from '@ohos.pasteboard'
import promptAction from '@ohos.promptAction'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import image from '@ohos.multimedia.image'
import fs from '@ohos.file.fs'
import fileUri from '@ohos.file.fileuri'
import { QRRecord } from '../model/QRRecord'
import { ParsedResult, ResultParser } from '../utils/ResultParser'

export class QRService {
  parseScanResult(rawText: string): ParsedResult {
    return ResultParser.parse(rawText)
  }

  createRecord(type: 'scan' | 'generate', content: string, color: string = '#000000', bgColor: string = '#FFFFFF'): QRRecord {
    const parsed = this.parseScanResult(content)
    return new QRRecord({
      type,
      content,
      contentType: parsed.contentType,
      color,
      bgColor,
      isFavorite: 0,
      createdAt: Date.now()
    })
  }

  async copyToClipboard(text: string): Promise<void> {
    const systemPasteboard = pasteboard.getSystemPasteboard()
    const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    await systemPasteboard.setData(pasteData)
  }

  async saveToAlbum(context: common.UIAbilityContext, pixelMap: image.PixelMap): Promise<string> {
    try {
      const packer = image.createImagePacker()
      const packed: ArrayBuffer = await packer.packing(pixelMap, { format: 'image/png', quality: 100 })
      await packer.release()

      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png')
      const asset = await helper.getAssets({
        fetchColumns: ['uri'],
        predicates: new (await import('@ohos.data.dataSharePredicates')).default().equalTo('uri', uri)
      })
      const photoAsset = asset.getFirstObject()
      const fd = await photoAsset.open('rw')
      await fs.write(fd, packed)
      await photoAsset.close(fd)
      return uri
    } catch (err) {
      promptAction.showToast({ message: '保存失败，请检查权限' })
      throw err
    }
  }

  async savePixelMapToAlbum(context: common.UIAbilityContext, pixelMap: image.PixelMap): Promise<string> {
    try {
      const packer = image.createImagePacker()
      const packed: ArrayBuffer = await packer.packing(pixelMap, { format: 'image/png', quality: 100 })
      await packer.release()

      // 写入沙箱临时文件，再通过 MediaLibrary 保存
      const tempPath = context.cacheDir + '/qr_temp_' + Date.now() + '.png'
      const file = fs.openSync(tempPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.writeSync(file.fd, packed)
      fs.closeSync(file.fd)

      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png')

      // 读取临时文件写入 PhotoAsset
      const srcFile = fs.openSync(tempPath, fs.OpenMode.READ_ONLY)
      const destUri = fileUri.getUriFromPath(tempPath)
      await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png', {
        title: 'HarmonyQR_' + Date.now()
      })
      fs.closeSync(srcFile.fd)
      try { fs.unlinkSync(tempPath) } catch (_e) { /* ignore */ }
      return uri
    } catch (err) {
      promptAction.showToast({ message: '保存失败，请检查存储权限' })
      throw err
    }
  }

  getFileUri(path: string): string {
    return fileUri.getUriFromPath(path)
  }

  showToast(message: string): void {
    promptAction.showToast({ message })
  }
}

const qrService = new QRService()
export default qrService
