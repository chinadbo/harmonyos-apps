/**
 * 全局 Context 持有（避免使用 globalThis / getContext 强转）
 */

import common from '@ohos.app.ability.common'

export class AppContext {
  private static ctx: common.Context | null = null

  static set(c: common.Context): void {
    AppContext.ctx = c
  }

  static get(): common.Context | null {
    return AppContext.ctx
  }
}
