import { QRContentType } from '../model/QRRecord'

export interface ParsedResult {
  contentType: QRContentType
  rawText: string
  displayTitle: string
  displaySubtitle: string
  actionLabel: string
  wifiSsid?: string
  wifiPassword?: string
  wifiEncryption?: string
  vcardName?: string
  vcardPhone?: string
  vcardEmail?: string
}

export class ResultParser {
  static parse(rawText: string): ParsedResult {
    const normalized: string = rawText.trim()
    if (this.isUrl(normalized)) {
      return {
        contentType: 'url',
        rawText: normalized,
        displayTitle: '链接二维码',
        displaySubtitle: normalized,
        actionLabel: '打开浏览器'
      }
    }

    if (this.isWifi(normalized)) {
      const wifiInfo = this.parseWifi(normalized)
      return {
        contentType: 'wifi',
        rawText: normalized,
        displayTitle: wifiInfo.ssid || 'WiFi 二维码',
        displaySubtitle: wifiInfo.encryption ? `加密方式：${wifiInfo.encryption}` : 'WiFi 配置',
        actionLabel: '复制 WiFi 信息',
        wifiSsid: wifiInfo.ssid,
        wifiPassword: wifiInfo.password,
        wifiEncryption: wifiInfo.encryption
      }
    }

    if (this.isVCard(normalized)) {
      const vcardInfo = this.parseVCard(normalized)
      return {
        contentType: 'vcard',
        rawText: normalized,
        displayTitle: vcardInfo.name || '联系人二维码',
        displaySubtitle: vcardInfo.phone || vcardInfo.email || '联系人信息',
        actionLabel: '复制联系人信息',
        vcardName: vcardInfo.name,
        vcardPhone: vcardInfo.phone,
        vcardEmail: vcardInfo.email
      }
    }

    return {
      contentType: 'text',
      rawText: normalized,
      displayTitle: '文本二维码',
      displaySubtitle: normalized,
      actionLabel: '复制文本'
    }
  }

  private static isUrl(content: string): boolean {
    return /^https?:\/\//i.test(content)
  }

  private static isWifi(content: string): boolean {
    return /^WIFI:T:/i.test(content)
  }

  private static isVCard(content: string): boolean {
    return /^BEGIN:VCARD/i.test(content)
  }

  private static parseWifi(content: string): { ssid: string; password: string; encryption: string } {
    const body = content.replace(/^WIFI:/i, '')
    const sections = body.split(';')
    const result = {
      ssid: '',
      password: '',
      encryption: ''
    }
    sections.forEach((section) => {
      if (section.startsWith('T:')) {
        result.encryption = section.substring(2)
      }
      if (section.startsWith('S:')) {
        result.ssid = section.substring(2)
      }
      if (section.startsWith('P:')) {
        result.password = section.substring(2)
      }
    })
    return result
  }

  private static parseVCard(content: string): { name: string; phone: string; email: string } {
    const lines = content.split(/\r?\n/)
    const result = {
      name: '',
      phone: '',
      email: ''
    }
    lines.forEach((line) => {
      if (line.startsWith('FN:')) {
        result.name = line.substring(3)
      }
      if (line.startsWith('TEL')) {
        const telParts = line.split(':')
        result.phone = telParts.length > 1 ? telParts[telParts.length - 1] : result.phone
      }
      if (line.startsWith('EMAIL')) {
        const emailParts = line.split(':')
        result.email = emailParts.length > 1 ? emailParts[emailParts.length - 1] : result.email
      }
    })
    return result
  }
}
