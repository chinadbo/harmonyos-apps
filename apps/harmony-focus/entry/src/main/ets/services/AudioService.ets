import media from '@ohos.multimedia.media'
import common from '@ohos.app.ability.common'
import { WhiteNoiseType } from '../common/Constants'

export class AudioService {
  private static instance: AudioService = new AudioService()
  private player?: media.AVPlayer
  private context?: common.UIAbilityContext
  private currentNoise: WhiteNoiseType = WhiteNoiseType.NONE
  private rawFd?: media.AVFileDescriptor

  static getInstance(): AudioService {
    return AudioService.instance
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  async play(type: WhiteNoiseType): Promise<void> {
    this.currentNoise = type
    if (type === WhiteNoiseType.NONE) {
      await this.stop()
      return
    }
    try {
      await this.release()
      if (!this.context) {
        return
      }
      // 使用 getRawFd 获取 rawfile 资源的文件描述符
      const resourceMgr = this.context.resourceManager
      const rawFd = await resourceMgr.getRawFd(`sounds/${type}.mp3`)
      this.rawFd = rawFd

      this.player = await media.createAVPlayer()
      this.player.on('stateChange', async (state: string) => {
        if (state === 'initialized' && this.player) {
          await this.player.prepare()
        } else if (state === 'prepared' && this.player) {
          await this.player.play()
        } else if (state === 'completed' && this.player) {
          // 循环播放：跳回开头
          await this.player.seek(0)
          await this.player.play()
        }
      })
      // 设置 fdSrc（AVPlayer 支持的标准方式）
      this.player.fdSrc = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      }
    } catch (err) {
      console.error(`AudioService.play error: ${JSON.stringify(err)}`)
    }
  }

  async stop(): Promise<void> {
    if (!this.player) {
      return
    }
    try {
      await this.player.stop()
    } catch (err) {
      console.warn(`AudioService.stop error: ${JSON.stringify(err)}`)
    }
  }

  async release(): Promise<void> {
    if (!this.player) {
      return
    }
    try {
      await this.player.release()
    } catch (err) {
      console.warn(`AudioService.release error: ${JSON.stringify(err)}`)
    }
    this.player = undefined
    // 关闭 rawFd
    if (this.rawFd && this.context) {
      try {
        await this.context.resourceManager.closeRawFd(`sounds/${this.currentNoise}.mp3`)
      } catch (_) {
        // ignore
      }
      this.rawFd = undefined
    }
  }
}

export const audioService: AudioService = AudioService.getInstance()
