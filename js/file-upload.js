var FileUpload;

FileUpload = class FileUpload {
  static handleDragOver(event) {
    event.preventDefault();
    return document.getElementById('drop-area').classList.add('highlight');
  }

  static handleDragLeave(event) {
    event.preventDefault();
    return document.getElementById('drop-area').classList.remove('highlight');
  }

  static handleDrop(event) {
    var files;
    event.preventDefault();
    document.getElementById('drop-area').classList.remove('highlight');
    files = event.dataTransfer.files;
    if (files.length > 0) {
      return this.handleFile(files[0]);
    }
  }

  static handleFileSelect(event) {
    var files;
    files = event.target.files;
    if (files.length > 0) {
      return this.handleFile(files[0]);
    }
  }

  static handleFile(file) {
    var imagePreview, reader;
    imagePreview = document.getElementById('image-preview');
    if (file.type.startsWith('image/')) {
      reader = new FileReader();
      reader.onload = function(event) {
        var data;
        data = event.target.result;
        imagePreview.src = data;
        imagePreview.style = "display: block";
        return ProcessImage.processImage(data);
      };
      return reader.readAsDataURL(file);
    } else {
      return alert('Please select a valid image file.');
    }
  }

};
