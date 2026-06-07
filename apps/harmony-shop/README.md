# HarmonyShop（购物清单）

HarmonyShop 是一个基于 HarmonyOS ArkTS 的购物清单管理应用，支持创建购物清单、维护清单商品、标记完成进度，并通过 RDB 在本地持久化数据。

## 功能
- 创建和删除购物清单
- 查看单个清单内的商品明细
- 添加商品并填写数量、单位、分类和备注
- 勾选商品完成状态并查看完成进度
- 常用商品快捷模板

## 架构
```text
entry/src/main/ets/
├── entryability/EntryAbility.ets
├── pages/
│   ├── Index.ets
│   ├── ListDetailPage.ets
│   └── AddItemPage.ets
├── components/
│   ├── ShoppingListCard.ets
│   ├── ShoppingItemRow.ets
│   ├── AddItemDialog.ets
│   └── ProgressBar.ets
├── database/ShopDatabase.ets
└── model/
    ├── ShoppingList.ets
    └── ShoppingItem.ets
```

## 存储
- `shopping_lists`：购物清单表
- `shopping_items`：购物商品表

## 构建
1. 安装依赖：`ohpm install`
2. 在 DevEco Studio 打开项目，或使用 hvigor 构建命令编译 HAP
3. 运行应用后进入首页管理购物清单
