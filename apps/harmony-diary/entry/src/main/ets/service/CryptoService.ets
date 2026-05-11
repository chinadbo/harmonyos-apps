import huks from '@ohos.security.huks';
import cryptoFramework from '@ohos.security.cryptoFramework';
import { EncryptedText } from '../model/DiaryModel';

export class CryptoService {
  private static instance?: CryptoService;
  private readonly alias: string = 'harmony_diary_master_key';

  static getInstance(): CryptoService {
    if (!CryptoService.instance) {
      CryptoService.instance = new CryptoService();
    }
    return CryptoService.instance;
  }

  private buildBaseProperties(): Object[] {
    return [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT
      },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_GCM },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
      { tag: huks.HuksTag.HUKS_TAG_DIGEST, value: huks.HuksKeyDigest.HUKS_DIGEST_NONE }
    ];
  }

  private buildOptions(iv?: Uint8Array): huks.HuksOptions {
    const properties: Object[] = this.buildBaseProperties();
    if (iv) {
      properties.push({ tag: huks.HuksTag.HUKS_TAG_NONCE, value: iv });
    }
    return { properties };
  }

  private async randomIv(): Promise<Uint8Array> {
    // 使用 cryptoFramework 生成密码学安全随机数（CSPRNG），替代不安全的 Math.random()
    const rand = cryptoFramework.createRandom();
    const dataBlob = await rand.generateRandom(12);
    return new Uint8Array(dataBlob.data);
  }

  private encode(value: string): Uint8Array {
    return new Uint8Array(new TextEncoder().encode(value));
  }

  private decode(value: Uint8Array): string {
    return new TextDecoder().decode(value);
  }

  private toHex(value: Uint8Array): string {
    let result = '';
    value.forEach((item: number) => {
      const hex = item.toString(16).padStart(2, '0');
      result += hex;
    });
    return result;
  }

  private fromHex(value: string): Uint8Array {
    const bytes = new Uint8Array(value.length / 2);
    for (let index = 0; index < bytes.length; index++) {
      bytes[index] = Number.parseInt(value.slice(index * 2, index * 2 + 2), 16);
    }
    return bytes;
  }

  async ensureKey(): Promise<void> {
    let exists = false;
    try {
      const result = await huks.isKeyItemExist(this.alias, this.buildOptions());
      exists = typeof result === 'boolean' ? result : Boolean((result as Record<string, Object>)['isKeyExist']);
    } catch (_error) {
      exists = false;
    }
    if (!exists) {
      await huks.generateKeyItem(this.alias, this.buildOptions());
    }
  }

  async encryptText(plainText: string): Promise<EncryptedText> {
    await this.ensureKey();
    // P0 Fix: 使用 CSPRNG 生成安全随机 IV（替代 Math.random()）
    const iv = await this.randomIv();
    const options = this.buildOptions(iv);
    // P0 Fix: HUKS 三段式 init → update → finish，移除 initSession 多余第三参数
    const initResult = await huks.initSession(this.alias, options) as Record<string, Object>;
    const handle = initResult['handle'] as number;
    const plainBytes = this.encode(plainText);
    // P0 Fix: 通过 updateSession 传递明文数据块
    const updateOptions: huks.HuksOptions = { properties: options.properties, inData: plainBytes };
    await huks.updateSession(handle, updateOptions);
    // finishSession 的 inData 传空，表示数据已全部通过 update 传递
    const finishOptions: huks.HuksOptions = { properties: options.properties, inData: new Uint8Array(0) };
    const finishResult = await huks.finishSession(handle, finishOptions) as Record<string, Object>;
    const encryptedBytes = (finishResult['outData'] ?? finishResult['data']) as Uint8Array;
    return {
      iv: this.toHex(iv),
      cipherText: this.toHex(encryptedBytes)
    };
  }

  async decryptText(value: EncryptedText): Promise<string> {
    await this.ensureKey();
    const iv = this.fromHex(value.iv);
    const options = this.buildOptions(iv);
    // P0 Fix: 移除 initSession 多余第三参数
    const initResult = await huks.initSession(this.alias, options) as Record<string, Object>;
    const handle = initResult['handle'] as number;
    const cipherBytes = this.fromHex(value.cipherText);
    // P0 Fix: 通过 updateSession 传递密文数据块
    const updateOptions: huks.HuksOptions = { properties: options.properties, inData: cipherBytes };
    await huks.updateSession(handle, updateOptions);
    // finishSession 的 inData 传空
    const finishOptions: huks.HuksOptions = { properties: options.properties, inData: new Uint8Array(0) };
    const finishResult = await huks.finishSession(handle, finishOptions) as Record<string, Object>;
    const decryptedBytes = (finishResult['outData'] ?? finishResult['data']) as Uint8Array;
    return this.decode(decryptedBytes);
  }
}

export const cryptoService = CryptoService.getInstance();
