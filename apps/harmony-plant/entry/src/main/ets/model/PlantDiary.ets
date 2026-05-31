export class PlantDiary {
  id: number = 0
  plantId: number = 0
  title: string = ''
  content: string = ''
  photoUri: string = ''
  createdAt: string = new Date().toISOString()

  constructor(source?: Partial<PlantDiary>) {
    if (!source) {
      return
    }
    this.id = Number(source.id ?? this.id)
    this.plantId = Number(source.plantId ?? this.plantId)
    this.title = source.title ?? this.title
    this.content = source.content ?? this.content
    this.photoUri = source.photoUri ?? this.photoUri
    this.createdAt = source.createdAt ?? this.createdAt
  }

  static fromRow(row: Record<string, Object | number | string | null>): PlantDiary {
    return new PlantDiary({
      id: Number(row.id ?? 0),
      plantId: Number(row.plantId ?? 0),
      title: String(row.title ?? ''),
      content: String(row.content ?? ''),
      photoUri: String(row.photoUri ?? ''),
      createdAt: String(row.createdAt ?? new Date().toISOString())
    })
  }
}
