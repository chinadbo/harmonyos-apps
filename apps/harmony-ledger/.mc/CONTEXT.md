# HarmonyOS 编码规范（必须遵守）

## 装饰器体系
- 统一使用 V1 体系：@Component + @State/@Prop/@Link/@StorageProp/@StorageLink
- 禁止使用 @ComponentV2/@ObservedV2/@Trace/@Param/@Local/@Monitor/@Computed
- 禁止在同一项目中混用 V1 和 V2 装饰器

## Import 风格
- 统一使用 @ohos.* 风格（如 `import relationalStore from '@ohos.data.relationalStore'`）
- 不使用 @kit.* 风格

## 常见陷阱（禁止踩坑）
- BasicDataSource 不是框架内置类，必须自行实现 IDataSource 接口
- fs.listFile() 返回 string[]，不是迭代器，没有 .next() 方法
- 不存在 media.fetchAVFileDescriptor，获取音频 metadata 用 media.createAVMetadataExtractor()
- @Reusable 只用于 V1 @Component，不用于 @ComponentV2
- PlayMode 是系统动画枚举，自定义播放模式枚举命名避免冲突（用 MusicPlayMode 等）
- onContinue 返回值类型是 AbilityConstant.OnContinueResult，不是 string
- getContext() 不能强转为 Ability 实例
- Canvas 绘制必须在 onReady 回调中执行，不能在 aboutToAppear 中
- postCardAction 参数必须是原生对象，禁止 JSON.stringify（会导致双重序列化）
- LazyForEach 的 Key 必须用数据 id，不能用 index（否则排序变化导致重建）
- FormExtensionAbility 内存限制 6MB，Widget 数据通信只传递简单数字/字符串
- RDB 所有操作必须通过 taskpool 或 async/await 异步执行，禁止主线程同步阻塞

## 本项目特定规范

### 数据模型
```typescript
// DataModels.ets 中定义
interface Transaction {
  id: number;
  type: 'income' | 'expense';
  amount: number;
  categoryId: number;
  note: string;
  date: string;  // 'YYYY-MM-DD'
  createdAt: number;
}

interface Category {
  id: number;
  name: string;
  icon: string;
  color: string;
  type: 'income' | 'expense' | 'both';
  isSystem: boolean;
  sortOrder: number;
}

interface Budget {
  id: number;
  categoryId: number;
  month: string;  // 'YYYY-MM'
  amount: number;
}
```

### LazyForEach 数据源（必须手动实现 IDataSource）
```typescript
class TransactionDataSource implements IDataSource {
  private list: Transaction[] = [];
  private listeners: DataChangeListener[] = [];
  
  totalCount(): number { return this.list.length; }
  getData(index: number): Transaction { return this.list[index]; }
  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.push(listener);
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx >= 0) this.listeners.splice(idx, 1);
  }
  setData(data: Transaction[]): void {
    this.list = data;
    this.listeners.forEach(l => l.onDataReloaded());
  }
}
```

### Canvas 图表绘制
```typescript
// 折线图组件
@Component
struct LineChart {
  @Prop data: number[] = [];
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  
  build() {
    Canvas(this.context)
      .width('100%')
      .height(200)
      .onReady(() => {
        this.drawChart();
      })
  }
  
  private drawChart(): void {
    // 在 onReady 中绘制，此时 canvas 尺寸已确定
    const width = this.context.width;
    const height = this.context.height;
    // ... 绘制逻辑
  }
}
```

### Widget postCardAction 正确写法
```typescript
// 正确：原生对象，框架自动序列化
postCardAction(this, {
  action: 'router',
  abilityName: 'EntryAbility',
  params: { targetPage: 'add' }
});

// 错误：JSON.stringify 导致双重序列化
// params: JSON.stringify({ targetPage: 'add' })
```

## 项目必备文件
- AppScope/app.json5 + AppScope/resources/base/element/string.json
- entry/src/main/module.json5
- entry/src/main/ets/entryability/EntryAbility.ets
- entry/src/main/ets/entryformability/EntryFormAbility.ets
- entry/src/main/resources/base/profile/main_pages.json
- entry/src/main/resources/base/profile/form_config.json
- build-profile.json5 + oh-package.json5
- privacy_statement.json
- README.md

## 权限最小化
- 只申请 ohos.permission.NOTIFICATION_CONTROLLER（预算超支通知）
- 本地 RDB 存储不需要额外权限

## 任务目标
构建 HarmonyLedger — 个人记账与预算管理 App，包含：
1. 首页（本月收支概览 + LazyForEach 账单列表 + FAB 快速记账）
2. 记账页（金额输入 + 分类选择 + 备注 + 日期）
3. 账单详情页（查看 + 编辑 + 删除）
4. 统计页（Canvas 折线图 30天趋势 + Canvas 饼图分类占比）
5. 预算页（按分类设置月预算 + 进度条 + 超支提醒）
6. 分类管理页（内置8分类 + 自定义颜色/图标）
7. 设置页（货币单位 + CSV 导出 + 关于）
8. 桌面 Widget（2×2，显示本月结余 + 今日支出 + 快速记账入口）

数据层：
- RelationalStore 四表（transactions/categories/budgets + 系统默认配置）
- 所有 DB 操作 async/await + taskpool
- AppStorage 跨页面状态共享

请按架构文档完整实现所有文件，确保可编译。
