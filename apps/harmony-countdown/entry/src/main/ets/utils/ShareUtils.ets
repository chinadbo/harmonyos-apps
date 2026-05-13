import image from '@ohos.multimedia.image';
import common from '@ohos.app.ability.common';
import { CountdownEvent } from '../model/CountdownEvent';
import { DateUtils } from './DateUtils';
import { IconConstants } from './IconConstants';

export class ShareUtils {
  static async shareEventCard(context: common.UIAbilityContext, event: CountdownEvent): Promise<void> {
    await this.buildPixelMap(event);
  }

  static async buildPixelMap(event: CountdownEvent): Promise<image.PixelMap> {
    let settings: RenderingContextSettings = new RenderingContextSettings(true);
    let canvas: OffscreenCanvas = new OffscreenCanvas(1080, 1440);
    let context2D: OffscreenCanvasRenderingContext2D = canvas.getContext('2d', settings) as OffscreenCanvasRenderingContext2D;
    let dayInfo = DateUtils.calculateDayInfo(event);
    context2D.fillStyle = '#FFF8F7';
    context2D.fillRect(0, 0, 1080, 1440);
    let gradient = context2D.createLinearGradient(0, 0, 1080, 1440);
    gradient.addColorStop(0, event.color);
    gradient.addColorStop(1, '#FF9E80');
    context2D.fillStyle = gradient;
    context2D.fillRect(60, 60, 960, 1320);
    context2D.fillStyle = '#FFFFFF';
    context2D.font = '72px sans-serif';
    context2D.fillText(IconConstants.getSymbol(event.icon), 100, 180);
    context2D.font = 'bold 64px sans-serif';
    context2D.fillText(event.title, 100, 290);
    context2D.font = '42px sans-serif';
    context2D.fillText(DateUtils.formatDisplayDate(event.targetDate), 100, 380);
    context2D.font = 'bold 180px sans-serif';
    context2D.fillText(`${dayInfo.dayCount}`, 100, 700);
    context2D.font = '56px sans-serif';
    context2D.fillText(dayInfo.displayText, 100, 800);
    context2D.font = '36px sans-serif';
    context2D.fillText(event.note.length > 0 ? event.note : '把重要的日子认真记住。', 100, 930);
    context2D.strokeStyle = 'rgba(255,255,255,0.35)';
    context2D.lineWidth = 4;
    context2D.strokeRect(100, 1020, 880, 240);
    context2D.font = '40px sans-serif';
    context2D.fillText(`重复提醒：${event.isRepeatYearly ? '每年' : '单次'}`, 140, 1110);
    context2D.fillText(`提醒时间：${DateUtils.pad(event.reminderHour)}:${DateUtils.pad(event.reminderMinute)}`, 140, 1190);
    context2D.fillText('HarmonyCountdown', 140, 1270);
    return await image.createPixelMap(new ArrayBuffer(1080 * 1440 * 4), {
      size: { width: 1080, height: 1440 },
      pixelFormat: image.PixelMapFormat.RGBA_8888,
      editable: true,
      alphaType: image.AlphaType.OPAQUE
    });
  }
}
