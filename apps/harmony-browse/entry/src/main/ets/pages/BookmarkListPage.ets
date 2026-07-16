import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BrowserDatabase } from '../database/BrowserDatabase';
import { Bookmark } from '../model/Bookmark';
import { BookmarkItem } from '../components/BookmarkItem';
import { Constants } from '../utils/Constants';

@Entry
@Component
struct BookmarkListPage {
  @State bookmarks: Bookmark[] = [];
  @State folderName: string = '';

  aboutToAppear() {
    this.loadBookmarks();
  }

  async loadBookmarks() {
    this.bookmarks = await BrowserDatabase.getInstance().queryBookmarks();
  }

  async deleteBookmark(id: number) {
    await BrowserDatabase.getInstance().deleteBookmark(id);
    await this.loadBookmarks();
    promptAction.showToast({ message: '书签已删除' });
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => router.back())

        Text('书签管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('添加')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#2196F3')
          .onClick(() => {
            promptAction.showDialog({
              title: '添加书签',
              message: '请输入网址',
              buttons: [
                { text: '取消', color: '#999999' },
                { text: '确定', color: '#2196F3' }
              ]
            }).then((value) => {
              if (value.index === 1) {
                // 简化处理，实际应弹出输入框
                this.loadBookmarks();
              }
            });
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      Scroll() {
        Column() {
          ForEach(this.bookmarks, (item: Bookmark, index: number) => {
            BookmarkItem({
              bookmark: item,
              onSelect: () => {
                router.back();
                // 需要通过事件传递URL，简化处理
              },
              onDelete: () => this.deleteBookmark(item.id)
            })
          }, (item: Bookmark) => item.id.toString())
        }
        .width('100%')
        .padding(12)
      }
      .layoutWeight(1)

      if (this.bookmarks.length === 0) {
        Text('暂无书签')
          .fontSize(16)
          .fontColor('#999999')
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
