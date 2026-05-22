@CustomDialog
export struct NewFolderDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: NewFolderDialog() });
  onConfirm: (name: string) => void = () => {};
  @State folderName: string = '';

  build() {
    Column({ space: 16 }) {
      Text('New Folder')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: 'Folder name' })
        .onChange((value: string) => {
          this.folderName = value;
        })
        .width('100%')

      Row({ space: 12 }) {
        Button('Cancel')
          .flexGrow(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('Confirm')
          .flexGrow(1)
          .onClick(() => {
            this.onConfirm(this.folderName);
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .width('100%')
  }
}
