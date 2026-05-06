import { HourlyWeather } from '../model/WeatherModel';

@Component
export struct HourlyItem {
  @Prop item: HourlyWeather;

  private formatHour(): string {
    const raw = Number(this.item.time);
    const hour = Math.floor(raw / 100);
    return `${hour.toString().padStart(2, '0')}:00`;
  }

  build() {
    Column({ space: 10 }) {
      Text(this.formatHour())
        .fontSize(14)
        .fontColor('#D9E8F2')
      Text(`${this.item.tempC}°`)
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
      Text(`${this.item.chanceofrain}% rain`)
        .fontSize(12)
        .fontColor('#AED8F1')
    }
    .width(88)
    .padding({ left: 12, right: 12, top: 14, bottom: 14 })
    .backgroundColor('#14FFFFFF')
    .borderRadius(20)
  }
}
