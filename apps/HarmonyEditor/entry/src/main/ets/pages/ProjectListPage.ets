import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ROUTES } from '../common/constants';
import { AppStyles } from '../common/styles';
import { buildProjectName } from '../common/utils';
import { ProjectCard } from '../components/ProjectCard';
import { DataStore } from '../model/DataStore';
import { ProjectSummary } from '../model/ProjectModel';

@Entry
@Component
struct ProjectListPage {
  @State private projects: Array<ProjectSummary> = [];
  @State private loading: boolean = true;

  aboutToAppear(): void {
    this.loadProjects();
  }

  private async loadProjects(): Promise<void> {
    this.loading = true;
    try {
      this.projects = await DataStore.getInstance().listProjectSummaries();
    } catch (error) {
      promptAction.showToast({ message: `Failed to load projects: ${this.normalizeError(error)}` });
    } finally {
      this.loading = false;
    }
  }

  private openProject(projectId: number): void {
    router.pushUrl({ url: ROUTES.EDITOR, params: { projectId } });
  }

  private async deleteProject(projectId: number): Promise<void> {
    AlertDialog.show({
      title: 'Delete project',
      message: 'Delete this project and all of its edits?',
      autoCancel: true,
      primaryButton: { value: 'Cancel' },
      secondaryButton: {
        value: 'Delete',
        action: () => {
          DataStore.getInstance().deleteProject(projectId).then(() => {
            promptAction.showToast({ message: 'Project deleted' });
            this.loadProjects();
          }).catch((error: Error) => {
            promptAction.showToast({ message: `Delete failed: ${error.message}` });
          });
        }
      }
    });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Row({ space: 12 }) {
          Column({ space: 6 }) {
            Text('HarmonyEditor')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Create, trim, filter, and export short-form videos on HarmonyOS.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('Settings')
            .height(40)
            .fontColor(AppStyles.colors.textPrimary)
            .backgroundColor(AppStyles.colors.surfaceAlt)
            .onClick(() => router.pushUrl({ url: ROUTES.SETTINGS }))
        }
        .width('100%')

        Button('New Project')
          .width('100%')
          .height(46)
          .fontColor('#FFFFFFFF')
          .backgroundColor(AppStyles.colors.brandPrimary)
          .borderRadius(AppStyles.radius.lg)
          .onClick(() => {
            AppStorage.SetOrCreate('editorDraftName', buildProjectName());
            router.pushUrl({ url: ROUTES.VIDEO_PICKER });
          })

        if (this.loading) {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(42)
              .height(42)
              .color(AppStyles.colors.brandPrimary)
            Text('Loading projects...')
              .fontSize(13)
              .fontColor(AppStyles.colors.textSecondary)
          }
          .width('100%')
          .height(280)
          .justifyContent(FlexAlign.Center)
        } else if (this.projects.length === 0) {
          Column({ space: 10 }) {
            Text('No projects yet')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppStyles.colors.textPrimary)
            Text('Start a new project to pick videos, trim clips, and export your first edit.')
              .fontSize(14)
              .fontColor(AppStyles.colors.textSecondary)
              .textAlign(TextAlign.Center)
            Button('Create First Project')
              .margin({ top: 8 })
              .fontColor('#FFFFFFFF')
              .backgroundColor(AppStyles.colors.brandPrimary)
              .onClick(() => router.pushUrl({ url: ROUTES.VIDEO_PICKER }))
          }
          .width('100%')
          .height(320)
          .padding(24)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppStyles.colors.surfaceAlt)
          .borderRadius(AppStyles.radius.lg)
        } else {
          Column({ space: 12 }) {
            ForEach(this.projects, (project: ProjectSummary) => {
              ProjectCard({
                project,
                onOpen: (projectId: number) => this.openProject(projectId),
                onDelete: (projectId: number) => this.deleteProject(projectId)
              })
            }, (project: ProjectSummary) => `${project.id}`)
          }
          .width('100%')
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
