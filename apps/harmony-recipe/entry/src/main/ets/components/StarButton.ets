import DatabaseService from '../service/DatabaseService';

@Component
export struct StarButton {
  @Prop recipeId: number = 0;
  @Prop favorite: boolean = false;
  onChanged?: (favorite: boolean) => void = undefined;
  @State isFavorite: boolean = false;
  @State scaleValue: number = 1;

  aboutToAppear(): void {
    this.isFavorite = this.favorite;
  }

  private async toggleFavorite(): Promise<void> {
    animateTo({ duration: 120 }, () => {
      this.scaleValue = 0.82;
    });
    this.isFavorite = await DatabaseService.getInstance().toggleFavorite(this.recipeId);
    animateTo({ duration: 180, curve: Curve.Friction }, () => {
      this.scaleValue = 1.12;
    });
    animateTo({ duration: 120, delay: 150 }, () => {
      this.scaleValue = 1;
    });
    if (this.onChanged) {
      this.onChanged(this.isFavorite);
    }
  }

  build() {
    Stack() {
      Text(this.isFavorite ? '★' : '☆')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isFavorite ? '#FF8A3D' : '#FFFFFF')
    }
    .width(36)
    .height(36)
    .backgroundColor(this.isFavorite ? '#FFF0E5' : '#332C2C2C')
    .borderRadius(18)
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .onClick(() => {
      this.toggleFavorite();
    })
  }
}
