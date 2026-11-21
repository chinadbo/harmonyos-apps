import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { CalendarView } from './CalendarView';
import { DbHelper } from '../database/DbHelper';
import { CheckupItem } from '../model/CheckupItem';
import { NotifyUtil } from '../utils/NotifyUtil';
import {
  formatDate,
  formatMonthDay,
  getWeekdayCN,
  parseDate,
  todayStr
} from '../utils/PregnancyCalc';

const DOMAIN: number = 0x0000;
const TAG: string = 'CheckupView';
const PINK: string = '#F062A3';
const PINK_DARK: string = '#D6336C';
const TITLE_COLOR: string = '#3A2C33';
const BODY_COLOR: string = '#5A4A52';
const MUTED_COLOR: string = '#A98D9B';
const CARD_BG: string = '#FFFFFF';

@CustomDialog
struct AddCheckupDialog {
  controller?: CustomDialogController;
  @Prop initialDate: string = '';
  onConfirm?: (name: string, date: string, note: string) => void;

  @State nameInput: string = '';
  @State noteInput: string = '';
  @State pickDate: Date = new Date();
  @State errorText: string = '';

  aboutToAppear(): void {
    if (this.initialDate.length > 0) {
      this.pickDate = parseDate(this.initialDate);
    }
  }

  private pickerStart(): Date {
    const start: Date = new Date();
    start.setFullYear(start.getFullYear() - 1);
    return start;
  }

  private pickerEnd(): Date {
    const end: Date = new Date();
    end.setFullYear(end.getFullYear() + 1);
    return end;
  }

  private confirm(): void {
    const name: string = this.nameInput.trim();
    if (name.length === 0) {
      this.errorText = '请输入产检名称';
      return;
    }
    if (this.onConfirm !== undefined) {
      this.onConfirm(name, formatDate(this.pickDate), this.noteInput.trim());
    }
    if (this.controller !== undefined) {
      this.controller.close();
    }
  }

  build() {
    Column() {
      Text('添加产检')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
      Text('记录自定义的产检安排')
        .fontSize(12)
        .fontColor(MUTED_COLOR)
        .margin({ top: 4 })

      Text('产检名称')
        .fontSize(13)
        .fontColor(BODY_COLOR)
        .margin({ top: 16 })
      TextInput({ text: this.nameInput, placeholder: '例如：胎儿心脏超声' })
        .type(InputType.Normal)
        .maxLength(30)
        .height(46)
        .fontSize(15)
        .fontColor(TITLE_COLOR)
        .placeholderColor('#C9B2BE')
        .backgroundColor('#FFF6FA')
        .borderRadius(12)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.nameInput = value;
          this.errorText = '';
        })

      Text('产检日期')
        .fontSize(13)
        .fontColor(BODY_COLOR)
        .margin({ top: 16 })
      DatePicker({
        start: this.pickerStart(),
        end: this.pickerEnd(),
        selected: this.pickDate
      })
        .width('100%')
        .onDateChange((value: Date) => {
          this.pickDate = value;
        })

      Text('备注（选填）')
        .fontSize(13)
        .fontColor(BODY_COLOR)
        .margin({ top: 12 })
      TextInput({ text: this.noteInput, placeholder: '例如：空腹、携带档案' })
        .type(InputType.Normal)
        .maxLength(60)
        .height(46)
        .fontSize(15)
        .fontColor(TITLE_COLOR)
        .placeholderColor('#C9B2BE')
        .backgroundColor('#FFF6FA')
        .borderRadius(12)
        .padding({ left: 14, right: 14 })
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.noteInput = value;
        })

      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(12)
          .fontColor('#E05A5A')
          .margin({ top: 10 })
      }

      Row() {
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
          if (this.controller !== undefined) {
            this.controller.close();
          }
        })

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

@Component
export struct CheckupView {
  @Prop @Watch('onDueDateChanged') dueDate: string = '';
  @Prop @Watch('onTick') refreshTick: number = 0;

  @State year: number = new Date().getFullYear();
  @State month: number = new Date().getMonth() + 1;
  @State markDates: string[] = [];
  @State monthPending: CheckupItem[] = [];
  @State monthDone: CheckupItem[] = [];
  @State totalCount: number = 0;

  private notifiedIds: number[] = [];
  private addDialog: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.reload();
  }

  onDueDateChanged(): void {
    this.reload();
  }

  onTick(): void {
    this.reload();
  }

  private pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private monthKey(): string {
    return `${this.year}-${this.pad2(this.month)}`;
  }

  private async reload(): Promise<void> {
    try {
      const list: CheckupItem[] = await DbHelper.getInstance().queryCheckups();
      const marks: string[] = [];
      const pending: CheckupItem[] = [];
      const done: CheckupItem[] = [];
      const key: string = this.monthKey();
      for (let i = 0; i < list.length; i++) {
        const item: CheckupItem = list[i];
        if (item.dueDate.length >= 7 && marks.indexOf(item.dueDate) < 0) {
          marks.push(item.dueDate);
        }
        if (item.dueDate.length >= 7 && item.dueDate.substring(0, 7) === key) {
          if (item.done) {
            done.push(item);
          } else {
            pending.push(item);
          }
        }
      }
      this.markDates = marks;
      this.monthPending = pending;
      this.monthDone = done;
      this.totalCount = list.length;
      await this.notifyToday(list);
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'reload failed: %{public}d %{public}s', error.code, error.message);
    }
  }

  private async notifyToday(list: CheckupItem[]): Promise<void> {
    const today: string = todayStr();
    for (let i = 0; i < list.length; i++) {
      const item: CheckupItem = list[i];
      if (item.dueDate !== today || item.done) {
        continue;
      }
      if (this.notifiedIds.indexOf(item.id) >= 0) {
        continue;
      }
      this.notifiedIds.push(item.id);
      try {
        const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        await NotifyUtil.requestPermission(context);
        await NotifyUtil.publishCheckupNotify(item.name, item.dueDate);
      } catch (err) {
        const error: BusinessError = err as BusinessError;
        hilog.error(DOMAIN, TAG, 'notifyToday failed: %{public}d %{public}s', error.code, error.message);
      }
    }
  }

  private async toggleDone(item: CheckupItem): Promise<void> {
    try {
      await DbHelper.getInstance().setCheckupDone(item.id, !item.done);
      promptAction.showToast({
        message: item.done ? `已取消完成「${item.name}」` : `已完成「${item.name}」`
      });
      await this.reload();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'toggleDone failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  private async importTemplate(): Promise<void> {
    if (this.dueDate.length === 0) {
      promptAction.showToast({ message: '请先在「我的」设置预产期' });
      return;
    }
    try {
      const added: number = await DbHelper.getInstance().importCheckupTemplate(this.dueDate);
      promptAction.showToast({
        message: added > 0 ? `已导入 ${added} 项常规产检` : '常规产检模板已存在'
      });
      await this.reload();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'importTemplate failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '导入失败，请重试' });
    }
  }

  private openAddDialog(): void {
    this.addDialog = new CustomDialogController({
      builder: AddCheckupDialog({
        initialDate: todayStr(),
        onConfirm: (name: string, date: string, note: string) => {
          this.saveCheckup(name, date, note);
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });
    this.addDialog.open();
  }

  private async saveCheckup(name: string, date: string, note: string): Promise<void> {
    const item: CheckupItem = new CheckupItem();
    item.name = name;
    item.dueDate = date;
    item.done = false;
    item.note = note;
    try {
      await DbHelper.getInstance().insertCheckup(item);
      promptAction.showToast({ message: '产检已添加' });
      await this.reload();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'saveCheckup failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '保存失败，请重试' });
    }
  }

  private dateLabel(item: CheckupItem): string {
    const base: string = `${formatMonthDay(item.dueDate)} ${getWeekdayCN(item.dueDate)}`;
    if (item.dueDate === todayStr()) {
      return `今天 · ${base}`;
    }
    return base;
  }

  @Builder
  header() {
    Row() {
      Column() {
        Text('产检管理')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
        Text(`本月 ${this.monthPending.length + this.monthDone.length} 项 · 累计 ${this.totalCount} 项`)
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('🩺')
        .fontSize(28)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 14 })
  }

  @Builder
  actionsRow() {
    Row() {
      Row() {
        Text('＋ 添加自定义产检')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
      }
      .layoutWeight(1)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(14)
      .backgroundColor(PINK)
      .onClick(() => {
        this.openAddDialog();
      })

      Row() {
        Text('一键导入常规产检')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(PINK_DARK)
      }
      .layoutWeight(1)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .borderRadius(14)
      .backgroundColor('#FFF0F6')
      .border({ width: 1, color: '#F3BFD6' })
      .margin({ left: 10 })
      .onClick(() => {
        this.importTemplate();
      })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  @Builder
  checkupRow(item: CheckupItem) {
    Row() {
      Column() {
        if (item.done) {
          Text('✓')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
      }
      .width(24)
      .height(24)
      .borderRadius(12)
      .backgroundColor(item.done ? PINK : '#FFFFFF')
      .border({ width: 1.5, color: item.done ? PINK : '#F0B3CB' })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(item.done ? '#A08A97' : TITLE_COLOR)
          .decoration({
            type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None,
            color: '#A08A97'
          })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.dateLabel(item))
          .fontSize(12)
          .fontColor(item.dueDate === todayStr() ? PINK_DARK : MUTED_COLOR)
          .margin({ top: 3 })
        if (item.note.length > 0) {
          Text(item.note)
            .fontSize(12)
            .fontColor('#BCA7B2')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(item.done ? '已完成' : '待办')
        .fontSize(11)
        .fontColor(item.done ? '#9A8A94' : PINK_DARK)
        .backgroundColor(item.done ? '#F4EEF1' : '#FFF0F6')
        .borderRadius(9)
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 0.5 }, color: '#F6E7EF' })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.toggleDone(item);
    })
  }

  @Builder
  listSection(title: string, items: CheckupItem[], doneList: boolean) {
    Column() {
      Row() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(`${items.length} 项`)
          .fontSize(12)
          .fontColor('#C58AA6')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (items.length === 0) {
        Column() {
          Text(doneList ? '还没有已完成的产检' : '本月暂无待办产检')
            .fontSize(13)
            .fontColor('#B59AA8')
          Text(doneList ? '完成产检后会自动归到这里' : '点击上方按钮添加或导入产检')
            .fontSize(11)
            .fontColor('#C9B2BE')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 12 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(items, (item: CheckupItem) => {
          this.checkupRow(item)
        }, (item: CheckupItem) => `${item.id}-${item.done ? 'd' : 'p'}`)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  build() {
    Scroll() {
      Column() {
        this.header()

        CalendarView({
          year: this.year,
          month: this.month,
          markDates: this.markDates,
          onMonthChange: (newYear: number, newMonth: number) => {
            this.year = newYear;
            this.month = newMonth;
            this.reload();
          }
        })

        this.actionsRow()
        this.listSection('待办产检', this.monthPending, false)
        this.listSection('已完成', this.monthDone, true)

        Text('点击产检条目可切换完成状态 · 圆点标记为产检日期')
          .fontSize(11)
          .fontColor('#C2A8B5')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ top: 16 })
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
