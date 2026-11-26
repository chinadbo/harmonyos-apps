/**
 * Category.ets — 品类实体（对应 categories 表）
 * key 主键，custom=1 表示用户自定义
 */
export class Category {
  key: string = '';
  name: string = '';
  icon: string = '◈';
  sortOrder: number = 0;
  custom: boolean = false;

  isCustom(): boolean {
    return this.custom;
  }

  clone(): Category {
    const copy = new Category();
    copy.key = this.key;
    copy.name = this.name;
    copy.icon = this.icon;
    copy.sortOrder = this.sortOrder;
    copy.custom = this.custom;
    return copy;
  }
}
