@Component
export struct VehicleFormView {
  @Link plateNumber: string;
  @Link brand: string;
  @Link model: string;
  @Link purchaseDate: string;
  @Link mileageText: string;
  @Link vin: string;
  @Link insuranceExpiry: string;
  @Link inspectionExpiry: string;
  @Link color: string;
  @Link isDefault: boolean;

  build() {
    Column({ space: 14 }) {
      TextInput({ text: this.plateNumber, placeholder: '车牌号' })
        .onChange((value: string) => { this.plateNumber = value; })
      TextInput({ text: this.brand, placeholder: '品牌' })
        .onChange((value: string) => { this.brand = value; })
      TextInput({ text: this.model, placeholder: '车型' })
        .onChange((value: string) => { this.model = value; })
      TextInput({ text: this.purchaseDate, placeholder: '购车日期 YYYY-MM-DD' })
        .onChange((value: string) => { this.purchaseDate = value; })
      TextInput({ text: this.mileageText, placeholder: '当前里程' })
        .type(InputType.Number)
        .onChange((value: string) => { this.mileageText = value; })
      TextInput({ text: this.vin, placeholder: 'VIN' })
        .onChange((value: string) => { this.vin = value; })
      TextInput({ text: this.insuranceExpiry, placeholder: '保险到期 YYYY-MM-DD' })
        .onChange((value: string) => { this.insuranceExpiry = value; })
      TextInput({ text: this.inspectionExpiry, placeholder: '年检到期 YYYY-MM-DD' })
        .onChange((value: string) => { this.inspectionExpiry = value; })
      TextInput({ text: this.color, placeholder: '颜色' })
        .onChange((value: string) => { this.color = value; })
      Row() {
        Text('设为默认车辆')
          .layoutWeight(1)
          .fontSize(15)
          .fontColor('#1F2D3D')
        Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
          .onChange((value: boolean) => { this.isDefault = value; })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F6F8FB')
      .borderRadius(16)
    }
    .width('100%')
  }
}
