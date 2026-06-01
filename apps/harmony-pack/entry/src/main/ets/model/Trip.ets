import { TripStatus, TripType } from './Constants'

export class Trip {
  id: number = 0
  title: string = ''
  destination: string = ''
  startDate: number = Date.now()
  endDate: number = Date.now()
  tripType: string = TripType.LEISURE
  status: string = TripStatus.UPCOMING
  note: string = ''
  reminder24Id: number = 0
  reminder2Id: number = 0
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  constructor(source?: Partial<Trip>) {
    if (source) {
      Object.assign(this, source)
    }
  }

  getDurationDays(): number {
    const duration = this.endDate - this.startDate
    return Math.max(1, Math.floor(duration / (24 * 60 * 60 * 1000)) + 1)
  }
}

export interface TripSummary {
  trip: Trip
  totalItems: number
  packedItems: number
  progress: number
}

export function createTripRow(trip: Trip): Record<string, number | string> {
  return {
    id: trip.id,
    title: trip.title,
    destination: trip.destination,
    start_date: trip.startDate,
    end_date: trip.endDate,
    trip_type: trip.tripType,
    status: trip.status,
    note: trip.note,
    reminder_24_id: trip.reminder24Id,
    reminder_2_id: trip.reminder2Id,
    created_at: trip.createdAt,
    updated_at: trip.updatedAt
  }
}
