import { ColorModel } from './ColorModel';

export class PaletteScheme {
  name: string;
  description: string;
  colors: Array<ColorModel>;

  constructor(name: string, description: string, colors: Array<ColorModel>) {
    this.name = name;
    this.description = description;
    this.colors = colors;
  }
}
