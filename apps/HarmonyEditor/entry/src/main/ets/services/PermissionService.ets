import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import { PERMISSIONS } from '../common/constants';

export class PermissionService {
  private static context: common.UIAbilityContext | null = null;

  static setContext(context: common.UIAbilityContext): void {
    PermissionService.context = context;
  }

  static getContext(): common.UIAbilityContext {
    if (!PermissionService.context) {
      throw new Error('Permission context is not initialized');
    }
    return PermissionService.context;
  }

  static async ensureReadMediaPermission(): Promise<boolean> {
    return PermissionService.ensurePermissions([PERMISSIONS.READ_MEDIA]);
  }

  static async ensureWriteMediaPermission(): Promise<boolean> {
    return PermissionService.ensurePermissions([PERMISSIONS.WRITE_MEDIA]);
  }

  static async ensureMediaLibraryPermissions(): Promise<boolean> {
    return PermissionService.ensurePermissions([PERMISSIONS.READ_MEDIA, PERMISSIONS.WRITE_MEDIA]);
  }

  static async ensurePermissions(permissions: Array<string>): Promise<boolean> {
    const context = PermissionService.getContext();
    const accessManager = abilityAccessCtrl.createAtManager();
    const tokenId: number = context.applicationInfo.accessTokenId;
    const pending: Array<string> = [];

    for (const permission of permissions) {
      const state = await accessManager.checkAccessToken(tokenId, permission);
      if (state !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        pending.push(permission);
      }
    }

    if (pending.length === 0) {
      return true;
    }

    const requestResult = await accessManager.requestPermissionsFromUser(context, pending);
    if (!requestResult.authResults || requestResult.authResults.length !== pending.length) {
      return false;
    }
    return requestResult.authResults.every((result: number) => result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
  }
}
