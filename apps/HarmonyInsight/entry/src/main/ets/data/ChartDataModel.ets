import { CSVParser } from './CSVParser';

// 图表类型枚举
export enum ChartType {
  BAR = 'bar',
  LINE = 'line',
  PIE = 'pie',
  SCATTER = 'scatter',
  RADAR = 'radar',
  AREA = 'area'
}

// 数据类型枚举
export enum DataType {
  NUMBER = 'number',
  CATEGORY = 'category',
  DATE = 'date'
}

/**
 * 图表数据模型
 */
export class ChartDataModel {
  title: string = '';
  xAxisLabels: string[] = [];
  series: SeriesData[] = [];
  chartType: ChartType = ChartType.BAR;

  constructor(title: string = '') {
    this.title = title;
  }

  /**
   * 从二维数组创建图表数据
   * @param headers 表头
   * @param rows 数据行
   * @param xAxisIndex X轴列索引
   * @param seriesColumns 系列列索引列表
   */
  static fromTableData(headers: string[], rows: string[][],
    xAxisIndex: number = 0,
    seriesColumns: number[] = [1]): ChartDataModel {
    const model = new ChartDataModel('图表');

    model.xAxisLabels = rows.map(row => row[xAxisIndex] || '');

    for (const colIndex of seriesColumns) {
      const data: number[] = [];
      for (const row of rows) {
        const val = parseFloat(row[colIndex]);
        data.push(isNaN(val) ? 0 : val);
      }
      model.series.push({
        name: headers[colIndex] || `Series ${colIndex}`,
        data: data,
        color: ''
      });
    }

    return model;
  }

  /**
   * 从 CSV 文件创建图表数据
   */
  static async fromCSV(path: string, xAxisIndex: number = 0, seriesColumns: number[] = [1]): Promise<ChartDataModel> {
    const [headers, rows] = await CSVParser.parseFromFile(path);
    return this.fromTableData(headers, rows, xAxisIndex, seriesColumns);
  }

  /**
   * 从 JSON 字符串反序列化
   */
  static fromJSON(json: string): ChartDataModel | null {
    try {
      const obj = JSON.parse(json);
      const model = new ChartDataModel(obj.title || '');
      model.xAxisLabels = obj.xAxisLabels || [];
      model.series = (obj.series || []).map((s: any) => ({
        name: s.name || '',
        data: s.data || [],
        color: s.color || ''
      }));
      model.chartType = obj.chartType || ChartType.BAR;
      return model;
    } catch {
      return null;
    }
  }

  /**
   * 序列化为 JSON 字符串
   */
  toJSON(): string {
    return JSON.stringify({
      title: this.title,
      xAxisLabels: this.xAxisLabels,
      series: this.series,
      chartType: this.chartType
    });
  }

  /**
   * 获取数据范围
   */
  getRange(): { min: number, max: number } {
    let min = Infinity;
    let max = -Infinity;

    for (const series of this.series) {
      for (const val of series.data) {
        if (val < min) min = val;
        if (val > max) max = val;
      }
    }

    if (min === Infinity) return { min: 0, max: 100 };
    return { min, max };
  }

  /**
   * 获取所有数据点总数
   */
  getTotalDataPoints(): number {
    return this.series.reduce((sum, s) => sum + s.data.length, 0);
  }

  /**
   * 获取最大系列长度
   */
  getMaxSeriesLength(): number {
    return Math.max(...this.series.map(s => s.data.length), 0);
  }
}

export interface SeriesData {
  name: string;
  data: number[];
  color: string;
}

/**
 * 图表配置模型
 */
export class ChartConfig {
  showLegend: boolean = true;
  showLabels: boolean = true;
  showGrid: boolean = true;
  showDataPoints: boolean = false;
  isDonut: boolean = false;
  colorScheme: string[] = ['#5B8FF9', '#5AD8A6', '#FF6B6B', '#FFD93D', '#6BCB77', '#4ECDC4'];
  theme: 'light' | 'dark' = 'light';
  animation: boolean = true;

  toJSON(): string {
    return JSON.stringify(this);
  }

  static fromJSON(json: string): ChartConfig {
    try {
      const obj = JSON.parse(json);
      const config = new ChartConfig();
      Object.assign(config, obj);
      return config;
    } catch {
      return new ChartConfig();
    }
  }
}

/**
 * 图表记录（用于历史存储）
 */
export interface ChartRecord {
  id: string;
  name: string;
  type: ChartType;
  data: string;
  config: string;
  createdAt: number;
  updatedAt: number;
}
