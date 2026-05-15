export type QRRecordType = 'scan' | 'generate'
export type QRContentType = 'url' | 'wifi' | 'vcard' | 'text'

export class QRRecord {
  id: number = 0
  type: QRRecordType = 'scan'
  content: string = ''
  contentType: QRContentType = 'text'
  color: string = '#000000'
  bgColor: string = '#FFFFFF'
  isFavorite: number = 0
  createdAt: number = 0

  constructor(init?: Partial<QRRecord>) {
    if (!init) {
      return
    }
    this.id = init.id ?? this.id
    this.type = init.type ?? this.type
    this.content = init.content ?? this.content
    this.contentType = init.contentType ?? this.contentType
    this.color = init.color ?? this.color
    this.bgColor = init.bgColor ?? this.bgColor
    this.isFavorite = init.isFavorite ?? this.isFavorite
    this.createdAt = init.createdAt ?? this.createdAt
  }

  static fromRow(row: Record<string, Object>): QRRecord {
    return new QRRecord({
      id: Number(row.id ?? 0),
      type: String(row.type ?? 'scan') as QRRecordType,
      content: String(row.content ?? ''),
      contentType: String(row.contentType ?? 'text') as QRContentType,
      color: String(row.color ?? '#000000'),
      bgColor: String(row.bgColor ?? '#FFFFFF'),
      isFavorite: Number(row.isFavorite ?? 0),
      createdAt: Number(row.createdAt ?? 0)
    })
  }
}
