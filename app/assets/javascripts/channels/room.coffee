App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  # 受信時の処理
  received: (data) ->
    $('#messages').prepend data['message_html']

  # 送信時の処理
  speak: (content, data_uri, file_name) ->
    # @perform 'speak' で 後述のapp/channels/room_channel.rb に
    # 定義したspeakアクションが実行されます。
    @perform 'speak', { content: content, data_uri: data_uri, file_name: file_name }
    clear_form '#test_form'

# フォームリセット
clear_form = (selector) ->
  $(selector).find(":text, :file").val("")

# 入力時の処理
$(document).on 'keypress', '#content', (event) ->
  # エンターキーを押した時に処理
  if event.which is 13
    content = $.trim($("#content").val())
    has_content = if content.length > 0 then true else false

    picture = $('#picture')
    has_picture = if picture.get(0).files.length > 0 then true else false

    if has_content or has_picture
      if has_picture
        file_name = picture.get(0).files[0].name
        # ファイル読み込み用のreader生成
        reader = new FileReader()
        # Data URI Scheme文字列を取得するためのファイル読み込み
        reader.readAsDataURL picture.get(0).files[0]
        # readerが画像を読み込んだ後の処理
        reader.addEventListener "loadend", ->
          # reader.result部分が、読み込んだ画像のData URI Scheme文字列
          App.room.speak content, reader.result, file_name
      else
          App.room.speak content

    # 後続のイベントキャンセル
    # これが無いとエンターを押したあとに画面が一番上まで
    # スクロールしたりします。
    event.preventDefault()
