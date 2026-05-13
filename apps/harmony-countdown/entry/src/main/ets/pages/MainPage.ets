import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { CountdownEvent } from '../model/CountdownEvent';
import { MainViewModel } from '../viewmodel/MainViewModel';
import { DateUtils } from '../utils/DateUtils';
import { IconConstants } from '../utils/IconConstants';

@Entry
@Component
struct MainPage {
  @State events: CountdownEvent[] = [];
  @State isLoading: boolean = true;
  private viewModel: MainViewModel = new MainViewModel();

  async aboutToAppear(): Promise<void> {
    let context = getContext(this) as common.UIAbilityContext;
    await this.viewModel.init(context);
    this.events = await this.viewModel.refresh();
    this.isLoading = false;
  }

  build() {
    Column() {
      this.buildHeader();
      if (this.isLoading) {
        Text('加载中...').fontSize(18).margin({ top: 40 });
      } else if (this.events.length === 0) {
        this.buildEmpty();
      } else {
        List({ space: 12 }) {
          ForEach(this.events, (item: CountdownEvent) => {
            ListItem() {
              this.buildCard(item);
            }
          }, (item: CountdownEvent) => `${item.id}`)
        }
        .padding({ left: 16, right: 16, bottom: 16 })
        .layoutWeight(1);
      }
      this.buildBottomBar();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF7F7F9');
  }

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('HarmonyCountdown').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#222222');
        Text(`共 ${this.events.length} 个重要日子`).fontSize(14).fontColor('#666666').margin({ top: 6 });
      }
      .alignItems(HorizontalAlign.Start);
      Blank();
      Button('日历').height(40).backgroundColor('#FFFFFF').fontColor('#333333').onClick(() => {
        router.pushUrl({ url: 'pages/CalendarPage' });
      });
      Button('设置').height(40).margin({ left: 8 }).backgroundColor('#FF5B4D').onClick(() => {
        router.pushUrl({ url: 'pages/SettingPage' });
      });
    }
    .padding({ left: 16, right: 16, top: 18, bottom: 18 });
  }

  @Builder
  buildEmpty() {
    Column({ space: 16 }) {
      Text('还没有倒计时').fontSize(24).fontWeight(FontWeight.Bold);
      Text('添加生日、纪念日、旅行计划或考试日期').fontSize(15).fontColor('#666666');
      Button('新建事件').width(180).height(46).backgroundColor('#FF5B4D').onClick(() => {
        router.pushUrl({ url: 'pages/EditPage', params: { id: 0 } });
      });
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .width('100%');
  }

  @Builder
  buildCard(item: CountdownEvent) {
    let dayInfo = DateUtils.calculateDayInfo(item);
    Row() {
      Column() {
        Text(IconConstants.getSymbol(item.icon)).fontSize(28).fontColor(item.color);
      }
      .width(44);
      Column({ space: 6 }) {
        Text(item.title).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#222222').maxLines(1);
        Text(DateUtils.formatDisplayDate(item.targetDate)).fontSize(14).fontColor('#888888');
        Text(dayInfo.displayText)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(dayInfo.isToday ? '#0A9B57' : (dayInfo.isPast ? '#8A8A8A' : item.color));
        if (item.note.length > 0) {
          Text(item.note).fontSize(13).fontColor('#666666').maxLines(1);
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);
      Column({ space: 8 }) {
        Button('详情').type(ButtonType.Capsule).backgroundColor('#FFF0EE').fontColor('#FF5B4D').onClick(() => {
          router.pushUrl({ url: 'pages/DetailPage', params: { id: item.id } });
        });
        Button('删除').type(ButtonType.Capsule).backgroundColor('#F1F3F5').fontColor('#444444').onClick(async () => {
          await this.viewModel.deleteEvent(item.id);
          this.events = await this.viewModel.refresh();
          promptAction.showToast({ message: '已删除' });
        });
      }
    }
    .padding(16)
    .borderRadius(20)
    .backgroundColor('#FFFFFF');
  }

  @Builder
  buildBottomBar() {
    Row() {
      Button('添加倒计时')
        .width('100%')
        .height(50)
        .backgroundColor('#FF5B4D')
        .onClick(() => {
          router.pushUrl({ url: 'pages/EditPage', params: { id: 0 } });
        });
    }
    .padding(16)
    .backgroundColor('#FFFFFF');
  }
}
