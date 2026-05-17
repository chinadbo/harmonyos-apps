import { EditParam, NoteIndexItem, PreviewParam, SearchResult } from '../model/NoteModel';
import { NoteStore } from '../model/NoteStore';
import { NoteCard } from '../components/NoteCard';
import { EmptyView } from '../components/EmptyView';

@Component
export struct SearchPage {
  pathStack: NavPathStack = new NavPathStack();
  @StorageLink('searchKeyword') searchKeyword: string = '';
  @StorageLink('searchResult') searchResult: SearchResult = { keyword: '', items: [] };
  @State keyword: string = '';

  aboutToAppear(): void {
    this.keyword = this.searchKeyword;
  }

  private runSearch(): void {
    try {
      NoteStore.search(this.keyword);
    } catch (error) {
      console.error('Failed to search in SearchPage: ' + JSON.stringify(error));
    }
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .backgroundColor('#E5E7EB')
          .fontColor('#374151')
          .onClick(() => {
            this.pathStack.pop();
          })

        Text('搜索笔记')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')

      Row({ space: 10 }) {
        TextInput({ placeholder: '输入标题或摘要关键字', text: this.keyword })
          .layoutWeight(1)
          .height(52)
          .backgroundColor('#FFFFFF')
          .onChange((value: string) => {
            this.keyword = value;
          })
        Button('搜索')
          .backgroundColor('#2563EB')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.runSearch();
          })
      }
      .width('100%')

      if (this.searchResult.keyword.length > 0) {
        Text(`关键字 “${this.searchResult.keyword}” 共找到 ${this.searchResult.items.length} 条结果`)
          .fontSize(13)
          .fontColor('#6B7280')
          .width('100%')
      }

      if (this.searchResult.items.length === 0) {
        EmptyView({
          title: this.searchResult.keyword.length > 0 ? '没有搜索到匹配内容' : '开始搜索你的笔记',
          description: this.searchResult.keyword.length > 0 ? '试试更换关键字，或检查标题与摘要内容。' : '支持按标题与摘要进行全文入口级搜索。'
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.searchResult.items, (note: NoteIndexItem) => {
            ListItem() {
              NoteCard({
                note: note,
                notebookName: NoteStore.getNotebookById(note.notebookId)?.name || '',
                onClick: (item: NoteIndexItem) => {
                  this.pathStack.pushPath({
                    name: 'PreviewPage',
                    param: {
                      noteId: item.id,
                      title: item.title
                    } as PreviewParam
                  });
                },
                onDelete: (item: NoteIndexItem) => {
                  NoteStore.deleteNote(item.id);
                  this.runSearch();
                }
              })
            }
          }, (note: NoteIndexItem) => note.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }

      if (this.searchResult.items.length > 0) {
        Button('创建新笔记')
          .width('100%')
          .backgroundColor('#16A34A')
          .fontColor('#FFFFFF')
          .onClick(() => {
            const notebook = NoteStore.ensureDefaultNotebook();
            this.pathStack.pushPath({
              name: 'EditPage',
              param: {
                noteId: '',
                notebookId: notebook.id,
                isNew: true
              } as EditParam
            });
          })
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
