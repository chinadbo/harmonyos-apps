import web_webview from '@ohos.web.webview';
import { PreviewParam } from '../model/NoteModel';
import { NoteStore } from '../model/NoteStore';

@Component
export struct PreviewPage {
  @Prop param: PreviewParam;
  @State markdownContent: string = '';
  private controller: web_webview.WebviewController = new web_webview.WebviewController();
  private webLoaded: boolean = false;

  aboutToAppear(): void {
    try {
      let content = this.param.content;
      if ((!content || content.length === 0) && this.param.noteId.length > 0) {
        content = NoteStore.loadNoteContent(this.param.noteId);
      }
      this.markdownContent = content || '';
    } catch (error) {
      console.error('PreviewPage aboutToAppear failed: ' + JSON.stringify(error));
      this.markdownContent = '# 预览失败\n\n无法加载当前笔记内容。';
    }
  }

  private loadContent(): void {
    try {
      const html = this.buildHtml(this.markdownContent);
      this.controller.loadData(html, 'text/html', 'UTF-8', '', '');
    } catch (error) {
      console.error('PreviewPage loadContent failed: ' + JSON.stringify(error));
    }
  }

  private buildHtml(content: string): string {
    const escaped = content
      .replace(/\\/g, '\\\\')
      .replace(/`/g, '\\`')
      .replace(/\$/g, '\\$');
    return `<!DOCTYPE html><html><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<style>
body{font-family:-apple-system,sans-serif;padding:16px;line-height:1.6;color:#333;max-width:100%;background:#fff}
h1,h2,h3{color:#1a1a2e;margin-top:24px}
code{background:#f0f0f0;padding:2px 6px;border-radius:3px;font-size:0.9em}
pre{background:#f8f8f8;padding:16px;border-radius:6px;overflow-x:auto}
pre code{background:none;padding:0}
blockquote{border-left:4px solid #ddd;margin:0;padding-left:16px;color:#666}
hr{border:none;border-top:1px solid #eee;margin:16px 0}
ul,ol{padding-left:20px}
p{margin:12px 0}
</style></head><body>
<div id="content"></div>
<script src="resource://rawfile/marked.min.js"></script>
<script>
window.onload=function(){
  var text=\`${escaped}\`;
  document.getElementById('content').innerHTML=marked.parse(text);
}
</script></body></html>`;
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.param.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
      }
      .width('100%')

      Web({
        src: '',
        controller: this.controller
      })
        .width('100%')
        .layoutWeight(1)
        .onControllerAttached(() => {
          this.loadContent();
        })
    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F8FB')
  }
}
