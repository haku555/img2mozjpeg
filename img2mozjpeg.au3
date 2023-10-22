#pragma compile(FileVersion, 1.0.0)

#include <GuiConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListView.au3>
#include <Array.au3>

$Form = GUICreate("img2mozjpeg", 380, 360,-1,-1,-1,$WS_EX_ACCEPTFILES) ;$WS_EX_ACCEPTFILES //ファイルドロップを可能にする
GUISetBkColor(0xFFFBF0)

$MenuItem1 = GUICtrlCreateMenu("ファイル")
$MenuItem2 = GUICtrlCreateMenuItem("終了", $MenuItem1)
$MenuItem3 = GUICtrlCreateMenu("ヘルプ")
$MenuItem4 = GUICtrlCreateMenuItem("使用方法", $MenuItem3)
$MenuItem5 = GUICtrlCreateMenuItem("WEBサイトへ", $MenuItem3)
$MenuItem6 = GUICtrlCreateMenuItem("バージョン情報", $MenuItem3)

GUICtrlCreateLabel("↓画像ファイルまたはフォルダをドラッグ＆ドロップ", 5, 3)

$FileInput = GUICtrlCreateInput("", 0, 20, 380, 340,BitOr($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlSetBkColor($FileInput, 0xffffff) ;白背景
GUICtrlSetState($FileInput, $GUI_DROPACCEPTED) ;ファイルドロップを受け付ける

GUISetState(@SW_SHOW)
Local $tmp = ""
While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $GUI_EVENT_DROPPED
            If @GUI_DropId = $FileInput Then
              $tmp = GUICtrlRead($FileInput)
              GUICtrlSetData($FileInput, "")
              ;"|"で配列に分割
              $InputFileArr = StringSplit($tmp,"|")
              ;ファイル名の両端に"を追加
              For $i = 1 to UBound( $InputFileArr ) - 1
                $InputFileArr[$i] = '"' & $InputFileArr[$i] & '"'
              Next
              ;配列から文字列に戻す。間は空白で開ける
              $InputFile = _ArrayToString($InputFileArr, " ", 1, UBound( $InputFileArr ) - 1)
              ;bat（処理本体）を呼び出す。引数に成形した$InputFileを指定
              If $InputFile <> "" Then
                ShellExecute("img2mozjpeg.bat", $InputFile, @ScriptDir & "\bin",default,@SW_HIDE)
              EndIf
            EndIf
        Case $MenuItem2; 終了
            Exit
        Case $MenuItem4; 使用方法
            MsgBox(0, "使用方法","入力ファイルはwebp、jpg、png、bmp、gif、avifに対応確認済みです"& @CRLF &"出力先は画像を入力した同じフォルダのjpgフォルダになります"& @CRLF &"複数ファイルドラッグ＆ドロップ対応しています"& @CRLF &"フォルダのドラッグ＆ドロップは一つのみ対応しています"& @CRLF &"注意点として画像ファイル以外の全ての形式のファイルも処理するのでフォルダをドラッグ＆ドロップする際は画像のみのフォルダにしてください"& @CRLF &"binフォルダ内のimg2mozjpeg.batに直接ドラッグ＆ドロップしても機能します"& @CRLF &"mozjpegの圧縮率を変えたい場合はimg2mozjpeg.bat内のcompressの値を変えてください", 0, $Form)
        Case $MenuItem5; WEBサイトへ
            ShellExecute("https://haku.cf")
        Case $MenuItem6; バージョン情報
            MsgBox(0, "バージョン情報","#-------------------------------------------------------------------------------"& @CRLF &"# img2mozjpeg v1.0.0"& @CRLF &"# 20231022 first. 20231022 modified"& @CRLF &"# script by HK https://haku.cf"& @CRLF &"#-------------------------------------------------------------------------------", 0, $Form)
    EndSwitch
WEnd