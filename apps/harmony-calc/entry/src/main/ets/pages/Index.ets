import { StandardCalcPage } from '../calculator/StandardCalcPage';
import { ScientificCalcPage } from '../calculator/ScientificCalcPage';
import { UnitConverterPage } from '../calculator/UnitConverterPage';
import { CurrencyPage } from '../calculator/CurrencyPage';

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        StandardCalcPage();
      }
      .tabBar({ text: '标准' });

      TabContent() {
        ScientificCalcPage();
      }
      .tabBar({ text: '科学' });

      TabContent() {
        UnitConverterPage();
      }
      .tabBar({ text: '单位' });

      TabContent() {
        CurrencyPage();
      }
      .tabBar({ text: '汇率' });
    }
    .barMode(BarMode.Fixed)
    .vertical(false)
    .backgroundColor('#1C1C1E')
    .onChange((index: number) => {
      this.currentIndex = index;
    });
  }
}
