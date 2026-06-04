import { MaintenanceRecord } from '../models/MaintenanceRecord';
import { maintenanceService } from '../services/MaintenanceService';
import { BarChart } from '../components/charts/BarChart';
import { PieChart } from '../components/charts/PieChart';
import { LineChart } from '../components/charts/LineChart';
import { formatCurrencyFromCent } from '../utils/Formatters';
import { SummaryCard } from '../views/SummaryCard';
import { SectionHeader } from '../views/SectionHeader';

@Component
export struct StatsPage {
  @Prop stack: NavPathStack = new NavPathStack();
  @State totalCost: number = 0;
  @State recordCount: number = 0;
  @State barLabels: string[] = [];
  @State barValues: number[] = [];
  @State pieLabels: string[] = [];
  @State pieValues: number[] = [];
  @State lineLabels: string[] = [];
  @State lineValues: number[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    const records: MaintenanceRecord[] = await maintenanceService.list();
    const costByType: Map<string, number> = await maintenanceService.totalCostByType();
    const trend: Map<string, number> = await maintenanceService.monthlyCostTrend();
    this.totalCost = records.reduce((sum: number, item: MaintenanceRecord) => sum + item.cost, 0);
    this.recordCount = records.length;
    this.barLabels = Array.from(costByType.keys());
    this.barValues = Array.from(costByType.values()).map((item: number) => Math.round(item / 100));
    this.pieLabels = Array.from(costByType.keys());
    this.pieValues = Array.from(costByType.values()).map((item: number) => Math.round(item / 100));
    this.lineLabels = Array.from(trend.keys());
    this.lineValues = Array.from(trend.values()).map((item: number) => Math.round(item / 100));
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        SectionHeader({ title: '费用统计' })
        Row({ space: 12 }) {
          SummaryCard({ title: '累计费用', value: formatCurrencyFromCent(this.totalCost), subValue: '保养成本总览', accentColor: '#4E7BF2' })
          SummaryCard({ title: '记录数量', value: `${this.recordCount}`, subValue: '全部保养记录', accentColor: '#5CC8B2' })
        }
        .width('100%')
        BarChart({ title: '类型费用柱状图', labels: this.barLabels, values: this.barValues })
        PieChart({ title: '类型费用占比', labels: this.pieLabels, values: this.pieValues })
        LineChart({ title: '月度费用趋势', labels: this.lineLabels, values: this.lineValues })
      }
      .padding(16)
      .width('100%')
    }
    .backgroundColor('#F3F6FB')
  }
}
