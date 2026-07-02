import sensor from '@ohos.sensor';
import { LowPassFilter } from '../utils/LowPassFilter';

export class SensorService {
  private static instance: SensorService;
  private headingCallback: ((heading: number) => void) | null = null;
  private lowPassFilter: LowPassFilter = new LowPassFilter(0.15);
  private isListening: boolean = false;
  private currentHeading: number = 0;

  private constructor() {}

  public static getInstance(): SensorService {
    if (!SensorService.instance) {
      SensorService.instance = new SensorService();
    }
    return SensorService.instance;
  }

  public startListening(callback: (heading: number) => void): boolean {
    if (this.isListening) {
      this.headingCallback = callback;
      callback(this.currentHeading);
      return true;
    }

    try {
      let sensorAvailable = sensor.getSensorListSync();
      let hasOrientation = false;
      for (let i = 0; i < sensorAvailable.length; i++) {
        if (sensorAvailable[i].sensorId === sensor.SensorId.ORIENTATION) {
          hasOrientation = true;
          break;
        }
      }

      if (!hasOrientation) {
        console.error('Orientation sensor not available');
        return false;
      }

      this.headingCallback = callback;
      this.lowPassFilter.reset();

      sensor.on(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) => {
        let rawHeading = data.alpha;
        if (rawHeading < 0) {
          rawHeading += 360;
        }
        this.currentHeading = this.lowPassFilter.filter(rawHeading);
        if (this.headingCallback) {
          this.headingCallback(this.currentHeading);
        }
      });

      this.isListening = true;
      return true;
    } catch (err) {
      console.error('Failed to start sensor:', JSON.stringify(err));
      return false;
    }
  }

  public stopListening(): void {
    if (this.isListening) {
      try {
        sensor.off(sensor.SensorId.ORIENTATION);
      } catch (err) {
        console.error('Failed to stop sensor:', JSON.stringify(err));
      }
      this.isListening = false;
      this.headingCallback = null;
    }
  }

  public getCurrentHeading(): number {
    return this.currentHeading;
  }

  public isActive(): boolean {
    return this.isListening;
  }
}