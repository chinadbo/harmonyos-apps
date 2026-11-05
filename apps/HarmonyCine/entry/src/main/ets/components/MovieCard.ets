/**
 * MovieCard：海报卡片（离线渐变海报方案）。
 * 渐变色底 + 标题首字 + 类型符号 + 状态角标；色板索引由条目 id 哈希 + 用户偏移决定。
 */
import {
  MovieItem,
  CineStatus,
  categoryLabel,
  categorySymbol,
  categoryColor,
  statusLabel,
  statusColor,
  posterColors
} from '../model/Movie';
import { RatingStars } from './RatingStars';

@Component
export struct MovieCard {
  @Prop movie: MovieItem;
  @StorageLink('posterOffset') posterOffset: number = 0;
  onOpen: (id: number) => void = (id: number) => {
  };

  private firstChar(): string {
    if (this.movie.title.length > 0) {
      return this.movie.title.charAt(0);
    }
    return '影';
  }

  build() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Column({ space: 6 }) {
          Text(this.firstChar())
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(1)
          Text(categorySymbol(this.movie.category))
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.9)
        }
        .width('100%')
        .height(168)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .linearGradient({
          angle: 135,
          colors: posterColors(this.movie.id, this.posterOffset)
        })
        .borderRadius(14)

        Text(statusLabel(this.movie.status))
          .fontSize(11)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(statusColor(this.movie.status))
          .borderRadius(10)
          .margin({ left: 8, bottom: 8 })
      }
      .width('100%')

      Text(this.movie.title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#22242E')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (this.movie.status === CineStatus.WATCHED && this.movie.rating > 0) {
        Row({ space: 4 }) {
          RatingStars({
            rating: this.movie.rating,
            starSize: 12,
            showValue: false
          })
          Text(`${Math.round(this.movie.rating)} 分`)
            .fontSize(11)
            .fontColor('#F5A623')
        }
        .width('100%')
      } else if (this.movie.status === CineStatus.WATCHING && this.movie.totalEpisodes > 0) {
        Text(`第 ${this.movie.progress}/${this.movie.totalEpisodes} 集`)
          .fontSize(11)
          .fontColor('#8A8F9E')
          .width('100%')
      } else {
        Text(categoryLabel(this.movie.category))
          .fontSize(11)
          .fontColor(categoryColor(this.movie.category))
          .width('100%')
      }
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .onClick(() => {
      this.onOpen(this.movie.id);
    })
  }
}
