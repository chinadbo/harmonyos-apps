import { ClipType } from '../model/ClipEntry';

const RE_URL = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
const RE_EMAIL = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;
const RE_PHONE = /^(\+?86)?1[3-9]\d{9}$/;
const RE_JSON_OBJ = /^\s*\{[\s\S]*\}\s*$/;
const RE_JSON_ARR = /^\s*\[[\s\S]*\]\s*$/;

// Patterns for privacy detection (password keywords, not phone/ID itself)
const RE_PRIVATE_KEYWORDS = /password|passwd|密码|secret|token|apikey|api_key/i;

const PREVIEW_MAX_LEN = 120;

export class ClipDetector {
  static detect(content: string): ClipType {
    const trimmed = content.trim();
    if (RE_URL.test(trimmed)) {
      return ClipType.URL;
    }
    if (RE_EMAIL.test(trimmed)) {
      return ClipType.EMAIL;
    }
    if (RE_PHONE.test(trimmed.replace(/\s|-/g, ''))) {
      return ClipType.PHONE;
    }
    if (RE_JSON_OBJ.test(trimmed) || RE_JSON_ARR.test(trimmed)) {
      try {
        JSON.parse(trimmed);
        return ClipType.JSON;
      } catch {
        // not valid JSON
      }
    }
    return ClipType.TEXT;
  }

  static isPrivate(content: string): boolean {
    // Only mark as private if content contains explicit password/secret keywords
    return RE_PRIVATE_KEYWORDS.test(content);
  }

  static buildPreview(content: string, isPrivate: boolean): string {
    if (isPrivate) {
      return '●●● 隐私内容 ●●●';
    }
    const trimmed = content.replace(/\s+/g, ' ').trim();
    if (trimmed.length <= PREVIEW_MAX_LEN) {
      return trimmed;
    }
    return trimmed.substring(0, PREVIEW_MAX_LEN) + '…';
  }

  static formatRelativeTime(timestamp: number): string {
    const diffMs = Date.now() - timestamp;
    const diffSec = Math.floor(diffMs / 1000);
    if (diffSec < 60) {
      return '刚刚';
    }
    const diffMin = Math.floor(diffSec / 60);
    if (diffMin < 60) {
      return `${diffMin} 分钟前`;
    }
    const diffHour = Math.floor(diffMin / 60);
    if (diffHour < 24) {
      return `${diffHour} 小时前`;
    }
    const diffDay = Math.floor(diffHour / 24);
    if (diffDay < 30) {
      return `${diffDay} 天前`;
    }
    const date = new Date(timestamp);
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }
}
