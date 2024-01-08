class FileUpload
  @handleDragOver = (event) ->
    event.preventDefault()
    document.getElementById('drop-area').classList.add('highlight')

  @handleDragLeave = (event) ->
    event.preventDefault()
    document.getElementById('drop-area').classList.remove('highlight')

  @handleDrop = (event) ->
    event.preventDefault()
    document.getElementById('drop-area').classList.remove('highlight')
    files = event.dataTransfer.files
    if files.length > 0
      @handleFile files[0]

  @handleFileSelect = (event) ->
    files = event.target.files
    if files.length > 0
      @handleFile files[0]

  @handleFile = (file) ->
    imagePreview = document.getElementById('image-preview')
    if file.type.startsWith('image/')
      reader = new FileReader()
      reader.onload = (event) ->
        data = event.target.result
        imagePreview.src = data
        imagePreview.style = "display: block"
        ProcessImage.processImage data
      reader.readAsDataURL file
    else
      alert 'Please select a valid image file.'