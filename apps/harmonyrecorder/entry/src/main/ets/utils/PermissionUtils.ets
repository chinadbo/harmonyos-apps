import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import common from '@ohos.app.ability.common';

export class PermissionUtils {
  private static readonly PERMISSIONS: Array<string> = [
    'ohos.permission.CAPTURE_SCREEN',
    'ohos.permission.MICROPHONE',
    'ohos.permission.READ_MEDIA',
    'ohos.permission.WRITE_MEDIA'
  ];

  static async requestAllPermissions(context: common.UIAbilityContext): Promise<boolean> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const grantStatuses: abilityAccessCtrl.GrantStatus[] = await atManager.requestPermissionsFromUser(context, this.PERMISSIONS);
    return grantStatuses.every((status: abilityAccessCtrl.GrantStatus) => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
  }

  static async checkPermission(context: common.UIAbilityContext, permission: string): Promise<boolean> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const grantStatus: abilityAccessCtrl.GrantStatus = await atManager.checkAccessToken(bundleInfo.appInfo.accessTokenId, permission);
    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  static async ensurePermissions(context: common.UIAbilityContext): Promise<void> {
    const granted: boolean = await this.requestAllPermissions(context);
    if (!granted) {
      throw new Error('Required permissions were not granted.');
    }
  }
}
