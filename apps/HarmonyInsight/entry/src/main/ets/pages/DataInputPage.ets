import router from '@ohos.router';
import { TextEncoder, TextDecoder } from '@kit.ArkTSCrypto';
import { picker } from '@kit.ArkUI';
import { CSVParser } from '../data/CSVParser';
import { ChartDataModel, ChartType } from '../data/ChartDataModel';
import { ThemeManager } from '../utils/ThemeManager';
import { FileHelper } from '../utils/FileHelper';

@Component
export struct DataInputPage {
  @State headers: string[] = ['类别', '数值'];
  @State rows: string[][] = [['示例A', '100'], ['示例B', '200']];
  @State theme: 'light' | 'dark' = ThemeManager.current;
  @State isLoading: boolean = false;
  @State errorMsg: string = '';

  aboutToAppear(): void {
    const params = router.getParams();
    if (params?.isEdit && params?.recordData) {
      this.loadFromRecord(params.recordData as string);
    }
  }

  loadFromRecord(dataJson: string): void {
    try {
      const model = ChartDataModel.fromJSON(dataJson);
      if (model) {
        this.headers = ['类别'];
        if (model.series.length > 0) {
          this.headers = ['类别'].concat(model.series.map(s => s.name));
        }
        this.rows = model.xAxisLabels.map((label, i) => {
          const row: string[] = [label];
          for (const s of model.series) {
            row.push(s.data[i]?.toString() || '0');
          }
          return row;
        });
      }
    } catch (err) {
      console.error('DataInputPage', `Load from record failed: ${JSON.stringify(err)}`);
    }
  }

  // 添加行
  addRow(): void {
    const newRow = new Array(this.headers.length).fill('');
    this.rows.push(newRow);
  }

  // 删除行
  removeRow(index: number): void {
    if (this.rows.length > 1) {
      this.rows.splice(index, 1);
    }
  }

  // 添加列
  addColumn(): void {
    this.headers.push(`数据${this.headers.length}`);
    for (const row of this.rows) {
      row.push('');
    }
  }

  // 删除列
  removeColumn(index: number): void {
    if (this.headers.length > 1) {
      this.headers.splice(index, 1);
      for (const row of this.rows) {
        row.splice(index, 1);
      }
    }
  }

  // 更新单元格
  updateCell(rowIndex: number, colIndex: number, value: string): void {
    if (rowIndex < this.rows.length && colIndex < this.rows[rowIndex].length) {
      this.rows[rowIndex][colIndex] = value;
    }
  }

  // 导入 CSV
  async importCSV(): Promise<void> {
    this.isLoading = true;
    this.errorMsg = '';
    try {
      const filePath = await FileHelper.pickCSVFile();
      if (filePath) {
        const [headers, rows] = await CSVParser.parseFromFile(filePath);
        if (headers.length > 0 && rows.length > 0) {
          this.headers = headers;
          this.rows = rows;
        }
      }
    } catch (err) {
      this.errorMsg = 'CSV 导入失败';
    }
    this.isLoading = false;
  }

  // 下一步：进入图表配置
  onNext(): void {
    if (this.rows.length === 0 || this.headers.length === 0) {
      this.errorMsg = '请至少输入一行数据';
      return;
    }

    // 验证数据
    for (let i = 0; i < this.rows.length; i++) {
      const row = this.rows[i];
      for (let j = 0; j < row.length; j++) {
        if (row[j].trim() === '') {
          this.errorMsg = `第 ${i + 1} 行第 ${j + 1} 列为空`;
          return;
        }
      }
    }

    // 构建 ChartDataModel
    const model = ChartDataModel.fromTableData(this.headers, this.rows, 0, Array.from({ length: Math.max(0, this.headers.length - 1) }, (_, i) => i + 1));

    const params = router.getParams();
    router.pushUrl({
      url: 'pages/ChartConfigPage',
      params: {
        recordId: params?.recordId || Date.now().toString(),
        recordName: params?.recordName || '新图表',
        recordType: params?.recordType || ChartType.BAR,
        recordData: model.toJSON(),
        recordConfig: params?.recordConfig || '',
        isEdit: params?.isEdit || false,
        dataHeaders: this.headers,
        dataRows: JSON.stringify(this.rows)
      }
    });
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(28)
          .height(28)
          .onClick(() => router.back())

        Text('数据输入')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })

        Spacer()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#F5F5F5')

      // 工具栏
      Row() {
        Button('导入 CSV')
          .onClick(() => this.importCSV())
          .type(ButtonType.Capsule)
          .backgroundColor('#5B8FF9')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .margin({ left: 16, top: 12 })

        Button('+ 列')
          .onClick(() => this.addColumn())
          .type(ButtonType.Capsule)
          .backgroundColor('#5AD8A6')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .margin({ left: 8, top: 12 })

        Spacer()
      }
      .width('100%')

      // 错误信息
      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize(14)
          .fontColor('#FF6B6B')
          .margin({ top: 8, left: 16 })
          .width('100%')
      }

      // 数据表格
      Scroll() {
        Column() {
          // 表头
          Row() {
            ForEach(this.headers, (header: string, colIdx: number) => {
              Text(header)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.theme === 'dark' ? '#AAAAAA' : '#666666')
                .width(100)
                .height(40)
                .textAlign(TextAlign.Center)
                .border({ bottom: { width: 1, color: this.theme === 'dark' ? '#333333' : '#E8E8E8' } })
            }, (header: string, idx: number) => idx.toString())
          }
          .width('100%')

          // 数据行
          ForEach(this.rows, (row: string[], rowIdx: number) => {
            ListItem() {
              Row() {
                ForEach(this.headers, (_, colIdx: number) => {
                  TextInput({ placeholder: rowIdx === 0 ? '' : '0', text: row[colIdx] })
                    .width(100)
                    .height(40)
                    .fontSize(14)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
                    .border({ bottom: { width: 1, color: this.theme === 'dark' ? '#333333' : '#E8E8E8' } })
                    .onChange((value: string) => this.updateCell(rowIdx, colIdx, value))
                }, (_, idx: number) => idx.toString())

                // 删除行按钮
                Button('-')
                  .onClick(() => this.removeRow(rowIdx))
                  .backgroundColor('#FF6B6B')
                  .fontColor('#FFFFFF')
                  .fontSize(12)
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .margin({ left: 8 })
              }
              .width('100%')
            }
          }, (row: string[], idx: number) => idx.toString())
        }
      }
      .width('100%')
      .flex(1)

      // 底部操作栏
      Row() {
        Button('+ 行')
          .onClick(() => this.addRow())
          .type(ButtonType.Capsule)
          .backgroundColor('#5AD8A6')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .margin({ left: 16 })

        Spacer()

        Button('下一步')
          .onClick(() => this.onNext())
          .type(ButtonType.Capsule)
          .backgroundColor('#5B8FF9')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(64)
      .alignItems(VerticalAlign.Center)
      .border({ top: { width: 1, color: this.theme === 'dark' ? '#333333' : '#E8E8E8' } })
      .backgroundColor(this.theme === 'dark' ? '#2D2D2D' : '#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme === 'dark' ? '#1A1A1A' : '#F5F5F5')
  }
}
