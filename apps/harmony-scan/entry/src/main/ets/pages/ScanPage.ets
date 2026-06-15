import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import fs from '@ohos.file.fs';
import camera from '@ohos.multimedia.camera';
import image from '@ohos.multimedia.image';
import { PermissionHelper } from '../utils/PermissionHelper';

@Component
struct ScanPage {
  @State docId: number = 0;
  @State isReady: boolean = false;
  @State isTaking: boolean = false;
  @State surfaceId: string = '';
  @State statusText: string = '正在初始化相机';

  private context = getContext(this) as Record<string, Object | string>;
  private cameraManager: camera.CameraManager | null = null;
  private captureSession: camera.PhotoSession | null = null;
  private cameraInput: camera.CameraInput | null = null;
  private previewOutput: camera.PreviewOutput | null = null;
  private photoOutput: camera.PhotoOutput | null = null;
  private previewProfile: camera.Profile | null = null;
  private photoProfile: camera.Profile | null = null;
  private xComponentController: XComponentController = new XComponentController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, number | boolean>;
    this.docId = Number(params?.docId ?? 0);
  }

  aboutToDisappear(): void {
    this.releaseCamera();
  }

  private async setupCamera(): Promise<void> {
    try {
      const granted = await PermissionHelper.requestCameraPermission(this.context as Object);
      if (!granted) {
        this.statusText = '相机权限未授予';
        return;
      }
      this.cameraManager = camera.getCameraManager(this.context as Object);
      const cameras = this.cameraManager.getSupportedCameras();
      if (!cameras || cameras.length === 0) {
        this.statusText = '未找到可用相机';
        return;
      }
      const targetCamera = cameras[0];
      const capability = this.cameraManager.getSupportedOutputCapability(targetCamera);
      this.previewProfile = capability.previewProfiles[0];
      this.photoProfile = capability.photoProfiles[0];
      this.cameraInput = await this.cameraManager.createCameraInput(targetCamera);
      await this.cameraInput.open();
      this.previewOutput = await this.cameraManager.createPreviewOutput(this.previewProfile, this.surfaceId);
      this.photoOutput = await this.cameraManager.createPhotoOutput(this.photoProfile);
      this.photoOutput.on('photoAvailable', async (photo: camera.Photo) => {
        await this.handlePhoto(photo.mainImage);
      });
      this.captureSession = await this.cameraManager.createCaptureSession() as camera.PhotoSession;
      this.captureSession.beginConfig();
      this.captureSession.addInput(this.cameraInput);
      this.captureSession.addOutput(this.previewOutput);
      this.captureSession.addOutput(this.photoOutput);
      await this.captureSession.commitConfig();
      await this.captureSession.start();
      this.isReady = true;
      this.statusText = '点击按钮拍摄文档';
    } catch (error) {
      this.statusText = '相机初始化失败';
    }
  }

  private async handlePhoto(photo: image.Image): Promise<void> {
    try {
      const component = photo.getComponent(image.ComponentType.JPEG);
      const filePath = `${this.context.filesDir as string}/scans/${this.docId}/raw_${Date.now()}.jpg`;
      this.ensureDocumentDir();
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, component.byteBuffer);
      fs.closeSync(file);
      this.isTaking = false;
      router.replaceUrl({
        url: 'pages/CropPage',
        params: {
          docId: this.docId,
          imagePath: filePath
        }
      });
    } catch (error) {
      this.isTaking = false;
      promptAction.showToast({ message: '保存照片失败' });
    }
  }

  private ensureDocumentDir(): void {
    const dir = `${this.context.filesDir as string}/scans/${this.docId}`;
    try {
      fs.accessSync(dir);
    } catch (error) {
      fs.mkdirSync(dir);
    }
  }

  private async takePhoto(): Promise<void> {
    if (!this.isReady || this.photoOutput === null || this.isTaking) {
      return;
    }
    this.isTaking = true;
    await this.photoOutput.capture();
  }

  private async releaseCamera(): Promise<void> {
    try {
      if (this.captureSession !== null) {
        await this.captureSession.stop();
        this.captureSession.release();
        this.captureSession = null;
      }
      if (this.previewOutput !== null) {
        this.previewOutput.release();
        this.previewOutput = null;
      }
      if (this.photoOutput !== null) {
        this.photoOutput.release();
        this.photoOutput = null;
      }
      if (this.cameraInput !== null) {
        this.cameraInput.close();
        this.cameraInput.release();
        this.cameraInput = null;
      }
    } catch (error) {
    }
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('扫描文档')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Stack({ alignContent: Alignment.Bottom }) {
        XComponent({
          id: 'camera_preview',
          type: XComponentType.SURFACE,
          controller: this.xComponentController
        })
          .width('100%')
          .height('72%')
          .backgroundColor('#0F172A')
          .borderRadius(24)
          .onLoad(() => {
            this.surfaceId = this.xComponentController.getXComponentSurfaceId();
            this.setupCamera();
          })

        Column({ space: 10 }) {
          Text(this.statusText)
            .fontSize(14)
            .fontColor('#FFFFFF')
          Button(this.isTaking ? '拍摄中...' : '拍照')
            .width(160)
            .height(52)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isReady ? '#4F46E5' : '#94A3B8')
            .borderRadius(26)
            .onClick(async () => {
              await this.takePhoto();
            })
        }
        .padding({ bottom: 28 })
      }
      .layoutWeight(1)

      Button('返回首页')
        .width('100%')
        .height(50)
        .backgroundColor('#E2E8F0')
        .fontColor('#1E293B')
        .borderRadius(18)
        .onClick(() => router.back())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F8FAFC')
  }
}

export default ScanPage;
