import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GroupDao } from '../database/GroupDao';
import { MemberDao } from '../database/MemberDao';
import { GROUP_SCENES, GROUP_SCENE_LABELS } from '../model/Group';

@Entry
@Component
struct AddGroupPage {
  private groupDao: GroupDao = new GroupDao();
  private memberDao: MemberDao = new MemberDao();
  private sceneOptions: SelectOption[] = [
    { value: GROUP_SCENE_LABELS.travel },
    { value: GROUP_SCENE_LABELS.dinner },
    { value: GROUP_SCENE_LABELS.rent },
    { value: GROUP_SCENE_LABELS.other }
  ];

  @State private groupName: string = '';
  @State private sceneIndex: number = 0;
  @State private memberNames: string[] = ['', ''];
  @State private saving: boolean = false;

  private updateMember(index: number, value: string): void {
    const next = this.memberNames.slice();
    next[index] = value;
    this.memberNames = next;
  }

  private addMember(): void {
    const next = this.memberNames.slice();
    next.push('');
    this.memberNames = next;
  }

  private removeMember(index: number): void {
    if (this.memberNames.length <= 2) {
      promptAction.showToast({ message: '至少保留 2 名成员' });
      return;
    }
    const next = this.memberNames.slice();
    next.splice(index, 1);
    this.memberNames = next;
  }

  private async saveGroup(): Promise<void> {
    if (this.groupName.trim().length === 0) {
      promptAction.showToast({ message: '请输入群组名称' });
      return;
    }
    const names = this.memberNames.map((item) => item.trim()).filter((item) => item.length > 0);
    if (names.length < 2) {
      promptAction.showToast({ message: '请至少填写 2 名成员' });
      return;
    }

    this.saving = true;
    try {
      const groupId = await this.groupDao.create(this.groupName.trim(), GROUP_SCENES[this.sceneIndex]);
      await this.memberDao.batchCreate(groupId, names);
      promptAction.showToast({ message: '群组已创建' });
      router.back();
    } catch (_) {
      promptAction.showToast({ message: '创建失败，请稍后重试' });
    }
    this.saving = false;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Button('返回')
            .type(ButtonType.Normal)
            .onClick(() => router.back())
          Text('新建分摊群组')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(52)
        }
        .width('100%')

        Column({ space: 12 }) {
          Text('群组名称')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          TextInput({ placeholder: '例如：杭州旅行、周末聚餐', text: this.groupName })
            .width('100%')
            .onChange((value: string) => {
              this.groupName = value;
            })

          Text('场景')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .alignSelf(ItemAlign.Start)
          Select(this.sceneOptions)
            .selected(this.sceneIndex)
            .value(this.sceneOptions[this.sceneIndex].value)
            .onSelect((index: number) => {
              this.sceneIndex = index;
            })
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        Column({ space: 12 }) {
          Row() {
            Text('成员列表')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
            Blank().layoutWeight(1)
            Button('添加成员')
              .fontSize(14)
              .onClick(() => this.addMember())
          }
          .width('100%')

          ForEach(this.memberNames, (memberName: string, index: number) => {
            Row({ space: 10 }) {
              TextInput({ placeholder: `成员 ${index + 1} 姓名`, text: memberName })
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.updateMember(index, value);
                })
              Button('删除')
                .fontSize(14)
                .backgroundColor('#FFFEE2E2')
                .fontColor($r('app.color.danger_color'))
                .onClick(() => this.removeMember(index))
            }
            .width('100%')
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFFFF')
        .borderRadius(20)

        Button(this.saving ? '保存中...' : '创建群组')
          .width('100%')
          .height(52)
          .fontSize(18)
          .fontColor('#FFFFFFFF')
          .backgroundColor($r('app.color.brand_color'))
          .onClick(() => {
            if (!this.saving) {
              this.saveGroup();
            }
          })
      }
      .width('100%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .backgroundColor('#FFF5F7FB')
  }
}
