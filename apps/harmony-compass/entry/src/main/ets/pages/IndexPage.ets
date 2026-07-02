import { CompassFace } from '../components/CompassFace';
import { DegreeDisplay } from '../components/DegreeDisplay';
import { DirectionText } from '../components/DirectionText';
import { SensorService } from '../services/SensorService';
import { LocationService, LocationInfo } from '../services/LocationService';

@Entry
@Component
struct IndexPage {
  @State heading: number = 0;
  @State direction: string = 'N';
  @State location: LocationInfo | null = null;
  @State sensorAvailable: boolean = true;
  @State locationError: string = '';

  private sensorService: SensorService = SensorService.getInstance();
  private locationService: LocationService = LocationService.getInstance();

  aboutToAppear() {
    this.startCompass();
    this.loadLocation();
  }

  aboutToDisappear() {
    this.sensorService.stopListening();
  }

  private startCompass(): void {
    let success = this.sensorService.startListening((newHeading: number) => {
      this.heading = newHeading;
    });
    this.sensorAvailable = success;
  }

  private async loadLocation(): Promise<void> {
    let loc = await this.locationService.getCurrentLocation();
    if (loc) {
      this.location = loc;
      this.locationError = '';
    } else {
      this.locationError = 'Location unavailable - check permissions';
    }
  }

  private refreshLocation(): void {
    this.locationError = 'Refreshing...';
    this.loadLocation();
  }

  build() {
    Column() {
      // Title
      Text($r('app.string.page_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 16, bottom: 8 })

      // Sensor unavailable warning
      if (!this.sensorAvailable) {
        Text($r('app.string.sensor_unavailable'))
          .fontSize(14)
          .fontColor($r('app.color.accent_red'))
          .margin({ bottom: 8 })
      }

      // Compass Face
      CompassFace({ heading: this.heading })
        .margin({ top: 16, bottom: 16 })

      // Degree Display
      DegreeDisplay({ heading: this.heading })
        .margin({ bottom: 4 })

      // Direction Text
      DirectionText({ heading: this.heading })
        .margin({ bottom: 24 })

      // Location Info Card
      Column() {
        if (this.location) {
          Row() {
            Column() {
              Text($r('app.string.latitude'))
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
              Text(this.location.latitude.toFixed(6))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text($r('app.string.longitude'))
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
              Text(this.location.longitude.toFixed(6))
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text($r('app.string.altitude'))
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
              Text(`${this.location.altitude.toFixed(1)}m`)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        } else {
          Text(this.locationError || $r('app.string.location_unavailable'))
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }

        // Refresh button
        Button($r('app.string.refresh_location'))
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor($r('app.color.accent_blue'))
          .margin({ top: 12 })
          .onClick(() => {
            this.refreshLocation();
          })
      }
      .width('90%')
      .padding(16)
      .backgroundColor($r('app.color.compass_background'))
      .borderRadius(12)
      .margin({ bottom: 24 })

      // Footer
      Text('HarmonyCompass v1.0')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .alignItems(HorizontalAlign.Center)
  }
}
