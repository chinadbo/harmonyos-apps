/**
 * 字符串工具类
 */
export class StringUtils {
  /**
   * 去除 HTML 标签，返回纯文本
   */
  static stripHtml(html: string): string {
    if (!html) return '';
    return html
      .replace(/<[^>]+>/g, '')
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&nbsp;/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  /**
   * 截断字符串到指定长度，超出加省略号
   */
  static truncate(str: string, maxLen: number): string {
    if (!str) return '';
    if (str.length <= maxLen) return str;
    return str.substring(0, maxLen) + '...';
  }

  /**
   * 从 URL 中提取域名（用于显示来源）
   */
  static getDomain(url: string): string {
    if (!url) return '';
    try {
      const match = url.match(/^https?:\/\/([^/]+)/);
      return match ? match[1].replace('www.', '') : url;
    } catch {
      return url;
    }
  }

  /**
   * 验证是否是有效的公网 URL（同时防止 SSRF 内网探测）
   * 过滤：localhost、127.0.0.1、10.*、172.16-31.*、192.168.*、file://
   */
  static isValidUrl(url: string): boolean {
    if (!url) return false;
    if (!/^https?:\/\/.+/.test(url)) return false;
    // 防 SSRF：过滤内网/本地地址
    const lower = url.toLowerCase();
    const internalPatterns = [
      /^https?:\/\/localhost/i,
      /^https?:\/\/127\./,
      /^https?:\/\/0\.0\.0\.0/,
      /^https?:\/\/10\.\d+\.\d+\.\d+/,
      /^https?:\/\/172\.(1[6-9]|2\d|3[01])\./,
      /^https?:\/\/192\.168\./,
      /^https?:\/\/::1/,
    ];
    for (const pattern of internalPatterns) {
      if (pattern.test(lower)) return false;
    }
    return true;
  }

  /**
   * 从 Feed 内容中提取 favicon URL
   */
  static getFaviconUrl(feedUrl: string): string {
    const domain = StringUtils.getDomain(feedUrl);
    return `https://${domain}/favicon.ico`;
  }
}
