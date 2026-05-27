import { Project } from '../model/Project'
import { ColorPicker } from '../components/ColorPicker'
import { DatabaseHelper } from '../database/DatabaseHelper'
import router from '@ohos.router'

@CustomDialog
struct ProjectDialog {
  controller: CustomDialogController
  @Link projectName: string
  @Link projectIcon: string
  @Link projectColor: string
  onConfirm: () => void = () => {}

  private icons: string[] = ['💼', '📚', '🎮', '🏃', '🎨', '🎵', '💻', '📱', '🍳', '✈️', '📝', '🔧']

  build() {
    Column() {
      Text('项目信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      TextInput({ placeholder: '项目名称', text: this.projectName })
        .width('100%')
        .height(44)
        .onChange((value: string) => {
          this.projectName = value
        })
        .margin({ bottom: 16 })

      Text('选择图标')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Grid() {
        ForEach(this.icons, (icon: string) => {
          GridItem() {
            Text(icon)
              .fontSize(28)
              .backgroundColor(this.projectIcon === icon ? '#E3F2FD' : 'transparent')
              .borderRadius(8)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
          }
          .onClick(() => {
            this.projectIcon = icon
          })
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
      .margin({ bottom: 16 })

      Text('选择颜色')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      ColorPicker({ selectedColor: $projectColor })
        .margin({ bottom: 16 })

      Row() {
        Button('取消')
          .type(ButtonType.Capsule)
          .backgroundColor('#E0E0E0')
          .fontColor('#666666')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })

        Button('确定')
          .type(ButtonType.Capsule)
          .backgroundColor('#4FC3F7')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => {
            this.onConfirm()
            this.controller.close()
          })
      }
      .width('100%')
    }
    .padding(24)
    .width('90%')
  }
}

@Entry
@Component
struct ProjectsPage {
  @State projects: Project[] = []
  @State dialogProjectName: string = ''
  @State dialogProjectIcon: string = '💼'
  @State dialogProjectColor: string = '#4FC3F7'
  @State editingProjectId: number = -1

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ProjectDialog({
      projectName: $dialogProjectName,
      projectIcon: $dialogProjectIcon,
      projectColor: $dialogProjectColor,
      onConfirm: () => {
        this.onDialogConfirm()
      }
    }),
    autoCancel: true
  })

  aboutToAppear(): void {
    this.loadProjects()
  }

  private async loadProjects(): Promise<void> {
    const db = DatabaseHelper.getInstance()
    this.projects = await db.getAllProjects()
  }

  private showAddDialog(): void {
    this.editingProjectId = -1
    this.dialogProjectName = ''
    this.dialogProjectIcon = '💼'
    this.dialogProjectColor = '#4FC3F7'
    this.dialogController.open()
  }

  private showEditDialog(project: Project): void {
    this.editingProjectId = project.id
    this.dialogProjectName = project.name
    this.dialogProjectIcon = project.icon
    this.dialogProjectColor = project.color
    this.dialogController.open()
  }

  private async onDialogConfirm(): Promise<void> {
    if (this.dialogProjectName.trim().length === 0) {
      return
    }
    const db = DatabaseHelper.getInstance()
    if (this.editingProjectId === -1) {
      await db.createProject(this.dialogProjectName.trim(), this.dialogProjectColor, this.dialogProjectIcon)
    } else {
      await db.updateProject(this.editingProjectId, this.dialogProjectName.trim(), this.dialogProjectColor, this.dialogProjectIcon)
    }
    this.loadProjects()
  }

  private async deleteProject(project: Project): Promise<void> {
    const db = DatabaseHelper.getInstance()
    await db.deleteProject(project.id)
    this.loadProjects()
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .fontColor('#4FC3F7')
          .onClick(() => {
            router.back()
          })

        Text('项目管理')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('添加')
          .type(ButtonType.Normal)
          .backgroundColor('transparent')
          .fontColor('#4FC3F7')
          .onClick(() => {
            this.showAddDialog()
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      if (this.projects.length === 0) {
        Column() {
          Text('📁')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无项目')
            .fontSize(16)
            .fontColor('#999999')
          Text('点击右上角添加项目')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 4 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List({ space: 1 }) {
          ForEach(this.projects, (project: Project) => {
            ListItem() {
              Row() {
                Circle()
                  .width(12)
                  .height(12)
                  .fill(project.color)
                  .margin({ right: 12 })

                Text(project.icon)
                  .fontSize(24)
                  .margin({ right: 8 })

                Text(project.name)
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFFFFF')
              .onClick(() => {
                this.showEditDialog(project)
              })
            }
            .swipeAction({
              end: this.DeleteBuilder(project)
            })
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  DeleteBuilder(project: Project) {
    Row() {
      Button('删除')
        .type(ButtonType.Normal)
        .backgroundColor('#F44336')
        .fontColor('#FFFFFF')
        .width(80)
        .height('100%')
        .onClick(() => {
          this.deleteProject(project)
        })
    }
    .height('100%')
  }
}
