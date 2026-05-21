import photoAccessHelper from '@ohos.file.photoAccessHelper'
import image from '@ohos.multimedia.image'
import fileIo from '@ohos.file.fs'
import dataSharePredicates from '@ohos.data.dataSharePredicates'
import { PhotoItem } from '../model/PhotoItem'

export class PhotoService {
  /**
   * 使用 PhotoViewPicker 无权限选择照片
   * 注意：PhotoViewPicker 无参构造，不传 context
   */
  static async selectPhotos(): Promise<PhotoItem[]> {
    try {
      let picker = new photoAccessHelper.PhotoViewPicker()
      let options = new photoAccessHelper.PhotoSelectOptions()
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      options.maxSelectNumber = 50

      let result = await picker.select(options)
      let photos: PhotoItem[] = []
      if (!result || !result.photoUris || result.photoUris.length === 0) {
        return photos
      }

      result.photoUris.forEach((uri: string, index: number) => {
        let item = new PhotoItem()
        item.uri = uri
        item.displayName = `图片${index + 1}`
        item.dateAdded = Date.now() - index * 3600 * 1000 * 24
        item.width = 0
        item.height = 0
        item.size = 0
        photos.push(item)
      })
      return photos
    } catch (err) {
      console.error(`selectPhotos error: ${JSON.stringify(err)}`)
      return []
    }
  }

  /**
   * 批量读取相册（需要 ohos.permission.READ_IMAGEVIDEO 权限）
   * 使用 FetchResult<PhotoAsset> 的标准遍历：getFirstObject / getNextObject
   */
  static async fetchAllPhotos(context: Context): Promise<PhotoItem[]> {
    try {
      let helper = photoAccessHelper.getPhotoAccessHelper(context)
      let predicates = new dataSharePredicates.DataSharePredicates()
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [
          photoAccessHelper.PhotoKeys.URI,
          photoAccessHelper.PhotoKeys.DISPLAY_NAME,
          photoAccessHelper.PhotoKeys.DATE_ADDED,
          photoAccessHelper.PhotoKeys.WIDTH,
          photoAccessHelper.PhotoKeys.HEIGHT,
          photoAccessHelper.PhotoKeys.SIZE
        ],
        predicates: predicates
      }

      let fetchResult = await helper.getAssets(fetchOptions)
      let photos: PhotoItem[] = []
      if (!fetchResult || fetchResult.getCount() === 0) {
        fetchResult?.close()
        return photos
      }

      // 正确遍历 FetchResult<PhotoAsset>：getFirstObject / getNextObject
      let asset = await fetchResult.getFirstObject()
      while (asset) {
        let item = new PhotoItem()
        item.uri = asset.uri
        item.displayName = asset.displayName
        item.dateAdded = asset.dateAdded * 1000
        item.width = asset.width
        item.height = asset.height
        item.size = asset.size
        photos.push(item)

        if (fetchResult.isAfterLast()) {
          break
        }
        asset = await fetchResult.getNextObject()
      }
      fetchResult.close()
      return photos
    } catch (err) {
      console.error(`fetchAllPhotos error: ${JSON.stringify(err)}`)
      return []
    }
  }

  /**
   * 通过 uri 获取 PixelMap（用于编辑）
   * 直接用 fileIo.open(uri) 获取 fd，再创建 ImageSource
   */
  static async getPixelMap(uri: string): Promise<image.PixelMap | null> {
    try {
      let file = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY)
      let source = image.createImageSource(file.fd)
      let pixelMap = await source.createPixelMap({
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      })
      await fileIo.close(file)
      return pixelMap
    } catch (err) {
      console.error(`getPixelMap error: ${JSON.stringify(err)}`)
      return null
    }
  }
}
