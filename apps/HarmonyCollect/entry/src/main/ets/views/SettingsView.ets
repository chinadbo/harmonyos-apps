/**
 * SettingsView.ets — 设置 Tab（显示偏好、品类管理、数据导出与清空、关于）
 */
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { Category } from '../model/Category';
import { CategoryDao, Db } from '../model/Db';
import { BackupService, ExportResult } from '../service/BackupService';
import { Prefs } from '../common/Prefs';
import { SegmentBar } from '../components/SegmentBar';
import { bumpRefresh, SORT_OPTIONS, categoryColor, C_TEXT, C_SUB, C_BG, C_BRAND, C_CARD, C_LINE, C_DANGER, C_SUCCESS } from '../common/Constants';

const APP_VERSION: string = '1.0.0';

@Component
export struct SettingsView {
  @StorageLink('viewMode') viewMode: string = 'grid';
  @StorageLink('sortMode') sortMode: string = 'created';
  @StorageLink('showAcquired') showAcquired: boolean = false;

  @State categories: Category[] = [];
  @State newCategoryName: string = '';
  @State exportedPath: string = '';

  aboutToAppear(): void {
    this.loadCategories();
  }

  private async loadCategories(): Promise<void> {
    if (!Db.isReady()) {
      await Db.waitReady(4000);
    }
    this.categories = await CategoryDao.queryAll();
  }

  private sortLabels(): string[] {
    const labels: string[] = [];
    for (let i = 0; i < SORT_OPTIONS.length; i++) {
      labels.push(SORT_OPTIONS[i].label);
    }
    return labels;
  }

  private sortIndex(): number {
    for (let i = 0; i < SORT_OPTIONS.length; i++) {
      if (SORT_OPTIONS[i].key === this.sortMode) {
        return i;
      }
    }
    return 0;
  }

  private onViewMode(index: number): void {
    this.viewMode = index === 0 ? 'grid' : 'list';
    Prefs.putString('viewMode', this.viewMode);
  }

  private onSortMode(index: number): void {
    this.sortMode = SORT_OPTIONS[index].key;
    Prefs.putString('sortMode', this.sortMode);
  }

  private onShowAcquired(isOn: boolean): void {
    this.showAcquired = isOn;
    Prefs.putBoolean('showAcquired', isOn);
  }

  private async addCategory(): Promise<void> {
    const name: string = this.newCategoryName.trim();
    if (name.length === 0) {
      promptAction.showToast({ message: '请输入品类名称' });
      return;
    }
    for (let i = 0; i < this.categories.length; i++) {
      if (this.categories[i].name === name) {
        promptAction.showToast({ message: '品类已存在' });
        return;
      }
    }
    try {
      const category = new Category();
      category.key = 'custom_' + Date.now().toString();
      category.name = name;
      category.icon = '✦';
      category.sortOrder = 100 + this.categories.length;
      category.custom = true;
      await CategoryDao.insert(category);
      this.newCategoryName = '';
      await this.loadCategories();
      promptAction.showToast({ message: '已添加品类' });
    } catch (err) {
      promptAction.showToast({ message: '添加失败' });
    }
  }

  private removeCategory(category: Category): void {
    promptAction.showDialog({
      title: '删除品类',
      message: '确定删除「' + category.name + '」吗？已使用该品类的藏品不会被删除，但会显示为其他。',
      buttons: [
        { text: '取消', color: '#8A8175' },
        { text: '删除', color: C_DANGER }
      ]
    }).then(async (res) => {
      if (res.index !== 1) {
        return;
      }
      try {
        await CategoryDao.removeCustom(category.key);
        await this.loadCategories();
      } catch (err) {
        promptAction.showToast({ message: '删除失败' });
      }
    });
  }

  private async exportData(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const result: ExportResult = await BackupService.exportJson(context);
      if (result.ok) {
        this.exportedPath = result.path;
        promptAction.showToast({ message: '已导出到沙箱 export 目录' });
      } else {
        promptAction.showToast({ message: result.message });
      }
    } catch (err) {
      promptAction.showToast({ message: '导出失败' });
    }
  }

  private clearAll(): void {
    promptAction.showDialog({
      title: '清空数据',
      message: '将删除全部藏品与心愿（品类保留），此操作不可撤销。建议先导出备份。',
      buttons: [
        { text: '取消', color: '#8A8175' },
        { text: '清空', color: C_DANGER }
      ]
    }).then(async (res) => {
      if (res.index !== 1) {
        return;
      }
      const ok: boolean = await BackupService.clearData();
      if (ok) {
        bumpRefresh();
        promptAction.showToast({ message: '已清空' });
      } else {
        promptAction.showToast({ message: '清空失败' });
      }
    });
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(C_SUB)
      .width('100%')
      .margin({ left: 4, bottom: 8 })
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('设置')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(C_TEXT)
          Text('偏好与数据管理')
            .fontSize(12)
            .fontColor(C_SUB)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 10 })

      Scroll() {
        Column({ space: 18 }) {
          // 显示偏好
          Column({ space: 14 }) {
            this.SectionTitle('显示偏好')

            Column({ space: 8 }) {
              Text('列表展示方式')
                .fontSize(14)
                .fontColor(C_TEXT)
                .width('100%')
              SegmentBar({
                options: ['网格', '列表'],
                selectedIndex: this.viewMode === 'grid' ? 0 : 1,
                onChange: (index: number) => this.onViewMode(index)
              })
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('默认排序')
                .fontSize(14)
                .fontColor(C_TEXT)
                .width('100%')
              SegmentBar({
                options: this.sortLabels(),
                selectedIndex: this.sortIndex(),
                onChange: (index: number) => this.onSortMode(index)
              })
            }
            .width('100%')

            Row() {
              Column() {
                Text('心愿单显示已入手')
                  .fontSize(14)
                  .fontColor(C_TEXT)
                Text('在心愿列表中包含已入手的记录')
                  .fontSize(11)
                  .fontColor(C_SUB)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.showAcquired })
                .selectedColor(C_SUCCESS)
                .onChange((value: boolean) => this.onShowAcquired(value))
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(C_CARD)
          .borderRadius(18)
          .border({ width: 1, color: C_LINE })

          // 品类管理
          Column() {
            this.SectionTitle('品类管理')

            Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
              ForEach(this.categories, (category: Category) => {
                Row() {
                  Text(category.icon)
                    .fontSize(12)
                    .fontColor(categoryColor(category.key))
                    .margin({ right: 4 })
                  Text(category.name)
                    .fontSize(12)
                    .fontColor(C_TEXT)
                  if (category.custom) {
                    Text('×')
                      .fontSize(14)
                      .fontColor(C_SUB)
                      .margin({ left: 6 })
                      .onClick(() => this.removeCategory(category))
                  }
                }
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .borderRadius(14)
                .backgroundColor(C_BG)
                .border({ width: 1, color: C_LINE })
              }, (category: Category) => category.key)
            }
            .width('100%')

            Row() {
              TextInput({ text: this.newCategoryName, placeholder: '新增自定义品类' })
                .layoutWeight(1)
                .height(40)
                .fontSize(14)
                .backgroundColor(C_BG)
                .borderRadius(10)
                .onChange((value: string) => this.newCategoryName = value)
                .onSubmit(() => { this.addCategory(); })
              Button('添加')
                .fontSize(14)
                .fontColor(0xFFFFFF)
                .backgroundColor(C_BRAND)
                .height(40)
                .borderRadius(10)
                .margin({ left: 8 })
                .padding({ left: 16, right: 16 })
                .onClick(() => { this.addCategory(); })
            }
            .width('100%')
            .margin({ top: 6 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(C_CARD)
          .borderRadius(18)
          .border({ width: 1, color: C_LINE })

          // 数据管理
          Column({ space: 10 }) {
            this.SectionTitle('数据管理')

            Row() {
              Column() {
                Text('导出为 JSON')
                  .fontSize(14)
                  .fontColor(C_TEXT)
                Text('保存到沙箱 filesDir/export/，含全部字段')
                  .fontSize(11)
                  .fontColor(C_SUB)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text('导出')
                .fontSize(13)
                .fontColor(0xFFFFFF)
                .backgroundColor(C_BRAND)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(16)
                .onClick(() => { this.exportData(); })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            if (this.exportedPath.length > 0) {
              Text('最近导出：' + this.exportedPath)
                .fontSize(10)
                .fontColor(C_SUB)
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }

            Divider().color(C_LINE)

            Row() {
              Column() {
                Text('清空全部数据')
                  .fontSize(14)
                  .fontColor(C_DANGER)
                Text('删除藏品与心愿，品类保留')
                  .fontSize(11)
                  .fontColor(C_SUB)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Text('清空')
                .fontSize(13)
                .fontColor(C_DANGER)
                .backgroundColor('#1AB34A3C')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .borderRadius(16)
                .onClick(() => this.clearAll())
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(C_CARD)
          .borderRadius(18)
          .border({ width: 1, color: C_LINE })

          // 关于
          Column({ space: 8 }) {
            this.SectionTitle('关于')
            Text('藏集阁 HarmonyCollect')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(C_TEXT)
              .width('100%')
            Text('版本 ' + APP_VERSION)
              .fontSize(12)
              .fontColor(C_SUB)
              .width('100%')
            Text('本应用不联网、不上传、无账号、无广告。全部藏品、心愿与图片仅保存在本机应用沙箱内，卸载即清除。')
              .fontSize(12)
              .fontColor(C_SUB)
              .lineHeight(19)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(C_CARD)
          .borderRadius(18)
          .border({ width: 1, color: C_LINE })

          Column().height(20)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(C_BG)
  }
}
