@Component
export struct StarRating {
  @Prop rating: number = 0;
  @Prop editable: boolean = false;
  @State internalRating: number = 0;
  private onChange?: (rating: number) => void;

  aboutToAppear(): void {
    this.internalRating = this.rating;
  }

  currentRating(): number {
    return this.editable ? this.internalRating : this.rating;
  }

  build() {
    Row({ space: 4 }) {
      ForEach([1, 2, 3, 4, 5], (star: number) => {
        Text(star <= this.currentRating() ? '★' : '☆')
          .fontSize(24)
          .fontColor(star <= this.currentRating() ? '#FFD700' : '#CCCCCC')
          .onClick(() => {
            if (this.editable) {
              this.internalRating = star;
              if (this.onChange) {
                this.onChange(star);
              }
            }
          })
      }, (star: number) => star.toString())
    }
  }
}
