import QtQuick 2.7
import QtQuick.Controls 2.0
import "emoji.js" as EmojiJSON
//import "../../fonts/."

Rectangle {
    id: emojiPicker
    property EmojiCategoryButton currSelEmojiButton
    property variant emojiParsedJson
    property int buttonWidth: 40
    property TextArea textArea

	FontLoader { id: emojiFont; source: "/fonts/OpenSansEmoji.ttf" }
	property var supportedEmojiFonts: ["Android Emoji"]
	property var rootFontName: emojiFont.name

    //displays all Emoji of one categroy by modifying the ListModel of emojiGrid
    function categoryChangedHandler (newCategoryName){
        emojiByCategory.clear()

        for (var i = 0; i < emojiParsedJson.emoji_by_category[newCategoryName].length; i++) {
            var elem = emojiParsedJson.emoji_by_category[newCategoryName][i]
            emojiByCategory.append({eCatName: newCategoryName, eCatText: elem})
        }
    }

    //adds the clicked Emoji (and one ' ' if the previous character isn't an Emoji) to textArea
    function emojiClickedHandler(selectedEmoji) {
        var strAppnd = ""
        var plainText = textArea.getText(0, textArea.length)

        if (plainText.length > 0) {
            var lastChar = plainText[plainText.length-1]
            if ((lastChar !== ' ') && (lastChar.charCodeAt(0) < 255)) {
				strAppnd = " "
            }
        }
		strAppnd += selectedEmoji

        textArea.insert(textArea.cursorPosition, strAppnd)
    }

	// If native emoji font exists use it, else use RS emoji font
	function selectFont ()
	{
		var fontFamilies =  Qt.fontFamilies()
		return fontFamilies.some(function (f)
		{
			if (supportedEmojiFonts.indexOf(f) !== -1)
			{
				console.log("Compatible native emoji font found: " +f)
				rootFontName = f
				return true
			}
			return false
		})
	}

    //parses JSON, publishes button handlers and inits textArea
    function completedHandler() {
//		emojiParsedJson = JSON.parse(EmojiJSON.emoji_json)
		emojiParsedJson = EmojiJSON.emoji_json
        for (var i = 0; i < emojiParsedJson.emoji_categories.length; i++) {
            var elem = emojiParsedJson.emoji_categories[i]
            emojiCategoryButtons.append({eCatName: elem.name, eCatText: elem.emoji_unified})
        }

        Qt.emojiCategoryChangedHandler = categoryChangedHandler
        Qt.emojiClickedHandler = emojiClickedHandler

        textArea.cursorPosition = textArea.length
        textArea.Keys.pressed.connect(keyPressedHandler)
    }


    //checks if the previous character is an Emoji and adds a ' ' if that's the case
    //this is necessary, because Emoji use a bigger font-size, and that font-size is kept using without a ' '
    function keyPressedHandler(event) {
		var testStr = textArea.getText(textArea.length-2, textArea.length)
        var ptrn = new RegExp("[\uD800-\uDBFF][\uDC00-\uDFFF]")
        if ((event.key !== Qt.Key_Backspace) && (ptrn.test(testStr))) {
			textArea.text += " "
			textArea.cursorPosition = textArea.length
        }
    }

    //all emoji of one category
    ListModel {
        id: emojiByCategory
    }

    GridView {
        id: emojiGrid
        width: parent.width
        anchors.fill: parent
        anchors.bottomMargin: buttonWidth
        cellWidth: buttonWidth; cellHeight: buttonWidth

        model: emojiByCategory
        delegate: EmojiButton {
            width: buttonWidth
            height: buttonWidth
            color: emojiPicker.color
			fontName: rootFontName
        }
    }


    //seperator
    Rectangle {
        color: emojiPicker.color
        anchors.bottom: parent.bottom
        width: parent.width
        height: buttonWidth
    }
    Rectangle {
        color: "black"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: buttonWidth
        width: parent.width
        height: 1
    }

    //emoji category selector
    ListView {
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.bottomMargin: buttonWidth
        orientation: ListView.Horizontal

        model: emojiCategoryButtons
        delegate: EmojiCategoryButton {
            width: buttonWidth
            height: buttonWidth
            color: emojiPicker.color
			fontName: rootFontName
        }
    }

    ListModel {
        id: emojiCategoryButtons
    }

	Component.onCompleted:
	{
		selectFont()
		completedHandler()
	}
}

