export class ColorModel {
  id: number;
  name: string;
  argb: number;
  hex: string;
  red: number;
  green: number;
  blue: number;
  alpha: number;
  hue: number;
  saturation: number;
  value: number;
  createdAt: number;

  constructor(
    argb: number,
    hex: string,
    red: number,
    green: number,
    blue: number,
    alpha: number,
    hue: number,
    saturation: number,
    value: number,
    name: string = '',
    id: number = 0,
    createdAt: number = Date.now()
  ) {
    this.id = id;
    this.name = name;
    this.argb = argb;
    this.hex = hex;
    this.red = red;
    this.green = green;
    this.blue = blue;
    this.alpha = alpha;
    this.hue = hue;
    this.saturation = saturation;
    this.value = value;
    this.createdAt = createdAt;
  }

  clone(): ColorModel {
    return new ColorModel(
      this.argb,
      this.hex,
      this.red,
      this.green,
      this.blue,
      this.alpha,
      this.hue,
      this.saturation,
      this.value,
      this.name,
      this.id,
      this.createdAt
    );
  }

  displayName(): string {
    if (this.name.length > 0) {
      return this.name;
    }
    return this.hex;
  }
}
