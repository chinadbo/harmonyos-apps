import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import { PinyinUtil } from '../utils/PinyinUtil'

const CREATE_WORDS_SQL = 'CREATE TABLE IF NOT EXISTS WORDS (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT NOT NULL UNIQUE, pinyin TEXT NOT NULL, definition TEXT NOT NULL, example TEXT NOT NULL, synonyms TEXT NOT NULL, antonyms TEXT NOT NULL, group_name TEXT NOT NULL, strokes INTEGER NOT NULL, radical TEXT NOT NULL, is_recommended INTEGER NOT NULL DEFAULT 0)'
const CREATE_IDIOMS_SQL = 'CREATE TABLE IF NOT EXISTS IDIOMS (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT NOT NULL UNIQUE, pinyin TEXT NOT NULL, summary TEXT NOT NULL, story TEXT NOT NULL, derivation TEXT NOT NULL, sample TEXT NOT NULL, initial TEXT NOT NULL)'
const CREATE_FAVORITES_SQL = 'CREATE TABLE IF NOT EXISTS FAVORITES (id INTEGER PRIMARY KEY AUTOINCREMENT, entry_id INTEGER NOT NULL, entry_type TEXT NOT NULL, word TEXT NOT NULL, pinyin TEXT NOT NULL, definition TEXT NOT NULL, group_name TEXT NOT NULL, created_at TEXT NOT NULL, UNIQUE(entry_id, entry_type))'
const CREATE_HISTORY_SQL = 'CREATE TABLE IF NOT EXISTS HISTORY (id INTEGER PRIMARY KEY AUTOINCREMENT, entry_id INTEGER NOT NULL, entry_type TEXT NOT NULL, word TEXT NOT NULL, pinyin TEXT NOT NULL, definition TEXT NOT NULL, query_text TEXT NOT NULL, created_at TEXT NOT NULL)'

const WORD_SEED_DATA = [
  { word: '春风', pinyin: 'chun feng', definition: '春日和暖的风，也比喻良好的教化。', example: '春风拂面，让人心情舒展。', synonyms: '和风', antonyms: '朔风', groupName: '默认', strokes: 9, radical: '日', isRecommended: 1 },
  { word: '山川', pinyin: 'shan chuan', definition: '山岳与河流的合称。', example: '祖国山川壮丽多姿。', synonyms: '河山', antonyms: '平原', groupName: '默认', strokes: 6, radical: '山', isRecommended: 1 },
  { word: '清朗', pinyin: 'qing lang', definition: '清明晴朗，也形容声音清亮。', example: '雨后的天空格外清朗。', synonyms: '晴朗', antonyms: '阴晦', groupName: '默认', strokes: 11, radical: '氵', isRecommended: 1 },
  { word: '敦厚', pinyin: 'dun hou', definition: '忠厚朴实。', example: '他待人敦厚真诚。', synonyms: '厚道', antonyms: '刻薄', groupName: '默认', strokes: 12, radical: '攵', isRecommended: 0 },
  { word: '旷达', pinyin: 'kuang da', definition: '胸襟开阔，性情豁达。', example: '诗句中透出旷达的气度。', synonyms: '豁达', antonyms: '拘谨', groupName: '默认', strokes: 8, radical: '日', isRecommended: 0 },
  { word: '星河', pinyin: 'xing he', definition: '银河，也泛指灿烂星空。', example: '抬头仰望，星河璀璨。', synonyms: '银河', antonyms: '无', groupName: '默认', strokes: 9, radical: '日', isRecommended: 1 },
  { word: '雅致', pinyin: 'ya zhi', definition: '高雅别致。', example: '小院布置得十分雅致。', synonyms: '雅观', antonyms: '粗俗', groupName: '默认', strokes: 12, radical: '隹', isRecommended: 0 },
  { word: '温润', pinyin: 'wen run', definition: '温和润泽，也形容人的气质。', example: '玉石表面温润柔和。', synonyms: '柔和', antonyms: '粗砺', groupName: '默认', strokes: 12, radical: '氵', isRecommended: 0 },
  { word: '笃行', pinyin: 'du xing', definition: '切实履行，专心实行。', example: '学以致用，贵在笃行。', synonyms: '践行', antonyms: '空谈', groupName: '默认', strokes: 16, radical: '竹', isRecommended: 0 },
  { word: '澄明', pinyin: 'cheng ming', definition: '清澈明净。', example: '湖水澄明如镜。', synonyms: '清澈', antonyms: '浑浊', groupName: '默认', strokes: 15, radical: '氵', isRecommended: 0 },
  { word: '远志', pinyin: 'yuan zhi', definition: '远大的志向。', example: '少年应怀远志。', synonyms: '抱负', antonyms: '短视', groupName: '默认', strokes: 7, radical: '辶', isRecommended: 1 },
  { word: '安宁', pinyin: 'an ning', definition: '平静安稳。', example: '夜色中村庄分外安宁。', synonyms: '安静', antonyms: '纷扰', groupName: '默认', strokes: 6, radical: '宀', isRecommended: 0 },
  { word: '明澈', pinyin: 'ming che', definition: '明亮而清澈。', example: '她的眼神明澈坚定。', synonyms: '透亮', antonyms: '晦暗', groupName: '默认', strokes: 15, radical: '氵', isRecommended: 0 },
  { word: '丰盈', pinyin: 'feng ying', definition: '丰富充足，也指姿态圆润。', example: '这篇文章感情丰盈。', synonyms: '充盈', antonyms: '匮乏', groupName: '默认', strokes: 9, radical: '豆', isRecommended: 0 },
  { word: '沉静', pinyin: 'chen jing', definition: '安静沉稳。', example: '他性格沉静，不急不躁。', synonyms: '沉稳', antonyms: '浮躁', groupName: '默认', strokes: 7, radical: '氵', isRecommended: 0 },
  { word: '新霁', pinyin: 'xin ji', definition: '雨后初晴。', example: '山林新霁，空气清甜。', synonyms: '初晴', antonyms: '连阴', groupName: '生僻字', strokes: 14, radical: '雨', isRecommended: 1 },
  { word: '葳蕤', pinyin: 'wei rui', definition: '形容草木茂盛，也可指华美。', example: '庭前草木葳蕤。', synonyms: '繁茂', antonyms: '凋零', groupName: '生僻字', strokes: 12, radical: '艹', isRecommended: 0 },
  { word: '氤氲', pinyin: 'yin yun', definition: '烟云弥漫，也形容气氛浓盛。', example: '茶香氤氲，满室温暖。', synonyms: '弥漫', antonyms: '消散', groupName: '生僻字', isRecommended: 0, strokes: 10, radical: '气' },
  { word: '熹微', pinyin: 'xi wei', definition: '天光微明。', example: '晨光熹微，街巷渐醒。', synonyms: '微明', antonyms: '昏暗', groupName: '生僻字', strokes: 16, radical: '灬', isRecommended: 0 },
  { word: '潋滟', pinyin: 'lian yan', definition: '形容水波荡漾闪光。', example: '湖面潋滟，映出青山。', synonyms: '波光', antonyms: '平寂', groupName: '生僻字', strokes: 14, radical: '氵', isRecommended: 0 },
  { word: '翩跹', pinyin: 'pian xian', definition: '形容轻快地旋转舞动。', example: '落叶在风中翩跹。', synonyms: '轻舞', antonyms: '滞重', groupName: '生僻字', strokes: 15, radical: '羽', isRecommended: 0 },
  { word: '缱绻', pinyin: 'qian quan', definition: '情意深厚，难舍难分。', example: '字里行间尽是缱绻深情。', synonyms: '眷恋', antonyms: '冷淡', groupName: '生僻字', strokes: 16, radical: '纟', isRecommended: 0 },
  { word: '旖旎', pinyin: 'yi ni', definition: '柔和美好，多形容风光。', example: '江南景色旖旎动人。', synonyms: '柔美', antonyms: '荒凉', groupName: '生僻字', strokes: 14, radical: '方', isRecommended: 0 },
  { word: '蹁跹', pinyin: 'pian xian', definition: '轻盈飘舞的样子。', example: '蝴蝶在花间蹁跹。', synonyms: '轻盈', antonyms: '笨重', groupName: '生僻字', strokes: 17, radical: '足', isRecommended: 0 },
  { word: '侘傺', pinyin: 'cha chi', definition: '失意惆怅。', example: '他一时侘傺难言。', synonyms: '惆怅', antonyms: '畅快', groupName: '生僻字', strokes: 8, radical: '亻', isRecommended: 0 },
  { word: '阑珊', pinyin: 'lan shan', definition: '将尽、零落，也形容夜深。', example: '夜色阑珊，灯火未歇。', synonyms: '零落', antonyms: '鼎盛', groupName: '生僻字', strokes: 12, radical: '门', isRecommended: 0 },
  { word: '缥缈', pinyin: 'piao miao', definition: '隐隐约约，若有若无。', example: '远山云雾缥缈。', synonyms: '飘忽', antonyms: '清晰', groupName: '生僻字', strokes: 14, radical: '纟', isRecommended: 0 },
  { word: '砥砺', pinyin: 'di li', definition: '磨炼、锤炼。', example: '在实践中砥砺品格。', synonyms: '磨炼', antonyms: '懈怠', groupName: '默认', strokes: 10, radical: '石', isRecommended: 0 },
  { word: '清晖', pinyin: 'qing hui', definition: '清亮的光辉，多指月光。', example: '清晖洒满庭院。', synonyms: '月华', antonyms: '阴翳', groupName: '默认', strokes: 11, radical: '日', isRecommended: 0 },
  { word: '苍穹', pinyin: 'cang qiong', definition: '天空。', example: '雄鹰掠过苍穹。', synonyms: '天空', antonyms: '大地', groupName: '默认', strokes: 8, radical: '穴', isRecommended: 1 },
  { word: '晨曦', pinyin: 'chen xi', definition: '清晨的阳光。', example: '晨曦照进窗台。', synonyms: '朝阳', antonyms: '暮色', groupName: '默认', strokes: 11, radical: '日', isRecommended: 1 },
  { word: '暮鼓', pinyin: 'mu gu', definition: '傍晚寺院的鼓声。', example: '远处传来悠悠暮鼓。', synonyms: '晚钟', antonyms: '晨钟', groupName: '默认', strokes: 14, radical: '鼓', isRecommended: 0 },
  { word: '朗润', pinyin: 'lang run', definition: '明朗润泽。', example: '文章语言朗润自然。', synonyms: '明润', antonyms: '干涩', groupName: '默认', strokes: 10, radical: '月', isRecommended: 0 },
  { word: '遒劲', pinyin: 'qiu jing', definition: '雄健有力，多形容书法。', example: '他的笔势遒劲苍健。', synonyms: '有力', antonyms: '柔弱', groupName: '默认', strokes: 12, radical: '辶', isRecommended: 0 },
  { word: '悠然', pinyin: 'you ran', definition: '闲适自在的样子。', example: '他神情悠然自得。', synonyms: '闲适', antonyms: '局促', groupName: '默认', strokes: 11, radical: '心', isRecommended: 0 },
  { word: '澹泊', pinyin: 'dan bo', definition: '恬淡寡欲。', example: '处世宜澹泊宁静。', synonyms: '淡泊', antonyms: '汲汲', groupName: '生僻字', strokes: 15, radical: '氵', isRecommended: 0 },
  { word: '峥嵘', pinyin: 'zheng rong', definition: '高峻突出，也比喻不平凡。', example: '岁月峥嵘，初心不改。', synonyms: '卓绝', antonyms: '平庸', groupName: '生僻字', strokes: 9, radical: '山', isRecommended: 0 },
  { word: '琅嬛', pinyin: 'lang huan', definition: '神话中的仙境书阁。', example: '他沉浸在如琅嬛般的书海。', synonyms: '书府', antonyms: '无', groupName: '生僻字', strokes: 12, radical: '王', isRecommended: 0 },
  { word: '霁月', pinyin: 'ji yue', definition: '雨后明月，比喻胸怀光明。', example: '其人如霁月清风。', synonyms: '明月', antonyms: '阴霾', groupName: '生僻字', strokes: 22, radical: '雨', isRecommended: 0 },
  { word: '湛然', pinyin: 'zhan ran', definition: '清澈明净，或形容神情安定。', example: '潭水湛然见底。', synonyms: '澄澈', antonyms: '混浊', groupName: '生僻字', strokes: 12, radical: '氵', isRecommended: 0 },
  { word: '寥廓', pinyin: 'liao kuo', definition: '高远空旷。', example: '秋空寥廓，雁阵南飞。', synonyms: '辽阔', antonyms: '逼仄', groupName: '生僻字', strokes: 14, radical: '宀', isRecommended: 0 },
  { word: '绵长', pinyin: 'mian chang', definition: '延续很长，深远持久。', example: '琴音绵长不绝。', synonyms: '悠长', antonyms: '短促', groupName: '默认', strokes: 11, radical: '纟', isRecommended: 0 },
  { word: '恬淡', pinyin: 'tian dan', definition: '心境安适，不求名利。', example: '他过着恬淡的生活。', synonyms: '淡然', antonyms: '浮华', groupName: '默认', strokes: 9, radical: '忄', isRecommended: 0 },
  { word: '昂扬', pinyin: 'ang yang', definition: '情绪高涨，奋发向上。', example: '队伍士气昂扬。', synonyms: '高昂', antonyms: '低沉', groupName: '默认', strokes: 8, radical: '日', isRecommended: 0 },
  { word: '温煦', pinyin: 'wen xu', definition: '温暖和煦。', example: '春日阳光温煦宜人。', synonyms: '和煦', antonyms: '凛冽', groupName: '默认', strokes: 13, radical: '灬', isRecommended: 0 },
  { word: '蕴藉', pinyin: 'yun jie', definition: '含蓄而有文采。', example: '他的谈吐颇为蕴藉。', synonyms: '含蓄', antonyms: '直露', groupName: '生僻字', strokes: 16, radical: '艹', isRecommended: 0 },
  { word: '轩昂', pinyin: 'xuan ang', definition: '精神饱满，气度不凡。', example: '他神采轩昂地走来。', synonyms: '昂扬', antonyms: '颓唐', groupName: '默认', strokes: 7, radical: '车', isRecommended: 0 },
  { word: '婉转', pinyin: 'wan zhuan', definition: '委婉含蓄，也形容声音动听。', example: '她的歌声十分婉转。', synonyms: '委婉', antonyms: '直率', groupName: '默认', strokes: 11, radical: '女', isRecommended: 0 },
  { word: '澎湃', pinyin: 'peng pai', definition: '形容波浪互相冲击，也比喻声势浩大。', example: '听完演讲，心潮澎湃。', synonyms: '激荡', antonyms: '平静', groupName: '默认', strokes: 15, radical: '氵', isRecommended: 0 },
  { word: '凝练', pinyin: 'ning lian', definition: '紧凑简练。', example: '这段文字十分凝练。', synonyms: '精炼', antonyms: '冗长', groupName: '默认', strokes: 16, radical: '冫', isRecommended: 0 },
  { word: '爽朗', pinyin: 'shuang lang', definition: '开朗直率，也形容天气清明。', example: '他的笑声爽朗有力。', synonyms: '开朗', antonyms: '阴郁', groupName: '默认', strokes: 11, radical: '爻', isRecommended: 0 },
  { word: '流岚', pinyin: 'liu lan', definition: '流动的山雾。', example: '清晨流岚绕峰。', synonyms: '山雾', antonyms: '晴空', groupName: '生僻字', strokes: 10, radical: '山', isRecommended: 0 },
  { word: '霏微', pinyin: 'fei wei', definition: '细雨或轻雪飘落的样子。', example: '窗外霏微细雨不断。', synonyms: '蒙蒙', antonyms: '骤烈', groupName: '生僻字', strokes: 16, radical: '雨', isRecommended: 0 },
  { word: '简静', pinyin: 'jian jing', definition: '简朴安静。', example: '居所布置得简静舒适。', synonyms: '清简', antonyms: '繁复', groupName: '默认', strokes: 13, radical: '竹', isRecommended: 0 },
  { word: '疏朗', pinyin: 'shu lang', definition: '稀疏而清朗，也指文字明快。', example: '庭院树影疏朗。', synonyms: '清朗', antonyms: '繁密', groupName: '默认', strokes: 12, radical: '疋', isRecommended: 0 },
  { word: '妥帖', pinyin: 'tuo tie', definition: '恰当稳妥。', example: '这件事处理得很妥帖。', synonyms: '稳妥', antonyms: '失当', groupName: '默认', strokes: 8, radical: '女', isRecommended: 0 },
  { word: '隽永', pinyin: 'juan yong', definition: '意味深长。', example: '短短几句却十分隽永。', synonyms: '深长', antonyms: '浅白', groupName: '生僻字', strokes: 10, radical: '隹', isRecommended: 0 }
]

const IDIOM_SEED_DATA = [
  { word: '安然无恙', pinyin: 'an ran wu yang', summary: '平安没有受到损害。', story: '古人用来表示经历变故后依旧平安。', derivation: '多用于灾后、险后报平安。', sample: '大雨过后，村庄依旧安然无恙。' },
  { word: '百折不挠', pinyin: 'bai zhe bu nao', summary: '无论遭受多少挫折都不退缩。', story: '常用来称赞意志坚定、遇难不屈的人。', derivation: '形容顽强不屈的精神。', sample: '科研团队以百折不挠的精神攻克难题。' },
  { word: '沧海一粟', pinyin: 'cang hai yi su', summary: '比喻非常渺小。', story: '苏轼在赤壁赋中借此感叹人生短暂。', derivation: '用于形容个体在宏大事物前的微小。', sample: '放在历史长河里，个人不过沧海一粟。' },
  { word: '得心应手', pinyin: 'de xin ying shou', summary: '运用自如，做起来很顺手。', story: '源于技艺纯熟后心手相应的状态。', derivation: '常用于称赞熟练技巧。', sample: '这位老匠人做起木工来得心应手。' },
  { word: '豁然开朗', pinyin: 'huo ran kai lang', summary: '由狭窄幽暗忽然变得开阔明亮，也比喻突然领悟。', story: '常用来形容困惑之后突然明白。', derivation: '既可写景，也可比喻思路打开。', sample: '听完老师讲解，我顿时豁然开朗。' },
  { word: '开卷有益', pinyin: 'kai juan you yi', summary: '读书总有好处。', story: '宋太宗鼓励读书，认为开卷必有所得。', derivation: '用来勉励学习。', sample: '坚持阅读，终究开卷有益。' },
  { word: '名副其实', pinyin: 'ming fu qi shi', summary: '名称或名声与实际相符合。', story: '古人用来称赞人或物名实相符。', derivation: '多用于肯定评价。', sample: '这座书店藏书丰富，真是名副其实。' },
  { word: '水到渠成', pinyin: 'shui dao qu cheng', summary: '条件成熟，事情自然成功。', story: '比喻顺其自然，时机到了便可成功。', derivation: '强调积累与时机。', sample: '基础打牢后，很多事都会水到渠成。' },
  { word: '谈笑风生', pinyin: 'tan xiao feng sheng', summary: '有说有笑，兴致高。', story: '形容言谈生动风趣、气氛活跃。', derivation: '常用于宴会和会谈场景。', sample: '几位老友久别重逢，席间谈笑风生。' },
  { word: '温故知新', pinyin: 'wen gu zhi xin', summary: '温习旧知识，从而得到新的理解。', story: '出自《论语》，强调复习的重要。', derivation: '用来说明学习方法。', sample: '老师常提醒我们温故知新。' },
  { word: '循序渐进', pinyin: 'xun xu jian jin', summary: '按一定步骤逐渐深入。', story: '古人强调学习做事要按次序推进。', derivation: '适用于学习、训练和建设。', sample: '学习书法需要循序渐进。' },
  { word: '一鼓作气', pinyin: 'yi gu zuo qi', summary: '趁劲头大的时候一口气完成。', story: '《左传》记载作战时第一次击鼓士气最盛。', derivation: '比喻趁热打铁。', sample: '我们决定一鼓作气完成方案。' },
  { word: '专心致志', pinyin: 'zhuan xin zhi zhi', summary: '一心一意，精神集中。', story: '古人用来形容求学者全神贯注。', derivation: '强调专注与投入。', sample: '只要专心致志，效率就会更高。' }
]

export class DatabaseHelper {
  private static store: relationalStore.RdbStore | null = null
  private static readonly DATABASE_NAME = 'harmony_word.db'
  private static readonly DATABASE_VERSION = 1

  static async init(context: common.UIAbilityContext): Promise<relationalStore.RdbStore> {
    if (this.store) {
      return this.store
    }
    const config: relationalStore.StoreConfig = {
      name: this.DATABASE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }
    this.store = await relationalStore.getRdbStore(context, config)
    await this.store.executeSql(CREATE_WORDS_SQL)
    await this.store.executeSql(CREATE_IDIOMS_SQL)
    await this.store.executeSql(CREATE_FAVORITES_SQL)
    await this.store.executeSql(CREATE_HISTORY_SQL)
    await this.ensureSeedData(this.store)
    return this.store
  }

  static getStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new Error('Database is not initialized')
    }
    return this.store
  }

  static async getWordSeedCount(): Promise<number> {
    return WORD_SEED_DATA.length
  }

  private static async ensureSeedData(store: relationalStore.RdbStore): Promise<void> {
    const wordCount = await this.queryCount(store, 'SELECT COUNT(*) AS count FROM WORDS')
    if (wordCount === 0) {
      for (const item of WORD_SEED_DATA) {
        await store.insert('WORDS', {
          word: item.word,
          pinyin: item.pinyin,
          definition: item.definition,
          example: item.example,
          synonyms: item.synonyms,
          antonyms: item.antonyms,
          group_name: item.groupName,
          strokes: item.strokes,
          radical: item.radical,
          is_recommended: item.isRecommended
        })
      }
    }

    const idiomCount = await this.queryCount(store, 'SELECT COUNT(*) AS count FROM IDIOMS')
    if (idiomCount === 0) {
      for (const item of IDIOM_SEED_DATA) {
        await store.insert('IDIOMS', {
          word: item.word,
          pinyin: item.pinyin,
          summary: item.summary,
          story: item.story,
          derivation: item.derivation,
          sample: item.sample,
          initial: PinyinUtil.getIndexerLabel(item.pinyin)
        })
      }
    }
  }

  private static async queryCount(store: relationalStore.RdbStore, sql: string): Promise<number> {
    const resultSet = await store.querySql(sql)
    let count = 0
    if (resultSet.goToFirstRow()) {
      count = resultSet.getLong(resultSet.getColumnIndex('count'))
    }
    resultSet.close()
    return count
  }
}
