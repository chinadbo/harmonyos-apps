import { PAGE_ABOUT, PAGE_INDEX, PAGE_SETTINGS, NAV_STACK_KEY } from '../constants/AppConstants';
import { IndexPage } from './IndexPage';
import { SettingsPage } from './SettingsPage';
import { AboutPage } from './AboutPage';

@Builder
function TempoPageBuilder(name: string, param: Object) {
  if (name === PAGE_INDEX) {
    IndexPage({ stack: AppStorage.get(NAV_STACK_KEY) as NavPathStack });
  } else if (name === PAGE_SETTINGS) {
    SettingsPage({ stack: AppStorage.get(NAV_STACK_KEY) as NavPathStack });
  } else if (name === PAGE_ABOUT) {
    AboutPage({ stack: AppStorage.get(NAV_STACK_KEY) as NavPathStack });
  }
}

@Entry
@Component
struct Index {
  private stack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    AppStorage.setOrCreate(NAV_STACK_KEY, this.stack);
    if (this.stack.size() === 0) {
      this.stack.pushPath({ name: PAGE_INDEX, param: {} });
    }
  }

  build() {
    Navigation(this.stack) {
    }
    .title('HarmonyTempo')
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(TempoPageBuilder)
    .mode(NavigationMode.Stack)
    .hideBackButton(false)
  }
}
