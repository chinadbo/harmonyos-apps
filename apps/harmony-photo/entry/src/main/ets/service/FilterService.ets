import effectKit from '@ohos.effectKit'
import image from '@ohos.multimedia.image'
import { FilterParams } from '../model/FilterParams'

export class FilterService {
  /**
   * 应用滤镜链
   * effectKit API: createEffect(pixelMap) 返回 Filter
   * Filter 方法：brightness(value: number), contrast(value: number), saturate(value: number), blur(radius: number)
   * 所有方法返回 void，调用后 getEffectPixelMap() 异步获取结果
   */
  static async applyFilters(pixelMap: image.PixelMap, params: FilterParams): Promise<image.PixelMap> {
    try {
      let filter = effectKit.createEffect(pixelMap)

      // brightness: effectKit 范围 0~2（1为原图），将 -1~1 映射到 0~2
      filter.brightness(params.brightness + 1)

      // contrast: effectKit 范围 0~10（1为原图），将 -1~1 映射为 0.2~2.5
      let contrastVal = (params.contrast + 1) * 1.0 + 0.2
      filter.contrast(contrastVal)

      // saturate: effectKit 范围 0~50（1为原图），将 -1~1 映射为 0~3
      let saturateVal = Math.max(0, (params.saturate + 1) * 1.5)
      filter.saturate(saturateVal)

      if (params.blur > 0) {
        filter.blur(params.blur)
      }

      let resultPixelMap = await filter.getEffectPixelMap()
      if (!resultPixelMap) {
        return pixelMap
      }
      return resultPixelMap
    } catch (err) {
      console.error(`FilterService.applyFilters error: ${JSON.stringify(err)}`)
      return pixelMap
    }
  }

  static getPresets(): Array<{ name: string; params: FilterParams }> {
    let raw = new FilterParams()

    let morning = new FilterParams()
    morning.presetName = '清晨'
    morning.brightness = 0.15
    morning.contrast = 0.08
    morning.saturate = 0.12

    let warm = new FilterParams()
    warm.presetName = '暖调'
    warm.brightness = 0.1
    warm.contrast = 0.1
    warm.saturate = 0.2

    let cold = new FilterParams()
    cold.presetName = '冷淡'
    cold.brightness = -0.05
    cold.contrast = 0.12
    cold.saturate = -0.2

    let retro = new FilterParams()
    retro.presetName = '复古'
    retro.brightness = 0.05
    retro.contrast = -0.08
    retro.saturate = -0.15
    retro.blur = 1

    let mono = new FilterParams()
    mono.presetName = '黑白'
    mono.brightness = 0.02
    mono.contrast = 0.18
    mono.saturate = -1.0

    return [
      { name: '原图', params: raw },
      { name: '清晨', params: morning },
      { name: '暖调', params: warm },
      { name: '冷淡', params: cold },
      { name: '复古', params: retro },
      { name: '黑白', params: mono }
    ]
  }
}
