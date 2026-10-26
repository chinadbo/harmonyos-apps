export class AngleSolver {
  private static readonly RAD_TO_DEG: number = 180 / Math.PI;

  // X 轴倾角（pitch）：绕设备 X 轴的倾角，atan2 返回弧度，统一在此转角度
  static pitchDeg(x: number, y: number, z: number): number {
    return Math.atan2(-y, z) * AngleSolver.RAD_TO_DEG;
  }

  // Y 轴倾角（roll）：绕设备 Y 轴的倾角
  static rollDeg(x: number, y: number, z: number): number {
    return Math.atan2(x, Math.sqrt(y * y + z * z)) * AngleSolver.RAD_TO_DEG;
  }

  static normalize180(angle: number): number {
    let a: number = angle % 360;
    if (a > 180) {
      a -= 360;
    }
    if (a < -180) {
      a += 360;
    }
    return a;
  }

  static normalize360(angle: number): number {
    let a: number = angle % 360;
    if (a < 0) {
      a += 360;
    }
    return a;
  }

  // 水平判定：双轴均小于阈值（度）
  static isLevel(pitch: number, roll: number, tolerance: number): boolean {
    return Math.abs(pitch) <= tolerance && Math.abs(roll) <= tolerance;
  }
}
