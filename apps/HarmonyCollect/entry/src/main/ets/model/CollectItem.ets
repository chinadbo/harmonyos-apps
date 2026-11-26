/**
 * CollectItem.ets — 藏品实体（对应 items 表）
 */
export class CollectItem {
  id: number = 0;
  name: string = '';
  category: string = 'other';
  condition: string = '全新';
  acquireDate: string = '';
  acquirePrice: number = 0;
  estValue: number = 0;
  serial: string = '';
  tags: string = '';
  imageUri: string = '';
  remark: string = '';
  createdAt: number = 0;

  /** 标签数组 */
  tagList(): string[] {
    const result: string[] = [];
    if (this.tags.length === 0) {
      return result;
    }
    const parts: string[] = this.tags.split(',');
    for (let i = 0; i < parts.length; i++) {
      const t = parts[i].trim();
      if (t.length > 0) {
        result.push(t);
      }
    }
    return result;
  }

  /** 盈亏 = 估值 - 入手价 */
  gain(): number {
    return this.estValue - this.acquirePrice;
  }

  /** 盈亏率（入手价为 0 时返回 0） */
  gainRate(): number {
    if (this.acquirePrice <= 0) {
      return 0;
    }
    return (this.estValue - this.acquirePrice) / this.acquirePrice;
  }

  hasImage(): boolean {
    return this.imageUri.length > 0;
  }

  /** 深拷贝（表单编辑时避免污染列表数据） */
  clone(): CollectItem {
    const copy = new CollectItem();
    copy.id = this.id;
    copy.name = this.name;
    copy.category = this.category;
    copy.condition = this.condition;
    copy.acquireDate = this.acquireDate;
    copy.acquirePrice = this.acquirePrice;
    copy.estValue = this.estValue;
    copy.serial = this.serial;
    copy.tags = this.tags;
    copy.imageUri = this.imageUri;
    copy.remark = this.remark;
    copy.createdAt = this.createdAt;
    return copy;
  }
}
