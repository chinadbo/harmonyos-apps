import { PAGE_CAR_EDIT, PAGE_CAR_LIST, PAGE_MAIN, PAGE_RECORD_EDIT, PAGE_RECORD_LIST, PAGE_REMINDERS, PAGE_STATS } from '../utils/Constants';
import { MainPage } from './MainPage';
import { CarListPage } from './CarListPage';
import { CarEditPage } from './CarEditPage';
import { RecordListPage } from './RecordListPage';
import { RecordEditPage } from './RecordEditPage';
import { StatsPage } from './StatsPage';
import { RemindersPage } from './RemindersPage';

@Builder
function PageBuilder(name: string, param: Object) {
  if (name === PAGE_MAIN) {
    MainPage({ stack: AppStorage.get('appNavStack') as NavPathStack });
  } else if (name === PAGE_CAR_LIST) {
    CarListPage({ stack: AppStorage.get('appNavStack') as NavPathStack });
  } else if (name === PAGE_CAR_EDIT) {
    CarEditPage({ stack: AppStorage.get('appNavStack') as NavPathStack, params: param });
  } else if (name === PAGE_RECORD_LIST) {
    RecordListPage({ stack: AppStorage.get('appNavStack') as NavPathStack, params: param });
  } else if (name === PAGE_RECORD_EDIT) {
    RecordEditPage({ stack: AppStorage.get('appNavStack') as NavPathStack, params: param });
  } else if (name === PAGE_STATS) {
    StatsPage({ stack: AppStorage.get('appNavStack') as NavPathStack });
  } else if (name === PAGE_REMINDERS) {
    RemindersPage({ stack: AppStorage.get('appNavStack') as NavPathStack });
  }
}

@Entry
@Component
struct Index {
  private stack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    AppStorage.setOrCreate('appNavStack', this.stack);
    if (this.stack.size() === 0) {
      this.stack.pushPath({ name: PAGE_MAIN, param: {} });
    }
  }

  build() {
    Navigation(this.stack) {
    }
    .title('HarmonyCar')
    .navDestination(PageBuilder)
    .mode(NavigationMode.Stack)
    .hideBackButton(false)
  }
}
