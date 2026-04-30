import { Feed } from '../model/Feed';

/**
 * OPML 工具类
 * 支持 OPML 2.0 格式的导入和导出
 */
export class OpmlUtils {
  /**
   * 将 Feed 列表导出为 OPML XML 字符串
   */
  static exportToOpml(feeds: Feed[]): string {
    const now = new Date().toUTCString();
    let opmlBody = '';
    feeds.forEach(feed => {
      const title = feed.title.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
      const url = feed.url.replace(/&/g, '&amp;');
      opmlBody += `    <outline type="rss" text="${title}" title="${title}" xmlUrl="${url}"/>\n`;
    });

    return `<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>HarmonyFeed Subscriptions</title>
    <dateCreated>${now}</dateCreated>
  </head>
  <body>
${opmlBody}  </body>
</opml>`;
  }

  /**
   * 从 OPML XML 字符串中解析订阅源列表
   * 返回 { url: string, title: string }[] 
   */
  static parseOpml(opmlXml: string): Array<{ url: string; title: string }> {
    const results: Array<{ url: string; title: string }> = [];
    // 简单正则匹配 outline 标签中的 xmlUrl 和 text/title
    const outlineRegex = /<outline[^>]+xmlUrl="([^"]+)"[^>]*(?:text|title)="([^"]*)"[^>]*\/>/gi;
    let match: RegExpExecArray | null;
    while ((match = outlineRegex.exec(opmlXml)) !== null) {
      const url = match[1];
      const title = match[2] || url;
      if (url) {
        results.push({ url, title });
      }
    }
    // 兼容 text/title 在前面的情况
    const outlineRegex2 = /<outline[^>]+(?:text|title)="([^"]*)"[^>]*xmlUrl="([^"]+)"[^>]*\/>/gi;
    while ((match = outlineRegex2.exec(opmlXml)) !== null) {
      const title = match[1];
      const url = match[2];
      if (url && !results.find(r => r.url === url)) {
        results.push({ url, title: title || url });
      }
    }
    return results;
  }
}
