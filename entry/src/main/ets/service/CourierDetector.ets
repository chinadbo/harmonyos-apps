import { COURIER_DEFINITIONS, type CourierDefinition } from '../utils/Constants';

export interface CourierMatchResult {
  courierCode: string;
  courierName: string;
}

export class CourierDetector {
  static detect(trackingNo: string): CourierMatchResult {
    const normalized: string = trackingNo.trim().toUpperCase();
    const matched: CourierDefinition | undefined = COURIER_DEFINITIONS.find((item: CourierDefinition) => {
      return item.patterns.some((pattern: RegExp) => pattern.test(normalized));
    });
    if (matched) {
      return {
        courierCode: matched.code,
        courierName: matched.name
      };
    }
    return {
      courierCode: 'UNKNOWN',
      courierName: '未知快递'
    };
  }
}
