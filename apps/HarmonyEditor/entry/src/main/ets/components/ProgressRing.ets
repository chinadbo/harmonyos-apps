import { AppStyles } from '../common/styles';

@Component
export struct ProgressRing {
  @Prop progress: number = 0;
  @Prop label: string = 'Exporting';
  @Prop color: string = AppStyles.colors.brandPrimary;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.progress, total: 100, type: ProgressType.Ring })
        .width(120)
        .height(120)
        .color(this.color)
        .backgroundColor(AppStyles.colors.surfaceMuted)
        .style({ strokeWidth: 10 })

      Column({ space: 6 }) {
        Text(`${Math.round(this.progress)}%`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppStyles.colors.textPrimary)
        Text(this.label)
          .fontSize(12)
          .fontColor(AppStyles.colors.textSecondary)
      }
    }
    .padding(12)
  }
}
