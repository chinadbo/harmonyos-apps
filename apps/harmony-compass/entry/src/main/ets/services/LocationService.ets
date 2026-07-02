import geoLocationManager from '@ohos.geoLocationManager';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';

export interface LocationInfo {
  latitude: number;
  longitude: number;
  altitude: number;
  accuracy: number;
}

export class LocationService {
  private static instance: LocationService;
  private currentLocation: LocationInfo | null = null;
  private hasPermission: boolean = false;

  private constructor() {}

  public static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  public async checkPermission(): Promise<boolean> {
    try {
      let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let tokenId = bundleInfo.appInfo.accessTokenId;
      let atManager = abilityAccessCtrl.createAtManager();
      let grantStatus = await atManager.checkAccessToken(tokenId, 'ohos.permission.LOCATION');
      this.hasPermission = grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      return this.hasPermission;
    } catch (err) {
      console.error('Failed to check location permission:', JSON.stringify(err));
      this.hasPermission = false;
      return false;
    }
  }

  public async getCurrentLocation(): Promise<LocationInfo | null> {
    let permitted = await this.checkPermission();
    if (!permitted) {
      console.warn('Location permission not granted');
      return null;
    }

    try {
      let location = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET
      });

      this.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude ?? 0,
        accuracy: location.accuracy ?? 0
      };

      return this.currentLocation;
    } catch (err) {
      console.error('Failed to get location:', JSON.stringify(err));
      return null;
    }
  }

  public getLastKnownLocation(): LocationInfo | null {
    return this.currentLocation;
  }

  public hasLocationPermission(): boolean {
    return this.hasPermission;
  }
}