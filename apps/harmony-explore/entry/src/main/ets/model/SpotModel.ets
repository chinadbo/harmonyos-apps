export interface SpotModel {
  id: number
  name: string
  address: string
  latitude: number
  longitude: number
  city: string
  category: string
  coverUri: string
  createdAt: number
  checkInCount: number
}

export function createEmptySpot(): SpotModel {
  return {
    id: 0,
    name: '',
    address: '',
    latitude: 0,
    longitude: 0,
    city: '',
    category: '',
    coverUri: '',
    createdAt: Date.now(),
    checkInCount: 0
  }
}
