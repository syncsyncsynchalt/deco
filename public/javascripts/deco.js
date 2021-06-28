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
      "length":{
        "regex":"none",
        "alertText":"* 入力可能文字数 ",
        "alertText2":" ～ ",
        "alertText3":" です"},
      "maxCheckbox":{
        "regex":"none",
        "alertText":"* 選択が上限を超えています"},
      "minCheckbox":{
        "regex":"none",
        "alertText":"* 選択してください ",
        "alertText2":" options"},
      "confirm":{
        "regex":"none",
        "alertText":"* 一致しません"},
      "telephone":{
        "regex":"/^[0-9\-\(\)\ ]+$/",
        "alertText":"* 電話番号が不正です"},
      "email":{
        "regex":"/^[a-zA-Z0-9_\.\-]+\@([a-zA-Z0-9\-]+\.)+[a-zA-Z0-9]{2,4}$/",
        "alertText":"* メールアドレスが不正です"},
      "date":{
        "regex":"/^[0-9]{4}\-\[0-9]{1,2}\-\[0-9]{1,2}$/",
        "alertText":"* Date invalide, format YYYY-MM-DD requis"},
      "onlyNumber":{
        "regex":"/^[0-9\ ]+$/",
        "alertText":"* 数字を入力してください"},
      "noSpecialCaracters":{
        "regex":"/^[0-9a-zA-Z]+$/",
        "alertText":"* Aucune caractere special accepte"},
      "onlyLetter":{
        "regex":"/^[a-zA-Z\ \']+$/",
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
        "regex":"/^[a-zA-Z0-9_\.\-]+\@(" + localDomains + ")$/",
        "alertText":"* メールアドレスが不正です(使用できないドメイン)"},
      "IPAddress":{
        "regex":"/^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)(\/[0-9]+)$/",
        "alertText":"* ＩＰアドレスが不正です"},
      "password":{
        "regex":"/^[a-zA-Z0-9]+$/",
        "alertText":"* 半角英数字のみ入力してください"},
      "file":{
          "regex":"/.+/",
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
      '<div id=\"group_C' + arInput +'\" class=\"input-l\"><img src=\"/images/common/name.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required]\' size=\"30\"/>  様<br />' +
      '<img src=\"/images/common/mail.jpg\" align=\"left\" /><input type=\"text\" id=\"' +
      y1 + '\" name=\"' + y2 + '\" value=\"\" ' +
      'class=\'validate[required, custom[email]]\' size=\"40\"/></div>' +
      '<div id=\"group_R' + arInput + '\" class=\"input-r\"><input type="button" onclick="del_receiver(\'' +
      arInput + '\', \'' + model_name + '\')" value="削除" /></div>' +
      '\n');

    arInput = 0;

    for (i in files) {
      if (files[i] == 1) {
             $.validationEngine.closePrompt($('#' + 'attachment' + '_' + i + '_file'));

      }
    }
  }else{
    window.alert(max_receivers_num+"名までです");
  }
}

//受信者フォーム削除処理
function del_receiver(n, model_name) {
  for (i in receivers) {
    if (receivers[i] == 1) {
      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_mail_address'));
      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_name'));
    }
  }

  $('#group_L' + n + '').remove();
  $('#group_C' + n + '').remove();
  $('#group_R' + n + '').remove();

  receivers[n] = 0;

  for (i in files) {
    if (files[i] == 1) {
      $.validationEngine.closePrompt($('#' + 'attachment' +
                                       '_' + i + '_file'));
      }
  }
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
  for (i in files) {
    if (files[i] == 1 && i > 1) {
      $.validationEngine.closePrompt($('#' + model_name + '_' + i + '_file'));    }
  }

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
      flash_url : "/swfupload.swf",
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

      button_image_url: "/images/common/file.png",
      button_width: "200",
      button_height: "45",
      button_placeholder_id: "spanButtonPlaceHolder",
      button_text_style: ".theFont {font-size: 12pt; color: #000000;  text-decoration: underline}",
      button_text_left_padding: 7,
      button_text_top_padding: 2,

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

