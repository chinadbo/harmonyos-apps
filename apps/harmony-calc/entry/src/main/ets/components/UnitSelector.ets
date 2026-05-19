import { UnitDefinition } from '../engine/UnitConverter';

@Component
export struct UnitSelector {
  @Prop title: string = '';
  @Prop units: Array<UnitDefinition> = [];
  @Link selectedKey: string;

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#A0A0A5')
        .width('100%');
      Select(this.units.map((item: UnitDefinition) => {
        return { value: item.label };
      }))
        .selected(this.findSelectedIndex())
        .value(this.findSelectedLabel())
        .fontColor(Color.White)
        .backgroundColor('#2C2C2E')
        .borderRadius(16)
        .onSelect((index: number) => {
          this.selectedKey = this.units[index].key;
        });
    }
    .width('100%');
  }

  private findSelectedIndex(): number {
    for (let i: number = 0; i < this.units.length; i += 1) {
      if (this.units[i].key === this.selectedKey) {
        return i;
      }
    }
    return 0;
  }

  private findSelectedLabel(): string {
    const index: number = this.findSelectedIndex();
    return this.units.length > 0 ? this.units[index].label : '';
  }
}
