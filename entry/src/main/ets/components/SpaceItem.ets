import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'
import inputMethodEngine from '@ohos.inputMethodEngine'

//空格组件
@Component
export struct SpaceItem {
  @Link inputStyle: KeyStyle
  private spaceWith?: Resource = undefined
  @StorageLink("isChinese") isChinese: boolean = true
  @StorageLink("themeMode") themeMode: string = 'light'
  private startX: number = 0
  private lastX: number = 0
  private moved: boolean = false
  private readonly CURSOR_STEP: number = 18

  private onSpaceTouch(event: TouchEvent): void {
    if (event.touches.length === 0) {
      return
    }
    const x = event.touches[0].x
    if (event.type === TouchType.Down) {
      this.startX = x
      this.lastX = x
      this.moved = false
    } else if (event.type === TouchType.Move) {
      if (Math.abs(x - this.startX) > this.CURSOR_STEP) {
        this.moved = true
      }
      const dx = x - this.lastX
      if (Math.abs(dx) >= this.CURSOR_STEP) {
        InputHandler.getInstance().moveCursor(dx > 0 ?
          inputMethodEngine.Direction.CURSOR_RIGHT : inputMethodEngine.Direction.CURSOR_LEFT)
        this.lastX = x
      }
    }
  }

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.letterKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
  }

  build() {
    Stack() {
      Text(this.isChinese ? '空格' : 'space')
        .fontSize(this.inputStyle.en_fontSize)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
    }
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
    .width(this.spaceWith == null ? this.inputStyle.spaceButtonWidth_2 : this.spaceWith)
    .borderRadius(10)
    .height('100%')
        .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .onTouch((event: TouchEvent) => {
      this.onSpaceTouch(event)
    })
    .onClick(() => {
      if (this.moved) {
        this.moved = false
        return
      }
      InputHandler.getInstance().insertText(' ');
    })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
  }
}
