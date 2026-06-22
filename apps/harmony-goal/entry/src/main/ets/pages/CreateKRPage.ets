import router from '@ohos.router';
import { GoalDetail, KRFormData, KRType, KeyResult } from '../model/GoalModel';
import { goalViewModel } from '../viewmodel/GoalViewModel';

@Entry
@Component
struct CreateKRPage {
  @StorageProp('selectedGoalDetail') detail: GoalDetail | null = null;
  @State goalId: number = 0;
  @State krId: number = 0;
  @State title: string = '';
  @State krType: KRType = 'number';
  @State targetValue: string = '100';
  @State currentValue: string = '0';
  @State unit: string = '';
  @State weight: string = '1';
  @State errorMessage: string = '';

  aboutToAppear(): void {
    let params = router.getParams() as Record<string, Object>;
    this.goalId = Number(params?.goalId ?? AppStorage.Get<number>('selectedGoalId') ?? 0);
    this.krId = Number(params?.krId ?? 0);
    let currentKr: KeyResult | undefined = this.detail?.keyResults.find((item: KeyResult) => item.id === this.krId);
    let form: KRFormData = goalViewModel.getKrFormData(this.goalId, currentKr ?? null);
    this.title = form.title;
    this.krType = form.krType;
    this.targetValue = `${form.targetValue}`;
    this.currentValue = `${form.currentValue}`;
    this.unit = form.unit;
    this.weight = `${form.weight}`;
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorMessage = '请输入 KR 标题';
      return;
    }
    let weightValue: number = Number(this.weight);
    if (weightValue <= 0) {
      this.errorMessage = '权重必须大于 0';
      return;
    }
    this.errorMessage = '';
    let payload: KRFormData = {
      goalId: this.goalId,
      title: this.title.trim(),
      krType: this.krType,
      targetValue: this.krType === 'boolean' ? 1 : Number(this.targetValue),
      currentValue: this.krType === 'boolean' ? (Number(this.currentValue) >= 1 ? 1 : 0) : Number(this.currentValue),
      unit: this.unit.trim(),
      weight: weightValue
    };
    if (this.krId > 0) {
      await goalViewModel.updateKeyResult(this.krId, payload);
    } else {
      await goalViewModel.createKeyResult(payload);
    }
    router.back();
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('返回')
            .height(36)
            .backgroundColor('#F3F5F8')
            .fontColor('#18202A')
            .onClick(() => router.back())
          Text(this.krId > 0 ? '编辑 KR' : '新建 KR')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 12 })
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('标题')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.title, placeholder: '例如：每周练习 4 次口语' })
            .height(44)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.title = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('类型')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          Row({ space: 8 }) {
            this.optionButton('number', this.krType === 'number', () => this.krType = 'number')
            this.optionButton('boolean', this.krType === 'boolean', () => {
              this.krType = 'boolean';
              this.targetValue = '1';
            })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        if (this.krType === 'number') {
          Column({ space: 10 }) {
            Text('目标值')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
            TextInput({ text: this.targetValue, placeholder: '100' })
              .height(44)
              .type(InputType.Number)
              .backgroundColor('#FFFFFF')
              .onChange((value: string) => this.targetValue = value)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
        }

        Column({ space: 10 }) {
          Text('当前值')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.currentValue, placeholder: this.krType === 'boolean' ? '0 或 1' : '0' })
            .height(44)
            .type(InputType.Number)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.currentValue = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('单位')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.unit, placeholder: '次 / 页 / 小时' })
            .height(44)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.unit = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        Column({ space: 10 }) {
          Text('权重')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
          TextInput({ text: this.weight, placeholder: '1' })
            .height(44)
            .type(InputType.Number)
            .backgroundColor('#FFFFFF')
            .onChange((value: string) => this.weight = value)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(18)

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(13)
            .fontColor('#FF6B6B')
        }

        Button(this.krId > 0 ? '保存 KR' : '创建 KR')
          .width('100%')
          .height(46)
          .backgroundColor('#4C7DFF')
          .onClick(async () => await this.save())
      }
      .padding(16)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }

  @Builder
  private optionButton(label: string, selected: boolean, action: () => void) {
    Button(label)
      .height(34)
      .backgroundColor(selected ? '#4C7DFF' : '#F3F5F8')
      .fontColor(selected ? '#FFFFFF' : '#18202A')
      .onClick(action)
  }
}
