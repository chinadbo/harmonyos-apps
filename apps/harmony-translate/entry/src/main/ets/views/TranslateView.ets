import { LanguageSelector } from '../components/LanguageSelector';
import { TranslateResultCard } from '../components/TranslateResultCard';
import { TranslateService } from '../service/TranslateService';
import { DatabaseService } from '../service/DatabaseService';
import { ClipboardService } from '../service/ClipboardService';
import { TranslateRecord } from '../model/TranslateRecord';
import { promptAction } from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';

@Component
export struct TranslateView {
  @State sourceText: string = '';
  @State resultText: string = '';
  @State sourceLang: string = 'zh';
  @State targetLang: string = 'en';
  @State isTranslating: boolean = false;
  @State isResultVisible: boolean = false;
  @State isFavorite: boolean = false;
  @State currentRecordId: number = -1;
  @StorageLink('clipboard_text') clipboardText: string = '';

  private translateService: TranslateService = new TranslateService();
  private clipboardService: ClipboardService = new ClipboardService();
  private dbService: DatabaseService | null = null;

  aboutToAppear(): void {
    this.translateService.loadDictionary(getContext(this) as Context);
    this.clipboardService.startListening((text: string) => {
      this.clipboardText = text;
    });
  }

  aboutToDisappear(): void {
    this.clipboardService.stopListening();
  }

  build() {
    Scroll() {
      Column() {
        // Clipboard tip
        if (this.clipboardText.length > 0) {
          Row() {
            Text(`📋 剪贴板: ${this.clipboardText.substring(0, 30)}${this.clipboardText.length > 30 ? '...' : ''}`)
              .fontSize(13)
              .fontColor('#4A90D9')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            Text('使用')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor('#4A90D9')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .onClick(() => {
                this.sourceText = this.clipboardText;
                this.clipboardText = '';
              })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#E8F4FD')
          .borderRadius(8)
          .margin({ bottom: 12 })
        }

        // Language selectors
        Row() {
          LanguageSelector({
            selectedCode: this.sourceLang,
            label: '源语言',
            onSelect: (code: string) => this.sourceLang = code
          })

          Text('⇄')
            .fontSize(24)
            .fontColor('#4A90D9')
            .onClick(() => {
              const temp = this.sourceLang;
              this.sourceLang = this.targetLang;
              this.targetLang = temp;
            })

          LanguageSelector({
            selectedCode: this.targetLang,
            label: '目标语言',
            onSelect: (code: string) => this.targetLang = code
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 })

        // Input area
        TextArea({ placeholder: '请输入要翻译的文本' })
          .placeholderColor('#999999')
          .fontSize(16)
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding(12)
          .margin({ bottom: 16 })
          .onChange((value: string) => {
            this.sourceText = value;
          })

        // Translate button
        Button('翻 译', { type: ButtonType.Capsule })
          .width('100%')
          .height(48)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A90D9')
          .enabled(!this.isTranslating)
          .onClick(() => this.doTranslate())
          .margin({ bottom: 16 })

        // Result card
        TranslateResultCard({
          result: this.resultText,
          isVisible: this.isResultVisible,
          isFavorite: this.isFavorite,
          onCopy: () => this.copyResult(),
          onShare: () => this.shareResult(),
          onFavorite: () => this.toggleFavorite()
        })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  private async doTranslate(): Promise<void> {
    if (!this.sourceText.trim()) {
      promptAction.showToast({ message: '请输入要翻译的文本' });
      return;
    }
    this.isTranslating = true;
    this.isResultVisible = false;
    try {
      const result = await this.translateService.translate(this.sourceText, this.sourceLang, this.targetLang);
      this.resultText = result;
      this.isResultVisible = true;
      this.isFavorite = false;
      this.currentRecordId = -1;
      // Save to history
      const record = new TranslateRecord(this.sourceText, result, this.sourceLang, this.targetLang);
      await this.saveRecord(record);
    } catch (e) {
      promptAction.showToast({ message: '翻译失败，请检查网络' });
    } finally {
      this.isTranslating = false;
    }
  }

  private async saveRecord(record: TranslateRecord): Promise<void> {
    const context = getContext(this) as Context;
    const db = new DatabaseService(context);
    await db.init();
    const id = await db.insert(record);
    this.currentRecordId = id;
    db.close();
  }

  private async copyResult(): Promise<void> {
    if (!this.resultText) return;
    const service = new ClipboardService();
    await service.copyToClipboard(this.resultText);
    promptAction.showToast({ message: '已复制到剪贴板' });
  }

  private async shareResult(): Promise<void> {
    if (!this.resultText) return;
    const want = {
      action: 'ohos.want.action.sendData',
      type: 'text/plain',
      parameters: {
        'ohos.extra.param.key.content': `原文：${this.sourceText}\n译文：${this.resultText}`
      }
    };
    try {
      const context = getContext(this) as Context;
      await context.startAbility(want);
    } catch (e) {
      console.error('Share failed:', e);
    }
  }

  private async toggleFavorite(): Promise<void> {
    if (this.currentRecordId < 0) return;
    this.isFavorite = !this.isFavorite;
    const context = getContext(this) as Context;
    const db = new DatabaseService(context);
    await db.init();
    await db.updateFavorite(this.currentRecordId, this.isFavorite);
    db.close();
    promptAction.showToast({ message: this.isFavorite ? '已收藏' : '已取消收藏' });
  }
}
