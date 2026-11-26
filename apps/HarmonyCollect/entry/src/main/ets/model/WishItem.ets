/**
 * WishItem.ets — 心愿单实体（对应 wishlist 表）
 * status: 0 想要 / 1 已入手
 */
export class WishItem {
  id: number = 0;
  name: string = '';
  category: string = 'other';
  targetPrice: number = 0;
  priority: number = 2;
  remark: string = '';
  createdAt: number = 0;
  status: number = 0;

  isAcquired(): boolean {
    return this.status === 1;
  }

  /** 优先级星标 */
  stars(): string {
    const level: number = this.priority < 1 ? 1 : (this.priority > 3 ? 3 : this.priority);
    let out: string = '';
    for (let i = 0; i < 3; i++) {
      out += i < level ? '★' : '☆';
    }
    return out;
  }

  clone(): WishItem {
    const copy = new WishItem();
    copy.id = this.id;
    copy.name = this.name;
    copy.category = this.category;
    copy.targetPrice = this.targetPrice;
    copy.priority = this.priority;
    copy.remark = this.remark;
    copy.createdAt = this.createdAt;
    copy.status = this.status;
    return copy;
  }
}
