class FileSaver
  @textFile: null

  # http://stackoverflow.com/questions/21012580/is-it-possible-to-write-data-to-file-using-only-javascript
  @makeTextFile: (text) ->
    data = new Blob [text], type: 'text/plain'
    # If we are replacing a previously generated file we need to
    # manually revoke the object URL to avoid memory leaks.
    if @textFile != null
      window.URL.revokeObjectURL @textFile
    @textFile = window.URL.createObjectURL data
    return @textFile

  @saveAsTextFile: (text) ->
    link = document.getElementById 'downloadlink'
    link.href = FileSaver.makeTextFile text
    link.style.display = 'block'
    return
