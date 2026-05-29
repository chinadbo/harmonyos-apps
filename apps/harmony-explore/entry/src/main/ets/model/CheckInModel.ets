export interface CheckInModel {
  id: number
  spotId: number
  checkInAt: number
  mood: string
  weather: string
  note: string
}

export interface CheckInPhotoModel {
  id: number
  checkInId: number
  uri: string
  createdAt: number
}

export interface CheckInDetailModel extends CheckInModel {
  spotName: string
  city: string
  address: string
  category: string
  coverUri: string
  photoUris: string[]
}
