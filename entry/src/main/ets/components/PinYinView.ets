import { KeyStyle } from '../common/styleConfiguration'
import { FcitxTheme } from '../common/FcitxTheme'
import { InputHandler } from '../model/KeyboardController'

@Component
export struct PinYinView {
  @Link inputStyle: KeyStyle
  @Link menuType: number
  @StorageLink("pinyin") pinyin: string = ""
  @StorageLink("isChinese") isChinese: boolean = true
  @StorageLink("isNineKey") isNineKey: boolean = false
  @StorageLink("themeMode") themeMode: string = 'light'

  private modeLabel(): string {
    if (!this.isChinese) {
      return 'English'
    }
    return this.isNineKey ? '拼音 · 九键' : '拼音 · 全键'
  }

  build() {
    Row() {
      Row({ space: 6 }) {
        Text(this.pinyin.length > 0 ? this.pinyin : this.modeLabel())
          .fontSize(this.pinyin.length > 0 ? 16 : 12)
          .fontWeight(this.pinyin.length > 0 ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.pinyin.length > 0 ? FcitxTheme.textPrimary(this.themeMode) :
            FcitxTheme.textSecondary(this.themeMode))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.pinyin.length > 0 ? this.modeLabel() : '')
          .fontSize(11)
          .fontColor(FcitxTheme.textSecondary(this.themeMode))
      }
      .layoutWeight(1)
      .margin({ left: 6 })
      .alignItems(VerticalAlign.Center)

      Row() {
        Row() {
          Text('设置')
            .fontSize(12)
            .fontColor(FcitxTheme.textSecondary(this.themeMode))
        }
        .width(40)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          AppStorage.setOrCreate('isKeySet', true)
        })

        Row() {
          Image($r('app.media.ic_emoji_smile'))
            .width(this.inputStyle.featurePicSize)
            .height(this.inputStyle.featurePicSize)
            .fillColor(FcitxTheme.textSecondary(this.themeMode))
        }
        .width(40)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.menuType = 4
        })
      }
      .width(80)
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .margin({ right: 2 })

      Column()
        .width(1)
        .height('44%')
        .backgroundColor(FcitxTheme.subtleDivider(this.themeMode))
        .margin({ left: 2, right: 2 })

      Row() {
        Image($r('app.media.ic_arrow_down'))
          .width(this.inputStyle.featurePicSize)
          .height(this.inputStyle.featurePicSize)
          .fillColor(FcitxTheme.textSecondary(this.themeMode))
      }
      .width(40)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        InputHandler.getInstance().hideKeyboardSelf()
      })
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .backgroundColor(FcitxTheme.toolbarBg(this.themeMode))
    .borderWidth({ bottom: 0.6 })
    .borderColor(FcitxTheme.subtleDivider(this.themeMode))
    .height(this.inputStyle.pinyinBarHeight)
    .padding({ left: 8, right: 8 })
  }
}
