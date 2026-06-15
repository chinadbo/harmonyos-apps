import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

export class PermissionHelper {
  static async requestCameraPermission(context: Object): Promise<boolean> {
    const manager = abilityAccessCtrl.createAtManager();
    const result = await manager.requestPermissionsFromUser(context, ['ohos.permission.CAMERA']);
    return result.authResults.every((item: number) => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
  }
}
