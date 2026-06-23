import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import preferences from '@ohos.data.preferences';
import { AppSettings, MindMap, MindMapMeta, createMindMap } from '../models/MindMap';
import { MindNode, createMindNode } from '../models/MindNode';
import { Constants } from './Constants';

export class FileStorage {
  private context: common.UIAbilityContext;
  private preference?: preferences.Preferences;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async initialize(): Promise<void> {
    try {
      await this.ensurePreference();
      await this.ensureStorageDirectory();
      await this.ensureSettings();
    } catch (error) {
      console.error(`initialize failed: ${JSON.stringify(error)}`);
    }
  }

  async loadMindMaps(): Promise<Array<MindMapMeta>> {
    try {
      const pref: preferences.Preferences = await this.ensurePreference();
      const rawValue: string = await pref.get(Constants.META_KEY, '[]') as string;
      const parsed: Array<MindMapMeta> = JSON.parse(rawValue) as Array<MindMapMeta>;
      return parsed.sort((left: MindMapMeta, right: MindMapMeta) => right.updatedAt - left.updatedAt);
    } catch (error) {
      console.error(`loadMindMaps failed: ${JSON.stringify(error)}`);
      return [];
    }
  }

  async loadSettings(): Promise<AppSettings> {
    try {
      const pref: preferences.Preferences = await this.ensurePreference();
      const rawValue: string = await pref.get(Constants.SETTINGS_KEY, '') as string;
      if (!rawValue) {
        return { isDarkMode: Constants.DEFAULT_THEME_DARK };
      }
      return JSON.parse(rawValue) as AppSettings;
    } catch (error) {
      console.error(`loadSettings failed: ${JSON.stringify(error)}`);
      return { isDarkMode: Constants.DEFAULT_THEME_DARK };
    }
  }

  async saveSettings(settings: AppSettings): Promise<void> {
    try {
      const pref: preferences.Preferences = await this.ensurePreference();
      await pref.put(Constants.SETTINGS_KEY, JSON.stringify(settings));
      await pref.flush();
    } catch (error) {
      console.error(`saveSettings failed: ${JSON.stringify(error)}`);
    }
  }

  async createMindMap(title: string): Promise<MindMap> {
    const mindMapId: string = this.createId();
    const safeTitle: string = title && title.trim().length > 0 ? title.trim() : Constants.DEFAULT_TITLE;
    const mindMap: MindMap = createMindMap(mindMapId, safeTitle, Constants.COLOR_PALETTE[0]);
    await this.saveMindMap(mindMap);
    return mindMap;
  }

  async loadMindMapById(id: string): Promise<MindMap | null> {
    try {
      const filePath: string = this.buildFilePath(`${id}${Constants.FILE_EXTENSION}`);
      if (!this.exists(filePath)) {
        return null;
      }
      const stat = fs.statSync(filePath);
      if (!stat) {
        return null;
      }
      const file: fs.File = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const bufferLength: number = Number(stat.size);
      const arrayBuffer: ArrayBuffer = new ArrayBuffer(bufferLength);
      fs.readSync(file.fd, arrayBuffer, { offset: 0, length: bufferLength });
      fs.closeSync(file);
      const content: string = this.arrayBufferToString(arrayBuffer);
      const parsed: MindMap = JSON.parse(content) as MindMap;
      return this.normalizeMindMap(parsed);
    } catch (error) {
      console.error(`loadMindMapById failed: ${JSON.stringify(error)}`);
      return null;
    }
  }

  async saveMindMap(mindMap: MindMap): Promise<void> {
    try {
      await this.ensureStorageDirectory();
      const target: MindMap = this.normalizeMindMap(mindMap);
      target.updatedAt = Date.now();
      const fileName: string = `${target.id}${Constants.FILE_EXTENSION}`;
      const filePath: string = this.buildFilePath(fileName);
      const content: string = JSON.stringify(target);
      const file: fs.File = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, content);
      fs.closeSync(file);
      await this.upsertMeta({
        id: target.id,
        title: target.title,
        fileName,
        createdAt: target.createdAt,
        updatedAt: target.updatedAt,
        nodeCount: Object.keys(target.nodes).length
      });
    } catch (error) {
      console.error(`saveMindMap failed: ${JSON.stringify(error)}`);
    }
  }

  async renameMindMap(id: string, title: string): Promise<void> {
    try {
      const mindMap: MindMap | null = await this.loadMindMapById(id);
      if (!mindMap) {
        return;
      }
      mindMap.title = title.trim().length > 0 ? title.trim() : mindMap.title;
      const rootNode: MindNode = mindMap.nodes[mindMap.rootNodeId];
      if (rootNode && rootNode.text.trim().length === 0) {
        rootNode.text = mindMap.title;
      }
      await this.saveMindMap(mindMap);
    } catch (error) {
      console.error(`renameMindMap failed: ${JSON.stringify(error)}`);
    }
  }

  async deleteMindMap(id: string): Promise<void> {
    try {
      const metas: Array<MindMapMeta> = await this.loadMindMaps();
      const targetMeta: MindMapMeta | undefined = metas.find((item: MindMapMeta) => item.id === id);
      if (targetMeta) {
        const filePath: string = this.buildFilePath(targetMeta.fileName);
        if (this.exists(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
      const nextMetas: Array<MindMapMeta> = metas.filter((item: MindMapMeta) => item.id !== id);
      await this.saveMetaList(nextMetas);
    } catch (error) {
      console.error(`deleteMindMap failed: ${JSON.stringify(error)}`);
    }
  }

  private async ensurePreference(): Promise<preferences.Preferences> {
    if (this.preference) {
      return this.preference;
    }
    this.preference = await preferences.getPreferences(this.context, Constants.PREFERENCES_NAME);
    return this.preference;
  }

  private async ensureSettings(): Promise<void> {
    try {
      const pref: preferences.Preferences = await this.ensurePreference();
      const value: string = await pref.get(Constants.SETTINGS_KEY, '') as string;
      if (!value) {
        await pref.put(Constants.SETTINGS_KEY, JSON.stringify({ isDarkMode: Constants.DEFAULT_THEME_DARK }));
        await pref.flush();
      }
    } catch (error) {
      console.error(`ensureSettings failed: ${JSON.stringify(error)}`);
    }
  }

  private async ensureStorageDirectory(): Promise<void> {
    try {
      const basePath: string = this.getStorageDirectory();
      if (!this.exists(basePath)) {
        fs.mkdirSync(basePath);
      }
    } catch (error) {
      console.error(`ensureStorageDirectory failed: ${JSON.stringify(error)}`);
    }
  }

  private async upsertMeta(meta: MindMapMeta): Promise<void> {
    try {
      const metas: Array<MindMapMeta> = await this.loadMindMaps();
      const filtered: Array<MindMapMeta> = metas.filter((item: MindMapMeta) => item.id !== meta.id);
      filtered.push(meta);
      filtered.sort((left: MindMapMeta, right: MindMapMeta) => right.updatedAt - left.updatedAt);
      await this.saveMetaList(filtered);
    } catch (error) {
      console.error(`upsertMeta failed: ${JSON.stringify(error)}`);
    }
  }

  private async saveMetaList(metas: Array<MindMapMeta>): Promise<void> {
    try {
      const pref: preferences.Preferences = await this.ensurePreference();
      await pref.put(Constants.META_KEY, JSON.stringify(metas));
      await pref.flush();
    } catch (error) {
      console.error(`saveMetaList failed: ${JSON.stringify(error)}`);
    }
  }

  private buildFilePath(fileName: string): string {
    return `${this.getStorageDirectory()}/${fileName}`;
  }

  private getStorageDirectory(): string {
    return `${this.context.filesDir}/${Constants.STORAGE_DIR}`;
  }

  private exists(path: string): boolean {
    try {
      fs.accessSync(path);
      return true;
    } catch (error) {
      return false;
    }
  }

  private createId(): string {
    return `mind_${Date.now()}_${Math.floor(Math.random() * 100000)}`;
  }

  private normalizeMindMap(mindMap: MindMap): MindMap {
    const normalizedNodes: Record<string, MindNode> = {};
    Object.keys(mindMap.nodes).forEach((nodeId: string) => {
      const node: MindNode = mindMap.nodes[nodeId];
      normalizedNodes[nodeId] = {
        id: node.id,
        parentId: node.parentId,
        text: node.text,
        color: node.color,
        childrenIds: Array.isArray(node.childrenIds) ? node.childrenIds : [],
        depth: typeof node.depth === 'number' ? node.depth : 0,
        x: typeof node.x === 'number' ? node.x : 0,
        y: typeof node.y === 'number' ? node.y : 0,
        width: typeof node.width === 'number' ? node.width : Constants.NODE_WIDTH,
        height: typeof node.height === 'number' ? node.height : Constants.NODE_HEIGHT
      };
    });
    if (!normalizedNodes[mindMap.rootNodeId]) {
      normalizedNodes[mindMap.rootNodeId] = createMindNode(mindMap.rootNodeId, '', mindMap.title, Constants.COLOR_PALETTE[0], 0);
    }
    return {
      id: mindMap.id,
      title: mindMap.title,
      rootNodeId: mindMap.rootNodeId,
      nodes: normalizedNodes,
      createdAt: mindMap.createdAt || Date.now(),
      updatedAt: mindMap.updatedAt || Date.now(),
      scale: mindMap.scale || 1,
      offsetX: mindMap.offsetX || 0,
      offsetY: mindMap.offsetY || 0
    };
  }

  private arrayBufferToString(buffer: ArrayBuffer): string {
    return String.fromCharCode.apply(null, Array.from(new Uint8Array(buffer)));
  }
}
