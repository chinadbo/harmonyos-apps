import geoLocationManager from '@ohos.geoLocationManager'

export interface ResolvedLocation {
  city: string
  address: string
}

export class LocationService {
  private static instance: LocationService = new LocationService()

  static getInstance(): LocationService {
    return LocationService.instance
  }

  async reverseGeocode(latitude: number, longitude: number): Promise<ResolvedLocation> {
    const addresses: Array<geoLocationManager.GeoAddress> = await geoLocationManager.getAddressesFromLocation({
      latitude,
      longitude,
      maxItems: 1,
      locale: 'zh-CN'
    })
    if (!addresses || addresses.length === 0) {
      return {
        city: '',
        address: ''
      }
    }
    const first: geoLocationManager.GeoAddress = addresses[0]
    const city: string = first.locality ?? first.administrativeArea ?? ''
    const addressParts: string[] = [
      first.countryName ?? '',
      first.administrativeArea ?? '',
      first.locality ?? '',
      first.subLocality ?? '',
      first.thoroughfare ?? '',
      first.featureName ?? ''
    ].filter((item: string) => item.length > 0)
    return {
      city,
      address: addressParts.join('')
    }
  }
}
