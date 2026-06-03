export interface HealthEvent {
  id: number
  petId: number
  eventType: string
  title: string
  eventDate: string
  nextDate: string
  hospital: string
  note: string
  reminderId: number
  createdAt: number
}
