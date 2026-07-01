import { COLORS } from '../constants/AppConstants';

@Component
export struct AboutPage {
  @Prop stack: NavPathStack = new NavPathStack();

  build() {
    Column({ space: 18 }) {
      Row() {
        Button('Back')
          .backgroundColor(COLORS.surfaceAlt)
          .fontColor(COLORS.textPrimary)
          .onClick(() => {
            this.stack.pop();
          })
        Blank()
      }
      .width('100%')

      Text('About HarmonyTempo')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.textPrimary)

      Text('HarmonyTempo is a dark-theme metronome for daily music practice. It focuses on fast tempo changes, clear visual feedback, and low-latency click playback.')
        .fontSize(16)
        .lineHeight(24)
        .fontColor(COLORS.textSecondary)

      Text('Features')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.textPrimary)
      Text('• Tempo range from 40 to 280 BPM\n• Five time signatures\n• Tap tempo and practice timer\n• Three click sounds with accent support\n• Local-only settings persistence')
        .fontSize(16)
        .lineHeight(26)
        .fontColor(COLORS.textSecondary)

      Text('Privacy')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.textPrimary)
      Text('HarmonyTempo does not request storage or microphone access. The app stores only local metronome preferences on your device.')
        .fontSize(16)
        .lineHeight(24)
        .fontColor(COLORS.textSecondary)

      Blank()
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
    .alignItems(HorizontalAlign.Start)
  }
}
