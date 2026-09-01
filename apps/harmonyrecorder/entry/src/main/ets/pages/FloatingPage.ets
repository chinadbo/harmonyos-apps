import { FloatingWindow } from '../components/FloatingWindow';

@Entry
@Component
struct FloatingPage {
  build() {
    Stack() {
      FloatingWindow()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000000')
  }
}
