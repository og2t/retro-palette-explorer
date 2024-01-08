class ProcessImage

  @processImage = (data) ->
    @canvas = document.createElement('canvas')
    @context = @canvas.getContext('2d')

    @canvas1 = document.getElementById 'image-1'
    @canvas2 = document.getElementById 'image-2'

    @context1 = @canvas1.getContext('2d')
    @context2 = @canvas2.getContext('2d')

    img = new Image()
    img.src = data
    img.onload = =>
      @canvas.width = img.width
      @canvas.height = img.height
      @canvas1.width = img.width
      @canvas1.height = img.height
      @canvas1.imageSmoothingEnabled = false
      @canvas2.width = img.width
      @canvas2.height = img.height
      @canvas2.imageSmoothingEnabled = false
      @context.drawImage(img, 0, 0)
      imageData = @context.getImageData(0, 0, @canvas.width, @canvas.height).data
      pixelData = @processPixelData(imageData)
      # console.table(pixelData)

  @processPixelData = (imageData) ->
    pixelData = {}
    for i in [0...imageData.length] by 4
      r = imageData[i]
      g = imageData[i + 1]
      b = imageData[i + 2]
      hex = @rgbToHex(r, g, b)
      pixelData[hex] = (pixelData[hex] or 0) + 1
      # plot pixel on canvas1 with color1
      x = (i / 4) % @canvas.width
      y = Math.floor((i / 4) / @canvas.width)
      color1 = Main.json[hex]?.color1
      @context1.fillStyle = color1
      @context1.fillRect(x, y, 1, 1);
      # plot pixel on canvas2 with color2
      color2 = Main.json[hex]?.color2 
      @context2.fillStyle = color2
      @context2.fillRect(x, y, 1, 1);
    return pixelData

  @componentToHex = (c) ->
    hex = c.toString(16)
    return '0' + hex if hex.length is 1
    return hex

  @rgbToHex = (r, g, b) ->
    return '#' + @componentToHex(r) + @componentToHex(g) + @componentToHex(b)
