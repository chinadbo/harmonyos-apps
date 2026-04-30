import { PlayerService } from '../service/PlayerService';

export default class PlayMusicIntentExecutor {
  async onExecuteInUIAbilityForeground(params: Record<string, Object>): Promise<Record<string, Object>> {
    return this.execute(params);
  }

  async onExecuteInBackground(params: Record<string, Object>): Promise<Record<string, Object>> {
    return this.execute(params);
  }

  private async execute(params: Record<string, Object>): Promise<Record<string, Object>> {
    const action: string = String(params['action'] ?? 'play');
    if (action === 'play') {
      await PlayerService.getInstance().play();
    } else if (action === 'pause') {
      await PlayerService.getInstance().pause();
    } else if (action === 'next') {
      await PlayerService.getInstance().next();
    } else if (action === 'previous') {
      await PlayerService.getInstance().previous();
    } else if (action === 'stop') {
      await PlayerService.getInstance().stop();
    }
    return { code: 0, action: action };
  }
}
