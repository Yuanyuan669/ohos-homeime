import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'

//返回组件
@Component
export struct ReturnItem {
  @Link inputStyle: KeyStyle
  @StorageLink("themeMode") themeMode: string = 'light'
  @StorageLink("enterKeyType") enterKeyType: number = 0

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.functionKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
  }

  private isAction(): boolean {
    return this.enterKeyType >= 2 && this.enterKeyType <= 7
  }

  private actionText(): string {
    switch (this.enterKeyType) {
      case 2:
        return '前往'
      case 3:
        return '搜索'
      case 4:
        return '发送'
      case 5:
        return '下一项'
      case 6:
        return '完成'
      case 7:
        return '上一项'
      default:
        return ''
    }
  }

  build() {
    Stack() {
      if (this.isAction()) {
        Text(this.actionText())
          .fontSize(this.inputStyle.switchNumberFontSize)
          .fontColor(FcitxTheme.textPrimary(this.themeMode))
          .maxLines(1)
      } else {
        Image($rawfile('return.svg'))
          .width(this.inputStyle.returnPicSize)
          .height(this.inputStyle.returnPicSize)
          .fillColor(FcitxTheme.textPrimary(this.themeMode))
      }
    }
    .backgroundColor(FcitxTheme.functionKeyBg(this.themeMode))
    .width(this.inputStyle.returnButtonWidthType_2) //mxg this.returnWidth
    .borderRadius(10)
    .height('100%')
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .onClick(() => {
      InputHandler.getInstance().sendKeyFunction();
    })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
