import fs from '@ohos.file.fs';

/**
 * CSV 文件解析器
 * 将 CSV 文件内容解析为二维数组
 */
export class CSVParser {

  /**
   * 从文件路径解析 CSV
   * @param path CSV 文件路径
   * @returns Promise<[string[], string[][]]>
   */
  static async parseFromFile(path: string): Promise<[string[], string[][]]> {
    const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    const buffer = new ArrayBuffer(65536);
    const readLen = fs.readSync(file.fd, buffer);
    const text = new TextDecoder().decode(buffer.slice(0, readLen));
    fs.closeSync(file);
    return this.parseFromText(text);
  }

  /**
   * 将 CSV 文本解析为表头和数据行
   * @param text CSV 文本
   * @returns [表头数组, 数据行二维数组]
   */
  static parseFromText(text: string): [string[], string[][]] {
    const lines = text.split('\n').filter(line => line.trim() !== '');
    if (lines.length === 0) {
      return [[], []];
    }

    const headers = this.parseCSVLine(lines[0]);
    const rows: string[][] = [];

    for (let i = 1; i < lines.length; i++) {
      rows.push(this.parseCSVLine(lines[i]));
    }

    return [headers, rows];
  }

  /**
   * 将二维数组导出为 CSV 文本
   * @param headers 表头
   * @param rows 数据行
   * @returns CSV 文本
   */
  static exportToCSV(headers: string[], rows: string[][]): string {
    const headerLine = this.escapeCSV(headers).join(',');
    const dataLines = rows.map(row => this.escapeCSV(row).join(',')).join('\n');
    return headerLine + '\n' + dataLines;
  }

  /**
   * 解析单行 CSV（带引号处理）
   */
  private static parseCSVLine(line: string): string[] {
    const result: string[] = [];
    let current = '';
    let inQuotes = false;

    for (let i = 0; i < line.length; i++) {
      const char = line[i];

      if (inQuotes) {
        if (char === '"') {
          // 检查是否是转义引号
          if (i + 1 < line.length && line[i + 1] === '"') {
            current += '"';
            i++; // 跳过下一个引号
          } else {
            inQuotes = false;
          }
        } else {
          current += char;
        }
      } else {
        if (char === '"') {
          inQuotes = true;
        } else if (char === ',') {
          result.push(current.trim());
          current = '';
        } else {
          current += char;
        }
      }
    }

    result.push(current.trim());
    return result;
  }

  /**
   * 转义 CSV 字段（处理逗号和引号）
   */
  private static escapeCSV(fields: string[]): string[] {
    return fields.map(field => {
      if (field.includes(',') || field.includes('"') || field.includes('\n')) {
        return '"' + field.replace(/"/g, '""') + '"';
      }
      return field;
    });
  }
}
