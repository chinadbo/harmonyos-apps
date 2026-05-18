import type resourceManager from '@ohos.resourceManager';
import { CourierDetector } from './CourierDetector';
import { PackageStatus, type TrackingQueryResult, type PackageRecord } from '../model/PackageModel';
import type { TrackingEvent } from '../model/TrackingEventModel';
import { MOCK_DATA_FILE, MOCK_LOCATIONS } from '../utils/Constants';
import { nowString, plusMinutes } from '../utils/TimeUtils';

interface MockDataEntry {
  courierCode?: string;
  courierName?: string;
  status: PackageStatus;
  events: TrackingEvent[];
}

export class TrackingService {
  private static cache: Record<string, MockDataEntry> | null = null;

  static async queryTracking(resourceManagerInstance: resourceManager.ResourceManager, trackingNo: string,
    remark: string = ''): Promise<TrackingQueryResult> {
    const normalizedTrackingNo: string = trackingNo.trim().toUpperCase();
    const detectorResult = CourierDetector.detect(normalizedTrackingNo);
    const mockMap: Record<string, MockDataEntry> = await this.loadMockData(resourceManagerInstance);
    const mockResult: MockDataEntry | undefined = mockMap[normalizedTrackingNo];
    const events: TrackingEvent[] = mockResult ? mockResult.events : this.generateRandomEvents(normalizedTrackingNo);
    const status: PackageStatus = mockResult ? mockResult.status : PackageStatus.IN_TRANSIT;
    const latestEvent: TrackingEvent = events[0];
    const packageRecord: PackageRecord = {
      trackingNo: normalizedTrackingNo,
      courierCode: mockResult?.courierCode ?? detectorResult.courierCode,
      courierName: mockResult?.courierName ?? detectorResult.courierName,
      remark,
      status,
      lastUpdate: latestEvent?.time ?? nowString(),
      latestDesc: latestEvent?.description ?? '暂无物流信息',
      isArchived: status === PackageStatus.DELIVERED,
      createdAt: nowString(),
      events
    };
    return {
      packageRecord,
      events
    };
  }

  private static async loadMockData(resourceManagerInstance: resourceManager.ResourceManager): Promise<Record<string, MockDataEntry>> {
    if (this.cache) {
      return this.cache;
    }
    try {
      const rawBuffer: Uint8Array = await resourceManagerInstance.getRawFileContent(MOCK_DATA_FILE);
      const jsonText: string = String.fromCharCode(...rawBuffer);
      this.cache = JSON.parse(jsonText) as Record<string, MockDataEntry>;
      return this.cache;
    } catch (_error) {
      this.cache = {};
      return this.cache;
    }
  }

  private static generateRandomEvents(trackingNo: string): TrackingEvent[] {
    const now: Date = new Date();
    const seed: number = trackingNo.split('').reduce((sum: number, char: string) => sum + char.charCodeAt(0), 0);
    const startIndex: number = seed % MOCK_LOCATIONS.length;
    return [
      {
        time: nowString(),
        location: MOCK_LOCATIONS[(startIndex + 2) % MOCK_LOCATIONS.length],
        description: '快件运输中，预计 24 小时内到达下一站',
        eventType: 'IN_TRANSIT'
      },
      {
        time: plusMinutes(now, -180),
        location: MOCK_LOCATIONS[(startIndex + 1) % MOCK_LOCATIONS.length],
        description: '快件已离开上一处理中心',
        eventType: 'DEPARTED'
      },
      {
        time: plusMinutes(now, -420),
        location: MOCK_LOCATIONS[startIndex],
        description: '快件已揽收，正在发往转运中心',
        eventType: 'PICKED_UP'
      }
    ];
  }
}
