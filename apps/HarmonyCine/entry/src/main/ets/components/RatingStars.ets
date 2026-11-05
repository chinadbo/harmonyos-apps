/**
 * RatingStars：0-10 星评分组件。
 * editable 为 true 时点击星标打分（再点当前值可清零），通过 onRatingChange 回调父组件。
 */
const STAR_VALUES: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

@Component
export struct RatingStars {
  @Prop rating: number = 0;
  @Prop editable: boolean = false;
  @Prop starSize: number = 18;
  @Prop showValue: boolean = true;
  onRatingChange: (value: number) => void = (value: number) => {
  };

  private roundedRating(): number {
    return Math.round(this.rating);
  }

  build() {
    Row({ space: 2 }) {
      ForEach(STAR_VALUES, (starIndex: number) => {
        Text(starIndex <= this.roundedRating() ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(starIndex <= this.roundedRating() ? '#F5A623' : '#C7CBD8')
          .onClick(() => {
            if (!this.editable) {
              return;
            }
            const next = starIndex === this.roundedRating() ? 0 : starIndex;
            this.rating = next;
            this.onRatingChange(next);
          })
      }, (starIndex: number) => `star_${starIndex}`)
      if (this.showValue) {
        Text(this.roundedRating() > 0 ? `${this.roundedRating()} 分` : '未评分')
          .fontSize(12)
          .fontColor('#8A8F9E')
          .margin({ left: 6 })
      }
    }
    .alignItems(VerticalAlign.Center)
  }
}
