import connection from '@ohos.net.connection'
import wifiManager from '@ohos.wifiManager'

export class NetworkService {
  async getNetworkType(): Promise<string> {
    try {
      const netHandle = connection.getDefaultNetSync()
      if (!netHandle || netHandle.netId === 0) {
        return 'Unknown'
      }
      const netCapabilities = await connection.getNetCapabilities(netHandle)
      if (netCapabilities.bearerTypes && netCapabilities.bearerTypes.length > 0) {
        const bearerType = netCapabilities.bearerTypes[0]
        if (bearerType === connection.NetBearType.BEARER_WIFI) {
          return 'WiFi'
        } else if (bearerType === connection.NetBearType.BEARER_CELLULAR) {
          // Try to determine 4G vs 5G
          return '4G/5G'
        }
      }
      return 'Unknown'
    } catch (err) {
      return 'Unknown'
    }
  }

  async getWifiSSID(): Promise<string> {
    try {
      const linkedInfo = wifiManager.getLinkedInfo()
      return linkedInfo.ssid || ''
    } catch (err) {
      return ''
    }
  }

  async getLocalIP(): Promise<string> {
    try {
      const netHandle = connection.getDefaultNetSync()
      if (!netHandle || netHandle.netId === 0) {
        return ''
      }
      const netAddr = await connection.getAddressesByName('localhost')
      if (netAddr && netAddr.length > 0) {
        return netAddr[0].address || ''
      }
      return ''
    } catch (err) {
      return ''
    }
  }
}

export const networkService = new NetworkService()
