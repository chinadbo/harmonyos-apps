@CustomDialog
export struct RenameDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: RenameDialog() });
  @Prop currentName: string = '';
  onConfirm: (newName: string) => void = () => {};
  @State inputName: string = '';

  aboutToAppear(): void {
    this.inputName = this.currentName;
  }

  build() {
    Column({ space: 16 }) {
      Text('Rename')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      TextInput({ text: this.inputName })
        .onChange((value: string) => {
          this.inputName = value;
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
            this.onConfirm(this.inputName);
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(24)
    .width('100%')
  }
}
