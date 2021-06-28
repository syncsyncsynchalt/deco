/* Demo Note:  This demo uses a FileProgress class that handles the UI for displaying the file name and percent complete.
The FileProgress class is not part of SWFUpload.
*/


/* **********************
   Event Handlers
   These are my custom event handlers to make my
   web application behave the way I went when SWFUpload
   completes different tasks.  These aren't part of the SWFUpload
   package.  They are part of my application.  Without these none
   of the actions SWFUpload makes will show up in my application.
   ********************** */

function swfUploadPreLoad() {
        var self = this;
        var loading = function () {
                //document.getElementById("divSWFUploadUI").style.display = "none";
                document.getElementById("divLoadingContent").style.display = "";

                var longLoad = function () {
                        document.getElementById("divLoadingContent").style.display = "none";
                        document.getElementById("divLongLoading").style.display = "";
                };
                this.customSettings.loadingTimeout = setTimeout(function () {
                                longLoad.call(self)
                        },
                        15 * 1000
                );
        };

        this.customSettings.loadingTimeout = setTimeout(function () {
                        loading.call(self);
                },
                1*1000
        );
}
function swfUploadLoaded() {
        var self = this;
        clearTimeout(this.customSettings.loadingTimeout);
        //document.getElementById("divSWFUploadUI").style.visibility = "visible";
        //document.getElementById("divSWFUploadUI").style.display = "block";
        document.getElementById("divLoadingContent").style.display = "none";
        document.getElementById("divLongLoading").style.display = "none";
        document.getElementById("divAlternateContent").style.display = "none";

        //document.getElementById("btnBrowse").onclick = function () { self.selectFiles(); };
        document.getElementById("btnCancel").onclick = function () { self.cancelQueue(); };
}

function swfUploadLoadFailed() {
        clearTimeout(this.customSettings.loadingTimeout);
        //document.getElementById("divSWFUploadUI").style.display = "none";
        document.getElementById("divLoadingContent").style.display = "none";
        document.getElementById("divLongLoading").style.display = "none";
        document.getElementById("divAlternateContent").style.display = "";
}


function fileQueued(file) {
        try {
                // add
            　　//total_file_size += file.size;
                //if (total_file_size > total_file_size_limit) {
                //    alert("合計ファイルサイズを超えました。");
                //    var progress = new FileProgress(file, this.customSettings.progressTarget);
                //    progress.setError();
                //    progress.toggleCancel(false, this, file.size);
　　　　　　　　//　　total_file_size　-= file.size;
                //}else{
                    var progress = new FileProgress(file, this.customSettings.progressTarget);
                    progress.setStatus("送信待機中...");
                    progress.toggleCancel(true, this, file.size);
            // add
            document.getElementById('send_filer').scrollTop = document.getElementById('send_filer').scrollHeight;
            total_queued_number++;
            document.getElementById("submitbtn").innerHTML = "<input src=\"" + script_url + "/assets/common/but_send.gif\" type=\"image\" />";
            if (total_queued_number == 1) {
                document.getElementById('send_filer').style.height = '88px'
            }else if (total_queued_number > 1 && total_queued_number < 5){
                var h = document.getElementById('send_filer').style.height.split('px')
                document.getElementById('send_filer').style.height = (parseInt(h[0]) + 66) + 'px'
            }else{
            }
            show_total_queued_number(total_queued_number);
                //}

        } catch (ex) {
                this.debug(ex);
        }

}

function fileQueueError(file, errorCode, message) {
        try {
                if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
                    alert("同時送信可能なファイル数を超えました。");
//                        alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
                        return;
                }

                var progress = new FileProgress(file, this.customSettings.progressTarget);
                progress.setError();
                // add
                // false -> true エラーでも取り消し表示
                //
                 progress.toggleCancel(false);

                switch (errorCode) {
                case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
                        progress.setStatus("ファイルサイズが制限を超えています" + SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT);
                        this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                                    // add
                        if (total_queued_number == 0) {
                            document.getElementById('send_filer').style.height = '88px'
                         }
                        document.getElementById('send_filer').scrollTop = document.getElementById('send_filer').scrollHeight;
                        break;
                case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
                        progress.setStatus("Cannot upload Zero Byte files.");
                        this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
                        progress.setStatus("Invalid File Type.");
                        this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                default:
                        if (file !== null) {
                                progress.setStatus("Unhandled Error");
                        }
                        this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                }
        } catch (ex) {
        this.debug(ex);
    }
}

function fileDialogComplete(numFilesSelected, numFilesQueued) {
        try {
                if (numFilesSelected > 0) {
                        document.getElementById(this.customSettings.cancelButtonId).disabled = false;
                }
                /* I want auto start the upload and I can do that here */
        } catch (ex)  {
        this.debug(ex);
        }
}

function uploadStart(file) {
        try {
                /* I don't want to do any file validation or anything,  I'll just update the UI and
                return true to indicate that the upload should start.
                It's important to update the UI here because in Linux no uploadProgress events are called. The best
                we can do is say we are uploading.
                 */
                var progress = new FileProgress(file, this.customSettings.progressTarget);
                progress.setStatus("送信状況");
                progress.toggleCancel(true, this, file.size);
        }
        catch (ex) {}

        return true;
}

function uploadProgress(file, bytesLoaded, bytesTotal) {
        try {
                var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);

                if (bytesLoaded == bytesTotal){
                    now = new Date();
                    pointtime = now.getTime()
                    show_log("処理中… <img src=" + script_url + "/assets/common/scan_progress.gif>")
                }

                if (total_file_size == 0) {
                    show_transfer_rate(0);
                } else if ((transfer_file_size + bytesLoaded) >= total_file_size) {
                    show_transfer_rate(100);
                } else {
                    show_transfer_rate(Math.ceil(((transfer_file_size + bytesLoaded)/ total_file_size) * 100));
                }

                var progress = new FileProgress(file, this.customSettings.progressTarget);
                progress.setProgress(percent);
                progress.setStatus("送信状況");
        } catch (ex) {
                this.debug(ex);
        }
}

function uploadSuccess(file, serverData) {
        try {
                var progress = new FileProgress(file, this.customSettings.progressTarget);
                progress.setComplete();
                progress.setStatus("送信完了");
                progress.toggleCancel(false);
            document.getElementById('send_filer').scrollTop += (document.getElementById('send_filer').scrollHeight - document.getElementById('send_filer').scrollHeight/total_queued_number)/total_queued_number;

            transfer_file_size += file.size

            if(transfer_file_size == total_file_size){
              show_log("処理中… <img src=" + script_url + "/assets/common/scan_progress.gif>")
            }else{
　　　　      show_log("送信中…")
            }
        } catch (ex) {
                this.debug(ex);
        }
}

function uploadError(file, errorCode, message) {
        try {
                var progress = new FileProgress(file, this.customSettings.progressTarget);
                progress.setError();
                //edit
                progress.toggleCancel(false);

                switch (errorCode) {
                case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
                        progress.setStatus("Upload Error: " + message);
                        this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
                        progress.setStatus("Upload Failed.");
                        this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.IO_ERROR:
                        progress.setStatus("Server (IO) Error");
                        this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
                        progress.setStatus("Security Error");
                        this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
                        progress.setStatus("Upload limit exceeded.");
                        this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
                        progress.setStatus("Failed Validation.  Upload skipped.");
                        this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
                        // If there aren't any files left (they were all cancelled) disable the cancel button
                        //if (this.getStats().files_queued === 0) {

                        //        document.getElementById(this.customSettings.cancelButtonId).disabled = true;
                        //}
                        progress.setStatus("キャンセルしました。");
                        progress.setCancelled();
                        break;
                case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
                        progress.setStatus("Stopped");
                        break;
                default:
                        progress.setStatus("Unhandled Error: " + errorCode);
                        this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
                        break;
                }
        } catch (ex) {
        this.debug(ex);
    }
}

function uploadComplete(file) {
        if (this.getStats().files_queued === 0) {
                document.getElementById(this.customSettings.cancelButtonId).disabled = true;
                alert("Osend_filerK");
        }
}

// This event comes from the Queue Plugin
function queueComplete(numFilesUploaded) {
//        var status = document.getElementById("divStatus");
//        status.innerHTML = numFilesUploaded + " file" + (numFilesUploaded === 1 ? "" : "s") + " uploaded.";
}
