import util from '@ohos.util';
import { Template, TemplateRecord } from '../model/Template';
import { TemplateItem } from '../components/TemplateItem';
import { EmptyState } from '../components/EmptyState';
import { ShareUtils } from '../utils/ShareUtils';

@Component
struct TemplatePage {
  @State templates: Template[] = [];
  @State keyword: string = '';
  @State previewName: string = '小雨';

  async aboutToAppear(): Promise<void> {
    if (this.templates.length > 0) {
      return;
    }
    let manager = getContext(this).resourceManager;
    let content = await manager.getRawFileContent('templates.json');
    let decoder = util.TextDecoder.create('utf-8');
    let text = decoder.decodeToString(content);
    let array = JSON.parse(text) as Array<{ id: number; content: string; category: string }>;
    this.templates = array.map(item => new TemplateRecord(item));
  }

  private getFilteredTemplates(): Template[] {
    if (!this.keyword.trim()) {
      return this.templates;
    }
    return this.templates.filter((item: Template) => item.content.indexOf(this.keyword) >= 0 || item.category.indexOf(this.keyword) >= 0);
  }

  build() {
    Column({ space: 16 }) {
      Text('祝福模板')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      TextInput({ placeholder: '输入预览姓名', text: this.previewName })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onChange((value: string) => this.previewName = value)

      TextInput({ placeholder: '搜索模板', text: this.keyword })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onChange((value: string) => this.keyword = value)

      if (this.getFilteredTemplates().length === 0) {
        EmptyState({
          title: '没有找到模板',
          description: '换个关键词试试。'
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.getFilteredTemplates(), (item: Template) => {
            ListItem() {
              TemplateItem({
                template: item,
                renderedText: ShareUtils.buildMessage(item.content, this.previewName || '朋友'),
                onCopy: async (text: string) => await ShareUtils.copyText(text),
                onShare: async (text: string) => await ShareUtils.shareText(text)
              })
            }
          }, (item: Template) => `${item.id}`)
        }
        .layoutWeight(1)
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }
}
