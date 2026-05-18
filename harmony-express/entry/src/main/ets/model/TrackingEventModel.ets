export interface TrackingEvent {
  id?: number;
  packageId?: number;
  time: string;
  location: string;
  description: string;
  eventType: string;
}
