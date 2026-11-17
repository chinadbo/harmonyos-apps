import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import hilog from '@ohos.hilog';
import util from '@ohos.util';
import { preferencesHelper, DEFAULT_COLOR_SCHEME } from '../utils/preferences';

const DOMAIN: number = 0x0000;
const TAG: string = 'SettingsPage';
const APP_VERSION: string = '1.0.0';
const RADIO_GROUP: string = 'colorScheme';

interface SchemeOption {
  value: string;
  title: string;
  desc: string;
}

interface PrivacySection {
  title: string;
  content: string;
}

interface PrivacyStatement {
  summary: string;
  sections: PrivacySection[];
}

const SCHEME_OPTIONS: SchemeOption[] = [
  { value: 'category', title: '按类别', desc: '碱金属、过渡金属、稀有气体等 10 类着色' },
  { value: 'state', title: '按状态', desc: '固态、液态、气态三种常温状态着色' },
  { value: 'block', title: '按区', desc: 's、p、d、f 四个电子区着色' }
];

@Entry
@Component
struct SettingsPage {
  @State colorScheme: string = DEFAULT_COLOR_SCHEME;
  @State loading: boolean = true;
  @State errorMessage: string = '';
  @State privacyText: string = '';
  @State privacyVisible: boolean = false;

  aboutToAppear(): void {
    this.loadSettings();
  }

  private async loadSettings(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await preferencesHelper.init(context);
      this.colorScheme = await preferencesHelper.getColorScheme();
      this.errorMessage = '';
    } catch (err) {
      this.errorMessage = '设置读取失败，已使用默认配色';
      hilog.error(DOMAIN, TAG, 'load settings failed: %{public}s', JSON.stringify(err));
    } finally {
      this.loading = false;
    }
  }

  private async selectScheme(value: string): Promise<void> {
    if (this.colorScheme === value) {
      return;
    }
    const previous: string = this.colorScheme;
    this.colorScheme = value;
    try {
      const context = getContext(this) as common.UIAbilityContext;
      await preferencesHelper.init(context);
      await preferencesHelper.setColorScheme(value);
      this.errorMessage = '';
    } catch (err) {
      this.colorScheme = previous;
      this.errorMessage = '配色保存失败，请重试';
      hilog.error(DOMAIN, TAG, 'save color scheme failed: %{public}s', JSON.stringify(err));
    }
  }

  private async loadPrivacy(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const bytes: Uint8Array = await context.resourceManager.getRawFileContent('privacy_statement.json');
      const decoder: util.TextDecoder = new util.TextDecoder('utf-8');
      const raw: string = decoder.decodeWithStream(bytes);
      const data = JSON.parse(raw) as PrivacyStatement;
      let text: string = data.summary;
      for (const section of data.sections) {
        text += '\n\n' + section.title + '\n' + section.content;
      }
      this.privacyText = text;
    } catch (err) {
      this.privacyText = '隐私声明加载失败';
      hilog.error(DOMAIN, TAG, 'load privacy statement failed: %{public}s', JSON.stringify(err));
    }
    this.privacyVisible = true;
  }

  private schemeTitle(value: string): string {
    for (const option of SCHEME_OPTIONS) {
      if (option.value === value) {
        return option.title;
      }
    }
    return '按类别';
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
          Text('正在读取设置')
            .fontSize(13)
            .fontColor('#99000000')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            if (this.errorMessage.length > 0) {
              Text(this.errorMessage)
                .fontSize(12)
                .fontColor('#C7361F')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(10)
                .backgroundColor('#FDECE9')
                .borderRadius(10)
            }
            this.SectionTitle('着色方案')
            this.SchemeCard()
            Text('影响元素周期表单元格的着色方式，当前为「' +
              this.schemeTitle(this.colorScheme) + '」，选择后立即保存。')
              .fontSize(11)
              .fontColor('#66000000')
              .lineHeight(17)
              .width('100%')
              .padding({ left: 4 })
            this.SectionTitle('关于')
            this.AboutCard()
            if (this.privacyVisible) {
              this.PrivacyCard()
            }
            this.DescriptionCard()
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 10, bottom: 24 })
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
      Column({ space: 2 }) {
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E6000000')
        Text('配色方案与应用信息')
          .fontSize(11)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 10, bottom: 8 })
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(12)
      .fontColor('#66000000')
      .width('100%')
      .textAlign(TextAlign.Start)
      .padding({ left: 4, top: 6 })
  }

  @Builder
  SchemeCard() {
    Column({ space: 10 }) {
      ForEach(SCHEME_OPTIONS, (option: SchemeOption) => {
        this.SchemeRow(option)
      }, (option: SchemeOption) => option.value)
    }
    .width('100%')
  }

  @Builder
  SchemeRow(option: SchemeOption) {
    Row({ space: 10 }) {
      Radio({ value: option.value, group: RADIO_GROUP })
        .checked(this.colorScheme === option.value)
        .width(22)
        .height(22)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.selectScheme(option.value);
          }
        })
      Column({ space: 3 }) {
        Text(option.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
        Text(option.desc)
          .fontSize(12)
          .fontColor('#99000000')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.colorScheme === option.value) {
        Text('已选')
          .fontSize(11)
          .fontColor('#0A59F7')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#EAF1FE')
          .borderRadius(9)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: this.colorScheme === option.value ? 1 : 0, color: '#0A59F7' })
    .onClick(() => {
      this.selectScheme(option.value);
    })
  }

  @Builder
  AboutCard() {
    Column() {
      this.AboutRow('应用名称', '元素周期表')
      this.RowDivider()
      this.AboutRow('版本', APP_VERSION)
      this.RowDivider()
      this.AboutRow('数据内容', '118 种元素')
      this.RowDivider()
      this.AboutRow('权限', '无')
      this.RowDivider()
      this.PrivacyRow()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 2, bottom: 2 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  AboutRow(label: string, value: string) {
    Row({ space: 12 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#66000000')
        .width(80)
      Text(value)
        .fontSize(14)
        .fontColor('#E6000000')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  PrivacyRow() {
    Row({ space: 12 }) {
      Text('隐私声明')
        .fontSize(13)
        .fontColor('#66000000')
        .width(80)
      Text('查看 >')
        .fontSize(14)
        .fontColor('#0A59F7')
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      this.loadPrivacy();
    })
  }

  @Builder
  PrivacyCard() {
    Column({ space: 8 }) {
      Row() {
        Text('隐私声明')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#E6000000')
        Blank()
        Text('收起')
          .fontSize(12)
          .fontColor('#0A59F7')
          .padding({ left: 8, top: 2, bottom: 2 })
          .onClick(() => {
            this.privacyVisible = false;
          })
      }
      .width('100%')
      Scroll() {
        Text(this.privacyText)
          .fontSize(12)
          .lineHeight(19)
          .fontColor('#99000000')
          .width('100%')
      }
      .width('100%')
      .scrollBar(BarState.Auto)
      .constraintSize({ maxHeight: 300 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  RowDivider() {
    Divider()
      .width('100%')
      .color('#0D000000')
  }

  @Builder
  DescriptionCard() {
    Column({ space: 6 }) {
      Text('应用说明')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E6000000')
      Text('离线元素周期表学习工具，支持周期表浏览、元素检索、详情查看、收藏与选择题测验。')
        .fontSize(12)
        .fontColor('#99000000')
        .lineHeight(19)
      Text('所有收藏与测验成绩仅保存在本机，不收集任何个人信息，应用不申请任何系统权限。')
        .fontSize(12)
        .fontColor('#99000000')
        .lineHeight(19)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
