// 标签管理页面，支持预设标签查看和自定义标签增删改
import common from '@ohos.app.ability.common';
import StorageManager from '../data/StorageManager';
import { createEmptyTagModel, TagModel } from '../models/TagModel';
import { EVENT_PRESET_COLORS } from '../utils/Constants';

@Component
struct TagManagePage {
  @State tags: TagModel[] = [];
  @State editingTag: TagModel = createEmptyTagModel();
  @State isEditing: boolean = false;

  aboutToAppear(): void {
    this.initializePage();
  }

  async initializePage(): Promise<void> {
    await StorageManager.initialize(getContext(this) as common.UIAbilityContext);
    await this.loadTags();
  }

  async loadTags(): Promise<void> {
    this.tags = await StorageManager.getAllTags();
  }

  editTag(tag: TagModel): void {
    this.editingTag = { ...tag };
    this.isEditing = true;
  }

  async saveTag(): Promise<void> {
    if (this.editingTag.name.trim().length === 0) {
      return;
    }
    await StorageManager.saveTag(this.editingTag);
    this.editingTag = createEmptyTagModel();
    this.isEditing = false;
    await this.loadTags();
  }

  async removeTag(tag: TagModel): Promise<void> {
    if (tag.isPreset) {
      return;
    }
    await StorageManager.deleteTag(tag.id);
    await this.loadTags();
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Text('标签管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .width('100%')

        Column({ space: 12 }) {
          ForEach(this.tags, (tag: TagModel) => {
            Row({ space: 12 }) {
              Circle()
                .width(16)
                .height(16)
                .fill(tag.color)
              Column({ space: 4 }) {
                Text(tag.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                Text(tag.isPreset ? '预设标签' : '自定义标签')
                  .fontSize(12)
                  .fontColor('#5B6770')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Button('编辑')
                .backgroundColor('#E8F3FF')
                .fontColor('#4A90D9')
                .borderRadius(16)
                .onClick(() => {
                  this.editTag(tag);
                })
              if (!tag.isPreset) {
                Button('删除')
                  .backgroundColor('#FFF1F1')
                  .fontColor('#D64545')
                  .borderRadius(16)
                  .onClick(() => {
                    this.removeTag(tag);
                  })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
          })
        }
        .width('100%')

        Column({ space: 12 }) {
          Text(this.isEditing ? '编辑标签' : '新建标签')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .width('100%')
          TextInput({ placeholder: '标签名称', text: this.editingTag.name })
            .backgroundColor('#F5F7FB')
            .borderRadius(16)
            .onChange((value: string) => {
              this.editingTag.name = value;
            })
          Row({ space: 10 }) {
            ForEach(EVENT_PRESET_COLORS, (color: string) => {
              Circle()
                .width(28)
                .height(28)
                .fill(color)
                .stroke(this.editingTag.color === color ? '#182431' : '#FFFFFF', this.editingTag.color === color ? 3 : 1)
                .onClick(() => {
                  this.editingTag.color = color;
                })
            })
          }
          Button(this.isEditing ? '保存标签' : '添加标签')
            .width('100%')
            .backgroundColor('#4A90D9')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .onClick(() => {
              this.saveTag();
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FB')
  }
}
