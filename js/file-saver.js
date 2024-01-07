var FileSaver;

FileSaver = (function() {
  class FileSaver {
    // http://stackoverflow.com/questions/21012580/is-it-possible-to-write-data-to-file-using-only-javascript
    static makeTextFile(text) {
      var data;
      data = new Blob([text], {
        type: 'text/plain'
      });
      // If we are replacing a previously generated file we need to
      // manually revoke the object URL to avoid memory leaks.
      if (this.textFile !== null) {
        window.URL.revokeObjectURL(this.textFile);
      }
      this.textFile = window.URL.createObjectURL(data);
      return this.textFile;
    }

    static saveAsTextFile(text) {
      var link;
      link = document.getElementById('downloadlink');
      link.href = FileSaver.makeTextFile(text);
      link.style.display = 'block';
    }

  };

  FileSaver.textFile = null;

  return FileSaver;

}).call(this);
