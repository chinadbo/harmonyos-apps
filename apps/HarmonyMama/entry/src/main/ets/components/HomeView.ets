import promptAction from '@ohos.promptAction';
import hilog from '@ohos.hilog';
import { BusinessError } from '@ohos.base';
import { WeekCard } from './WeekCard';
import { DbHelper } from '../database/DbHelper';
import { CheckupItem } from '../model/CheckupItem';
import { WEEKLY_KNOWLEDGE, WeeklyInfo } from '../data/WeeklyKnowledge';
import {
  daysUntil,
  diffDays,
  formatMonthDay,
  formatWeekDay,
  getPregnancyWeek,
  getStage,
  getWeekdayCN,
  PregnancyWeek,
  todayStr
} from '../utils/PregnancyCalc';

const DOMAIN: number = 0x0000;
const TAG: string = 'HomeView';
const CARD_BG: string = '#FFFFFF';
const TITLE_COLOR: string = '#3A2C33';
const BODY_COLOR: string = '#5A4A52';
const MUTED_COLOR: string = '#A98D9B';

@Component
export struct HomeView {
  @Prop @Watch('onDueDateChanged') dueDate: string = '';
  @Prop @Watch('onTick') refreshTick: number = 0;

  @State week: number = 0;
  @State day: number = 0;
  @State stage: string = '孕早期';
  @State daysLeft: number = 0;
  @State info: WeeklyInfo = WEEKLY_KNOWLEDGE[0];
  @State todos: CheckupItem[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  onDueDateChanged(): void {
    this.refresh();
  }

  onTick(): void {
    this.refresh();
  }

  private knowledgeForWeek(week: number): WeeklyInfo {
    let target: number = week;
    if (target < 1) {
      target = 1;
    }
    if (target > 40) {
      target = 40;
    }
    for (let i = 0; i < WEEKLY_KNOWLEDGE.length; i++) {
      if (WEEKLY_KNOWLEDGE[i].week === target) {
        return WEEKLY_KNOWLEDGE[i];
      }
    }
    return WEEKLY_KNOWLEDGE[0];
  }

  private async refresh(): Promise<void> {
    if (this.dueDate.length === 0) {
      this.todos = [];
      return;
    }
    const today: string = todayStr();
    const pregnancy: PregnancyWeek = getPregnancyWeek(this.dueDate, today);
    this.week = pregnancy.week;
    this.day = pregnancy.day;
    this.stage = getStage(pregnancy.week);
    this.daysLeft = daysUntil(this.dueDate, today);
    this.info = this.knowledgeForWeek(pregnancy.week);
    try {
      const pending: CheckupItem[] = await DbHelper.getInstance().queryCheckupsByDone(false);
      const soon: CheckupItem[] = [];
      for (let i = 0; i < pending.length; i++) {
        if (diffDays(today, pending[i].dueDate) <= 7) {
          soon.push(pending[i]);
        }
      }
      this.todos = soon;
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'refresh todos failed: %{public}d %{public}s', error.code, error.message);
      this.todos = [];
    }
  }

  private async markDone(item: CheckupItem): Promise<void> {
    try {
      await DbHelper.getInstance().setCheckupDone(item.id, true);
      promptAction.showToast({ message: `已完成「${item.name}」` });
      await this.refresh();
    } catch (err) {
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, 'markDone failed: %{public}d %{public}s', error.code, error.message);
      promptAction.showToast({ message: '操作失败，请重试' });
    }
  }

  private isOverdue(item: CheckupItem): boolean {
    return diffDays(todayStr(), item.dueDate) < 0;
  }

  private todoDateLabel(item: CheckupItem): string {
    const gap: number = diffDays(todayStr(), item.dueDate);
    const base: string = `${formatMonthDay(item.dueDate)} ${getWeekdayCN(item.dueDate)}`;
    if (gap === 0) {
      return `今天 · ${base}`;
    }
    if (gap === 1) {
      return `明天 · ${base}`;
    }
    if (gap > 1) {
      return `${gap} 天后 · ${base}`;
    }
    return `已逾期 ${-gap} 天 · ${base}`;
  }

  @Builder
  greeting() {
    Row() {
      Column() {
        Text('你好，准妈妈')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
        Text(`${formatMonthDay(todayStr())} ${getWeekdayCN(todayStr())}`)
          .fontSize(12)
          .fontColor(MUTED_COLOR)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('🌸')
        .fontSize(26)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 14 })
  }

  @Builder
  emptyCard() {
    Column() {
      Text('🌸')
        .fontSize(40)
      Text('欢迎使用 HarmonyMama')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(TITLE_COLOR)
        .margin({ top: 10 })
      Text('设置预产期后，这里会展示孕周、本周胎儿发育提示和产检待办。')
        .fontSize(13)
        .fontColor(MUTED_COLOR)
        .lineHeight(20)
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(28)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
  }

  @Builder
  knowledgeCard() {
    Column() {
      Row() {
        Text('👶 本周胎儿发育')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(formatWeekDay(this.week, this.day))
          .fontSize(11)
          .fontColor('#D6336C')
          .backgroundColor('#FFF0F6')
          .borderRadius(10)
          .padding({ left: 9, right: 9, top: 3, bottom: 3 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('大小')
          .fontSize(12)
          .fontColor('#B58AA0')
          .backgroundColor('#FFF0F6')
          .borderRadius(8)
          .padding({ left: 7, right: 7, top: 2, bottom: 2 })
        Text(this.info.size)
          .fontSize(13)
          .fontColor(BODY_COLOR)
          .margin({ left: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 12 })

      Text(this.info.development)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(BODY_COLOR)
        .margin({ top: 10 })

      Divider()
        .width('100%')
        .color('#F5E6EE')
        .margin({ top: 14, bottom: 12 })

      Text('💡 准妈妈提示')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#D6336C')
      Text(this.info.momTip)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(BODY_COLOR)
        .margin({ top: 6 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  @Builder
  todoRow(item: CheckupItem) {
    Row() {
      Column() {
        Text('○')
          .fontSize(15)
          .fontColor('#D6336C')
      }
      .width(26)
      .height(26)
      .borderRadius(13)
      .border({ width: 1.5, color: '#F0B3CB' })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 12 })

      Column() {
        Text(item.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(TITLE_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.todoDateLabel(item))
          .fontSize(12)
          .fontColor(this.isOverdue(item) ? '#E05A5A' : MUTED_COLOR)
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
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 0.5 }, color: '#F6E7EF' })
    .onClick(() => {
      this.markDone(item);
    })
  }

  @Builder
  todoCard() {
    Column() {
      Row() {
        Text('产检待办')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(TITLE_COLOR)
          .layoutWeight(1)
        Text(`${this.todos.length} 项`)
          .fontSize(12)
          .fontColor('#C58AA6')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('未来 7 天内及已逾期、尚未完成的产检，点击可标记完成')
        .fontSize(12)
        .fontColor(MUTED_COLOR)
        .margin({ top: 4 })

      if (this.todos.length === 0) {
        Column() {
          Text('✅')
            .fontSize(28)
          Text('近 7 天暂无产检安排')
            .fontSize(13)
            .fontColor('#B59AA8')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 20, bottom: 10 })
        .justifyContent(FlexAlign.Center)
      } else {
        ForEach(this.todos, (item: CheckupItem) => {
          this.todoRow(item)
        }, (item: CheckupItem) => `${item.id}`)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(CARD_BG)
    .borderRadius(22)
    .margin({ top: 16 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 12, color: 'rgba(214,51,108,0.08)', offsetX: 0, offsetY: 4 })
  }

  build() {
    Scroll() {
      Column() {
        this.greeting()
        if (this.dueDate.length === 0) {
          this.emptyCard()
        } else {
          WeekCard({
            week: this.week,
            day: this.day,
            stage: this.stage,
            daysLeft: this.daysLeft
          })
          this.knowledgeCard()
          this.todoCard()
        }
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
