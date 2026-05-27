@Component
export struct ColorPicker {
  @Link selectedColor: string
  private colors: string[] = [
    '#F44336', '#E91E63', '#9C27B0', '#673AB7',
    '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4',
    '#009688', '#4CAF50', '#FF9800', '#795548'
  ]

  build() {
    Grid() {
      ForEach(this.colors, (color: string) => {
        GridItem() {
          Stack() {
            Circle()
              .width(36)
              .height(36)
              .fill(color)

            if (this.selectedColor === color) {
              Circle()
                .width(44)
                .height(44)
                .fill('transparent')
                .border({ width: 3, color: color })
            }
          }
          .width(48)
          .height(48)
          .alignContent(Alignment.Center)
        }
        .onClick(() => {
          this.selectedColor = color
        })
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(12)
    .columnsGap(12)
    .width('100%')
    .padding(16)
  }
}
