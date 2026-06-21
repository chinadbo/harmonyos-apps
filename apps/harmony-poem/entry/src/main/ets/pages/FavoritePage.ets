import common from '@ohos.app.ability.common';
import { FavoriteDao } from '../database/FavoriteDao';
import { PoemService } from '../service/PoemService';
import { Poem } from '../model/Poem';
import { Favorite } from '../model/Favorite';
import { PoemCard } from '../components/PoemCard';
import { EmptyView } from '../components/EmptyView';

@Component
export struct FavoritePage {
  @State favorites: Poem[] = [];

  aboutToAppear(): void {
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    const poems = await PoemService.loadPoems(context);
    const favoriteRows = await FavoriteDao.getAllFavorites(context);
    this.favorites = favoriteRows
      .map((item: Favorite) => PoemService.getById(poems, item.poemId))
      .filter((item: Poem | null) => item !== null) as Poem[];
  }

  async removeFavorite(poemId: number): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await FavoriteDao.removeFavorite(context, poemId);
    await this.loadFavorites();
  }

  build() {
    Column({ space: 12 }) {
      Text('我的收藏')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.theme_primary'))
        .width('100%')

      if (this.favorites.length === 0) {
        EmptyView({ title: '还没有收藏诗词', description: '在详情页点击收藏后，会显示在这里。' })
      } else {
        List({ space: 12 }) {
          ForEach(this.favorites, (poem: Poem) => {
            ListItem() {
              PoemCard({
                poem: poem,
                showDelete: true,
                onDelete: (id: number) => {
                  this.removeFavorite(id);
                }
              })
            }
          }, (poem: Poem) => `${poem.id}`)
        }
        .layoutWeight(1)
        .width('100%')
        .divider({ strokeWidth: 0 })
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.theme_background'))
  }
}
