import router from '@ohos.router';

// 底部导航组件
@Component
export struct NavBar {
  @Prop current: number = 0;

  build() {
    Row() {
      NavItem({ icon: '🌙', label: '今日', idx: 0, current: this.current })
      NavItem({ icon: '📅', label: '月历', idx: 1, current: this.current })
      NavItem({ icon: '🌅', label: '日月', idx: 2, current: this.current })
      NavItem({ icon: '✨', label: '清单', idx: 3, current: this.current })
      NavItem({ icon: '📚', label: '知识', idx: 4, current: this.current })
      NavItem({ icon: '⚙️', label: '设置', idx: 5, current: this.current })
    }
    .width('100%')
    .height(64)
    .padding({ left: 6, right: 6 })
    .backgroundColor('#0D1230')
    .justifyContent(FlexAlign.SpaceBetween)
    .border({ width: { top: 0.5 }, color: 'rgba(154, 163, 199, 0.2)' })
  }
}

@Component
struct NavItem {
  @Prop icon: string = '';
  @Prop label: string = '';
  @Prop idx: number = 0;
  @Prop current: number = 0;

  private routes: string[] = [
    'pages/Index', 'pages/MoonCalendar', 'pages/SunMoon',
    'pages/StarList', 'pages/Learn', 'pages/Settings'
  ];

  build() {
    Column({ space: 2 }) {
      Text(this.icon)
        .fontSize(22)
        .opacity(this.current === this.idx ? 1 : 0.45)
      Text(this.label)
        .fontSize(10)
        .fontColor(this.current === this.idx ? '#F5D76E' : '#9AA3C7')
    }
    .width('15%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.current !== this.idx) {
        router.replaceUrl({ url: this.routes[this.idx] });
      }
    })
  }
}
