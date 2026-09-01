import window from '@ohos.window';
import common from '@ohos.app.ability.common';

export class WindowManager {
  private static instance?: WindowManager;
  private subWindow: any = null;

  static getInstance(): WindowManager {
    if (!this.instance) {
      this.instance = new WindowManager();
    }
    return this.instance;
  }

  async showFloatingWindow(context: common.UIAbilityContext, pagePath: string = 'pages/RecordingPage'): Promise<void> {
    if (this.subWindow) {
      await this.subWindow.showWindow();
      return;
    }

    const createWindowMethod: ((context: common.UIAbilityContext, config: Object) => Promise<any>) | undefined = (window as Record<string, ((context: common.UIAbilityContext, config: Object) => Promise<any>) | undefined>).createWindow;
    if (!createWindowMethod) {
      throw new Error('window.createWindow is unavailable in the current SDK.');
    }

    const subWindow: any = await createWindowMethod(context, {
      name: 'HarmonyRecorderFloatingWindow',
      windowType: (window as Record<string, any>).WindowType?.TYPE_FLOAT ?? 2038,
      ctx: context
    });

    await subWindow.moveWindowTo(900, 1400);
    await subWindow.resize(240, 240);
    await subWindow.loadContent(pagePath);
    await subWindow.setWindowBackgroundColor('#00000000');
    await subWindow.showWindow();
    this.subWindow = subWindow;
  }

  async hideFloatingWindow(): Promise<void> {
    if (!this.subWindow) {
      return;
    }
    await this.subWindow.hide();
  }

  async destroyFloatingWindow(): Promise<void> {
    if (!this.subWindow) {
      return;
    }
    await this.subWindow.destroyWindow();
    this.subWindow = null;
  }
}

export const windowManager: WindowManager = WindowManager.getInstance();
