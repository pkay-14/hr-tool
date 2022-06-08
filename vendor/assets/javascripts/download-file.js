(function () {
  /**
   * @description download the file
   * @param {Blob | BlobPart} fileContent
   * @param {String} fileName
   */
  function downloadFile(fileContent, fileName) {
    const link = document.createElement('a');

    link.href = window.URL.createObjectURL(new Blob([fileContent]));
    link.download = fileName;
    link.click();
    link.remove();
  }

  window.downloadFile = downloadFile;
}());
