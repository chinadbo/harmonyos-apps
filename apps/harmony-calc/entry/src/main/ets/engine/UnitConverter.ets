export type UnitCategory = 'length' | 'weight' | 'temperature' | 'area' | 'speed';

export interface UnitDefinition {
  key: string;
  label: string;
  factor: number;
}

export interface CategoryDefinition {
  key: UnitCategory;
  label: string;
}

export class UnitConverter {
  private static readonly CATEGORIES: Array<CategoryDefinition> = [
    { key: 'length', label: '长度' },
    { key: 'weight', label: '重量' },
    { key: 'temperature', label: '温度' },
    { key: 'area', label: '面积' },
    { key: 'speed', label: '速度' }
  ];

  private static readonly UNITS: Record<string, Array<UnitDefinition>> = {
    'length': [
      { key: 'm', label: '米 (m)', factor: 1 },
      { key: 'km', label: '千米 (km)', factor: 1000 },
      { key: 'cm', label: '厘米 (cm)', factor: 0.01 },
      { key: 'mm', label: '毫米 (mm)', factor: 0.001 },
      { key: 'in', label: '英寸 (in)', factor: 0.0254 },
      { key: 'ft', label: '英尺 (ft)', factor: 0.3048 }
    ],
    'weight': [
      { key: 'kg', label: '千克 (kg)', factor: 1 },
      { key: 'g', label: '克 (g)', factor: 0.001 },
      { key: 'lb', label: '磅 (lb)', factor: 0.45359237 },
      { key: 'oz', label: '盎司 (oz)', factor: 0.028349523125 },
      { key: 't', label: '吨 (t)', factor: 1000 }
    ],
    'temperature': [
      { key: 'c', label: '摄氏度 (°C)', factor: 1 },
      { key: 'f', label: '华氏度 (°F)', factor: 1 },
      { key: 'k', label: '开尔文 (K)', factor: 1 }
    ],
    'area': [
      { key: 'sqm', label: '平方米 (m²)', factor: 1 },
      { key: 'sqkm', label: '平方千米 (km²)', factor: 1000000 },
      { key: 'ha', label: '公顷 (ha)', factor: 10000 },
      { key: 'sqft', label: '平方英尺 (ft²)', factor: 0.09290304 },
      { key: 'acre', label: '英亩 (acre)', factor: 4046.8564224 }
    ],
    'speed': [
      { key: 'mps', label: '米/秒 (m/s)', factor: 1 },
      { key: 'kmh', label: '千米/时 (km/h)', factor: 0.2777777778 },
      { key: 'mph', label: '英里/时 (mph)', factor: 0.44704 },
      { key: 'knot', label: '节 (knot)', factor: 0.5144444444 }
    ]
  };

  static getCategories(): Array<CategoryDefinition> {
    return this.CATEGORIES.slice();
  }

  static getUnits(category: UnitCategory): Array<UnitDefinition> {
    return (this.UNITS[category] || []).slice();
  }

  static convert(category: UnitCategory, fromUnit: string, toUnit: string, value: number): number {
    if (category === 'temperature') {
      const kelvin: number = this.toKelvin(fromUnit, value);
      return this.fromKelvin(toUnit, kelvin);
    }
    const baseValue: number = value * this.getFactor(category, fromUnit);
    return baseValue / this.getFactor(category, toUnit);
  }

  private static getFactor(category: UnitCategory, unitKey: string): number {
    const units: Array<UnitDefinition> = this.UNITS[category] || [];
    for (let i: number = 0; i < units.length; i += 1) {
      if (units[i].key === unitKey) {
        return units[i].factor;
      }
    }
    throw new Error('不支持的单位');
  }

  private static toKelvin(unitKey: string, value: number): number {
    switch (unitKey) {
      case 'c':
        return value + 273.15;
      case 'f':
        return (value - 32) * 5 / 9 + 273.15;
      case 'k':
        return value;
      default:
        throw new Error('不支持的温度单位');
    }
  }

  private static fromKelvin(unitKey: string, value: number): number {
    switch (unitKey) {
      case 'c':
        return value - 273.15;
      case 'f':
        return (value - 273.15) * 9 / 5 + 32;
      case 'k':
        return value;
      default:
        throw new Error('不支持的温度单位');
    }
  }
}
