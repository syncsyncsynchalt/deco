

(function($) {
        $.fn.validationEngineLanguage = function() {};
        $.validationEngineLanguage = {
                newLang: function() {
                        $.validationEngineLanguage.allRules = {"required":{
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
                                                "alertText":"* Chiffres seulement accepté"},
                                        "noSpecialCaracters":{
                                                "regex":"/^[0-9a-zA-Z]+$/",
                                                "alertText":"* Aucune caractère spécial accepté"},
                                        "onlyLetter":{
                                                "regex":"/^[a-zA-Z\ \']+$/",
                                                "alertText":"* Lettres seulement accepté"},
                                        "ajaxUser":{
                                                "file":"validateUser.php",
                                                "alertTextOk":"* Ce nom est déjà pris",
                                                "alertTextLoad":"* Chargement, veuillez attendre",
                                                "alertText":"* Ce nom est déjà pris"},
                                        "ajaxName":{
                                                "file":"validateUser.php",
                                                "alertText":"* Ce nom est déjà pris",
                                                "alertTextOk":"*Ce nom est disponible",
                                                "alertTextLoad":"* LChargement, veuillez attendre"},
                                        "localDomain":{
                                            "regex":"/^[a-zA-Z0-9_\.\-]+\@<%= %>$/",
                                            "alertText":"*<%= a %>メールアドレスが不正です。"}

                                }
                }
        }
})(jQuery);

$(document).ready(function() {
        $.validationEngineLanguage.newLang()
});
