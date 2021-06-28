function print_header(site_category, param_id) {

  document.write("<div id=\"header\">" +
                 "<img src=\"/images/common/deco_logo01.jpg\" alt=\"DECO Drive\" />" +
                 "</div><br />" +
                 "<div id=\"global-nav\"><ul>");

  switch (site_category) {
  case "file_receive":
    document.write("<li id=\"p_top\"><a href=\"/file_receive\">トップページ</a></li>" +
                   "<li></li>" +
                   "<li></li>");
    break;
  case "requested_file_send":
    document.write("<li id=\"p_top\"><a href=\"/requested_file_send/login/" + param_id + "\">トップページ</a></li>" +
                   "<li></li>" +
                   "<li></li>");
    break;
  case "requested_file_receive":
    document.write("<li id=\"p_top\"><a href=\"/requested_file_receive/login/" + param_id + "\">トップページ</a></li>" +
                   "<li></li>" +
                   "<li></li>");
   break;
  case "system":
    break;
  default:
    document.write("<li id=\"p_top\"><a href=\"/\">トップページ</a></li>" + 
                   "<li id=\"p_sen\"><a href=\"/file_send\">ファイル送信</a></li>" +
                   "<li id=\"p_req\"><a href=\"/file_request\">ファイル依頼</a></li>");
    break;
  }
  
  if (site_category != "system") {
    for (i = 0; i < amtHeaderMenu; i++) {
      document.write("<li id=\"p_srv\"><a href=\"/contents/load/" + (i + 1) + "\">" + headerMenu[i] + "</a></li>");
    }
  }
  document.write("</ul></div>");

}
