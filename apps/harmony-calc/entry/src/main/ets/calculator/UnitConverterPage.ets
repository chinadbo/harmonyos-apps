import { UnitConverter, UnitCategory, CategoryDefinition, UnitDefinition } from '../engine/UnitConverter';
import { UnitSelector } from '../components/UnitSelector';

@Component
export struct UnitConverterPage {
  @State private categories: Array<CategoryDefinition> = UnitConverter.getCategories();
  @State private currentIndex: number = 0;
  @State private fromUnit: string = UnitConverter.getUnits('length')[0].key;
  @State private toUnit: string = UnitConverter.getUnits('length')[1].key;
  @State private inputValue: string = '1';
  @State private outputValue: string = '1000';

  build() {
    Column({ space: 16 }) {
      Text('单位换算')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%');

      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex }) {
        ForEach(this.categories, (category: CategoryDefinition, index: number) => {
          TabContent() {
            this.buildConverter(category.key);
          }
          .tabBar(category.label);
        });
      }
      .vertical(false)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.currentIndex = index;
        this.resetUnits(this.categories[index].key);
      })
      .width('100%')
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#1C1C1E');
  }

  @Builder
  private buildConverter(category: UnitCategory): void {
    const units: Array<UnitDefinition> = UnitConverter.getUnits(category);
    Column({ space: 16 }) {
      UnitSelector({ title: '从', units: units, selectedKey: $fromUnit });
      TextInput({ text: this.inputValue, placeholder: '输入数值' })
        .type(InputType.Normal)
        .fontColor(Color.White)
        .backgroundColor('#2C2C2E')
        .borderRadius(16)
        .onChange((value: string) => {
          this.inputValue = value;
          this.updateOutput(category);
        });
      UnitSelector({ title: '到', units: units, selectedKey: $toUnit });
      TextInput({ text: this.outputValue, placeholder: '换算结果' })
        .type(InputType.Normal)
        .fontColor(Color.White)
        .backgroundColor('#2C2C2E')
        .borderRadius(16)
        .onChange((value: string) => {
          this.outputValue = value;
          this.updateInput(category);
        });
      Button('交换单位')
        .fontColor(Color.White)
        .backgroundColor('#FF9F0A')
        .borderRadius(20)
        .onClick(() => {
          const temp: string = this.fromUnit;
          this.fromUnit = this.toUnit;
          this.toUnit = temp;
          this.updateOutput(category);
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#242426')
    .borderRadius(24);
  }

  private resetUnits(category: UnitCategory): void {
    const units: Array<UnitDefinition> = UnitConverter.getUnits(category);
    this.fromUnit = units[0].key;
    this.toUnit = units.length > 1 ? units[1].key : units[0].key;
    this.inputValue = '1';
    this.updateOutput(category);
  }

  private updateOutput(category: UnitCategory): void {
    const value: number = Number(this.inputValue);
    if (!isFinite(value)) {
      this.outputValue = '';
      return;
    }
    const result: number = UnitConverter.convert(category, this.fromUnit, this.toUnit, value);
    this.outputValue = this.format(result);
  }

  private updateInput(category: UnitCategory): void {
    const value: number = Number(this.outputValue);
    if (!isFinite(value)) {
      this.inputValue = '';
      return;
    }
    const result: number = UnitConverter.convert(category, this.toUnit, this.fromUnit, value);
    this.inputValue = this.format(result);
  }

  private format(value: number): string {
    return value.toFixed(8).replace(/\.0+$/, '').replace(/(\.\d*?[1-9])0+$/, '$1');
  }
}
