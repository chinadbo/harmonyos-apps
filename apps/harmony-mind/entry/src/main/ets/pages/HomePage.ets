import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { FileStorage } from '../utils/FileStorage';
import { MindMapMeta } from '../models/MindMap';
import { MindCard } from '../components/MindCard';
import { Constants } from '../utils/Constants';

@Entry
@Component
struct HomePage {
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State private storage?: FileStorage;
  @State private mindMaps: Array<MindMapMeta> = [];
  @State private filteredMindMaps: Array<MindMapMeta> = [];
  @State private keyword: string = '';
  @State private deleteVisible: boolean = false;
  @State private targetDeleteId: string = '';
  @State private targetDeleteTitle: string = '';
  @State private creating: boolean = false;
  @State private errorMessage: string = '';

  aboutToAppear(): void {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.storage = new FileStorage(context);
      this.storage.initialize().then(() => {
        this.loadData();
        if (this.storage) {
          this.storage.loadSettings().then((settings) => {
            this.isDarkMode = settings.isDarkMode;
          });
        }
      });
    } catch (error) {
      this.errorMessage = '页面初始化失败';
    }
  }

  private async loadData(): Promise<void> {
    try {
      if (!this.storage) {
        return;
      }
      this.mindMaps = await this.storage.loadMindMaps();
      this.applyFilter();
    } catch (error) {
      this.errorMessage = '脑图列表加载失败';
    }
  }

  private applyFilter(): void {
    try {
      const key: string = this.keyword.trim().toLowerCase();
      if (!key) {
        this.filteredMindMaps = [...this.mindMaps];
        return;
      }
      this.filteredMindMaps = this.mindMaps.filter((item: MindMapMeta) => item.title.toLowerCase().indexOf(key) >= 0);
    } catch (error) {
      this.filteredMindMaps = [...this.mindMaps];
    }
  }

  private async createNewMindMap(): Promise<void> {
    try {
      if (!this.storage || this.creating) {
        return;
      }
      this.creating = true;
      const map = await this.storage.createMindMap(Constants.DEFAULT_TITLE);
      await this.loadData();
      this.creating = false;
      router.pushUrl({ url: 'pages/EditorPage', params: { mindMapId: map.id } });
    } catch (error) {
      this.creating = false;
      this.errorMessage = '新建脑图失败';
    }
  }

  private promptDelete(item: MindMapMeta): void {
    this.targetDeleteId = item.id;
    this.targetDeleteTitle = item.title;
    this.deleteVisible = true;
  }

  private async confirmDelete(): Promise<void> {
    try {
      if (!this.storage || !this.targetDeleteId) {
        this.deleteVisible = false;
        return;
      }
      await this.storage.deleteMindMap(this.targetDeleteId);
      this.deleteVisible = false;
      this.targetDeleteId = '';
      this.targetDeleteTitle = '';
      await this.loadData();
    } catch (error) {
      this.errorMessage = '删除脑图失败';
      this.deleteVisible = false;
    }
  }

  build() {
    Stack() {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyMind')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            Text('用脑图整理你的灵感与想法')
              .fontSize(15)
              .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF607080')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button('设置')
            .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
            .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            .onClick(() => {
              router.pushUrl({ url: 'pages/SettingsPage' });
            })
        }
        .width('100%')

        TextInput({ text: this.keyword, placeholder: '搜索脑图标题' })
          .width('100%')
          .fontSize(16)
          .onChange((value: string) => {
            this.keyword = value;
            this.applyFilter();
          })

        Button(this.creating ? '正在创建...' : '新建脑图')
          .width('100%')
          .height(52)
          .fontSize(18)
          .enabled(!this.creating)
          .backgroundColor('#FF5B8FF9')
          .onClick(() => {
            this.createNewMindMap();
          })

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#FFE14D4D')
        }

        if (this.filteredMindMaps.length === 0) {
          Column({ space: 10 }) {
            Text('暂无脑图')
              .fontSize(22)
              .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            Text('点击上方按钮，创建你的第一张脑图')
              .fontSize(15)
              .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF607080')
          }
          .width('100%')
          .padding({ top: 60 })
        } else {
          List({ space: 14 }) {
            ForEach(this.filteredMindMaps, (item: MindMapMeta) => {
              ListItem() {
                MindCard({ item, isDarkMode: this.isDarkMode, onOpen: (id: string) => {
                  router.pushUrl({ url: 'pages/EditorPage', params: { mindMapId: id } });
                }, onDelete: (target: MindMapMeta) => {
                  this.promptDelete(target);
                } })
              }
            }, (item: MindMapMeta) => item.id)
          }
          .width('100%')
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .padding(20)
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDarkMode ? '#FF14181F' : '#FFF7F8FC')
      .alignItems(HorizontalAlign.Start)

      if (this.deleteVisible) {
        Column() {
          Column({ space: 16 }) {
            Text('确认删除')
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
            Text(`确定删除“${this.targetDeleteTitle}”吗？此操作不可撤销。`)
              .fontSize(16)
              .fontColor(this.isDarkMode ? '#FFD5DFEA' : '#FF607080')
            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .backgroundColor(this.isDarkMode ? '#FF303B48' : '#FFE7ECF3')
                .fontColor(this.isDarkMode ? '#FFF4F7FB' : '#FF1F2530')
                .onClick(() => {
                  this.deleteVisible = false;
                })
              Button('确认删除')
                .layoutWeight(1)
                .backgroundColor('#FFE14D4D')
                .onClick(() => {
                  this.confirmDelete();
                })
            }
            .width('100%')
          }
          .width('84%')
          .padding(20)
          .backgroundColor(this.isDarkMode ? '#FF1E2630' : '#FFFFFFFF')
          .borderRadius(20)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
      }
    }
    .width('100%')
    .height('100%')
  }
}
