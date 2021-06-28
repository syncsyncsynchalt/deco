//チェックボックスをすべて解除
function uncheck_all(){
    i = 0;
    id = "checkbox_" + i;
    while(document.getElementById(id) != null){
        document.getElementById(id).checked = false;

        i++;
        id = "checkbox_" + i;
    }
}

//チェックボックスをすべてチェック
function check_all(){
    i = 0;
    id = "checkbox_" + i;
    while(document.getElementById(id) != null){
        document.getElementById(id).checked = true;

        i++;
        id = "checkbox_" + i;
    }
}

//チェックボックスの状態を取得
function get_checkbox_state(){
    checkbox_state = new Array();
    i = 0;
    id = "checkbox_" + i;
    while(document.getElementById(id) != null){
        checkbox_state[i] = document.getElementById(id).checked

        i++;
        id = "checkbox_" + i;
    }
    return(checkbox_state) 
}

//受取人情報の一覧を取得
function get_table_value(){
    table_value = new Array();
    i = 0;
    j = 0;
    id = "list_" + i + "_" + j;
    while(document.getElementById(id) != null){
        table_row = new Array();
        while(document.getElementById(id) != null){
            //IE
            if (document.getElementById(id).innerText != null){         
                table_row[j] = document.getElementById(id).innerText;
            }
            //Firefox
            if(document.getElementById(id).textContent != null){      
                table_row[j] = document.getElementById(id).textContent;
            }

            j++;
            id = "list_" + i + "_" + j;
        }
        table_value.push(table_row);

        i++;
        j=0;
        id = "list_" + i + "_" + j;
    }
    return(table_value) 
}

//受取人情報の更新
function renew_form(div_id, model_name, id_name, text, login_flg){
    if(window.parent.opener.closed == true)
    {
        window.parent.close();
        return;
    }
    
    if(!window.parent.opener.document.getElementById(div_id))
    {
        window.parent.close();
        return;
    }
    
    if(window.confirm("既に入力されている情報は、削除されます。\nよろしいですか？")){
        //宛先欄をすべて削除
        window.parent.opener.del_receiver_all(model_name);

        //1番目の受取人の情報の削除
        element = window.parent.opener.document.getElementById(model_name + "_"+ 1 + "_name");
        if(element){
            element.value = "";
        }
        element = window.parent.opener.document.getElementById(model_name + "_"+ 1 + "_mail_address");
        if(element){
            element.value = "";
        }
//        window.parent.opener.$.validationEngine.closePrompt('#' + model_name + '_1_mail_address');
//        window.parent.opener.$.validationEngine.closePrompt('#' + model_name + '_1_name');

        //選択されたCSVファイルのレコードをファイル送信画面に入力
        table_value = get_table_value();
        checkbox_state = get_checkbox_state();
        i = 0;
        receiver_number = i + 1;
        result_add_receiver = true;
        while(i < checkbox_state.length && result_add_receiver == true){
            result_add_receiver = true;
            if(checkbox_state[i] == true){
                if(receiver_number > 1){
                    if (login_flg == '1') {
                        result_add_receiver = window.parent.opener.add_receiver_address_book(model_name, id_name, text);
                    }
                    else{
                        result_add_receiver = window.parent.opener.add_receiver(model_name, id_name, text);
                    }
                }
                element = window.parent.opener.document.getElementById(model_name + "_"+ receiver_number + "_name");
                if(element){
                    if(table_value[i][0] != null){
                        element.value = table_value[i][0];
                    }
                    else{
                        element.value = "";
                    }
                }
                element = window.parent.opener.document.getElementById(model_name + "_"+ receiver_number + "_mail_address");
                if(element){
                    if(table_value[i][1] != null){
                        element.value = table_value[i][1];
                    }
                    else{
                        element.value = "";
                    }
                }
                receiver_number++;
              }
              i++;
        }
        window.parent.close();
    }
}
