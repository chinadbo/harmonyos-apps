/**
 * AddMoviePage：快速添加。
 * 上半部：种子库网格（多选，一键批量加入片单）；
 * 下半部：自定义表单（片名/类型/状态/评分/集数/备注）。
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BusinessError } from '@ohos.base';
import {
  MovieItem,
  CineCategory,
  CineStatus,
  categoryLabel,
  categoryList,
  statusLabel,
  statusList
} from '../model/Movie';
import { dbReady } from '../data/DbService';
import { insertMovies, insertMovie } from '../data/MovieRepository';
import { SEED_MOVIES, SeedEntry, buildSeedMovie } from '../data/SeedData';
import { RatingStars } from '../components/RatingStars';

@Entry
@Component
struct AddMoviePage {
  @State selectedTitles: Set<string> = new Set<string>();
  @State customTitle: string = '';
  @State customCategory: string = CineCategory.TV;
  @State customStatus: string = CineStatus.WISH;
  @State customRating: number = 0;
  @State customEpisodes: string = '';
  @State customComment: string = '';
  @State submitting: boolean = false;

  private toggleSeed(entry: SeedEntry): void {
    const next = new Set<string>(this.selectedTitles);
    if (next.has(entry.title)) {
      next.delete(entry.title);
    } else {
      next.add(entry.title);
    }
    this.selectedTitles = next;
  }

  private selectedSeeds(): SeedEntry[] {
    const result: SeedEntry[] = [];
    for (const seed of SEED_MOVIES) {
      if (this.selectedTitles.has(seed.title)) {
        result.push(seed);
      }
    }
    return result;
  }

  private async addSelectedSeeds(): Promise<void> {
    if (this.selectedTitles.size === 0 || this.submitting) {
      return;
    }
    this.submitting = true;
    try {
      const now = Date.now();
      const movies: MovieItem[] = [];
      const seeds = this.selectedSeeds();
      for (const seed of seeds) {
        movies.push(buildSeedMovie(seed, now));
      }
      const inserted = await insertMovies(movies);
      promptAction.showToast({ message: `已添加 ${inserted} 部到片单`, duration: 1500 });
      router.back();
    } catch (err) {
      const e = err as BusinessError;
      promptAction.showToast({ message: `添加失败: ${e.message}`, duration: 2000 });
      this.submitting = false;
    }
  }

  private buildCustomMovie(): MovieItem {
    return {
      id: 0,
      title: this.customTitle.trim(),
      category: this.customCategory,
      status: this.customStatus,
      rating: this.customStatus === CineStatus.WATCHED ? this.customRating : 0,
      progress: 0,
      totalEpisodes: Number.parseInt(this.customEpisodes, 10) || 0,
      comment: this.customComment.trim(),
      createdTime: Date.now(),
      updatedTime: Date.now()
    };
  }

  private async addCustomMovie(): Promise<void> {
    const title = this.customTitle.trim();
    if (title.length === 0) {
      promptAction.showToast({ message: '请先填写片名', duration: 1500 });
      return;
    }
    if (this.submitting) {
      return;
    }
    this.submitting = true;
    try {
      const rowId = await insertMovie(this.buildCustomMovie());
      if (rowId > 0) {
        promptAction.showToast({ message: `已添加「${title}」`, duration: 1500 });
        router.back();
      } else {
        promptAction.showToast({ message: '添加失败，请重试', duration: 2000 });
        this.submitting = false;
      }
    } catch (err) {
      const e = err as BusinessError;
      promptAction.showToast({ message: `添加失败: ${e.message}`, duration: 2000 });
      this.submitting = false;
    }
  }

  async aboutToAppear(): Promise<void> {
    await dbReady();
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#22242E')
          .padding({ left: 4, right: 12 })
          .onClick(() => {
            router.back();
          })
        Text('添加影视')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#22242E')
          .layoutWeight(1)
        if (this.selectedTitles.size > 0) {
          Text(`加入所选 (${this.selectedTitles.size})`)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#3D5AFE')
            .borderRadius(14)
            .margin({ right: 16 })
            .onClick(() => {
              this.addSelectedSeeds();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, top: 14, bottom: 10 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          // 种子库
          Column({ space: 10 }) {
            Text('热门推荐（可多选批量加入）')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#444652')
              .width('100%')
            Grid() {
              ForEach(SEED_MOVIES, (seed: SeedEntry) => {
                GridItem() {
                  Column({ space: 4 }) {
                    Text(seed.title)
                      .fontSize(13)
                      .fontColor(this.selectedTitles.has(seed.title) ? '#FFFFFF' : '#22242E')
                      .fontWeight(FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(`${categoryLabel(seed.category)} · ${statusLabel(seed.status)}`)
                      .fontSize(10)
                      .fontColor(this.selectedTitles.has(seed.title) ? '#E9EDFF' : '#8A8F9E')
                  }
                  .width('100%')
                  .padding({ left: 10, right: 10, top: 10, bottom: 10 })
                  .backgroundColor(this.selectedTitles.has(seed.title) ? '#3D5AFE' : '#FFFFFF')
                  .borderRadius(12)
                  .onClick(() => {
                    this.toggleSeed(seed);
                  })
                }
              }, (seed: SeedEntry) => `${seed.title}_${this.selectedTitles.has(seed.title) ? 1 : 0}`)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(8)
            .rowsGap(8)
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 4, bottom: 16 })

          // 自定义表单
          Column({ space: 14 }) {
            Text('自定义添加')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#444652')
              .width('100%')

            TextInput({ placeholder: '片名' })
              .fontSize(14)
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .onChange((value: string) => {
                this.customTitle = value;
              })

            Row({ space: 8 }) {
              Text('类型')
                .fontSize(13)
                .fontColor('#666A78')
                .width(52)
              ForEach(categoryList(), (category: string) => {
                Text(categoryLabel(category))
                  .fontSize(13)
                  .fontColor(this.customCategory === category ? '#FFFFFF' : '#666A78')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.customCategory === category ? '#3D5AFE' : '#FFFFFF')
                  .borderRadius(14)
                  .onClick(() => {
                    this.customCategory = category;
                  })
              }, (category: string) => category)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Row({ space: 8 }) {
              Text('状态')
                .fontSize(13)
                .fontColor('#666A78')
                .width(52)
              ForEach(statusList(), (status: string) => {
                Text(statusLabel(status))
                  .fontSize(13)
                  .fontColor(this.customStatus === status ? '#FFFFFF' : '#666A78')
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.customStatus === status ? '#3D5AFE' : '#FFFFFF')
                  .borderRadius(14)
                  .onClick(() => {
                    this.customStatus = status;
                  })
              }, (status: string) => status)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Row({ space: 8 }) {
              Text('评分')
                .fontSize(13)
                .fontColor('#666A78')
                .width(52)
              RatingStars({
                rating: this.customRating,
                editable: true,
                starSize: 20
              })
                .onRatingChange((value: number) => {
                  this.customRating = value;
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            Row({ space: 8 }) {
              Text('总集数')
                .fontSize(13)
                .fontColor('#666A78')
              TextInput({ placeholder: '电影可不填' })
                .layoutWeight(1)
                .fontSize(14)
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.customEpisodes = value;
                })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            TextInput({ placeholder: '备注/一句短评（选填）' })
              .fontSize(14)
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .onChange((value: string) => {
                this.customComment = value;
              })

            Button('添加到片单')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor('#3D5AFE')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .margin({ top: 4, bottom: 24 })
              .enabled(!this.submitting)
              .onClick(() => {
                this.addCustomMovie();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F4F8')
  }
}
