import { ColorModel } from '../model/ColorModel';
import { PaletteScheme } from '../model/PaletteScheme';

interface RGB {
  r: number;
  g: number;
  b: number;
}

interface HSV {
  h: number;
  s: number;
  v: number;
}

export class ColorConverter {
  static fromHex(hex: string, name: string = ''): ColorModel {
    let normalized: string = hex.trim().replace('#', '').toUpperCase();
    if (normalized.length === 3) {
      normalized = `${normalized[0]}${normalized[0]}${normalized[1]}${normalized[1]}${normalized[2]}${normalized[2]}`;
    }
    if (normalized.length === 6) {
      normalized = `FF${normalized}`;
    }
    const alpha: number = parseInt(normalized.slice(0, 2), 16);
    const red: number = parseInt(normalized.slice(2, 4), 16);
    const green: number = parseInt(normalized.slice(4, 6), 16);
    const blue: number = parseInt(normalized.slice(6, 8), 16);
    return this.fromRgba(red, green, blue, alpha, name);
  }

  static fromArgb(argb: number, name: string = ''): ColorModel {
    const alpha: number = (argb >>> 24) & 0xFF;
    const red: number = (argb >>> 16) & 0xFF;
    const green: number = (argb >>> 8) & 0xFF;
    const blue: number = argb & 0xFF;
    return this.fromRgba(red, green, blue, alpha, name);
  }

  static fromRgba(red: number, green: number, blue: number, alpha: number = 255, name: string = ''): ColorModel {
    const hsv: HSV = this.rgbToHsv(red, green, blue);
    const argb: number = (((alpha & 0xFF) << 24) | ((red & 0xFF) << 16) | ((green & 0xFF) << 8) | (blue & 0xFF)) >>> 0;
    return new ColorModel(
      argb,
      this.rgbaToHex(red, green, blue, alpha),
      red,
      green,
      blue,
      alpha,
      hsv.h,
      hsv.s,
      hsv.v,
      name.length > 0 ? name : this.createName(hsv)
    );
  }

  static fromHsv(hue: number, saturation: number, value: number, alpha: number = 255, name: string = ''): ColorModel {
    const rgb: RGB = this.hsvToRgb(hue, saturation, value);
    return this.fromRgba(rgb.r, rgb.g, rgb.b, alpha, name);
  }

  static rgbToHsv(red: number, green: number, blue: number): HSV {
    const r: number = red / 255;
    const g: number = green / 255;
    const b: number = blue / 255;
    const max: number = Math.max(r, g, b);
    const min: number = Math.min(r, g, b);
    const delta: number = max - min;
    let hue: number = 0;

    if (delta !== 0) {
      if (max === r) {
        hue = 60 * (((g - b) / delta) % 6);
      } else if (max === g) {
        hue = 60 * (((b - r) / delta) + 2);
      } else {
        hue = 60 * (((r - g) / delta) + 4);
      }
    }

    if (hue < 0) {
      hue += 360;
    }

    const saturation: number = max === 0 ? 0 : delta / max;
    const value: number = max;
    return {
      h: this.round(hue, 1),
      s: this.round(saturation, 4),
      v: this.round(value, 4)
    };
  }

  static hsvToRgb(hue: number, saturation: number, value: number): RGB {
    const normalizedHue: number = ((hue % 360) + 360) % 360;
    const chroma: number = value * saturation;
    const x: number = chroma * (1 - Math.abs(((normalizedHue / 60) % 2) - 1));
    const match: number = value - chroma;
    let rPrime: number = 0;
    let gPrime: number = 0;
    let bPrime: number = 0;

    if (normalizedHue < 60) {
      rPrime = chroma;
      gPrime = x;
    } else if (normalizedHue < 120) {
      rPrime = x;
      gPrime = chroma;
    } else if (normalizedHue < 180) {
      gPrime = chroma;
      bPrime = x;
    } else if (normalizedHue < 240) {
      gPrime = x;
      bPrime = chroma;
    } else if (normalizedHue < 300) {
      rPrime = x;
      bPrime = chroma;
    } else {
      rPrime = chroma;
      bPrime = x;
    }

    return {
      r: Math.round((rPrime + match) * 255),
      g: Math.round((gPrime + match) * 255),
      b: Math.round((bPrime + match) * 255)
    };
  }

  static rgbaToHex(red: number, green: number, blue: number, alpha: number = 255): string {
    if (alpha === 255) {
      return `#${this.toHex(red)}${this.toHex(green)}${this.toHex(blue)}`;
    }
    return `#${this.toHex(alpha)}${this.toHex(red)}${this.toHex(green)}${this.toHex(blue)}`;
  }

  static rgbString(color: ColorModel): string {
    return `rgb(${color.red}, ${color.green}, ${color.blue})`;
  }

  static rgbaString(color: ColorModel): string {
    return `rgba(${color.red}, ${color.green}, ${color.blue}, ${this.round(color.alpha / 255, 2)})`;
  }

  static hsvString(color: ColorModel): string {
    return `hsv(${Math.round(color.hue)}°, ${Math.round(color.saturation * 100)}%, ${Math.round(color.value * 100)}%)`;
  }

  static contrastColor(argb: number): number {
    const red: number = (argb >>> 16) & 0xFF;
    const green: number = (argb >>> 8) & 0xFF;
    const blue: number = argb & 0xFF;
    const luminance: number = (0.299 * red + 0.587 * green + 0.114 * blue) / 255;
    return luminance > 0.58 ? 0xFF111111 : 0xFFFFFFFF;
  }

  static paletteSchemes(baseColor: ColorModel): Array<PaletteScheme> {
    const hues: Array<PaletteScheme> = [];
    hues.push(new PaletteScheme('Complementary', 'High contrast pairing', [
      baseColor.clone(),
      this.shiftHue(baseColor, 180, 'Complement')
    ]));
    hues.push(new PaletteScheme('Analogous', 'Balanced neighboring hues', [
      this.shiftHue(baseColor, -30, 'Analogous A'),
      baseColor.clone(),
      this.shiftHue(baseColor, 30, 'Analogous B')
    ]));
    hues.push(new PaletteScheme('Triadic', 'Three evenly spaced tones', [
      baseColor.clone(),
      this.shiftHue(baseColor, 120, 'Triadic A'),
      this.shiftHue(baseColor, 240, 'Triadic B')
    ]));
    hues.push(new PaletteScheme('Split Complementary', 'Contrast with softer balance', [
      baseColor.clone(),
      this.shiftHue(baseColor, 150, 'Split A'),
      this.shiftHue(baseColor, 210, 'Split B')
    ]));
    hues.push(new PaletteScheme('Monochrome', 'Same hue with varied value', [
      this.fromHsv(baseColor.hue, Math.min(1, baseColor.saturation * 0.55), 0.25, 255, 'Mono Dark'),
      this.fromHsv(baseColor.hue, Math.min(1, baseColor.saturation * 0.8), 0.5, 255, 'Mono Mid'),
      baseColor.clone(),
      this.fromHsv(baseColor.hue, Math.max(0.12, baseColor.saturation * 0.45), 0.9, 255, 'Mono Light')
    ]));
    return hues;
  }

  static shiftHue(color: ColorModel, delta: number, name: string = ''): ColorModel {
    return this.fromHsv((color.hue + delta + 360) % 360, color.saturation, color.value, color.alpha, name);
  }

  private static toHex(value: number): string {
    return Math.max(0, Math.min(255, value)).toString(16).padStart(2, '0').toUpperCase();
  }

  private static round(value: number, decimals: number): number {
    const multiplier: number = Math.pow(10, decimals);
    return Math.round(value * multiplier) / multiplier;
  }

  private static createName(hsv: HSV): string {
    const hue: number = hsv.h;
    const valuePercent: number = hsv.v * 100;
    const saturationPercent: number = hsv.s * 100;
    if (valuePercent < 15) {
      return 'Near Black';
    }
    if (valuePercent > 92 && saturationPercent < 10) {
      return 'Near White';
    }
    if (saturationPercent < 12) {
      return 'Neutral';
    }
    if (hue < 15 || hue >= 345) {
      return 'Red';
    }
    if (hue < 45) {
      return 'Orange';
    }
    if (hue < 70) {
      return 'Yellow';
    }
    if (hue < 165) {
      return 'Green';
    }
    if (hue < 200) {
      return 'Cyan';
    }
    if (hue < 255) {
      return 'Blue';
    }
    if (hue < 290) {
      return 'Purple';
    }
    return 'Magenta';
  }
}
