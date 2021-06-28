///////////////  オリジナルバリデーション  ///////////////
(function($) {
  $.fn.validationEngineLanguage = function() {};
  $.validationEngineLanguage = {
    newLang: function(localDomains) {
    $.validationEngineLanguage.allRules = {
      "required":{
        "regex":"none",
        "alertText":"* 入力されていません",
        "alertTextCheckboxMultiple":"* 選択してください",
        "alertTextCheckboxe":"* 選択してください"},
      "minSize": {
        "regex": "none",
        "alertText": "* ",
        "alertText2": "文字以上にしてください"
      },
      "maxSize": {
        "regex": "none",
        "alertText": "* ",
        "alertText2": "文字以下にしてください"
      },
      "maxCheckbox":{
        "regex":"none",
        "alertText":"* 選択が上限を超えています"},
      "minCheckbox":{
        "regex":"none",
        "alertText":"* 選択してください ",
        "alertText2":" options"},
      "equals": {
        "regex": "none",
        "alertText": "* 入力された値が一致しません"
      },
      "telephone":{
        "regex": /^[0-9\-\(\)\ ]+$/,
        "alertText":"* 電話番号が不正です"},
      "email":{
        "regex": /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i,
        "alertText":"* メールアドレスが不正です"},
      "domain":{
        "regex": /^([a-zA-Z0-9\-]+\.)+[a-zA-Z0-9]{2,4}$/,
        "alertText":"* ドメインが不正です"},
      "date":{
        "regex": /^[0-9]{4}\-\[0-9]{1,2}\-\[0-9]{1,2}$/,
        "alertText":"* Date invalide, format YYYY-MM-DD requis"},
      "onlyNumber":{
        "regex": /^[0-9\ ]+$/,
        "alertText":"* 数字を入力してください"},
      "noSpecialCaracters":{
        "regex": /^[0-9a-zA-Z]+$/,
        "alertText":"* Aucune caractere special accepte"},
      "onlyLetter":{
        "regex": /^[a-zA-Z\ \']+$/,
        "alertText":"* Lettres seulement accepte"},
      "ajaxUser":{
        "file":"validateUser.php",
        "alertTextOk":"* Ce nom est deja pris",
        "alertTextLoad":"* Chargement, veuillez attendre",
        "alertText":"* Ce nom est deja pris"},
      "ajaxName":{
        "file":"validateUser.php",
        "alertText":"* Ce nom est deja pris",
        "alertTextOk":"*Ce nom est disponible",
        "alertTextLoad":"* LChargement, veuillez attendre"},
      "localDomain":{
        "regex": /^[a-zA-Z0-9_\.\-]+\@( + localDomains + )$/,
        "alertText":"* メールアドレスが不正です(使用できないドメイン)"},
      "IPAddress":{
        "regex": /^((([01]?[0-9]{1,2})|(2[0-4][0-9])|(25[0-5]))[.]){3}(([0-1]?[0-9]{1,2})|(2[0-4][0-9])|(25[0-5]))((\/(([0-2]?[0-9])|(3[0-2])))?)$/,
        "alertText":"* ＩＰアドレスが不正です"},
      "password":{
        "regex": /^[a-zA-Z0-9]+$/,
        "alertText":"* 半角英数字のみ入力してください"},
      "file":{
        "regex": /.+/,
        "alertText":"* ファイルを選択してください"}
      }
    }
  }
})(jQuery);

///////////////  受信者の追加・削除関連関数  ///////////////

var arInput; //初期入力フォームの数
var receivers = new Array();
var max_receivers_num;

//受信者フォーム追加処理
function add_receiver(model_name, id_name, text) {

  for (i in receivers) {
    if (receivers[i] == 0) {
      arInput = i;
      break;
    }
  }
  if (arInput) {
    receivers[arInput] = 1;

    x1 = model_name + "_" + arInput + "_name";
    x2 = model_name + "[" + arInput + "][name]";
    y1 = model_name + "_" + arInput + "_mail_address";
    y2 = model_name + "[" + arInput + "][mail_address]";

    $("#" + id_name).append('<div id=\"group_L' + arInput +
                            '\"  class=\"item\">' + text + ' ' + arInput + '人目</div>' +
      '<div id=\"group_C' + arInput +'\" class=\"input-l\"><img src=\"' + script_url + '/assets/common/name.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required]\' size=\"30\"/>  様<br />' +
      '<img src=\"' + script_url + '/assets/common/mail.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      y1 + '\" name=\"' + y2 + '\" value=\"\" ' +
      'class=\'validate[required, custom[email]]\' size=\"40\"/></div>' +
      '<div id=\"group_R' + arInput + '\" class=\"input-r\"><input type="button" onclick="del_receiver(\'' +
      arInput + '\', \'' + model_name + '\')" value="削除" /></div>' +
      '\n');


    arInput = 0;

//    for (i in files) {
//      if (files[i] == 1) {
//             $.validationEngine.closePrompt($('#' + 'attachment' + '_' + i + '_file'));
//
//      }
//    }
  }else{
    window.alert(max_receivers_num+"名までです");
  }
}


//受信者フォーム追加処理
function add_receiver_address_book(model_name, id_name, text) {

  for (i in receivers) {
    if (receivers[i] == 0) {
      arInput = i;
      break;
    }
  }
  if (arInput) {
    receivers[arInput] = 1;

    x1 = model_name + "_" + arInput + "_name";
    x2 = model_name + "[" + arInput + "][name]";
    y1 = model_name + "_" + arInput + "_mail_address";
    y2 = model_name + "[" + arInput + "][mail_address]";

    $("#" + id_name).append('<div id=\"group_L' + arInput +
                            '\"  class=\"item\">' + text + ' ' + arInput + '人目<div class=\"re_address_p\"><div class=\"re_address\" onClick=\"open_modal_window(\'/address_books/index_sub?recipient_number=' + arInput + '\',\'modal\');\" title=\"アドレス帳\"></div></div></div>' +
      '<div id=\"group_C' + arInput +'\" class=\"input-l\"><img src=\"' + script_url + '/assets/common/name.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required]\' size=\"30\"/>  様<br />' +
      '<img src=\"' + script_url + '/assets/common/mail.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      y1 + '\" name=\"' + y2 + '\" value=\"\" ' +
      'class=\'validate[required, custom[email]]\' size=\"40\"/></div>' +
      '<div id=\"group_R' + arInput + '\" class=\"input-r\"><input type="button" onclick="del_receiver(\'' +
      arInput + '\', \'' + model_name + '\')" value="削除" /></div>' +
      '\n');


    arInput = 0;

//    for (i in files) {
//      if (files[i] == 1) {
//             $.validationEngine.closePrompt($('#' + 'attachment' + '_' + i + '_file'));
//
//      }
//    }
  }else{
    window.alert(max_receivers_num+"名までです");
  }
}

//受信者フォーム削除処理
function del_receiver(n, model_name) {
//  for (i in receivers) {//
//    if (receivers[i] == 1) {
//      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_mail_address'));
//      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_name'));
//    }
//  }

  $('#group_L' + n + '').remove();
  $('#group_C' + n + '').remove();
  $('#group_R' + n + '').remove();

  receivers[n] = 0;

//  for (i in files) {
//    if (files[i] == 1) {
//      $.validationEngine.closePrompt($('#' + 'attachment' +
//                                       '_' + i + '_file'));
//      }
//  }
}

//////////////  Flashなしバージョンのファイル追加・削除関連関数  /////////////

var arInput_f; //初期入力フォームの数
var files = new Array();
var max_files_num;

// ファイル選択フォーム追加処理
function add_file(model_name, id_name) {
  for (i in files) {
    if (files[i] == 0) {
      arInput_f = i;
      break;
    }
  }

  if (arInput_f) {
    files[arInput_f] = 1;

    x1 = model_name + "_" + arInput_f + "_file";
    x2 = model_name + "[" + arInput_f + "][file]";

    $("#" + id_name).append('<div id=\"group_L_f' + arInput_f +
      '\"  class=\"item\">ファイル ' + arInput_f + '個目</div>' +
      '<div id=\"group_C_f' + arInput_f +'\" class=\"input-l\"><input type=\"file\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[custom[file]]\' size=\"30\"/></div>'+
      '<div id=\"group_R_f' + arInput_f +'\" class=\"input-r\"><input type="button" onclick="del_file(\'' +
      arInput_f + '\', \'' + model_name + '\')" value="削除" /></div>' +
                                '\n');
    arInput_f = 0;
  }else{
     window.alert(max_files_num+"個までです");
  }
}

// ファイル選択フォーム削除処理
function del_file(n, model_name) {
//  for (i in files) {
//    if (files[i] == 1 && i > 1) {
//      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_file'));    }
//  }

  $('#group_L_f' + n + '').remove();
  $('#group_C_f' + n + '').remove();
  $('#group_R_f' + n + '').remove();

  files[n] = 0;
}

///////////////  ファイルアップロードプログレスバー関連  ///////////////

starttime = 0;
pointtime = 0;
finishtime = 0;

function file_upload() {
  //var swfu;
  total_queued_number = 0;
  total_file_size = 0;
  transfer_file_size = 0;

  window.onload = function() {
    var settings = {
      flash_url : script_url + "/swfupload.swf",
      upload_url: target_url,// Relative to the SWF file
      post_params: {"Relay_id": post_param_relay_id,
                    "Requested_Matter_id": post_param_requsted_matter_id},
      file_size_limit : size_limit + " MB",
      file_types : "*.*",
      file_types_description : "Files",
      file_upload_limit : send_limit,
      file_queue_limit : 0,
      custom_settings : {
        progressTarget : "fsUploadProgress"
      },
      debug: false,

      button_image_url: script_url + "/assets/common/file.png",
      button_width: "200",
      button_height: "45",
      button_placeholder_id: "spanButtonPlaceHolder",
      button_text_style: ".theFont {font-size: 12pt; color: #000000;  text-decoration: underline}",
      button_text_left_padding: 7,
      button_text_top_padding: 2,
        button_cursor : SWFUpload.CURSOR.HAND,
        button_window_mode : SWFUpload.WINDOW_MODE.TRANSPARENT,

      // The event handler functions are defined in handlers.js
      file_queued_handler : fileQueued,
      file_queue_error_handler : fileQueueError,
      file_dialog_complete_handler : fileDialogComplete,
      upload_start_handler : uploadStart,
      upload_progress_handler : uploadProgress,
      upload_error_handler : uploadError,
      upload_success_handler : uploadSuccess,
      // upload_complete_handler : uploadComplete,
      upload_complete_handler : function(file) {
        if (this.getStats().files_queued === 0 && total_queued_number > 0) {
          now2 = new Date();
          finishtime = now2.getTime();
          show_log("ファイル送信完了");document.send_matter.submit();
        }
      },
      queue_complete_handler : queueComplete// Queue plugin event
    };
    swfu = new SWFUpload(settings);
  };
}

function flow() {
  swfu.startUpload();
}

function show_total_queued_number(num) {
  var status = document.getElementById("total_queued_number");
  status.innerHTML = "選択ファイル数：" + num;
}

function show_total_file_size(size) {
  var status = document.getElementById("total_file_size");
  status.innerHTML = "合計サイズ：" + show_file_size(size);
}

function show_file_size(size) {
  var size_with_unit;
  if (size >= (1024*1024)) {
    size_with_unit = Math.round(size/1024/1024) + "MB"
  }else if (size > 1024 && size <= (1024*1024)){
    size_with_unit = Math.round(size/1024) + "KB"
  }else{
    size_with_unit = Math.round(size) + "B"
  }
  return size_with_unit;
}

function show_transfer_rate(rate) {
  var status = document.getElementById("transfer_rate");
  status.innerHTML = rate  + "%";
  document.getElementById("progressbar").style.backgroundPosition = -360 + (360*rate/100) + "px 0px";
}

function show_log(text) {
  var log = document.getElementById("log");
  log.innerHTML = text
}

function showtime() {
  var status = document.getElementById("debug1");
  var status2 = document.getElementById("debug2");
  status.innerHTML = "送信時間：" + (pointtime - starttime);
  status2.innerHTML = "処理時間：" + (finishtime - pointtime);
}

function open_window(recipient_number){
    win=window.open("/address_books/?recipient_number="+recipient_number,"new","width=700,height=480,resizable=yes,scrollbars=yes");
    win.moveTo(0,0);
}

function open_modal_window(url, element_class) {
  $("."+element_class).load(url).modal({
    onOpen: $("."+element_class).html('...Loading'),
      close: true,
      onShow: function() {
          $("#simplemodal-container").draggable({cursor: 'move', opacity: 0.1});
          $(".simplemodal-wrap").css('overflow','hidden');
      }
  });
  return false;
}