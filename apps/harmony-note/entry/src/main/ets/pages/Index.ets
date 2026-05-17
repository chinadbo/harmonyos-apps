import { Notebook, NoteIndexItem, NoteListParam, EditParam, PreviewParam } from '../model/NoteModel';
import { NoteStore } from '../model/NoteStore';
import { NotebookCard } from '../components/NotebookCard';
import { NoteCard } from '../components/NoteCard';
import { EmptyView } from '../components/EmptyView';
import { NoteListPage } from './NoteListPage';
import { EditPage } from './EditPage';
import { PreviewPage } from './PreviewPage';
import { SearchPage } from './SearchPage';

@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack();
  @StorageLink('notebooks') notebooks: Notebook[] = [];
  @StorageLink('notes') notes: NoteIndexItem[] = [];
  @StorageLink('selectedNotebookId') selectedNotebookId: string = '';
  @StorageLink('lastError') lastError: string = '';
  @StorageLink('homeRefreshFlag') homeRefreshFlag: number = 0;
  @State createSheet: boolean = false;
  @State notebookName: string = '';
  @State notebookDesc: string = '';

  aboutToAppear(): void {
    try {
      NoteStore.reload();
      if (this.notebooks.length === 0) {
        const notebook = NoteStore.ensureDefaultNotebook();
        this.selectedNotebookId = notebook.id;
      }
    } catch (error) {
      console.error('Index aboutToAppear failed: ' + JSON.stringify(error));
    }
  }

  @Builder
  pageMap(name: string, param: object) {
    if (name === 'NoteListPage') {
      NavDestination() {
        NoteListPage({ param: param as NoteListParam, pathStack: this.pathStack })
      }
    } else if (name === 'EditPage') {
      NavDestination() {
        EditPage({ param: param as EditParam, pathStack: this.pathStack })
      }
    } else if (name === 'PreviewPage') {
      NavDestination() {
        PreviewPage({ param: param as PreviewParam })
      }
    } else if (name === 'SearchPage') {
      NavDestination() {
        SearchPage({ pathStack: this.pathStack })
      }
    }
  }

  private getSelectedNotebook(): Notebook | null {
    const target = this.notebooks.find((item: Notebook) => item.id === this.selectedNotebookId);
    return target ? target : null;
  }

  private getRecentNotes(): NoteIndexItem[] {
    return [...this.notes].sort((a: NoteIndexItem, b: NoteIndexItem) => b.updatedAt - a.updatedAt).slice(0, 5);
  }

  private openNoteList(notebook: Notebook): void {
    this.selectedNotebookId = notebook.id;
    this.pathStack.pushPath({
      name: 'NoteListPage',
      param: {
        notebookId: notebook.id,
        title: notebook.name
      } as NoteListParam
    });
  }

  private openCreateNote(): void {
    const notebook = this.getSelectedNotebook() || NoteStore.ensureDefaultNotebook();
    this.pathStack.pushPath({
      name: 'EditPage',
      param: {
        noteId: '',
        notebookId: notebook.id,
        isNew: true
      } as EditParam
    });
  }

  private createNotebook(): void {
    try {
      const notebook = NoteStore.createNotebook(this.notebookName, this.notebookDesc);
      this.selectedNotebookId = notebook.id;
      this.notebookName = '';
      this.notebookDesc = '';
      this.createSheet = false;
    } catch (error) {
      console.error('Failed to create notebook from Index: ' + JSON.stringify(error));
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 6 }) {
            Text('HarmonyNote')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
            Text('鸿蒙原生 Markdown 笔记应用')
              .fontSize(14)
              .fontColor('#64748B')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Button('搜索')
            .type(ButtonType.Capsule)
            .backgroundColor('#EEF2FF')
            .fontColor('#1D4ED8')
            .onClick(() => {
              this.pathStack.pushPath({ name: 'SearchPage' });
            })
        }
        .width('100%')

        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text(String(this.notebooks.length))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')
            Text('笔记本')
              .fontSize(13)
              .fontColor('#6B7280')
          }
          .layoutWeight(1)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)

          Column({ space: 6 }) {
            Text(String(this.notes.length))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')
            Text('笔记总数')
              .fontSize(13)
              .fontColor('#6B7280')
          }
          .layoutWeight(1)
          .height(88)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .width('100%')

        if (this.lastError.length > 0) {
          Row() {
            Text(this.lastError)
              .fontSize(13)
              .fontColor('#B91C1C')
              .layoutWeight(1)
            Button('关闭')
              .type(ButtonType.Capsule)
              .fontSize(12)
              .backgroundColor('#FEE2E2')
              .fontColor('#B91C1C')
              .onClick(() => {
                NoteStore.clearError();
                this.lastError = '';
              })
          }
          .padding(12)
          .width('100%')
          .backgroundColor('#FEF2F2')
          .borderRadius(12)
        }

        Row() {
          Text('笔记本')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Blank()
          Button('新建分类')
            .type(ButtonType.Capsule)
            .backgroundColor('#2563EB')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.createSheet = true;
            })
        }
        .width('100%')

        if (this.notebooks.length === 0) {
          EmptyView({
            title: '还没有笔记本',
            description: '先创建一个分类，再开始记录 Markdown 笔记。',
            buttonText: '创建默认分类',
            onAction: () => {
              const notebook = NoteStore.ensureDefaultNotebook();
              this.selectedNotebookId = notebook.id;
            }
          })
        } else {
          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.notebooks, (notebook: Notebook) => {
                Column() {
                  NotebookCard({
                    notebook: notebook,
                    selected: notebook.id === this.selectedNotebookId,
                    onClick: (item: Notebook) => {
                      this.openNoteList(item);
                    }
                  })
                }
                .width(260)
              }, (notebook: Notebook) => notebook.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

        Row() {
          Text('最近笔记')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Blank()
          Button('新建笔记')
            .type(ButtonType.Capsule)
            .backgroundColor('#16A34A')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.openCreateNote();
            })
        }
        .width('100%')

        if (this.getRecentNotes().length === 0) {
          EmptyView({
            title: '暂无笔记',
            description: '创建第一篇笔记后，这里会显示最近更新内容。',
            buttonText: '立即创建',
            onAction: () => {
              this.openCreateNote();
            }
          })
        } else {
          Column({ space: 12 }) {
            ForEach(this.getRecentNotes(), (note: NoteIndexItem) => {
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
                }
              })
            }, (note: NoteIndexItem) => note.id)
          }
          .width('100%')
        }
      }
      .padding(20)
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F8FB')
      .bindSheet($$this.createSheet, this.createNotebookSheet(), {
        height: 360,
        showClose: true
      })
    }
    .navDestination(this.pageMap)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }

  @Builder
  private createNotebookSheet() {
    Column({ space: 16 }) {
      Text('创建笔记本')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '请输入笔记本名称', text: this.notebookName })
        .onChange((value: string) => {
          this.notebookName = value;
        })
        .width('100%')
        .height(52)
        .backgroundColor('#F8FAFC')

      TextArea({ placeholder: '请输入分类描述（可选）', text: this.notebookDesc })
        .onChange((value: string) => {
          this.notebookDesc = value;
        })
        .width('100%')
        .height(120)
        .backgroundColor('#F8FAFC')

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor('#E5E7EB')
          .fontColor('#374151')
          .onClick(() => {
            this.createSheet = false;
          })
        Button('创建')
          .layoutWeight(1)
          .backgroundColor('#2563EB')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.createNotebook();
          })
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
  }
}
