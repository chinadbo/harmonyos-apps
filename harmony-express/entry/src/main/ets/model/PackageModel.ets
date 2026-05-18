import type { TrackingEvent } from './TrackingEventModel';

export enum PackageStatus {
  PENDING = 0,
  IN_TRANSIT = 1,
  DELIVERING = 2,
  DELIVERED = 3,
  EXCEPTION = 4,
  RETURNED = 5
}

export interface PackageRecord {
  id?: number;
  trackingNo: string;
  courierCode: string;
  courierName: string;
  remark: string;
  status: PackageStatus;
  lastUpdate: string;
  latestDesc: string;
  isArchived: boolean;
  createdAt: string;
  events?: TrackingEvent[];
}

export interface TrackingQueryResult {
  packageRecord: PackageRecord;
  events: TrackingEvent[];
}
