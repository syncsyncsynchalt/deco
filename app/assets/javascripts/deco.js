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
        "min": {
          "regex": "none",
          "alertText": "* ",
          "alertText2": "以上にしてください"
        },
        "max": {
          "regex": "none",
          "alertText": "* ",
          "alertText2": "以下にしてください"
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
//          "regex": /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i,
          "regex": /^[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
          "alertText":"* メールアドレスが不正です"},
        "emailAccount":{
          "regex": /^[a-zA-Z0-9.!#\$%&'*+\/=?^_`{|}~-]+$/,
          "alertText":"* メールアカウントが不正です"},
        "domain":{
//          "regex": /^([a-zA-Z0-9\-]+\.)+[a-zA-Z0-9]{2,4}$/,
          "regex": /^[a-zA-Z0-9\-]+(?:\.[a-zA-Z0-9-]+)*$/,
          "alertText":"* ドメインが不正です"},
        "url":{
          "regex": /^https?:\/\/[\w\/:%#\$&\?\(\)~\.=\+\-]+$/,
          "alertText":"* URLが不正です"},
        "date":{
          "regex": /^[0-9]{4}\-\[0-9]{1,2}\-\[0-9]{1,2}$/,
          "alertText":"* Date invalide, format YYYY-MM-DD requis"},
        "onlyNumber":{
          "regex": /^[0-9]+$/,
          "alertText":"* 数字を入力してください"},
        "onlyHalfWidthAlphanumeric":{
          "regex": /^[a-zA-Z0-9]+$/,
          "alertText":"* 半角英数字を入力してください"},
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
          "regex": ".*@(" + localDomains + ")",
          "alertText":"* 使用できないドメインが指定されています"},
        "IPAddress":{
          "regex": /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])((\/(([0-2]?[0-9])|(3[0-2])|(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])))?)$/,
          "alertText":"* ＩＰアドレスが不正です"},
        "password":{
//          "regex": /^[a-zA-Z0-9]+$/,
          "regex": /^[a-zA-Z0-9!-\/:-@\[-`\{-~]+$/,
          "alertText":"* 半角英数字および記号で入力してください。"},
        "receive_password":{
          "regex": /^[a-zA-Z0-9]+$/,
          "alertText":"* 半角英数字で入力してください。"},
        "file":{
          "regex": /.+/,
          "alertText":"* ファイルを選択してください"}
      };
    }
  };
})(jQuery);

///////////////  受信者の追加・削除関連関数  ///////////////

var arInput; //初期入力フォームの数
var receivers = new Array();
var max_receivers_num;

//受信者フォーム追加処理
function add_receiver(model_name, id_name, text) {
  var result = true;
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
      '<div id=\"group_C' + arInput +'\" class=\"input-l\"><img src=\"' + image_path('common/name.jpg') + '\" align=\"left\" /><input type=\"text\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required, maxSize[72]]\' size=\"30\"/>  様<br />' +
      '<img src=\"' + image_path('common/mail.jpg') + '\" align=\"left\" /><input type=\"text\" id=\"' +
      y1 + '\" name=\"' + y2 + '\" value=\"\" ' +
      'class=\'validate[required, maxSize[255], custom[email]]\' size=\"40\"/></div>' +
      '<div id=\"group_R' + arInput + '\" class=\"input-r\"><input type="button" onclick="del_receiver(\'' +
      arInput + '\', \'' + model_name + '\')" value="削除" /></div>' +
      '\n');

    arInput = 0;
  }else{
    window.alert(max_receivers_num+"名までです");
    result = false;
  }
  return(result);
}

//受信者フォーム追加処理
function add_receiver_address_book(model_name, id_name, text) {
  var result = true;
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
                            '\"  class=\"item\">' + text + ' ' + arInput + '人目<div class=\"re_address_p\"><div class=\"re_address\" onClick=\"open_modal_window(\'' + script_url + '/address_books/index_sub?recipient_number=' + arInput + '\',\'modal\');\" title=\"アドレス帳\"></div></div></div>' +
      '<div id=\"group_C' + arInput +'\" class=\"input-l\"><img src=\"' + image_path('common/name.jpg') + '\" align=\"left\" /><input type=\"text\" id=\"' +
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required, maxSize[72]]\' size=\"30\"/>  様<br />' +
      '<img src=\"' + image_path('common/mail.jpg') + '\" align=\"left\" /><input type=\"text\" id=\"' +
      y1 + '\" name=\"' + y2 + '\" value=\"\" ' +
      'class=\'validate[required, maxSize[255], custom[email]]\' size=\"40\"/></div>' +
      '<div id=\"group_R' + arInput + '\" class=\"input-r\"><input type="button" onclick="del_receiver(\'' +
      arInput + '\', \'' + model_name + '\')" value="削除" /></div>' +
      '\n');

    arInput = 0;
  }else{
    window.alert(max_receivers_num+"名までです");
    result = false;
  }
  return(result);
}

//受信者フォーム削除処理
function del_receiver(n, model_name) {
  $('#group_L' + n + '').remove();
  $('#group_C' + n + '').remove();
  $('#group_R' + n + '').remove();

  receivers[n] = 0;
}

//全受信者フォーム削除処理
function del_receiver_all(model_name) {
  for (i in receivers) {
    if (receivers[i] == 1) {
      del_receiver(i, model_name);
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
      x1 + '\" name=\"' + x2 + '\" value=\"\" class=\'validate[required]\' size=\"30\"/></div>'+
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
  $('#group_L_f' + n + '').remove();
  $('#group_C_f' + n + '').remove();
  $('#group_R_f' + n + '').remove();

  files[n] = 0;
}

///////////////  ファイルアップロードプログレスバー関連  ///////////////

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

function show_transfer_rate_html5(rate) {
  var status = document.getElementById("transfer_rate_html5");
  status.innerHTML = rate + "%";
  document.getElementById("progressbar").style.backgroundPosition = -360 + (360*rate/100) + "px 0px";
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