import { KeyStyle } from '../common/styleConfiguration'
import { InputHandler } from '../model/KeyboardController'
import { FcitxTheme } from '../common/FcitxTheme'
import { keyItemGray } from './KeyItemGray'
import { ChangeItem } from './ChangeItem'
import { SpaceItem } from './SpaceItem'
import { DeleteItem } from './DeleteItem'
import { ReturnItem } from './ReturnItem'

interface NineKeyDef {
  digit: string
  label: string
  letters: string[]
  direct: boolean
}

const NINE_KEYS: NineKeyDef[] = [
  { digit: '1', label: '，。？', letters: ['，', '。', '？'], direct: true },
  { digit: '2', label: 'ABC', letters: ['a', 'b', 'c'], direct: false },
  { digit: '3', label: 'DEF', letters: ['d', 'e', 'f'], direct: false },
  { digit: '4', label: 'GHI', letters: ['g', 'h', 'i'], direct: false },
  { digit: '5', label: 'JKL', letters: ['j', 'k', 'l'], direct: false },
  { digit: '6', label: 'MNO', letters: ['m', 'n', 'o'], direct: false },
  { digit: '7', label: 'PQRS', letters: ['p', 'q', 'r', 's'], direct: false },
  { digit: '8', label: 'TUV', letters: ['t', 'u', 'v'], direct: false },
  { digit: '9', label: 'WXYZ', letters: ['w', 'x', 'y', 'z'], direct: false },
  { digit: '0', label: '空格', letters: [' '], direct: true }
]

// 九键（多击）键盘：字母键按拼音上屏，标点/空格直接上屏
@Component
export struct NineKeyMenu {
  @Link inputStyle: KeyStyle
  @Link menuType: number
  @StorageLink('isChinese') isChinese: boolean = true
  @StorageLink('pinyin') pinyin: string = ''
  @StorageLink('themeMode') themeMode: string = 'light'
  private lastKeyIndex: number = -1
  private tapIndex: number = 0
  private timerId: number = -1
  private longPressTimer: number = -1
  private longPressed: boolean = false
  private readonly TAP_TIMEOUT: number = 2600

  aboutToAppear(): void {
    this.longPressed = false
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearTimeout(this.timerId)
      this.timerId = -1
    }
    this.cancelLongPress()
  }

  @Styles pressedStyles() {
    .backgroundColor(FcitxTheme.letterKeyPressed(this.themeMode))
  }

  @Styles normalStyles() {
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
  }

  private cancelLongPress(): void {
    if (this.longPressTimer >= 0) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = -1
    }
  }

  private startLongPress(item: NineKeyDef): void {
    this.cancelLongPress()
    this.longPressed = false
    if (item.digit !== '1') {
      return
    }
    this.longPressTimer = setTimeout(() => {
      this.longPressTimer = -1
      this.longPressed = true
      this.menuType = 2
    }, 450)
  }

  private onKeyTap(item: NineKeyDef): void {
    const idx = NINE_KEYS.indexOf(item)
    const letters = item.letters
    if (idx === this.lastKeyIndex && this.timerId >= 0) {
      InputHandler.getInstance().deleteForward(1, this.isChinese && !item.direct)
      this.tapIndex = (this.tapIndex + 1) % letters.length
    } else {
      this.tapIndex = 0
      this.lastKeyIndex = idx
    }
    if (this.timerId >= 0) {
      clearTimeout(this.timerId)
    }
    const letter = letters[this.tapIndex]
    InputHandler.getInstance().insertText(letter, this.isChinese && !item.direct)
    this.timerId = setTimeout(() => {
      this.timerId = -1
    }, this.TAP_TIMEOUT)
  }

  @Builder
  private nineKeyItem(item: NineKeyDef) {
    Stack() {
      Column() {
        Text(item.digit)
          .fontSize(this.inputStyle.litterNumberFontSize)
          .fontColor(FcitxTheme.textSecondary(this.themeMode))
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 9, top: 4 })

      Text(item.label)
        .fontSize(item.direct ? this.inputStyle.ninePunctFontSize : this.inputStyle.nineLabelFontSize)
        .fontColor(FcitxTheme.textPrimary(this.themeMode))
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .height('100%')
    .borderRadius(10)
    .backgroundColor(FcitxTheme.letterKeyBg(this.themeMode))
    .margin({ left: 3, right: 3, top: 1, bottom: 1 })
    .shadow({ radius: 1, color: FcitxTheme.shadowColor(this.themeMode), offsetY: 1 })
    .stateStyles({
      normal: this.normalStyles, pressed: this.pressedStyles
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.startLongPress(item)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.cancelLongPress()
      }
    })
    .onClick(() => {
      if (this.longPressed) {
        this.longPressed = false
        return
      }
      this.onKeyTap(item)
    })
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Row({ space: 6 }) {
        ForEach(NINE_KEYS.slice(0, 3), (item: NineKeyDef) => {
          this.nineKeyItem(item)
        }, (item: NineKeyDef) => item.digit)
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Row({ space: 6 }) {
        ForEach(NINE_KEYS.slice(3, 6), (item: NineKeyDef) => {
          this.nineKeyItem(item)
        }, (item: NineKeyDef) => item.digit)
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Row({ space: 6 }) {
        ForEach(NINE_KEYS.slice(6, 9), (item: NineKeyDef) => {
          this.nineKeyItem(item)
        }, (item: NineKeyDef) => item.digit)
      }
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })

      Row({ space: 2 }) {
        keyItemGray({ keyValue: '?123', menuType: $menuType, inputStyle: $inputStyle })
        ChangeItem({ keyValue: 'ABC', menuType: $menuType, inputStyle: $inputStyle })
        SpaceItem({ inputStyle: $inputStyle })
        DeleteItem({ inputStyle: $inputStyle })
        ReturnItem({ inputStyle: $inputStyle })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(this.inputStyle.basicButtonHeight)
      .margin({ top: this.inputStyle.paddingTop })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 4,
      right: 4
    })
    .backgroundColor(FcitxTheme.panelBg(this.themeMode))
  }
}
