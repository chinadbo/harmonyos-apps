import { ColorModel } from '../model/ColorModel';
import { ColorCard } from '../components/ColorCard';

@Component
export struct FavoritesPage {
  @Link favorites: Array<ColorModel>;
  onOpenDetail: (color: ColorModel) => void = () => {};
  onDelete: (id: number) => void = () => {};
  onSave: (color: ColorModel) => void = () => {};
  onCopy: (color: ColorModel) => void = () => {};

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Column({ space: 6 }) {
          Text('Favorite swatches')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text(this.favorites.length > 0 ? 'Saved colors are stored locally on this device.' : 'No favorites yet. Save colors from the other tabs to build a library.')
            .fontSize(14)
            .fontColor('#6B7280');
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%');

        if (this.favorites.length === 0) {
          Column() {
            Text('Your favorites library is empty.')
              .fontSize(16)
              .fontColor('#6B7280');
          }
          .width('100%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .alignItems(HorizontalAlign.Center);
        } else {
          ForEach(this.favorites, (color: ColorModel) => {
            Column({ space: 8 }) {
              ColorCard({
                color,
                title: color.displayName(),
                subtitle: color.hex,
                onOpenDetail: this.onOpenDetail,
                onCopy: this.onCopy,
                onSave: this.onSave
              });
              Button('Remove')
                .width('100%')
                .height(40)
                .fontSize(14)
                .fontColor('#B42318')
                .backgroundColor('#FEE4E2')
                .borderRadius(14)
                .onClick(() => {
                  this.onDelete(color.id);
                });
            }
            .width('100%');
          }, (color: ColorModel) => `${color.id}`);
        }
      }
      .padding(16)
      .width('100%');
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#F6F7FB');
  }
}
