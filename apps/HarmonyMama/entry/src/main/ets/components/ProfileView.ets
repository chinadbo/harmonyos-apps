import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { DbHelper } from '../database/DbHelper';
import { CheckupItem } from '../model/CheckupItem';
import { WeightRecord } from '../model/WeightRecord';
import { KickSession } from '../model/KickSession';
import {
  addDays,
  calcDueDateDirect,
  calcDueDateFromLmp,
  daysUntil,
  formatDate,
  formatDateCN,
  formatWeekDay,
  getPregnancyWeek,
  getStage,
  parseDate,
  PregnancyWeek,
  todayStr
} from '../utils/PregnancyCalc';

const DOMAIN: number = 0x0000;
const TAG: string = 'ProfileView';
const PINK: string = '#F062A3';
const PINK_DARK: string = '#D6336C';
const TITLE_COLOR: string = '#3A2C33';
const BODY_COLOR: string = '#5A4A52';
const MUTED_COLOR: string = '#A98D9B';

interface PrivacySection {
  title: string;
  body: string;
}

const PRIVACY_SUMMARY: string = '本应用是纯离线的孕期管理工具。您记录的全部数据仅保存在本机应用私有目录中，绝不上传至任何服务器，也不与任何第三方共享。';

const PRIVACY_SECTIONS: PrivacySection[] = [
  { title: '数据收集', body: '应用未申请网络、位置或媒体权限，无账号体系，不收集、不采集、不追踪任何个人信息。' },
  { title: '本地存储', body: '产检记录、体重记录、胎动会话保存在本机 RDB 数据库；末次月经、预产期等设置保存在本机 Preferences。数据不会离开您的设备。' },
  { title: '数据共享', body: '不与任何第三方共享数据，也不接入任何统计、广告或云端服务 SDK。' },
  { title: '用户权利', body: '卸载应用，或在系统设置中清除应用数据，即可删除全部本地记录。当前版本不提供数据导出功能。' },
  { title: '儿童隐私', body: '本应用不面向儿童收集任何信息。' },
  { title: '声明更新', body: '本声明如有变更，将随应用版本更新同步说明。' }
];

@CustomDialog
export struct DueDateDialog {
  controller?: CustomDialogController;
  @Prop initialDueDate: string = '';
  @Prop allowCancel: boolean = true;
  onConfirm?: (dueDate: string, lmp: string, mode: number) => void;

  @State mode: number = 0;
  @State lmpDate: Date = new Date(Date.now() - 84 * 24 * 60 * 60 * 1000);
  @State dueInput: string = '';
  @State errorText: string = '';

  aboutToAppear(): void {
    if (this.isValidDateString(this.initialDueDate)) {
      this.dueInput = this.initialDueDate;
      this.lmpDate = this.clampLmp(parseDate(addDays(this.initialDueDate, -280)));
    } else {
      this.dueInput = calcDueDateFromLmp(formatDate(this.lmpDate));
    }
  }

  private lmpStart(): Date {
    const start: Date = new Date();
    start.setDate(start.getDate() - 300);
    return start;
  }

  private lmpEnd(): Date {
    return new Date();
  }

  private clampLmp(date: Date): Date {
    const start: Date = this.lmpStart();
    const end: Date = this.lmpEnd();
    if (date.getTime() < start.getTime()) {
      return start;
    }
    if (date.getTime() > end.getTime()) {
      return end;
    }
    return date;
  }

  private isValidDateString(value: string): boolean {
    const parts: string[] = value.split('-');
    if (parts.length !== 3 || parts[0].length !== 4 || parts[1].length !== 2 || parts[2].length !== 2) {
      return false;
    }
    const year: number = parseInt(parts[0], 10);
    const month: number = parseInt(parts[1], 10);
    const day: number = parseInt(parts[2], 10);
    if (Number.isNaN(year) || Number.isNaN(month) || Number.isNaN(day)) {
      return false;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return false;
    }
    const check: Date = new Date(year, month - 1, day);
    return check.getFullYear() === year && check.getMonth() === month - 1 && check.getDate() === day;
  }

  private previewDueDate(): string {
    if (this.mode === 0) {
      return calcDueDateFromLmp(formatDate(this.lmpDate));
    }
    const text: string = this.dueInput.trim();
    if (this.isValidDateString(text)) {
      return calcDueDateDirect(text);
    }
    return '';
  }

  private previewDueCN(): string {
    const due: string = this.previewDueDate();
    if (due.length === 0) {
      return '待输入';
    }
    return formatDateCN(due);
  }

  private previewWeekLabel(): string {
    const due: string = this.previewDueDate();
    if (due.length === 0) {
      return '输入日期后自动计算';
    }
    const pregnancy: PregnancyWeek = getPregnancyWeek(due, todayStr());
    return formatWeekDay(pregnancy.week, pregnancy.day);
  }

  private switchMode(mode: number): void {
    if (this.mode === mode) {
      return;
    }
    this.mode = mode;
    this.errorText = '';
    if (mode === 1) {
      this.dueInput = calcDueDateFromLmp(formatDate(this.lmpDate));
    } else {
      const text: string = this.dueInput.trim();
      if (this.isValidDateString(text)) {
        this.lmpDate = this.clampLmp(parseDate(addDays(text, -280)));
      }
    }
  }

  private onLmpChanged(value: Date): void {
    this.lmpDate = value;
    this.dueInput = calcDueDateFromLmp(formatDate(value));
    this.errorText = '';
  }

  private confirm(): void {
    let dueDate: string = '';
    let lmp: string = '';
    if (this.mode === 0) {
      if (this.lmpDate.getTime() > Date.now()) {
        this.errorText = '末次月经日期不能晚于今天';
        return;
      }
      lmp = formatDate(this.lmpDate);
      dueDate = calcDueDateFromLmp(lmp);
    } else {
      const text: string = this.dueInput.trim();
      if (!this.isValidDateString(text)) {
        this.errorText = '请输入正确的日期，格式如 2027-06-01';
        return;
      }
      dueDate = calcDueDateDirect(text);
      lmp = addDays(dueDate, -280);
    }
    if (this.onConfirm !== undefined) {
      this.onConfirm(dueDate, lmp, this.mode);
    }
    if (this.controller !== undefined) {
      this.controller.close();
    }
  }

  private cancel(): void {
    if (this.controller !== undefined) {
      this.controller.close();
    }
  }

  @Builder
  modeTab(label: string, value: number) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontWeight(this.mode === value ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.mode === value ? '#FFFFFF' : '#B06A8A')
    }
    .layoutWeight(1)
    .height(34)
    .justifyContent(FlexAlign.Center)
    .borderRadius(15)
    .backgroundColor(this.mode === value ? PINK : '#00000000')
    .onClick(() => {
      this.switchMode(value);
    })
  }

  build() {
    Column() {
      Text('设置预产期')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
      Text('选择一种方式，帮助计算孕周与产检时间')
        .fontSize(12)
        .fontColor(MUTED_COLOR)
        .margin({ top: 4 })

      Row() {
        this.modeTab('末次月经', 0)
        this.modeTab('预产期', 1)
      }
      .width('100%')
      .padding(3)
      .backgroundColor('#F7E9F0')
      .borderRadius(18)
      .margin({ top: 16 })

      if (this.mode === 0) {
        Text('末次月经第一天')
          .fontSize(13)
          .fontColor(BODY_COLOR)
          .margin({ top: 16 })
        DatePicker({
          start: this.lmpStart(),
          end: this.lmpEnd(),
          selected: this.lmpDate
        })
          .width('100%')
          .onDateChange((value: Date) => {
            this.onLmpChanged(value);
          })
      } else {
        Text('预产期日期')
          .fontSize(13)
          .fontColor(BODY_COLOR)
          .margin({ top: 16 })
        TextInput({ text: this.dueInput, placeholder: '例如 2027-06-01' })
          .type(InputType.Normal)
          .maxLength(10)
          .height(46)
          .fontSize(16)
          .fontColor(TITLE_COLOR)
          .placeholderColor('#C9B2BE')
          .backgroundColor('#FFF6FA')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .margin({ top: 8 })
          .onChange((value: string) => {
            this.dueInput = value;
            this.errorText = '';
          })
        Text('格式：YYYY-MM-DD')
          .fontSize(11)
          .fontColor('#BCA7B2')
          .margin({ top: 6 })
      }

      Column() {
        Row() {
          Text('预产期')
            .fontSize(12)
            .fontColor('#9A7C8B')
            .layoutWeight(1)
          Text(this.previewDueCN())
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(PINK_DARK)
        }
        .width('100%')
        Row() {
          Text('当前孕周')
            .fontSize(12)
            .fontColor('#9A7C8B')
            .layoutWeight(1)
          Text(this.previewWeekLabel())
            .fontSize(13)
            .fontColor(BODY_COLOR)
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFF4F9')
      .borderRadius(14)
      .margin({ top: 14 })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(12)
          .fontColor('#E05A5A')
          .margin({ top: 10 })
      }

      Row() {
        if (this.allowCancel) {
          Row() {
            Text('取消')
              .fontSize(15)
              .fontColor('#8C7A84')
          }
          .layoutWeight(1)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .borderRadius(22)
          .backgroundColor('#F7F1F4')
          .margin({ right: 10 })
          .onClick(() => {
            this.cancel();
          })
        }
        Row() {
          Text('保存')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .borderRadius(22)
        .backgroundColor(PINK)
        .onClick(() => {
          this.confirm();
        })
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('88%')
    .padding(22)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }
}

@CustomDialog
struct PrivacyDialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('隐私声明')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
      Text('生效日期：2026-11-21')
        .fontSize(11)
        .fontColor('#B59AA8')
        .margin({ top: 4 })
      Text(PRIVACY_SUMMARY)
        .fontSize(13)
        .lineHeight(20)
        .fontColor(BODY_COLOR)
        .margin({ top: 12 })

      Scroll() {
        Column() {
          ForEach(PRIVACY_SECTIONS, (section: PrivacySection) => {
            Column() {
              Text(section.title)
                .fontSize(13)
                .fontWeight(FontWeight.Medium)
                .fontColor(PINK_DARK)
              Text(section.body)
                .fontSize(13)
                .lineHeight(20)
                .fontColor('#6B5A63')
                .margin({ top: 4 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 14 })
          }, (section: PrivacySection) => section.title)
        }
        .width('100%')
      }
      .width('100%')
      .constraintSize({ maxHeight: 300 })
      .scrollBar(BarState.Off)
      .margin({ top: 6 })

      Row() {
        Text('我知道了')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(22)
      .backgroundColor(PINK)
      .margin({ top: 4 })
      .onClick(() => {
        if (this.controller !== undefined) {
          this.controller.close();
        }
      })
    }
    .width('88%')
    .padding(22)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct ProfileView {
  @Prop @Watch('onDueDateChanged') dueDate: string = '';
  @Prop @Watch('onTick') refreshTick: number = 0;
  onDueDateChange?: (dueDate: string, lmp: string, mode: number) => void;

  @State week: number = 0;
  @State day: number = 0;
  @State stage: string = '孕早期';
  @State daysLeft: number = 0;
  @State doneCount: number = 0;
  @State weightCount: number = 0;
  @State kickCount: number = 0;

  private resetDialog: CustomDialogController | null = null;
  privacyDialog: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog(),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear(): void {
    this.refreshPregnancy();
    this.loadStats();
  }

  onDueDateChanged(): void {
    this.refreshPregnancy();
  }

  onTick(): void {
    this.refreshPregnancy();
    this.loadStats();
  }

  private refreshPregnancy(): void {
    if (this.dueDate.length === 0) {
      this.week = 0;
      this.day = 0;
      this.stage = '孕早期';
      this.daysLeft = 0;
      return;
    }
    const pregnancy: PregnancyWeek = getPregnancyWeek(this.dueDate, todayStr());
    this.week = pregnancy.week;
    this.day = pregnancy.day;
    this.stage = getStage(pregnancy.week);
    this.daysLeft = daysUntil(this.dueDate);
  }

  private async loadStats(): Promise<void> {
    try {
      const doneList: CheckupItem[] = await DbHelper.getInstance().queryCheckupsByDone(true);
      const weights: WeightRecord[] = await DbHelper.getInstance().queryWeights();
      const kicks: KickSession[] = await DbHelper.getInstance().queryKickSessions();
      this.doneCount = doneList.length;
      this.weightCount = weights.length;
      this.kickCount = kicks.length;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'loadStats failed: %{public}d %{public}s', error.code, error.message);
    }
  }

  private openResetDialog(): void {
    this.resetDialog = new CustomDialogController({
      builder: DueDateDialog({
        initialDueDate: this.dueDate,
        allowCancel: true,
        onConfirm: (dueDate: string, lmp: string, mode: number) => {
          if (this.onDueDateChange !== undefined) {
            this.onDueDateChange(dueDate, lmp, mode);
          }
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.resetDialog.open();
  }

  private countdownLabel(): string {
    if (this.daysLeft > 0) {
      return `还有 ${this.daysLeft} 天`;
    }
    if (this.daysLeft === 0) {
      return '今天预产期';
    }
    return `已超过预产期 ${-this.daysLeft} 天`;
  }

  @Builder
  profileHeader() {
    Column() {
      Row() {
        Column() {
          Text('预产期')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.85)')
          Text(this.dueDate.length > 0 ? formatDateCN(this.dueDate) : '尚未设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 6 })
          Text(this.dueDate.length > 0
            ? `${formatWeekDay(this.week, this.day)} · ${this.stage} · ${this.countdownLabel()}`
            : '设置后可查看孕周、倒计时与数据统计')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.9)')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('👤')
          .fontSize(36)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text('重新设置预产期')
          .fontSize(13)
          .fontColor(PINK_DARK)
      }
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor('rgba(255,255,255,0.92)')
      .borderRadius(16)
      .margin({ top: 16 })
      .onClick(() => {
        this.openResetDialog();
      })
    }
    .width('100%')
    .padding(20)
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
    .linearGradient({
      angle: 135,
      colors: [['#FFB6D5', 0.0], ['#FF8DBE', 0.55], ['#F26BA8', 1.0]]
    })
    .shadow({ radius: 16, color: 'rgba(242,107,168,0.32)', offsetX: 0, offsetY: 8 })
  }

  @Builder
  statItem(kind: number) {
    Column() {
      Text(kind === 0 ? '🩺' : (kind === 1 ? '⚖️' : '👣'))
        .fontSize(18)
      Text(kind === 0 ? `${this.doneCount}` : (kind === 1 ? `${this.weightCount}` : `${this.kickCount}`))
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(PINK_DARK)
        .margin({ top: 4 })
      Text(kind === 0 ? '产检完成' : (kind === 1 ? '体重记录' : '胎动会话'))
        .fontSize(11)
        .fontColor(MUTED_COLOR)
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor('#FFF4F9')
    .borderRadius(16)
  }

  @Builder
  statsCard() {
    Column() {
      Text('数据统计')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
      Row() {
        this.statItem(0)
        Row()
          .width(10)
          .height(1)
        this.statItem(1)
        Row()
          .width(10)
          .height(1)
        this.statItem(2)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  menuCard() {
    Column() {
      Row() {
        Text('🔒')
          .fontSize(18)
        Column() {
          Text('隐私声明')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(TITLE_COLOR)
          Text('了解数据如何仅保存在本机')
            .fontSize(11)
            .fontColor(MUTED_COLOR)
            .margin({ top: 3 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
        Text('›')
          .fontSize(22)
          .fontColor('#C9A9BA')
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.privacyDialog.open();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .margin({ top: 16 })
  }

  build() {
    Scroll() {
      Column() {
        this.profileHeader()
        this.statsCard()
        this.menuCard()
        Text('HarmonyMama 孕期伴侣 · 纯离线运行，数据仅保存在本机')
          .fontSize(11)
          .fontColor('#C2A8B5')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 20 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 18, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF6FA')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
