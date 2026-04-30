import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';

export class PermissionUtils {
  static async requestPermissions(context: common.UIAbilityContext, permissions: string[]): Promise<boolean> {
    try {
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const grantStatus: abilityAccessCtrl.GrantStatus[] = await atManager.requestPermissionsFromUser(context, permissions);
      return grantStatus.every((item: abilityAccessCtrl.GrantStatus) => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
    } catch (error) {
      console.error(`[PermissionUtils] requestPermissions failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async checkPermission(context: common.UIAbilityContext, permission: string): Promise<boolean> {
    try {
      const appInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const tokenId: number = appInfo.appInfo.accessTokenId;
      const result = await atManager.checkAccessToken(tokenId, permission);
      return result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      console.error(`[PermissionUtils] checkPermission failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  static async ensureMediaPermission(context: common.UIAbilityContext): Promise<boolean> {
    const permissions: string[] = ['ohos.permission.READ_MEDIA', 'ohos.permission.READ_AUDIO'];
    const checks = await Promise.all(permissions.map((permission: string) => this.checkPermission(context, permission)));
    if (checks.every(Boolean)) {
      return true;
    }
    return this.requestPermissions(context, permissions);
  }
}
