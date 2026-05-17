import { NoteDataSource } from '../model/NoteDataSource';
import { EditParam, NoteIndexItem, NoteListParam, PreviewParam } from '../model/NoteModel';
import { NoteStore } from '../model/NoteStore';
import { NoteCard } from '../components/NoteCard';
import { EmptyView } from '../components/EmptyView';

@Component
export struct NoteListPage {
  @Prop param: NoteListParam;
  pathStack: NavPathStack = new NavPathStack();
  @State dataSource: NoteDataSource = new NoteDataSource();
  @State notes: NoteIndexItem[] = [];

  aboutToAppear(): void {
    this.reload();
  }

  private reload(): void {
    try {
      const items = NoteStore.getNotesByNotebook(this.param.notebookId);
      this.notes = items;
      this.dataSource.replaceAll(items);
    } catch (error) {
      console.error('Failed to load notebook notes: ' + JSON.stringify(error));
      this.notes = [];
      this.dataSource.replaceAll([]);
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

        Column({ space: 4 }) {
          Text(this.param.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
          Text(`${this.notes.length} 篇笔记`)
            .fontSize(13)
            .fontColor('#6B7280')
        }
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Button('新建')
          .type(ButtonType.Capsule)
          .backgroundColor('#2563EB')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.pathStack.pushPath({
              name: 'EditPage',
              param: {
                noteId: '',
                notebookId: this.param.notebookId,
                isNew: true
              } as EditParam
            });
          })
      }
      .width('100%')

      if (this.notes.length === 0) {
        EmptyView({
          title: '这个分类下还没有笔记',
          description: '创建第一篇 Markdown 笔记，开始记录灵感与待办。',
          buttonText: '创建笔记',
          onAction: () => {
            this.pathStack.pushPath({
              name: 'EditPage',
              param: {
                noteId: '',
                notebookId: this.param.notebookId,
                isNew: true
              } as EditParam
            });
          }
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.notes, (note: NoteIndexItem) => {
            ListItem() {
              NoteCard({
                note: note,
                notebookName: this.param.title,
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
                  this.reload();
                }
              })
            }
          }, (note: NoteIndexItem) => note.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
