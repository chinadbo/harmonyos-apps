import { StarTarget, LearnCard } from '../model/models';

export const starTargets: StarTarget[] = [
  {
    id: 'sirius', name: '天狼星 Sirius', constellation: '大犬座', mag: -1.46, difficulty: 1,
    bestSeason: '冬季', ra: 101.287, dec: -16.716,
    desc: '全天最亮恒星，冬季大三角成员。猎户座腰带三星向东南延伸即可找到，双筒可见周围星云弥漫。'
  },
  {
    id: 'canopus', name: '老人星 Canopus', constellation: '船底座', mag: -0.74, difficulty: 2,
    bestSeason: '春季（南方低空）', ra: 95.988, dec: -52.696,
    desc: '全天第二亮星，中国北方需在冬春傍晚南方低空寻找，越往南越容易观测。'
  },
  {
    id: 'arcturus', name: '大角星 Arcturus', constellation: '牧夫座', mag: -0.05, difficulty: 1,
    bestSeason: '春季', ra: 213.915, dec: 19.182,
    desc: '北天最亮星，春季大曲线（北斗斗柄延伸）的终点，橙色巨星，城市中肉眼易见。'
  },
  {
    id: 'vega', name: '织女星 Vega', constellation: '天琴座', mag: 0.03, difficulty: 1,
    bestSeason: '夏季', ra: 279.234, dec: 38.784,
    desc: '夏季大三角成员，七夕传说的织女。与牛郎隔银河相望，蓝白色光芒非常醒目。'
  },
  {
    id: 'altair', name: '牛郎星 Altair', constellation: '天鹰座', mag: 0.76, difficulty: 1,
    bestSeason: '夏季', ra: 297.696, dec: 8.868,
    desc: '夏季大三角南方顶点，两侧各有一颗小星即"扁担星"，自转极快而呈扁球形。'
  },
  {
    id: 'deneb', name: '天津四 Deneb', constellation: '天鹅座', mag: 1.25, difficulty: 1,
    bestSeason: '夏季', ra: 310.358, dec: 45.280,
    desc: '夏季大三角第三顶点，天鹅座尾巴，光度约为太阳 20 万倍的蓝白超巨星。'
  },
  {
    id: 'polaris', name: '北极星 Polaris', constellation: '小熊座', mag: 1.98, difficulty: 1,
    bestSeason: '全年', ra: 37.955, dec: 89.264,
    desc: '北斗勺口两星连线延长五倍即达。找到它就找到正北方向，是观星第一步。'
  },
  {
    id: 'betelgeuse', name: '参宿四 Betelgeuse', constellation: '猎户座', mag: 0.5, difficulty: 1,
    bestSeason: '冬季', ra: 88.793, dec: 7.407,
    desc: '猎户左肩红色超巨星，随时可能爆发为超新星。与参宿七橙蓝对照观测很有趣。'
  },
  {
    id: 'rigel', name: '参宿七 Rigel', constellation: '猎户座', mag: 0.13, difficulty: 1,
    bestSeason: '冬季', ra: 78.634, dec: -8.202,
    desc: '猎户右足蓝超巨星，光度约为太阳 12 万倍，冬季夜空的宝石。'
  },
  {
    id: 'antares', name: '心宿二 Antares', constellation: '天蝎座', mag: 1.06, difficulty: 2,
    bestSeason: '夏季', ra: 247.352, dec: -26.432,
    desc: '天蝎座之心，"大火"。红色超巨星，夏夜南方低空鱼钩状蝎尾极具辨识度。'
  },
  {
    id: 'pollux', name: '北河三 Pollux', constellation: '双子座', mag: 1.14, difficulty: 1,
    bestSeason: '冬季', ra: 116.329, dec: 28.026,
    desc: '双子座亮星，最靠近太阳的巨星之一，与北河二一黄一白并排。'
  },
  {
    id: 'spica', name: '角宿一 Spica', constellation: '室女座', mag: 0.97, difficulty: 2,
    bestSeason: '春季', ra: 201.298, dec: -11.161,
    desc: '春季大三角最亮成员，沿北斗斗柄大弧线向南再顺行即达，蓝白色密近双星。'
  },
  {
    id: 'm31', name: '仙女座星系 M31', constellation: '仙女座', mag: 3.44, difficulty: 2,
    bestSeason: '秋季', ra: 10.685, dec: 41.269,
    desc: '肉眼可见的最远天体（约 254 万光年），暗夜中呈纺锤状光斑，双筒观感更佳。'
  },
  {
    id: 'm42', name: '猎户座大星云 M42', constellation: '猎户座', mag: 4.0, difficulty: 1,
    bestSeason: '冬季', ra: 83.822, dec: -5.391,
    desc: '佩剑中间的"模糊星"，肉眼可见的恒星摇篮，双筒可见云气结构。'
  },
  {
    id: 'm45', name: '昴星团 M45', constellation: '金牛座', mag: 1.6, difficulty: 1,
    bestSeason: '冬季', ra: 60.744, dec: 24.117,
    desc: '七姊妹星团，肉眼可见 6-7 颗聚星，双筒可见数十颗蓝星如钻石洒盘。'
  },
  {
    id: 'm13', name: '武仙座球状星团 M13', constellation: '武仙座', mag: 5.78, difficulty: 3,
    bestSeason: '夏季', ra: 250.423, dec: 36.461,
    desc: '北天最亮球状星团，需黑暗天空肉眼极限可见，小型望远镜中呈糖霜光斑。'
  },
  {
    id: 'm44', name: '蜂巢星团 M44', constellation: '巨蟹座', mag: 3.7, difficulty: 2,
    bestSeason: '春季', ra: 130.1, dec: 19.67,
    desc: '鬼宿星团，肉眼可感的朦胧光斑，双筒中数十颗星散布如蜂巢。'
  },
  {
    id: 'doublecluster', name: '英仙双星团 NGC869/884', constellation: '英仙座', mag: 4.3, difficulty: 2,
    bestSeason: '冬季', ra: 34.8, dec: 57.14,
    desc: '两团年轻星团比邻而居，双筒同框观测最震撼的目标之一。'
  },
  {
    id: 'albireo', name: '辇道增七 Albireo', constellation: '天鹅座', mag: 3.1, difficulty: 2,
    bestSeason: '夏季', ra: 292.68, dec: 27.96,
    desc: '全天最美双星：金蓝两色对比强烈，小型望远镜即可分辨，考验分辨率的入门目标。'
  },
  {
    id: 'lyrids', name: '天琴座流星雨辐射点', constellation: '天琴座', mag: 0, difficulty: 2,
    bestSeason: '4 月下旬', ra: 271.0, dec: 34.0,
    desc: '每年 4 月 22 日前后极大，ZHR 约 18。午夜后面向天顶躺椅观测，注意保暖。'
  },
  {
    id: 'perseids', name: '英仙座流星雨辐射点', constellation: '英仙座', mag: 0, difficulty: 1,
    bestSeason: '8 月中旬', ra: 46.0, dec: 58.0,
    desc: '北半球三大流星雨之一，8 月 12-13 日极大 ZHR 约 100，彻夜可观测的夏季盛宴。'
  },
  {
    id: 'gemini', name: '双子座流星雨辐射点', constellation: '双子座', mag: 0, difficulty: 1,
    bestSeason: '12 月中旬', ra: 112.0, dec: 32.0,
    desc: '全年最稳定流星雨，12 月 14 日前后极大 ZHR 约 150，火流星比例高，后半夜最佳。'
  }
];

export const learnCards: LearnCard[] = [
  {
    id: 'l_solar', title: '太阳系', subtitle: '我们的家园星系',
    body: '太阳系以太阳为中心，八大行星、矮行星、小行星、彗星绕其公转。太阳占系统总质量的 99.86%，其核心每秒聚变约 6 亿吨氢。从水星到海王星，行星轨道几乎位于同一平面，这是 46 亿年前原行星盘坍缩的遗迹。',
    facts: ['日地距离约 1.5 亿公里（1 天文单位）', '光从太阳到地球需 8 分 20 秒', '木星质量是其余行星总和的 2.5 倍']
  },
  {
    id: 'l_moon', title: '月球', subtitle: '地球唯一的天然卫星',
    body: '月球直径 3474 公里，距地球平均 38.4 万公里，以 27.3 天绕地球一周，又以相同周期自转，因此永远以同一面朝向地球（潮汐锁定）。月相由日月角距决定，从朔到望的会合周期为 29.53 天。',
    facts: ['月球正以每年 3.8 厘米远离地球', '月震比地震弱得多且持续时间更长', '月球昼夜温差可达 300°C']
  },
  {
    id: 'l_star', title: '恒星', subtitle: '夜空中的核聚变灯塔',
    body: '恒星由引力坍缩的分子云点燃，主序期靠氢聚变发光。质量决定命运：红矮星可燃烧万亿年，而蓝超巨星几百万年即走向超新星爆发。恒星的颜色对应表面温度——红约 3000K，蓝超过 20000K。',
    facts: ['肉眼全天约能看到 6000 颗恒星', '夜空最亮的星并非最热的星', '参宿四若置于太阳位置将吞没木星轨道']
  },
  {
    id: 'l_deep', title: '深空天体', subtitle: '银河系内外的远方',
    body: '深空天体包括星云（气体尘埃云）、星团（恒星群）与星系。梅西耶星表 110 个目标是最经典的入门清单。行星状星云是垂死恒星抛出的外壳，而弥漫星云 M42 这样的"恒星 nursery"正孕育新恒星。',
    facts: ['M31 是肉眼可见最远天体（约 250 万光年）', '球状星团 M13 含数十万颗老年恒星', '猎户座大星云直径约 24 光年']
  },
  {
    id: 'l_zodiac', title: '黄道十二宫', subtitle: '太阳的年度巡游',
    body: '黄道是太阳周年视运动的轨迹，穿过 13 个星座（含蛇夫座）。古人将黄道等分 12 段用于历法，即十二宫。生日"星座"实为太阳当年所在黄道段的旧称，与今天的位置已相差约一个月（岁差所致）。',
    facts: ['地球自转轴每约 25800 年进动一周', '黄道其实穿过 13 个星座', '岁差由托勒密时代正式记录']
  },
  {
    id: 'l_metor', title: '流星雨', subtitle: '彗尾尘埃的烟花',
    body: '流星体多为沙砾大小的彗星碎片，以每秒 11-72 公里冲入大气燃烧发光。当地球每年同期穿越同一彗星轨道尘埃带时，流星从天球上同一点（辐射点）涌出，形成流星雨。观测流星雨无需望远镜。',
    facts: ['英仙雨母体为斯威夫特-塔特尔彗星', 'ZHR 指理想条件下每小时流星数', '偶发流星平均每小时约 10 颗']
  },
  {
    id: 'l_light', title: '观星礼仪', subtitle: '呵护黑夜与双眼',
    body: '人眼暗适应需 20-30 分钟，一次白光照射即前功尽弃——用红光手电保护夜视力。光污染让城市居民错过 99% 的星空，选择晴夜、月相接近朔的窗口、避开城市灯光，是成功观测的三大要素。',
    facts: ['蓝/白光抑制褪黑素并毁掉暗适应', '朔月前后两周是深空观测黄金期', '手机屏幕亮度即使最低也偏亮']
  },
  {
    id: 'l_tele', title: '器材入门', subtitle: '从肉眼到天文望远镜',
    body: '新手最佳投资是一副 7x50 或 10x50 双筒望远镜：轻便、视场大、易寻星。天文望远镜看口径不看病宣传的"倍率"——集光力与分辨率都由口径决定。先学会用星图认星，再考虑器材升级。',
    facts: ['双筒规格 7x50：7 倍、50mm 口径', '口径每增 1 寸，集光力增约 78%', '80mm 望远镜可看清月面环形山细节']
  }
];
