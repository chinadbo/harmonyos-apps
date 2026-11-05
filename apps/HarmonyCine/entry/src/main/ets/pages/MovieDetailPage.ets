/**
 * MovieDetailPage：条目详情。
 * 展示渐变海报头图、状态三按钮流转（确认弹窗）、评分即时生效、
 * 进度步进、标题/备注编辑保存、删除确认、观看记录时间线。
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import {
  MovieItem,
  WatchRecordItem,
  CineStatus,
  categoryLabel,
  statusLabel,
  statusColor,
  statusList,
  watchActionLabel,
  formatDateTime,
  posterColors,
  emptyMovie
} from '../model/Movie';
import { dbReady } from '../data/DbService';
import {
  getMovieById,
  updateStatus,
  updateRating,
  updateMovieFields,
  deleteMovie,
  getWatchRecords,
  isSeriesLike
} from '../data/MovieRepository';
import { RatingStars } from '../components/RatingStars';

const FEEDBACK_TIMEOUT_MS: number = 2000;

@Entry
@Component
struct MovieDetailPage {
  @State movie: MovieItem = emptyMovie();
  @State records: WatchRecordItem[] = [];
  @State loaded: boolean = false;
  @State editTitle: string = '';
  @State editComment: string = '';
  @State editProgress: number = 0;
  @State editTotalEpisodes: number = 0;
  @State feedback: string = '';
  @StorageLink('posterOffset') posterOffset: number = 0;
  private movieId: number = 0;
  private feedbackTimerId: number = -1;

  private showFeedback(message: string): void {
    this.feedback = message;
    if (this.feedbackTimerId !== -1) {
      clearTimeout(this.feedbackTimerId);
    }
    this.feedbackTimerId = setTimeout(() => {
      this.feedbackTimerId = -1;
      this.feedback = '';
    }, FEEDBACK_TIMEOUT_MS);
  }

  private async loadMovie(): Promise<void> {
    try {
      const movie = await getMovieById(this.movieId);
      if (movie === null) {
        this.loaded = false;
        return;
      }
      this.movie = movie;
      this.editTitle = movie.title;
      this.editComment = movie.comment;
      this.editProgress = movie.progress;
      this.editTotalEpisodes = movie.totalEpisodes;
      this.records = await getWatchRecords(this.movieId);
      this.loaded = true;
    } catch (err) {
      const e = err as BusinessError;
      console.error(`[HarmonyCine] loadMovie failed, code=${e.code} message=${e.message}`);
    }
  }

  private async reload(): Promise<void> {
    await this.loadMovie();
  }

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, number>;
    if (params !== null && params !== undefined) {
      const id = params['id'];
      if (typeof id === 'number') {
        this.movieId = id;
      }
    }
    await dbReady();
    await this.loadMovie();
  }

  aboutToDisappear(): void {
    if (this.feedbackTimerId !== -1) {
      clearTimeout(this.feedbackTimerId);
      this.feedbackTimerId = -1;
    }
  }

  private confirmStatusChange(newStatus: string): void {
    if (this.movie.status === newStatus) {
      return;
    }
    AlertDialog.show({
      title: '状态流转',
      message: `将「${this.movie.title}」标记为「${statusLabel(newStatus)}」？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.applyStatusChange(newStatus);
        }
      }
    });
  }

  private async applyStatusChange(newStatus: string): Promise<void> {
    try {
      await updateStatus(this.movieId, newStatus);
      if (newStatus === CineStatus.WATCHED && this.movie.totalEpisodes > 0) {
        this.editProgress = this.movie.totalEpisodes;
      }
      if (newStatus === CineStatus.WISH) {
        this.editProgress = 0;
      }
      this.showFeedback(`已标记为「${statusLabel(newStatus)}」`);
      await this.reload();
    } catch (err) {
      const e = err as BusinessError;
      this.showFeedback(`操作失败: ${e.message}`);
    }
  }

  private async applyRating(value: number): Promise<void> {
    try {
      await updateRating(this.movieId, value);
      this.showFeedback(value > 0 ? `评分更新为 ${value} 分` : '已清除评分');
      await this.reload();
    } catch (err) {
      const e = err as BusinessError;
      this.showFeedback(`操作失败: ${e.message}`);
    }
  }

  private async saveEdits(): Promise<void> {
    const title = this.editTitle.trim();
    if (title.length === 0) {
      promptAction.showToast({ message: '片名不能为空', duration: 1500 });
      return;
    }
    try {
      const updated: MovieItem = {
        id: this.movie.id,
        title: title,
        category: this.movie.category,
        status: this.movie.status,
        rating: this.movie.rating,
        progress: this.editProgress,
        totalEpisodes: this.editTotalEpisodes,
        comment: this.editComment.trim(),
        createdTime: this.movie.createdTime,
        updatedTime: this.movie.updatedTime
      };
      await updateMovieFields(updated);
      this.showFeedback('已保存');
      await this.reload();
    } catch (err) {
      const e = err as BusinessError;
      this.showFeedback(`保存失败: ${e.message}`);
    }
  }

  private confirmDelete(): void {
    AlertDialog.show({
      title: '删除条目',
      message: `确定删除「${this.movie.title}」吗？该操作不可恢复。`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#D93026',
        action: () => {
          this.applyDelete();
        }
      }
    });
  }

  private async applyDelete(): Promise<void> {
    try {
      await deleteMovie(this.movieId);
      promptAction.showToast({ message: '已删除', duration: 1200 });
      router.back();
    } catch (err) {
      const e = err as BusinessError;
      this.showFeedback(`删除失败: ${e.message}`);
    }
  }

  private stepProgress(delta: number): void {
    const max = this.editTotalEpisodes > 0 ? this.editTotalEpisodes : 9999;
    let next = this.editProgress + delta;
    if (next < 0) {
      next = 0;
    }
    if (next > max) {
      next = max;
    }
    this.editProgress = next;
  }

  build() {
    Column() {
      if (!this.loaded) {
        Column({ space: 10 }) {
          Text('条目不存在或已删除')
            .fontSize(15)
            .fontColor('#8A8F9E')
          Text('返回')
            .fontSize(14)
            .fontColor('#3D5AFE')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('#E9EDFF')
            .borderRadius(18)
            .onClick(() => {
              router.back();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 渐变海报头图
            Stack({ alignContent: Alignment.TopStart }) {
              Column({ space: 8 }) {
                Text(this.movie.title.charAt(0))
                  .fontSize(64)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(categoryLabel(this.movie.category))
                  .fontSize(15)
                  .fontColor('#FFFFFF')
                  .opacity(0.92)
              }
              .width('100%')
              .padding({ top: 46 })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .linearGradient({
                angle: 135,
                colors: posterColors(this.movie.id, this.posterOffset)
              })

              Text('‹')
                .fontSize(26)
                .fontColor('#FFFFFF')
                .margin({ left: 16, top: 14 })
                .onClick(() => {
                  router.back();
                })
            }
            .width('100%')

            Column({ space: 16 }) {
              // 标题 + 状态
              Column({ space: 8 }) {
                Text(this.movie.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#22242E')
                  .width('100%')
                Row({ space: 10 }) {
                  Text(categoryLabel(this.movie.category))
                    .fontSize(12)
                    .fontColor('#666A78')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor('#F0F1F6')
                    .borderRadius(10)
                  Text(statusLabel(this.movie.status))
                    .fontSize(12)
                    .fontColor('#FFFFFF')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor(statusColor(this.movie.status))
                    .borderRadius(10)
                  Text(`更新于 ${formatDateTime(this.movie.updatedTime)}`)
                    .fontSize(12)
                    .fontColor('#8A8F9E')
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .padding({ left: 16, right: 16, top: 14 })

              // 状态流转三按钮
              Row({ space: 8 }) {
                ForEach(statusList(), (status: string) => {
                  Text(statusLabel(status))
                    .fontSize(13)
                    .fontColor(this.movie.status === status ? '#FFFFFF' : '#444652')
                    .fontWeight(this.movie.status === status ? FontWeight.Bold : FontWeight.Normal)
                    .padding({ left: 18, right: 18, top: 9, bottom: 9 })
                    .backgroundColor(this.movie.status === status ? statusColor(status) : '#FFFFFF')
                    .borderRadius(18)
                    .onClick(() => {
                      this.confirmStatusChange(status);
                    })
                }, (status: string) => `${status}_${this.movie.status}`)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)

              if (this.feedback.length > 0) {
                Text(this.feedback)
                  .fontSize(12)
                  .fontColor('#3D5AFE')
              }

              // 评分
              Column({ space: 6 }) {
                Text('我的评分')
                  .fontSize(13)
                  .fontColor('#666A78')
                  .width('100%')
                RatingStars({
                  rating: this.movie.rating,
                  editable: true,
                  starSize: 24
                })
                  .onRatingChange((value: number) => {
                    this.applyRating(value);
                  })
              }
              .padding({ left: 16, right: 16 })
              .width('100%')

              // 编辑区
              Column({ space: 12 }) {
                Text('编辑信息')
                  .fontSize(13)
                  .fontColor('#666A78')
                TextInput({ text: this.editTitle })
                  .fontSize(14)
                  .padding(12)
                  .backgroundColor('#F4F4F8')
                  .borderRadius(12)
                  .onChange((value: string) => {
                    this.editTitle = value;
                  })

                if (isSeriesLike(this.movie)) {
                  Column({ space: 8 }) {
                    Text('观看进度')
                      .fontSize(13)
                      .fontColor('#666A78')
                      .width('100%')
                    Row({ space: 14 }) {
                      Button('−')
                        .fontSize(18)
                        .fontColor('#444652')
                        .width(36)
                        .height(36)
                        .borderRadius(18)
                        .backgroundColor('#F0F1F6')
                        .onClick(() => {
                          this.stepProgress(-1);
                        })
                      Text(this.editTotalEpisodes > 0
                        ? `${this.editProgress} / ${this.editTotalEpisodes} 集`
                        : `第 ${this.editProgress} 集`)
                        .fontSize(15)
                        .fontColor('#22242E')
                      Button('+')
                        .fontSize(18)
                        .fontColor('#444652')
                        .width(36)
                        .height(36)
                        .borderRadius(18)
                        .backgroundColor('#F0F1F6')
                        .onClick(() => {
                          this.stepProgress(1);
                        })
                      Text(`总集数: ${this.editTotalEpisodes}`)
                        .fontSize(12)
                        .fontColor('#8A8F9E')
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .width('100%')

                  Row({ space: 8 }) {
                    Button('总集数 −1')
                      .fontSize(12)
                      .fontColor('#666A78')
                      .height(32)
                      .borderRadius(16)
                      .backgroundColor('#F0F1F6')
                      .onClick(() => {
                        if (this.editTotalEpisodes > 0) {
                          this.editTotalEpisodes -= 1;
                        }
                      })
                    Button('总集数 +1')
                      .fontSize(12)
                      .fontColor('#666A78')
                      .height(32)
                      .borderRadius(16)
                      .backgroundColor('#F0F1F6')
                      .onClick(() => {
                        this.editTotalEpisodes += 1;
                      })
                  }
                  .width('100%')
                }

                TextArea({ text: this.editComment, placeholder: '写一句短评...' })
                  .fontSize(14)
                  .padding(12)
                  .height(80)
                  .backgroundColor('#F4F4F8')
                  .borderRadius(12)
                  .onChange((value: string) => {
                    this.editComment = value;
                  })

                Button('保存修改')
                  .width('100%')
                  .height(42)
                  .borderRadius(21)
                  .backgroundColor('#3D5AFE')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .onClick(() => {
                    this.saveEdits();
                  })
              }
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ left: 16, right: 16 })
              .alignItems(HorizontalAlign.Start)

              // 观看记录
              Column({ space: 10 }) {
                Text('观看记录')
                  .fontSize(13)
                  .fontColor('#666A78')
                if (this.records.length === 0) {
                  Text('暂无记录')
                    .fontSize(13)
                    .fontColor('#8A8F9E')
                } else {
                  ForEach(this.records, (record: WatchRecordItem) => {
                    Row() {
                      Text(watchActionLabel(record.action))
                        .fontSize(13)
                        .fontColor('#444652')
                        .layoutWeight(1)
                      Text(formatDateTime(record.recordTime))
                        .fontSize(12)
                        .fontColor('#8A8F9E')
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                  }, (record: WatchRecordItem) => `record_${record.id}`)
                }
              }
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ left: 16, right: 16 })
              .alignItems(HorizontalAlign.Start)

              // 删除
              Button('删除该条目')
                .width('100%')
                .height(42)
                .borderRadius(21)
                .backgroundColor('#FFFFFF')
                .fontColor('#D93026')
                .fontSize(14)
                .margin({ left: 16, right: 16, bottom: 30 })
                .onClick(() => {
                  this.confirmDelete();
                })
            }
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F4F8')
  }
}
