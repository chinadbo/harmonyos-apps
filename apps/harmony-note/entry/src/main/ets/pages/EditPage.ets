import { EditParam, PreviewParam } from '../model/NoteModel';
import { NoteStore } from '../model/NoteStore';
import { MarkdownToolbar } from '../components/MarkdownToolbar';

@Component
export struct EditPage {
  @Prop param: EditParam;
  pathStack: NavPathStack = new NavPathStack();
  @State title: string = '';
  @State content: string = '';
  @State saveMessage: string = '';
  @State currentNoteId: string = '';
  @State currentIsNew: boolean = true;

  aboutToAppear(): void {
    try {
      this.currentNoteId = this.param.noteId;
      this.currentIsNew = this.param.isNew;
      if (!this.currentIsNew && this.currentNoteId.length > 0) {
        const meta = NoteStore.findNoteMeta(this.currentNoteId);
        if (meta) {
          this.title = meta.title;
        }
        this.content = NoteStore.loadNoteContent(this.currentNoteId);
      }
    } catch (error) {
      console.error('EditPage aboutToAppear failed: ' + JSON.stringify(error));
      this.saveMessage = '加载笔记失败';
    }
  }

  private appendMarkdown(value: string): void {
    if (this.content.length > 0 && !this.content.endsWith('\n')) {
      this.content += '\n';
    }
    this.content += value + '\n';
  }

  private saveNote(): void {
    try {
      const note = NoteStore.saveNote(
        this.currentNoteId,
        this.param.notebookId,
        this.title,
        this.content,
        this.currentIsNew
      );
      this.currentNoteId = note.id;
      this.currentIsNew = false;
      this.saveMessage = '保存成功';
    } catch (error) {
      console.error('Failed to save note in EditPage: ' + JSON.stringify(error));
      this.saveMessage = '保存失败';
    }
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Button('返回')
          .type(ButtonType.Capsule)
          .backgroundColor('#E5E7EB')
          .fontColor('#374151')
          .onClick(() => {
            this.pathStack.pop();
          })

        Text(this.currentIsNew ? '新建笔记' : '编辑笔记')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })

        Blank()

        Button('预览')
          .type(ButtonType.Capsule)
          .backgroundColor('#EEF2FF')
          .fontColor('#1D4ED8')
          .onClick(() => {
            this.pathStack.pushPath({
              name: 'PreviewPage',
              param: {
                noteId: this.currentNoteId,
                title: this.title.length > 0 ? this.title : '未命名笔记',
                content: this.content
              } as PreviewParam
            });
          })

        Button('保存')
          .type(ButtonType.Capsule)
          .backgroundColor('#16A34A')
          .fontColor('#FFFFFF')
          .margin({ left: 8 })
          .onClick(() => {
            this.saveNote();
          })
      }
      .width('100%')

      if (this.saveMessage.length > 0) {
        Text(this.saveMessage)
          .fontSize(13)
          .fontColor(this.saveMessage === '保存成功' ? '#166534' : '#B91C1C')
          .padding(10)
          .width('100%')
          .backgroundColor(this.saveMessage === '保存成功' ? '#DCFCE7' : '#FEE2E2')
          .borderRadius(10)
      }

      TextInput({ placeholder: '请输入笔记标题', text: this.title })
        .onChange((value: string) => {
          this.title = value;
        })
        .height(54)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .fontSize(18)

      MarkdownToolbar({
        onInsert: (value: string) => {
          this.appendMarkdown(value);
        }
      })

      TextArea({ placeholder: '在这里输入 Markdown 内容...', text: this.content })
        .onChange((value: string) => {
          this.content = value;
        })
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#FFFFFF')
        .fontSize(16)
        .borderRadius(16)
        .padding(16)
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
