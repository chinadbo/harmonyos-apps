@Component
export struct ExpiryBanner {
  @Prop expiredCount: number = 0;
  @Prop expiringSoonCount: number = 0;

  private message(): string {
    if (this.expiredCount > 0) {
      return `已有 ${this.expiredCount} 项食材过期，${this.expiringSoonCount} 项即将到期`;
    }
    if (this.expiringSoonCount > 0) {
      return `${this.expiringSoonCount} 项食材将在 7 天内到期`;
    }
    return '当前食材状态良好';
  }

  private bannerColor(): string {
    if (this.expiredCount > 0) {
      return '#FFF1F3';
    }
    if (this.expiringSoonCount > 0) {
      return '#FFF7ED';
    }
    return '#EEF9F1';
  }

  build() {
    Row() {
      Column({ space: 4 }) {
        Text('有效期提醒')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#20331E')
        Text(this.message())
          .fontSize(13)
          .fontColor('#51684E')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.bannerColor())
    .borderRadius(20)
  }
}
