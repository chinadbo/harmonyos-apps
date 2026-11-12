import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { CharEntry, CharRepository, CharUtil } from '../model/CharData';
import { CharStat, MasteryUtil } from '../model/PracticeRecord';
import { DbHelper } from '../db/DbHelper';
import { AppTheme } from '../common/Theme';
import { ToastUtil } from '../common/AppUtil';

interface ListParams {
  grade: number;
}

interface DetailParams {
  char: string;
}

@Entry
@Component
struct CharList {
  @State chars: CharEntry[] = [];
  @State filtered: CharEntry[] = [];
  @State grade: number = 1;
  @State difficulty: number = 0;
  @State keyword: string = '';
  @State statMap: Map<string, CharStat> = new Map<string, CharStat>();
  @State loaded: boolean = false;
  private gradeOptions: number[] = [0, 1, 2, 3, 4, 5, 6];
  private difficultyOptions: number[] = [0, 1, 2, 3];

  aboutToAppear(): void {
    const raw: Object = router.getParams();
    if (raw !== undefined && raw !== null) {
      const params: ListParams = raw as ListParams;
      if (params.grade !== undefined && params.grade > 0) {
        this.grade = params.grade;
      }
    }
  }

  onPageShow(): void {
    this.loadData();
  }

  private async loadData(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    this.chars = await CharRepository.getInstance().load(context);
    await DbHelper.getInstance().init(context);
    const stats: CharStat[] = await DbHelper.getInstance().getCharStats();
    const map: Map<string, CharStat> = new Map<string, CharStat>();
    for (let i = 0; i < stats.length; i++) {
      map.set(stats[i].char, stats[i]);
    }
    this.statMap = map;
    this.applyFilter();
    this.loaded = true;
  }

  private applyFilter(): void {
    const result: CharEntry[] = [];
    for (let i = 0; i < this.chars.length; i++) {
      const entry: CharEntry = this.chars[i];
      if (this.grade > 0 && entry.grade !== this.grade) {
        continue;
      }
      const count: number = entry.strokes.length;
      if (this.difficulty === 1 && count > 3) {
        continue;
      }
      if (this.difficulty === 2 && (count < 4 || count > 6)) {
        continue;
      }
      if (this.difficulty === 3 && count < 7) {
        continue;
      }
      if (!CharUtil.matches(entry, this.keyword)) {
        continue;
      }
      result.push(entry);
    }
    this.filtered = result;
  }

  private masteryOf(char: string): number {
    const stat: CharStat | undefined = this.statMap.get(char);
    if (stat === undefined) {
      return 0;
    }
    return MasteryUtil.mastery(stat.bestScore, stat.attempts);
  }

  private statText(char: string): string {
    const stat: CharStat | undefined = this.statMap.get(char);
    if (stat === undefined) {
      return '未练习';
    }
    return `${stat.attempts}次 · 最佳${stat.bestScore}`;
  }

  private openDetail(char: string): void {
    const params: DetailParams = { char: char };
    router.pushUrl({ url: 'pages/CharDetail', params: params }).catch(() => {
      ToastUtil.show('页面打开失败');
    });
  }

  @Builder
  gradeChip(value: number) {
    Text(value === 0 ? '全部' : `${value}年级`)
      .fontSize(12)
      .fontColor(this.grade === value ? '#FFFFFF' : AppTheme.INK_LIGHT)
      .backgroundColor(this.grade === value ? AppTheme.INK : AppTheme.CARD)
      .borderRadius(14)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .onClick(() => {
        this.grade = value;
        this.applyFilter();
      })
  }

  @Builder
  difficultyChip(value: number) {
    Text(value === 0 ? '全部笔画' : (value === 1 ? '1-3画' : (value === 2 ? '4-6画' : '7画以上')))
      .fontSize(12)
      .fontColor(this.difficulty === value ? AppTheme.ACCENT : AppTheme.INK_LIGHT)
      .backgroundColor(this.difficulty === value ? AppTheme.ACCENT_SOFT : AppTheme.CARD)
      .borderRadius(14)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .onClick(() => {
        this.difficulty = value;
        this.applyFilter();
      })
  }

  @Builder
  charCell(entry: CharEntry) {
    Column({ space: 3 }) {
      Text(entry.char)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.INK)
      Text(entry.pinyin)
        .fontSize(10)
        .fontColor(AppTheme.INK_FAINT)
      Text(`${entry.strokes.length} 画`)
        .fontSize(10)
        .fontColor(AppTheme.INK_LIGHT)
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(3)
          .backgroundColor(AppTheme.CARD_ALT)
          .borderRadius(2)
        Row()
          .width(`${this.masteryOf(entry.char)}%`)
          .height(3)
          .backgroundColor(AppTheme.masteryColor(this.masteryOf(entry.char)))
          .borderRadius(2)
      }
      .width('52%')
      .margin({ top: 2 })
      Text(this.statText(entry.char))
        .fontSize(9)
        .fontColor(AppTheme.INK_FAINT)
    }
    .width('23%')
    .height(118)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(AppTheme.CARD)
    .borderRadius(14)
    .border({
      width: this.masteryOf(entry.char) > 0 ? 1 : 0,
      color: AppTheme.masteryColor(this.masteryOf(entry.char))
    })
    .margin({ right: '1%', left: '1%', bottom: 8 })
    .onClick(() => {
      this.openDetail(entry.char);
    })
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(30)
          .fontColor(AppTheme.INK)
          .width(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Column({ space: 2 }) {
          Text('字库')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppTheme.INK)
          Text(`共 ${this.filtered.length} 个字 · 按年级与笔画筛选`)
            .fontSize(11)
            .fontColor(AppTheme.INK_FAINT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 8, right: 16, top: 12, bottom: 10 })

      Scroll() {
        Column({ space: 12 }) {
          TextInput({ placeholder: '搜索汉字或拼音', text: this.keyword })
            .height(40)
            .fontSize(14)
            .fontColor(AppTheme.INK)
            .placeholderColor(AppTheme.INK_FAINT)
            .backgroundColor(AppTheme.CARD)
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.keyword = value;
              this.applyFilter();
            })

          Column({ space: 8 }) {
            Row({ space: 6 }) {
              ForEach(this.gradeOptions, (value: number) => {
                this.gradeChip(value)
              }, (value: number) => `g${value}`)
            }
            .width('100%')
            Row({ space: 6 }) {
              ForEach(this.difficultyOptions, (value: number) => {
                this.difficultyChip(value)
              }, (value: number) => `d${value}`)
            }
            .width('100%')
          }
          .width('100%')

          if (this.filtered.length === 0) {
            Column({ space: 10 }) {
              Text(this.loaded ? '未找到匹配的汉字' : '正在载入字库…')
                .fontSize(15)
                .fontColor(AppTheme.INK_LIGHT)
              Text(this.loaded ? '尝试切换年级、笔画范围或清空搜索' : '读音数据与笔画路径正在准备')
                .fontSize(12)
                .fontColor(AppTheme.INK_FAINT)
            }
            .width('100%')
            .padding({ top: 60, bottom: 60 })
            .alignItems(HorizontalAlign.Center)
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.filtered, (entry: CharEntry) => {
                this.charCell(entry)
              }, (entry: CharEntry) => `${entry.char}`)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG)
  }
}
