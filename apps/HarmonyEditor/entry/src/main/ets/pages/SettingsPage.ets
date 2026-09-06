import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import fs from '@ohos.file.fs';
import { EXPORT_FORMAT_OPTIONS, EXPORT_RESOLUTION_OPTIONS, ExportFormat, ExportResolution } from '../common/constants';
import { AppStyles } from '../common/styles';
import { getOutputDir } from '../common/utils';
import { DataStore } from '../model/DataStore';
import { PermissionService } from '../services/PermissionService';

@Entry
@Component
struct SettingsPage {
  @StorageLink('defaultExportResolution') private defaultExportResolution: string = ExportResolution.RES_ORIGINAL;
  @StorageLink('defaultExportFormat') private defaultExportFormat: string = ExportFormat.FORMAT_MP4;
  @StorageLink('autoSaveEnabled') private autoSaveEnabled: boolean = true;
  @State private loading: boolean = true;
  @State private clearing: boolean = false;

  aboutToAppear(): void {
    this.loadSettings();
  }

  private async loadSettings(): Promise<void> {
    this.loading = true;
    try {
      const settings = await DataStore.getInstance().getExportSettings();
      AppStorage.SetOrCreate<string>('defaultExportResolution', settings.resolution);
      AppStorage.SetOrCreate<string>('defaultExportFormat', settings.format);
      AppStorage.SetOrCreate<boolean>('autoSaveEnabled', settings.autoSaveEnabled);
    } catch (error) {
      promptAction.showToast({ message: `Failed to load settings: ${this.normalizeError(error)}` });
    } finally {
      this.loading = false;
    }
  }

  private async persistSettings(): Promise<void> {
    try {
      await DataStore.getInstance().saveExportSettings({
        resolution: this.defaultExportResolution as ExportResolution,
        format: this.defaultExportFormat as ExportFormat,
        autoSaveEnabled: this.autoSaveEnabled
      });
      promptAction.showToast({ message: 'Settings updated' });
    } catch (error) {
      promptAction.showToast({ message: `Failed to save settings: ${this.normalizeError(error)}` });
    }
  }

  private async updateResolution(value: string): Promise<void> {
    this.defaultExportResolution = value;
    await this.persistSettings();
  }

  private async updateFormat(value: string): Promise<void> {
    this.defaultExportFormat = value;
    await this.persistSettings();
  }

  private async updateAutoSave(value: boolean): Promise<void> {
    this.autoSaveEnabled = value;
    await this.persistSettings();
  }

  private confirmClearCache(): void {
    AlertDialog.show({
      title: 'Clear export cache',
      message: 'Remove exported temporary files and reset the current draft markers?',
      autoCancel: true,
      primaryButton: { value: 'Cancel' },
      secondaryButton: {
        value: 'Clear',
        action: () => {
          this.clearCache();
        }
      }
    });
  }

  private async clearCache(): Promise<void> {
    this.clearing = true;
    try {
      const outputDir = getOutputDir(PermissionService.getContext());
      const entries = fs.listFile(outputDir);
      let removedCount = 0;
      if (Array.isArray(entries)) {
        for (const entry of entries) {
          const targetPath = `${outputDir}/${entry}`;
          try {
            fs.unlink(targetPath);
            removedCount += 1;
          } catch (_error) {
          }
        }
      }
      AppStorage.SetOrCreate<string>('editorDraftName', '');
      AppStorage.SetOrCreate<number>('currentProjectId', 0);
      promptAction.showToast({ message: `Cleared ${removedCount} cached file(s).` });
    } catch (error) {
      promptAction.showToast({ message: `Failed to clear cache: ${this.normalizeError(error)}` });
    } finally {
      this.clearing = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('Settings')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Adjust default export behavior and clean up local editor cache files.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('Back')
            .height(40)
            .fontColor(AppStyles.colors.textPrimary)
            .backgroundColor(AppStyles.colors.surfaceAlt)
            .onClick(() => router.back())
        }
        .width('100%')

        if (this.loading) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(42)
              .height(42)
              .color(AppStyles.colors.brandPrimary)
            Text('Loading settings...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(260)
          .justifyContent(FlexAlign.Center)
        } else {
          this.buildOptionCard('Default Resolution', EXPORT_RESOLUTION_OPTIONS.map((option) => option.value as string), this.defaultExportResolution, (value: string) => {
            this.updateResolution(value);
          })

          this.buildOptionCard('Default Format', EXPORT_FORMAT_OPTIONS.map((option) => option.value as string), this.defaultExportFormat, (value: string) => {
            this.updateFormat(value);
          })

          Column({ space: 12 }) {
            Row() {
              Column({ space: 4 }) {
                Text('Auto Save')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppStyles.colors.textPrimary)
                Text('Persist clip, filter, and audio changes automatically when editing.')
                  .fontSize(12)
                  .fontColor(AppStyles.colors.textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Toggle({ type: ToggleType.Switch, isOn: this.autoSaveEnabled })
                .onChange((value: boolean) => this.updateAutoSave(value))
            }
            .width('100%')
          }
          .padding(AppStyles.cardPadding)
          .width('100%')
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
          .border({ width: 1, color: AppStyles.colors.border })

          Column({ space: 12 }) {
            Text('Maintenance')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Delete exported temporary files from the app sandbox and reset current draft markers.')
              .fontSize(12)
              .fontColor(AppStyles.colors.textSecondary)
            Button(this.clearing ? 'Clearing...' : 'Clear Cache')
              .width('100%')
              .height(42)
              .fontColor('#FFFFFFFF')
              .backgroundColor(this.clearing ? AppStyles.colors.surfaceMuted : AppStyles.colors.danger)
              .borderRadius(AppStyles.radius.lg)
              .onClick(() => {
                if (!this.clearing) {
                  this.confirmClearCache();
                }
              })
          }
          .padding(AppStyles.cardPadding)
          .width('100%')
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
          .border({ width: 1, color: AppStyles.colors.border })
        }
      }
      .padding(AppStyles.pagePadding)
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppStyles.colors.background)
  }

  @Builder
  private buildOptionCard(title: string, options: Array<string>, selectedValue: string, onChange: (value: string) => void) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppStyles.colors.textPrimary)

      Row({ space: 10 }) {
        ForEach(options, (option: string) => {
          Text(option.toUpperCase())
            .fontSize(12)
            .fontWeight(selectedValue === option ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(selectedValue === option ? '#FFFFFFFF' : AppStyles.colors.textSecondary)
            .backgroundColor(selectedValue === option ? AppStyles.colors.brandPrimary : AppStyles.colors.chip)
            .borderRadius(AppStyles.radius.pill)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .onClick(() => onChange(option))
        }, (option: string) => option)
      }
      .width('100%')
    }
    .padding(AppStyles.cardPadding)
    .width('100%')
    .backgroundColor(AppStyles.colors.surfaceAlt)
    .borderRadius(AppStyles.radius.lg)
    .border({ width: 1, color: AppStyles.colors.border })
  }

  private normalizeError(error: unknown): string {
    if (typeof error === 'object' && error !== null && 'message' in error) {
      const message = (error as Record<string, unknown>)['message'];
      if (typeof message === 'string') {
        return message;
      }
    }
    return JSON.stringify(error);
  }
}
