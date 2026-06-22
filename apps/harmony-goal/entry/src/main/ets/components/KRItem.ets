import { KeyResult } from '../model/GoalModel';

@Component
export struct KRItem {
  @Prop item: KeyResult;
  @Prop accentColor: string = '#4C7DFF';
  onProgressChange: (krId: number, value: number) => void = () => {};
  onEdit?: (krId: number) => void;
  onDelete?: (krId: number) => void;
  @State inputValue: string = '';

  aboutToAppear(): void {
    this.inputValue = `${this.item.currentValue}`;
  }

  private progressPercent(): number {
    if (this.item.krType === 'boolean') {
      return this.item.currentValue >= 1 ? 100 : 0;
    }
    if (this.item.targetValue <= 0) {
      return 0;
    }
    return Math.min((this.item.currentValue / this.item.targetValue) * 100, 100);
  }

  private commitValue(nextValue: number): void {
    let safeValue: number = Math.max(0, nextValue);
    this.inputValue = `${safeValue}`;
    this.onProgressChange(this.item.id, safeValue);
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#18202A')
          Text(this.item.krType === 'boolean'
            ? `布尔型 KR · 权重 ${this.item.weight}`
            : `数值型 KR · 当前 ${this.item.currentValue}${this.item.unit} / 目标 ${this.item.targetValue}${this.item.unit} · 权重 ${this.item.weight}`)
            .fontSize(12)
            .fontColor('#5E6B7A')
        }
        .layoutWeight(1)
        Row({ space: 6 }) {
          if (this.onEdit) {
            Button('编辑')
              .height(28)
              .fontSize(12)
              .backgroundColor('#F3F5F8')
              .fontColor('#18202A')
              .onClick(() => this.onEdit && this.onEdit(this.item.id))
          }
          if (this.onDelete) {
            Button('删除')
              .height(28)
              .fontSize(12)
              .backgroundColor('#FFF1F1')
              .fontColor('#FF6B6B')
              .onClick(() => this.onDelete && this.onDelete(this.item.id))
          }
        }
      }
      if (this.item.krType === 'boolean') {
        Row({ space: 10 }) {
          Text(this.item.currentValue >= 1 ? '已完成' : '未完成')
            .fontSize(13)
            .fontColor(this.item.currentValue >= 1 ? '#20C997' : '#5E6B7A')
          Toggle({ type: ToggleType.Switch, isOn: this.item.currentValue >= 1 })
            .selectedColor(this.accentColor)
            .onChange((value: boolean) => {
              this.commitValue(value ? 1 : 0);
            })
        }
      } else {
        Column({ space: 10 }) {
          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(8)
              .backgroundColor('#E8EDF5')
              .borderRadius(4)
            Row()
              .width(`${this.progressPercent()}%`)
              .height(8)
              .backgroundColor(this.accentColor)
              .borderRadius(4)
          }
          Row({ space: 8 }) {
            Button('-1')
              .width(48)
              .height(34)
              .backgroundColor('#F3F5F8')
              .fontColor('#18202A')
              .onClick(() => this.commitValue(this.item.currentValue - 1))
            TextInput({ text: this.inputValue, placeholder: '当前值' })
              .layoutWeight(1)
              .height(40)
              .type(InputType.Number)
              .backgroundColor('#F8FAFD')
              .onChange((value: string) => {
                this.inputValue = value;
              })
              .onSubmit(() => {
                this.commitValue(Number(this.inputValue));
              })
            Button('+1')
              .width(48)
              .height(34)
              .backgroundColor('#EDF2FF')
              .fontColor(this.accentColor)
              .onClick(() => this.commitValue(this.item.currentValue + 1))
            Button('保存')
              .height(34)
              .backgroundColor(this.accentColor)
              .onClick(() => this.commitValue(Number(this.inputValue)))
          }
          Text(`完成 ${this.progressPercent().toFixed(1)}%`)
            .fontSize(12)
            .fontColor('#5E6B7A')
        }
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}
