import { FileBrowserPage } from '../ets/views/FileBrowserPage'
import { FilePreviewPage } from '../ets/views/FilePreviewPage'
import { SearchPage } from '../ets/views/SearchPage'
import { FavoritesPage } from '../ets/views/FavoritesPage'
import { FileDetailSheet } from '../ets/views/FileDetailSheet'
import { FileItem } from '../ets/model/FileItem'

@Entry
@Component
struct Index {
  @State navStack: NavPathStack = new NavPathStack()
  @State selectedTab: number = 0

  @Builder pageBuilder(name: string, param: object) {
    if (name === 'FileBrowserPage') {
      FileBrowserPage({ navStack: this.navStack, dirPath: ((param as Record<string, string>)['path']) ?? '' })
    } else if (name === 'FilePreviewPage') {
      FilePreviewPage({ file: JSON.parse(((param as Record<string, string>)['file']) ?? '{}') as FileItem, navStack: this.navStack })
    } else if (name === 'SearchPage') {
      SearchPage({ navStack: this.navStack })
    } else if (name === 'FavoritesPage') {
      FavoritesPage({ navStack: this.navStack })
    } else if (name === 'FileDetailSheet') {
      FileDetailSheet({})
    }
  }

  build() {
    Navigation(this.navStack) {
      Tabs({ barPosition: BarPosition.End, index: this.selectedTab }) {
        TabContent() {
          Column() {
            Text('HarmonyFiles').fontSize(24).fontWeight(FontWeight.Bold).padding({top:20, bottom:16, left:20})
            List() {
              ListItem() {
                Row() {
                  Text('📂').fontSize(24).margin({right:12})
                  Column() {
                    Text('My Files').fontSize(16).fontWeight(FontWeight.Medium)
                    Text('Internal storage').fontSize(13).fontColor('#999999').margin({top:2})
                  }.alignItems(HorizontalAlign.Start)
                }.width('100%').padding({left:20,right:20,top:14,bottom:14}).backgroundColor('#FFFFFF')
                .onClick(() => {
                  const ctx = getContext(this)
                  this.navStack.pushPathByName('FileBrowserPage', {path: ctx.filesDir, navStack: this.navStack} as Record<string,Object>)
                })
              }
              ListItem() {
                Row() {
                  Text('⬇️').fontSize(24).margin({right:12})
                  Column() {
                    Text('Downloads').fontSize(16).fontWeight(FontWeight.Medium)
                    Text('Downloaded files').fontSize(13).fontColor('#999999').margin({top:2})
                  }.alignItems(HorizontalAlign.Start)
                }.width('100%').padding({left:20,right:20,top:14,bottom:14}).backgroundColor('#FFFFFF').margin({top:1})
                .onClick(() => {
                  const ctx = getContext(this)
                  const dlPath = ctx.filesDir + '/Download'
                  this.navStack.pushPathByName('FileBrowserPage', {path: dlPath, navStack: this.navStack} as Record<string,Object>)
                })
              }
              ListItem() {
                Row() {
                  Text('🖼').fontSize(24).margin({right:12})
                  Column() {
                    Text('Pictures').fontSize(16).fontWeight(FontWeight.Medium)
                    Text('Images & photos').fontSize(13).fontColor('#999999').margin({top:2})
                  }.alignItems(HorizontalAlign.Start)
                }.width('100%').padding({left:20,right:20,top:14,bottom:14}).backgroundColor('#FFFFFF').margin({top:1})
                .onClick(() => {
                  const ctx = getContext(this)
                  const picPath = ctx.filesDir + '/Pictures'
                  this.navStack.pushPathByName('FileBrowserPage', {path: picPath, navStack: this.navStack} as Record<string,Object>)
                })
              }
            }.backgroundColor('#F1F3F5').layoutWeight(1)
          }.width('100%').height('100%').backgroundColor('#F1F3F5')
        }.tabBar('📁 Files')

        TabContent() {
          SearchPage({ navStack: this.navStack })
        }.tabBar('🔍 Search')

        TabContent() {
          FavoritesPage({ navStack: this.navStack })
        }.tabBar('⭐ Favorites')
      }
      .barMode(BarMode.Fixed)
      .onChange((index) => { this.selectedTab = index })
    }
    .navDestination(this.pageBuilder)
    .title('')
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width('100%').height('100%')
  }
}
