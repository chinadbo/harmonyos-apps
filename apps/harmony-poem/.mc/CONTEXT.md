# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import media from '@ohos.multimedia.media'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例

## 项目必备文件
- AppScope/app.json5 + resources
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json（隐私声明）
- README.md（功能说明 + 架构 + 构建方式）

## 权限最小化
- 只申请实际用到的权限
- READ_MEDIA 范围太大，优先用 READ_AUDIO/READ_IMAGES 等细分权限

## 本项目特定规范

### 目标：HarmonyPoem 古诗词赏析 App

**页面列表（main_pages.json 必须包含）：**
- pages/Index（首页/每日一诗，底部导航栏入口）
- pages/ExplorePage（探索页，按朝代/作者/体裁分类）
- pages/DetailPage（诗词详情，全文+注释+赏析+朗读）
- pages/FavoritePage（收藏页，用户收藏列表）
- pages/SearchPage（搜索页，全文关键词搜索）

**数据源自实现（必须）：**
```typescript
class PoemDataSource implements IDataSource {
  private poems: Poem[] = [];
  private listeners: DataChangeListener[] = [];
  
  constructor(poems: Poem[]) {
    this.poems = poems;
  }
  
  totalCount(): number { return this.poems.length; }
  getData(index: number): Poem { return this.poems[index]; }
  
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) this.listeners.splice(idx, 1);
  }
  
  notifyDataReload(): void {
    this.listeners.forEach(l => l.onDataReloaded());
  }
  
  updatePoems(poems: Poem[]): void {
    this.poems = poems;
    this.notifyDataReload();
  }
}
```

**RDB 初始化（DatabaseHelper）：**
```typescript
import relationalStore from '@ohos.data.relationalStore';
const SQL_CREATE_FAVORITES = `CREATE TABLE IF NOT EXISTS favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  poem_id INTEGER NOT NULL,
  note TEXT DEFAULT '',
  tag TEXT DEFAULT '',
  created_at INTEGER NOT NULL
)`;
const SQL_CREATE_HISTORY = `CREATE TABLE IF NOT EXISTS reading_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  poem_id INTEGER NOT NULL UNIQUE,
  view_count INTEGER DEFAULT 1,
  last_viewed INTEGER NOT NULL
)`;
```

**rawfile 读取诗词数据：**
```typescript
import resourceManager from '@ohos.resourceManager';
// 在 context 中读取
const raw = await context.resourceManager.getRawFileContent('poems.json');
const text = String.fromCharCode(...new Uint8Array(raw));
const poems = JSON.parse(text) as Poem[];
```

**每日一诗算法（确定性，不随机）：**
```typescript
function getDailyPoem(poems: Poem[]): Poem {
  const now = new Date();
  const dayOfYear = Math.floor((now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000);
  return poems[dayOfYear % poems.length];
}
```

**poems.json 结构（放在 rawfile/ 下，至少包含 30 首经典诗词）：**
```json
[
  {
    "id": 1,
    "title": "静夜思",
    "author": "李白",
    "dynasty": "唐",
    "genre": "五言绝句",
    "content": ["床前明月光，", "疑是地上霜。", "举头望明月，", "低头思故乡。"],
    "annotation": ["床前：窗前，一说床头。", "疑：好像。", "举头：抬起头。"],
    "appreciation": "这首诗写游子思乡之情，以简洁的语言表达了深切的思念。月光如霜，引发作者对故乡的无限思念。",
    "tags": ["思乡", "月亮", "经典"]
  }
]
```
包含至少 30 首：静夜思、春晓、登鹳雀楼、将进酒、望庐山瀑布、早发白帝城、黄鹤楼、枫桥夜泊、送元二使安西、九月九日忆山东兄弟、相思、出塞、凉州词、芙蓉楼送辛渐、咏鹅、悯农、锄禾、游子吟、清明、江雪、渔歌子、望天门山、绝句(两个黄鹂)、春日、题西林壁、饮湖上初晴后雨、晓出净慈寺送林子方、泊船瓜洲、元日、梅花(王安石)。

**底部导航使用 Tabs + TabContent：**
```typescript
Tabs({ barPosition: BarPosition.End }) {
  TabContent() { Index() }.tabBar(this.TabBuilder('首页', 0, $r('app.media.icon_home')))
  TabContent() { ExplorePage() }.tabBar(this.TabBuilder('探索', 1, $r('app.media.icon_explore')))
  TabContent() { SearchPage() }.tabBar(this.TabBuilder('搜索', 2, $r('app.media.icon_search')))
  TabContent() { FavoritePage() }.tabBar(this.TabBuilder('收藏', 3, $r('app.media.icon_favorite')))
}
```

**颜色主题（color.json）：**
- 主色：#8B4513（棕色，传统国风）
- 背景：#FFF8F0（暖米色）
- 强调：#D4A017（金色）
