import { ColorWheelPage } from './ColorWheelPage';
import { ImagePickerPage } from './ImagePickerPage';
import { PalettePage } from './PalettePage';
import { FavoritesPage } from './FavoritesPage';
import { ColorDetailPage } from './ColorDetailPage';
import { ColorModel } from '../model/ColorModel';
import { PaletteScheme } from '../model/PaletteScheme';
import { ColorConverter } from '../utils/ColorConverter';
import { DatabaseHelper } from '../database/DatabaseHelper';
import { ShareService } from '../services/ShareService';

interface DetailPageParam {
  hex: string;
  name: string;
}

@Entry
@Component
struct Index {
  private navPathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();

  @State currentTab: number = 0;
  @State currentColor: ColorModel = ColorConverter.fromHex('#5B8CFF', 'Azure');
  @State extractedColors: Array<ColorModel> = [];
  @State paletteSchemes: Array<PaletteScheme> = ColorConverter.paletteSchemes(ColorConverter.fromHex('#5B8CFF', 'Azure'));
  @State favorites: Array<ColorModel> = [];
  @State initialized: boolean = false;
  @State statusText: string = 'Create palettes, inspect image colors, and keep your best swatches.';

  aboutToAppear(): void {
    this.initialize();
  }

  private async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }
    try {
      await DatabaseHelper.init(getContext(this) as Record<string, object>);
      this.initialized = true;
      await this.refreshFavorites();
    } catch (error) {
      this.statusText = 'Favorites storage is unavailable in the current environment.';
    }
  }

  private updateBaseColor(color: ColorModel): void {
    this.currentColor = color.clone();
    this.paletteSchemes = ColorConverter.paletteSchemes(this.currentColor);
  }

  private handleImageColors(colors: Array<ColorModel>): void {
    this.extractedColors = colors.slice();
    if (colors.length > 0) {
      this.updateBaseColor(colors[0]);
      this.currentTab = 2;
    }
  }

  private openDetail(color: ColorModel): void {
    this.navPathStack.pushPath({
      name: 'ColorDetailPage',
      param: {
        hex: color.hex,
        name: color.displayName()
      }
    });
  }

  private async refreshFavorites(): Promise<void> {
    if (!this.initialized) {
      return;
    }
    try {
      this.favorites = await DatabaseHelper.listFavorites();
    } catch (error) {
      this.statusText = 'Failed to load favorites from local storage.';
    }
  }

  private async saveFavorite(color: ColorModel): Promise<void> {
    try {
      if (!this.initialized) {
        await this.initialize();
      }
      const exists = await DatabaseHelper.existsByHex(color.hex);
      if (exists) {
        this.statusText = `${color.hex} is already in favorites.`;
        return;
      }
      await DatabaseHelper.saveFavorite(color);
      await this.refreshFavorites();
      this.statusText = `${color.hex} saved to favorites.`;
    } catch (error) {
      this.statusText = 'Unable to save the color right now.';
    }
  }

  private async deleteFavorite(id: number): Promise<void> {
    try {
      await DatabaseHelper.deleteFavorite(id);
      await this.refreshFavorites();
      this.statusText = 'Favorite removed.';
    } catch (error) {
      this.statusText = 'Unable to remove the favorite right now.';
    }
  }

  private async copyColor(color: ColorModel): Promise<void> {
    try {
      await ShareService.copyText(`${color.hex} | ${ColorConverter.rgbString(color)} | ${ColorConverter.hsvString(color)}`);
      this.statusText = `${color.hex} copied to the clipboard.`;
    } catch (error) {
      this.statusText = 'Clipboard access failed.';
    }
  }

  @Builder
  private buildDestination(name: string, param?: Object): void {
    if (name === 'ColorDetailPage') {
      const detailParam = param as DetailPageParam;
      const detailColor = ColorConverter.fromHex(detailParam.hex, detailParam.name);
      ColorDetailPage({
        color: detailColor,
        onBack: () => {
          this.navPathStack.pop();
        },
        onCopy: () => {
          this.copyColor(detailColor);
        },
        onSave: () => {
          this.saveFavorite(detailColor);
        }
      });
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 12 }) {
        Column({ space: 6 }) {
          Text('HarmonyPalette')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937');
          Text(this.statusText)
            .fontSize(14)
            .fontColor('#6B7280')
            .maxLines(2);
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 12, left: 16, right: 16 });

        Tabs({ barPosition: BarPosition.End, controller: this.tabsController, index: this.currentTab }) {
          TabContent() {
            ColorWheelPage({
              currentColor: $currentColor,
              onColorSelected: (color: ColorModel) => {
                this.updateBaseColor(color);
              },
              onOpenDetail: (color: ColorModel) => {
                this.openDetail(color);
              },
              onSave: (color: ColorModel) => {
                this.saveFavorite(color);
              },
              onCopy: (color: ColorModel) => {
                this.copyColor(color);
              }
            });
          }
          .tabBar('ColorWheel');

          TabContent() {
            ImagePickerPage({
              currentColor: $currentColor,
              extractedColors: $extractedColors,
              onColorSelected: (color: ColorModel) => {
                this.updateBaseColor(color);
              },
              onColorsExtracted: (colors: Array<ColorModel>) => {
                this.handleImageColors(colors);
              },
              onOpenDetail: (color: ColorModel) => {
                this.openDetail(color);
              },
              onSave: (color: ColorModel) => {
                this.saveFavorite(color);
              },
              onCopy: (color: ColorModel) => {
                this.copyColor(color);
              }
            });
          }
          .tabBar('ImagePicker');

          TabContent() {
            PalettePage({
              currentColor: $currentColor,
              paletteSchemes: $paletteSchemes,
              onOpenDetail: (color: ColorModel) => {
                this.openDetail(color);
              },
              onSave: (color: ColorModel) => {
                this.saveFavorite(color);
              },
              onCopy: (color: ColorModel) => {
                this.copyColor(color);
              }
            });
          }
          .tabBar('Palette');

          TabContent() {
            FavoritesPage({
              favorites: $favorites,
              onOpenDetail: (color: ColorModel) => {
                this.openDetail(color);
              },
              onDelete: (id: number) => {
                this.deleteFavorite(id);
              },
              onSave: (color: ColorModel) => {
                this.saveFavorite(color);
              },
              onCopy: (color: ColorModel) => {
                this.copyColor(color);
              }
            });
          }
          .tabBar('Favorites');
        }
        .barMode(BarMode.Fixed)
        .scrollable(false)
        .layoutWeight(1);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F7FB');
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.buildDestination);
  }
}
