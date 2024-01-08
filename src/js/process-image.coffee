class ProcessImage

  @processImage = (data) ->
    img = new Image()
    img.src = data
    img.onload = =>
      canvas = document.createElement('canvas')
      context = canvas.getContext('2d')
      canvas.width = img.width
      canvas.height = img.height
      context.drawImage(img, 0, 0)
      imageData = context.getImageData(0, 0, canvas.width, canvas.height).data
      pixelData = @processPixelData(imageData)
      console.table(pixelData)

  @processPixelData = (imageData) ->
    pixelData = {}
    for i in [0...imageData.length] by 4
      r = imageData[i]
      g = imageData[i + 1]
      b = imageData[i + 2]
      hex = @rgbToHex(r, g, b)
      pixelData[hex] = (pixelData[hex] or 0) + 1
    return pixelData

  @componentToHex = (c) ->
    hex = c.toString(16)
    return '0' + hex if hex.length is 1
    return hex

  @rgbToHex = (r, g, b) ->
    return '#' + @componentToHex(r) + @componentToHex(g) + @componentToHex(b)
