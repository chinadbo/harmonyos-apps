import { Article } from '../model/Article';
import { Feed } from '../model/Feed';
import { DateUtils } from '../utils/DateUtils';
import { StringUtils } from '../utils/StringUtils';

/**
 * RSS/Atom Feed 解析器
 * 支持 RSS 2.0 / Atom 1.0 格式
 * 使用正则解析 XML（HarmonyOS 无内置 DOMParser，用正则实现轻量解析）
 */
export class RssParser {

  /**
   * 解析 Feed XML，返回 { feedMeta, articles }
   */
  static parse(xml: string, feedId: number, feedUrl: string): {
    feedTitle: string;
    feedDescription: string;
    articles: Article[];
  } {
    // 清理 XML 声明和命名空间，简化解析
    const cleanXml = xml
      .replace(/<\?xml[^>]*\?>/g, '')
      .replace(/xmlns:[^=]+="[^"]*"/g, '')
      // 仅去除 XML 标签内的命名空间前缀（避免破坏正文中的 URL）
      .replace(/<([a-z]+):(\w[\w-]*)/gi, '<$2')
      .replace(/<\/([a-z]+):(\w[\w-]*)/gi, '</$2');

    const isAtom = /<feed[\s>]/.test(cleanXml);

    if (isAtom) {
      return RssParser.parseAtom(cleanXml, feedId, feedUrl);
    } else {
      return RssParser.parseRss(cleanXml, feedId, feedUrl);
    }
  }

  // ===== RSS 2.0 解析 =====
  private static parseRss(xml: string, feedId: number, feedUrl: string): {
    feedTitle: string;
    feedDescription: string;
    articles: Article[];
  } {
    const feedTitle = RssParser.extractTag(xml, 'title') || feedUrl;
    const feedDescription = RssParser.extractTag(xml, 'description') || '';

    // 提取所有 <item> 块
    const itemBlocks = RssParser.extractAllBlocks(xml, 'item');
    const articles: Article[] = [];

    for (const block of itemBlocks) {
      const title = StringUtils.stripHtml(RssParser.extractTag(block, 'title') || '');
      const link = RssParser.extractTag(block, 'link') ||
        RssParser.extractAttr(block, 'link', 'href') || '';
      const guid = RssParser.extractTag(block, 'guid') || link;
      const author = RssParser.extractTag(block, 'author') ||
        RssParser.extractTag(block, 'creator') || '';
      const pubDate = RssParser.extractTag(block, 'pubDate') ||
        RssParser.extractTag(block, 'date') || '';
      const description = RssParser.extractTag(block, 'description') || '';
      const content = RssParser.extractTag(block, 'encoded') ||
        RssParser.extractTag(block, 'content') || description;

      if (!title && !link) continue;

      articles.push(new Article({
        feedId,
        feedTitle,
        guid: guid || `${feedUrl}_${Date.now()}_${Math.random()}`,
        title: title || '(无标题)',
        link,
        author: StringUtils.stripHtml(author),
        summary: StringUtils.truncate(StringUtils.stripHtml(description), 500),
        content,
        publishedAt: DateUtils.parseDate(pubDate) || Date.now(),
        createdAt: Date.now(),
      }));
    }

    return { feedTitle, feedDescription, articles };
  }

  // ===== Atom 1.0 解析 =====
  private static parseAtom(xml: string, feedId: number, feedUrl: string): {
    feedTitle: string;
    feedDescription: string;
    articles: Article[];
  } {
    const feedTitle = StringUtils.stripHtml(RssParser.extractTag(xml, 'title') || feedUrl);
    const feedDescription = StringUtils.stripHtml(RssParser.extractTag(xml, 'subtitle') || '');

    // 提取所有 <entry> 块
    const entryBlocks = RssParser.extractAllBlocks(xml, 'entry');
    const articles: Article[] = [];

    for (const block of entryBlocks) {
      const title = StringUtils.stripHtml(RssParser.extractTag(block, 'title') || '');
      // Atom link: <link href="..." rel="alternate"/>
      const link = RssParser.extractAtomLink(block);
      const guid = RssParser.extractTag(block, 'id') || link;
      const author = StringUtils.stripHtml(RssParser.extractTag(block, 'name') || '');
      const updated = RssParser.extractTag(block, 'updated') ||
        RssParser.extractTag(block, 'published') || '';
      const summary = RssParser.extractTag(block, 'summary') || '';
      const content = RssParser.extractTag(block, 'content') || summary;

      if (!title && !link) continue;

      articles.push(new Article({
        feedId,
        feedTitle,
        guid: guid || `${feedUrl}_${Date.now()}_${Math.random()}`,
        title: title || '(无标题)',
        link,
        author,
        summary: StringUtils.truncate(StringUtils.stripHtml(summary), 500),
        content,
        publishedAt: DateUtils.parseDate(updated) || Date.now(),
        createdAt: Date.now(),
      }));
    }

    return { feedTitle, feedDescription, articles };
  }

  // ===== XML 辅助解析 =====

  /** 提取标签内容（第一个匹配） */
  private static extractTag(xml: string, tag: string): string {
    const regex = new RegExp(`<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`, 'i');
    const match = xml.match(regex);
    if (!match) return '';
    // 去除 CDATA 包装
    return match[1].replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1').trim();
  }

  /** 提取标签属性值 */
  private static extractAttr(xml: string, tag: string, attr: string): string {
    const regex = new RegExp(`<${tag}[^>]*${attr}="([^"]*)"`, 'i');
    const match = xml.match(regex);
    return match ? match[1] : '';
  }

  /** 提取 Atom <link href="..." rel="alternate"/> */
  private static extractAtomLink(xml: string): string {
    // 优先找 rel="alternate" 的 link
    const altMatch = xml.match(/<link[^>]*rel="alternate"[^>]*href="([^"]*)"/i);
    if (altMatch) return altMatch[1];
    // 再找没有 rel 属性的 link
    const plainMatch = xml.match(/<link[^>]*href="([^"]*)"/i);
    if (plainMatch) return plainMatch[1];
    // 最后找纯文本 <link>url</link>
    return RssParser.extractTag(xml, 'link');
  }

  /** 提取所有指定标签块 */
  private static extractAllBlocks(xml: string, tag: string): string[] {
    const blocks: string[] = [];
    const regex = new RegExp(`<${tag}[^>]*>[\\s\\S]*?<\\/${tag}>`, 'gi');
    let match: RegExpExecArray | null;
    while ((match = regex.exec(xml)) !== null) {
      blocks.push(match[0]);
    }
    return blocks;
  }
}
