var ProcessImage;

ProcessImage = class ProcessImage {
  static processImage(data) {
    var img;
    this.canvas = document.createElement('canvas');
    this.context = this.canvas.getContext('2d');
    this.canvas1 = document.getElementById('image-1');
    this.canvas2 = document.getElementById('image-2');
    this.context1 = this.canvas1.getContext('2d');
    this.context2 = this.canvas2.getContext('2d');
    img = new Image();
    img.src = data;
    return img.onload = () => {
      var imageData, pixelData;
      this.canvas.width = img.width;
      this.canvas.height = img.height;
      this.canvas1.width = img.width;
      this.canvas1.height = img.height;
      this.canvas1.imageSmoothingEnabled = false;
      this.canvas2.width = img.width;
      this.canvas2.height = img.height;
      this.canvas2.imageSmoothingEnabled = false;
      this.context.drawImage(img, 0, 0);
      imageData = this.context.getImageData(0, 0, this.canvas.width, this.canvas.height).data;
      return pixelData = this.processPixelData(imageData);
    };
  }

  // console.table(pixelData)
  static processPixelData(imageData) {
    var b, color1, color2, g, hex, i, j, pixelData, r, ref, ref1, ref2, x, y;
    pixelData = {};
    for (i = j = 0, ref = imageData.length; j < ref; i = j += 4) {
      r = imageData[i];
      g = imageData[i + 1];
      b = imageData[i + 2];
      hex = this.rgbToHex(r, g, b);
      pixelData[hex] = (pixelData[hex] || 0) + 1;
      // plot pixel on canvas1 with color1
      x = (i / 4) % this.canvas.width;
      y = Math.floor((i / 4) / this.canvas.width);
      color1 = (ref1 = Main.json[hex]) != null ? ref1.color1 : void 0;
      this.context1.fillStyle = color1;
      this.context1.fillRect(x, y, 1, 1);
      color2 = (ref2 = Main.json[hex]) != null ? ref2.color2 : void 0;
      this.context2.fillStyle = color2;
      this.context2.fillRect(x, y, 1, 1);
    }
    return pixelData;
  }

  static componentToHex(c) {
    var hex;
    hex = c.toString(16);
    if (hex.length === 1) {
      return '0' + hex;
    }
    return hex;
  }

  static rgbToHex(r, g, b) {
    return '#' + this.componentToHex(r) + this.componentToHex(g) + this.componentToHex(b);
  }

};
