import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import { Element, loadElements, getCategoryColor } from '../model/Element';
import { dbHelper } from '../utils/db';

const DOMAIN: number = 0x0000;
const TAG: string = 'ElementDetail';

interface DetailParams {
  atomicNumber: number;
}

const CATEGORY_LABELS: Map<string, string> = new Map<string, string>();
CATEGORY_LABELS.set('alkali-metal', '碱金属');
CATEGORY_LABELS.set('alkaline-earth', '碱土金属');
CATEGORY_LABELS.set('transition', '过渡金属');
CATEGORY_LABELS.set('post-transition', '后过渡金属');
CATEGORY_LABELS.set('metalloid', '类金属');
CATEGORY_LABELS.set('nonmetal', '非金属');
CATEGORY_LABELS.set('halogen', '卤素');
CATEGORY_LABELS.set('noble-gas', '稀有气体');
CATEGORY_LABELS.set('lanthanide', '镧系');
CATEGORY_LABELS.set('actinide', '锕系');

const STATE_LABELS: Map<string, string> = new Map<string, string>();
STATE_LABELS.set('solid', '固态');
STATE_LABELS.set('liquid', '液态');
STATE_LABELS.set('gas', '气态');

function categoryLabel(category: string): string {
  const label = CATEGORY_LABELS.get(category);
  return label === undefined ? category : label;
}

function stateLabel(state: string): string {
  const label = STATE_LABELS.get(state);
  return label === undefined ? state : label;
}

function formatNumber(value: number): string {
  const abs: number = Math.abs(value);
  if (abs !== 0 && (abs < 0.001 || abs >= 100000)) {
    return value.toExponential(2);
  }
  return (Math.round(value * 1000) / 1000).toString();
}

function formatTemperature(value: number | null): string {
  if (value === null) {
    return '未知';
  }
  return formatNumber(value) + ' °C';
}

@Entry
@Component
struct ElementDetail {
  @State element: Element | null = null;
  @State favorite: boolean = false;
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State favoriteBusy: boolean = false;
  private atomicNumber: number = 0;

  aboutToAppear(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const params: DetailParams = router.getParams() as DetailParams;
    if (params === undefined || params === null || typeof params.atomicNumber !== 'number') {
      this.loading = false;
      this.errorMessage = '缺少元素参数，无法显示详情';
      return;
    }
    this.atomicNumber = params.atomicNumber;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const elements: Element[] = await loadElements(context);
      let target: Element | null = null;
      for (const item of elements) {
        if (item.atomicNumber === this.atomicNumber) {
          target = item;
          break;
        }
      }
      if (target === null) {
        this.loading = false;
        this.errorMessage = '未找到该元素';
        return;
      }
      await dbHelper.init(context);
      const favorite: boolean = await dbHelper.isFavorite(this.atomicNumber);
      this.element = target;
      this.favorite = favorite;
      this.loading = false;
    } catch (err) {
      this.loading = false;
      this.errorMessage = '元素数据加载失败，请重试';
      hilog.error(DOMAIN, TAG, 'load detail failed: %{public}s', JSON.stringify(err));
    }
  }

  private async toggleFavorite(): Promise<void> {
    if (this.element === null || this.favoriteBusy) {
      return;
    }
    this.favoriteBusy = true;
    try {
      if (this.favorite) {
        await dbHelper.removeFavorite(this.atomicNumber);
        this.favorite = false;
      } else {
        await dbHelper.addFavorite(this.atomicNumber);
        this.favorite = true;
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'toggle favorite failed: %{public}s', JSON.stringify(err));
    } finally {
      this.favoriteBusy = false;
    }
  }

  private groupText(element: Element): string {
    if (element.group === 0) {
      return '无（' + categoryLabel(element.category) + '）';
    }
    return element.group.toString();
  }

  private discoveredText(): string {
    if (this.element === null || this.element.discoveredYear === null) {
      return '未知';
    }
    return this.element.discoveredYear.toString() + ' 年';
  }

  build() {
    Column() {
      this.Header()
      if (this.loading) {
        Column({ space: 8 }) {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#0A59F7')
          Text('正在加载元素详情')
            .fontSize(13)
            .fontColor('#99000000')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.element === null) {
        Column({ space: 12 }) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#99000000')
            .textAlign(TextAlign.Center)
          Button('返回元素表', { type: ButtonType.Normal })
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#0A59F7')
            .borderRadius(10)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 24, right: 24 })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            this.HeroCard()
            this.FavoriteButton()
            this.PropertiesCard()
            this.UsageCard()
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  @Builder
  Header() {
    Row() {
      Text('返回')
        .fontSize(14)
        .fontColor('#0A59F7')
        .padding({ left: 4, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          router.back();
        })
      Text('元素详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#E6000000')
      Blank()
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 10, bottom: 6 })
  }

  @Builder
  HeroCard() {
    Row({ space: 14 }) {
      Column() {
        Text(this.element !== null ? this.element.atomicNumber.toString() : '')
          .fontSize(11)
          .fontColor('#B3000000')
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 10 })
        Text(this.element !== null ? this.element.symbol : '')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
          .width('100%')
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
      .width(96)
      .height(96)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.element !== null ? getCategoryColor(this.element.category) : '#B9C4D4')
      .borderRadius(12)
      .border({ width: 0.5, color: '#26000000' })

      Column({ space: 4 }) {
        Text(this.element !== null ? this.element.nameZh : '')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        Text(this.element !== null ? this.element.nameEn : '')
          .fontSize(15)
          .fontColor('#99000000')
        Text(this.element !== null
          ? '相对原子质量 ' + this.element.atomicMass.toString() : '')
          .fontSize(13)
          .fontColor('#66000000')
        if (this.element !== null) {
          Text(categoryLabel(this.element.category))
            .fontSize(12)
            .fontColor('#E6000000')
            .padding({ left: 10, right: 10, top: 3, bottom: 3 })
            .backgroundColor('#66FFFFFF')
            .borderRadius(10)
            .border({ width: 0.5, color: '#33000000' })
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  FavoriteButton() {
    Button(this.favorite ? '已收藏 · 点击取消' : '收藏该元素', { type: ButtonType.Normal })
      .width('100%')
      .height(44)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.favorite ? '#0A59F7' : '#FFFFFF')
      .backgroundColor(this.favorite ? '#EAF1FE' : '#0A59F7')
      .borderRadius(12)
      .border({ width: this.favorite ? 1 : 0, color: '#0A59F7' })
      .enabled(!this.favoriteBusy)
      .opacity(this.favoriteBusy ? 0.6 : 1)
      .onClick(() => {
        this.toggleFavorite();
      })
  }

  @Builder
  PropertiesCard() {
    Column() {
      this.InfoRow('原子序数', this.element !== null ? this.element.atomicNumber.toString() : '')
      this.RowDivider()
      this.InfoRow('元素符号', this.element !== null ? this.element.symbol : '')
      this.RowDivider()
      this.InfoRow('中文名', this.element !== null ? this.element.nameZh : '')
      this.RowDivider()
      this.InfoRow('英文名', this.element !== null ? this.element.nameEn : '')
      this.RowDivider()
      this.InfoRow('相对原子质量',
        this.element !== null ? this.element.atomicMass.toString() : '')
      this.RowDivider()
      this.InfoRow('周期', this.element !== null ? '第 ' + this.element.period.toString() + ' 周期' : '')
      this.RowDivider()
      this.InfoRow('族', this.element !== null ? this.groupText(this.element) : '')
      this.RowDivider()
      this.InfoRow('区', this.element !== null ? this.element.block + ' 区' : '')
      this.RowDivider()
      this.InfoRow('电子排布', this.element !== null ? this.element.electronConfig : '')
      this.RowDivider()
      this.InfoRow('常温状态', this.element !== null ? stateLabel(this.element.state) : '')
      this.RowDivider()
      this.InfoRow('密度', this.element !== null
        ? formatNumber(this.element.density) + ' g/cm³' : '')
      this.RowDivider()
      this.InfoRow('熔点', this.element !== null
        ? formatTemperature(this.element.meltingPoint) : '')
      this.RowDivider()
      this.InfoRow('沸点', this.element !== null
        ? formatTemperature(this.element.boilingPoint) : '')
      this.RowDivider()
      this.InfoRow('发现年份', this.discoveredText())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 4 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#66000000')
        .width(88)
      Text(value)
        .fontSize(14)
        .fontColor('#E6000000')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 11, bottom: 11 })
  }

  @Builder
  RowDivider() {
    Divider()
      .width('100%')
      .color('#0D000000')
  }

  @Builder
  UsageCard() {
    Column({ space: 8 }) {
      Text('用途')
        .fontSize(13)
        .fontColor('#66000000')
      Text(this.element !== null ? this.element.usage : '')
        .fontSize(14)
        .fontColor('#E6000000')
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }
}
