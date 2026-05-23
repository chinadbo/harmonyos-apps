import { ClipType } from '../model/ClipEntry';

interface BadgeConfig {
  label: string;
  bgColor: string;
  textColor: string;
}

function getBadgeConfig(type: ClipType): BadgeConfig {
  switch (type) {
    case ClipType.URL:
      return { label: 'URL', bgColor: '#E3F2FD', textColor: '#1565C0' };
    case ClipType.EMAIL:
      return { label: '邮箱', bgColor: '#E0F2F1', textColor: '#00695C' };
    case ClipType.PHONE:
      return { label: '手机', bgColor: '#F3E5F5', textColor: '#6A1B9A' };
    case ClipType.JSON:
      return { label: 'JSON', bgColor: '#FFF3E0', textColor: '#E65100' };
    default:
      return { label: '文本', bgColor: '#F5F5F5', textColor: '#424242' };
  }
}

@Component
export struct TypeBadge {
  @Prop type: ClipType = ClipType.TEXT;
  @Prop isPrivate: boolean = false;

  build() {
    if (this.isPrivate) {
      Text('隐私')
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor('#F44336')
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    } else {
      Text(getBadgeConfig(this.type).label)
        .fontSize(10)
        .fontColor(getBadgeConfig(this.type).textColor)
        .backgroundColor(getBadgeConfig(this.type).bgColor)
        .borderRadius(4)
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
    }
  }
}
