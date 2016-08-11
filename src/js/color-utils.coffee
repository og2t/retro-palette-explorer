class ColorUtils

  ###
  # Color (value)
  ###

  @colorToHEX: (color) ->
    return '#' + ("000000" + color.toString(16)).substr(-6)

  # Converts numeric value into r, g, b object
  @colorToRGB: (color) ->
    return {
      r: color >> 16 & 0xff
      g: color >> 8 & 0xff
      b: color & 0xff
    }

  @colorToRGBArray: (color) ->
    rgb = @colorToRGB color
    return [rgb.r, rgb.g, rgb.b]

  @colorToRGBString: (color) ->
    return "rgb(#{@colorToRGBArray(color).join(',')})"

  @RGBToColor: (r, g, b) ->
    return (r << 16) + (g << 8) + b

  # Mixes two colors
  @mixColors: (color1, color2) ->
    rgb1 = @colorToRGB color1
    rgb2 = @colorToRGB color2
    r = Math.floor((rgb1.r + rgb2.r) / 2)
    g = Math.floor((rgb1.g + rgb2.g) / 2)
    b = Math.floor((rgb1.b + rgb2.b) / 2)
    return @RGBToColor r, g, b

  # Returns distance between two colors [0..1]
  # The more similar, the closer to 1
  @getColorSimilarity: (color1, color2) ->
    rgb1 = @colorToRGB color1
    rgb2 = @colorToRGB color2
    r = (rgb2.r - rgb1.r) * (rgb2.r - rgb1.r)
    g = (rgb2.g - rgb1.g) * (rgb2.g - rgb1.g)
    b = (rgb2.b - rgb1.b) * (rgb2.b - rgb1.b)
    return 1 - Math.sqrt(r + g + b) / 441.6729559300637

  @getNearestColorIndex: (hex, array) ->
    r1 = hex >> 16 & 0xff
    g1 = hex >> 8 & 0xff
    b1 = hex & 0xff

    minDistance = 0x1000
    nearestColor = 0

    arrayLength = array.length

    for i in [0..arrayLength]
      r2 = array[i] >> 16 & 0xff
      g2 = array[i] >> 8 & 0xff
      b2 = array[i] & 0xff

      distance = (r2 - r1) * (r2 - r1) + (g2 - g1) * (g2 - g1) + (b2 - b1) * (b2 - b1)
      distance = Math.sqrt distance

      if (distance < minDistance)
        minDistance = distance
        nearestColor = i

    return nearestColor


  ###
  # RGB
  ###

  @RGBtoHEX: (r, g, b) ->
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

  @RGBtoHSL: (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = (max + min) / 2
    s = (max + min) / 2
    l = (max + min) / 2

    if (max == min)
      h = s = 0 # achromatic
    else
      d = max - min
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch max
        when r then h = (g - b) / d + (if g < b then 6 else 0)
        when g then h = (b - r) / d + 2
        when b then h = (r - g) / d + 4
      h /= 6
    return {
      h: h
      s: s
      l: l
    }


  ###
  # HSL
  ###

  @hueToRGB: (p, q, t) ->
    if (t < 0) then t += 1
    if (t > 1) then t -= 1
    if (t < 1/6) then return p + (q - p) * 6 * t
    if (t < 1/2) then return q
    if (t < 2/3) then return p + (q - p) * (2/3 - t) * 6
    return p

  @HSLtoRGB: (h, s, l) ->
    if s is 0
      # Monochromatic
      r = g = b = l
    else
      q = (if l < 0.5 then l * (1 + s) else l + s - l * s)
      p = 2 * l - q
      h = h / 360
      r = @hueToRGB p, q, h + 1/3
      g = @hueToRGB p, q, h
      b = @hueToRGB p, q, h - 1/3
    return [r * 255, g * 255, b * 255]

  @HSLtoRGBArray: (h, s, l) ->
    return HSLtoRGB( h, s, l )

  @HSLtoRGBObject: (h, s, l) ->
    result = @HSLtoRGB h, s, l
    return {
      r: result[0]
      g: result[1]
      b: result[2]
    }

  @HSLtoRGBString: (h, s, l) ->
    rgb = @HSLtoRGB h, s, l
    return [Math.floor(rgb[0]), Math.floor(rgb[1]), Math.floor(rgb[2])].join ','


  ###
  # HEX
  ###

  @HEXtoHSL: (hex) ->
    rgb = @HEXtoRGBObject hex
    return @RGBtoHSL rgb.r, rgb.g, rgb.b

  @HEXtoRGBArray: (hex) ->
    color = parseInt hex.replace('#', ''), 16
    r = color >> 16 & 0xff
    g = color >> 8 & 0xff
    b = color & 0xff
    return [r, g, b]

  @getHEXDistance: (hex1, hex2) ->
    rgb1 = @HEXtoRGBObject hex1
    rgb2 = @HEXtoRGBObject hex2
    r = (rgb2.r - rgb1.r) * (rgb2.r - rgb1.r)
    g = (rgb2.g - rgb1.g) * (rgb2.g - rgb1.g)
    b = (rgb2.b - rgb1.b) * (rgb2.b - rgb1.b)
    return Math.sqrt(r + g + b)

  @HEXtoRGBObject: (hex) ->
    result = @HEXtoRGBArray hex
    return {
      r: result[0],
      g: result[1],
      b: result[2]
    }

  @mixHEX: (hex1, hex2) ->
    rgb1 = @HEXtoRGBObject hex1
    rgb2 = @HEXtoRGBObject hex2
    r = Math.floor((rgb1.r + rgb2.r) / 2)
    g = Math.floor((rgb1.g + rgb2.g) / 2)
    b = Math.floor((rgb1.b + rgb2.b) / 2)
    return @RGBtoHEX r, g, b

  @HEXtoRGBString: (hex) ->
    return "rgb(#{@HEXtoRGBArray(hex).join(',')})"
