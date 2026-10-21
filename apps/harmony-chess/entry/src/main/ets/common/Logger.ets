export class Logger {
  private static TAG: string = 'HarmonyChess';

  static d(msg: string): void {
    console.debug(`[${Logger.TAG}] ${msg}`);
  }

  static i(msg: string): void {
    console.info(`[${Logger.TAG}] ${msg}`);
  }

  static w(msg: string): void {
    console.warn(`[${Logger.TAG}] ${msg}`);
  }

  static e(msg: string): void {
    console.error(`[${Logger.TAG}] ${msg}`);
  }
}
