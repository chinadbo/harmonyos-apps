@CustomDialog
export struct DeleteConfirmDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: DeleteConfirmDialog() });
  @Prop fileName: string = '';
  onConfirm: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Text('Delete?')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Text(this.fileName)
        .fontSize(14)
        .fontColor('#666666')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .width('100%')

      Row({ space: 12 }) {
        Button('Cancel')
          .flexGrow(1)
          .backgroundColor('#CCCCCC')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close();
          })

        Button('Delete')
          .flexGrow(1)
          .backgroundColor('#FF3B30')
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .width('100%')
  }
}
