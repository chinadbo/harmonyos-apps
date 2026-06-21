import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { Poem } from '../model/Poem';
import { PoemService } from '../service/PoemService';
import { FavoriteDao } from '../database/FavoriteDao';
import { HistoryDao } from '../database/HistoryDao';
import { EmptyView } from '../components/EmptyView';

@Entry
@Component
struct DetailPage {
  @State poem: Poem | null = null;
  @State isFavorite: boolean = false;
  @State toastText: string = '';

  aboutToAppear(): void {
    this.loadDetail();
  }

  async loadDetail(): Promise<void> {
    const params = router.getParams() as Record<string, number>;
    const poemId = Number(params.poemId);
    const context = getContext(this) as common.UIAbilityContext;
    const poems = await PoemService.loadPoems(context);
    this.poem = PoemService.getById(poems, poemId);
    if (this.poem) {
      this.isFavorite = await FavoriteDao.isFavorite(context, this.poem.id);
      await HistoryDao.recordView(context, this.poem.id);
    }
  }

  async toggleFavorite(): Promise<void> {
    if (!this.poem) {
      return;
    }
    const context = getContext(this) as common.UIAbilityContext;
    if (this.isFavorite) {
      await FavoriteDao.removeFavorite(context, this.poem.id);
      this.toastText = '已取消收藏';
    } else {
      await FavoriteDao.addFavorite(context, this.poem.id);
      this.toastText = '已加入收藏';
    }
    this.isFavorite = !this.isFavorite;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        if (!this.poem) {
          EmptyView({ title: '诗词不存在', description: '未找到对应的详情数据。' })
        } else {
          Column({ space: 8 }) {
            Text(this.poem.title)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.theme_primary'))
            Text(`${this.poem.dynasty} · ${this.poem.author} · ${this.poem.genre}`)
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: 18, bottom: 8 })

          Row({ space: 12 }) {
            Button(this.isFavorite ? '取消收藏' : '收藏')
              .type(ButtonType.Capsule)
              .backgroundColor($r('app.color.theme_primary'))
              .onClick(() => {
                this.toggleFavorite();
              })
            Button('朗读')
              .type(ButtonType.Capsule)
              .backgroundColor($r('app.color.theme_accent'))
              .fontColor($r('app.color.text_primary'))
              .onClick(() => {
                this.toastText = '朗读功能 UI 已展示，可在此接入 TTS 接口。';
              })
          }

          if (this.toastText.length > 0) {
            Text(this.toastText)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
          }

          Column({ space: 10 }) {
            Text('全文')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
            ForEach(this.poem.content, (line: string) => {
              Text(line)
                .fontSize(18)
                .lineHeight(30)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .textAlign(TextAlign.Center)
            })
          }
          .width('100%')
          .padding(18)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(18)

          Column({ space: 10 }) {
            Text('注释')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
            ForEach(this.poem.annotation, (item: string, index: number) => {
              Text(`${index + 1}. ${item}`)
                .fontSize(15)
                .lineHeight(24)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
            })
          }
          .width('100%')
          .padding(18)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(18)

          Column({ space: 10 }) {
            Text('赏析')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
            Text(this.poem.appreciation)
              .fontSize(16)
              .lineHeight(28)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor($r('app.color.surface'))
          .borderRadius(18)
        }
      }
      .padding(16)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.theme_background'))
  }
}
