class Main

  palette: Palettes.PEPTO
  paletteType: 'PEPTO'
  sortBy: ['luma']
  lumaDiffThreshold: 1
  ditherType: 'noDither'
  excludeNative: false
  scale: 2
  swap: true
  stopLoop: false

  constructor: () ->
    @canvasContainer = document.getElementById 'canvas-container'
    @canvasContainer.addEventListener 'click', (event) =>
      @scale = if @scale is 1 then 2 else 1
      @filter()

    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'

    @canvasAlt = document.getElementById 'canvas-alt'
    @contextAlt = @canvasAlt.getContext '2d'

    @excludeCheckbox = document.getElementById 'exclude'
    @excludeCheckbox.onchange = (event) =>
      @excludeNative = event.target.checked
      @filter()

    @swapCheckbox = document.getElementById 'swap'
    @swapCheckbox.onchange = (event) =>
      @swap = event.target.checked
      @filter()

    @sortSelect = document.getElementById 'sort'
    @sortSelect.onchange = (event) =>
      @sortBy = (event.target.options[event.target.selectedIndex].value).split ','
      @filter()

    @ditherSelect = document.getElementById 'dither'
    @ditherSelect.onchange = (event) =>
      @ditherType = event.target.options[event.target.selectedIndex].value
      console.log(@ditherType)
      if @ditherType is 'lace'
        @stopLoop = false
        @loop()
      else
        # Fix by cancelAnimationFrame
        @stopLoop = true
        setTimeout => 
          @table.classList.remove 'odd'
          @canvasContainer.classList.remove 'odd'
        , 100
      @filter()

    @paletteSelect = document.getElementById 'palette'
    @paletteSelect.onchange = (event) =>
      @paletteType = (event.target.options[event.target.selectedIndex].value)
      @palette = Palettes[@paletteType]
      @filter()

    @text = document.getElementById 'text'
    @output = document.getElementById 'output'

    @slider = document.getElementById 'slider'
    @slider.oninput = (event) =>
      @text.value = event.target.value
    @slider.onchange = (event) =>
      @lumaDiffThreshold = event.target.value
      @filter()

    @filter()
    return

  createData: () ->
    @output.value = '''
; Paint.NET Palette File
; Lines that start with a semicolon are comments
; Colors are written as 8-digit hexadecimal numbers: aarrggbb
; For example, this would specify green: FF00FF00
; The alpha ('aa') value specifies how transparent a color is. FF is fully opaque, 00 is fully transparent.
; A palette must consist of ninety six (96) colors. If there are less than this, the remaining color
; slots will be set to white (FFFFFFFF). If there are more, then the remaining colors will be ignored.

'''
    @mixed = []
    @json = []
    for index1 in [0..0xf]
      for index2 in [index1..0xf]
        col1 = ColorUtils.colorToHEX @palette[index1]
        col2 = ColorUtils.colorToHEX @palette[index2]
        mixIndex = (Palettes.lumaOrder.indexOf(index1) + Palettes.lumaOrder.indexOf(index2)) / 2
        mix = ColorUtils.mixHEX col1, col2
        mixHSL = ColorUtils.HEXtoHSL mix
        col1HSL = ColorUtils.HEXtoHSL col1
        col2HSL = ColorUtils.HEXtoHSL col2
        distance = ColorUtils.getHEXDistance col1, col2
        diffLuma = Math.abs(Palettes.lumas[index1] - Palettes.lumas[index2]) / 32
        diffL = Math.abs(col2HSL.l - col1HSL.l)

        if diffLuma > @lumaDiffThreshold then continue

        # if @excludeNative and (col1 is col2) then continue
        if @excludeNative and (col1 isnt col2) then continue

        if @swap
          # Switch colors
          if col1HSL.l > col2HSL.l
            temp = col1
            col1 = col2
            col2 = temp

        @mixed.push
          h: mixHSL.h
          s: mixHSL.s
          l: mixHSL.l
          mixIndex: mixIndex
          luma: (Palettes.lumas[index1] + Palettes.lumas[index2]) / 2
          diffH: Math.abs(col2HSL.h - col1HSL.h)
          diffS: Math.abs(col2HSL.s - col1HSL.s)
          diffL: diffL
          diffLuma: diffLuma
          distance: distance
          index1: index1.toString(16)
          index2: index2.toString(16)
          col1: col1
          col2: col2
          mix: mix

          distTo0: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x0]
          distTo1: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x1]
          distTo2: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x2]
          distTo3: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x3]
          distTo4: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x4]
          distTo5: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x5]
          distTo6: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x6]
          distTo7: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x7]
          distTo8: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x8]
          distTo9: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0x9]
          distToA: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xA]
          distToB: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xB]
          distToC: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xC]
          distToD: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xD]
          distToE: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xE]
          distToF: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX @palette[0xF]
          distToRed:   ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX 0xff0000
          distToGreen: ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX 0x00ff00
          distToBlue:  ColorUtils.getHEXDistance mix, ColorUtils.colorToHEX 0x0000ff

        # @json.push
        #   index1: index1
        #   index2: index2
        #   mix: mix

        @output.value += mix.split('#').join('ff').toUpperCase() + '\n'
    # Add remaining rows
    remainingRows = 96 - @mixed.length
    if (remainingRows > 0)
      for r in [0..remainingRows]
        @output.value += 'FFFFFFFF' + '\n'
    @json = @output.value
    return


  filter: () ->
    @createData()
    @sortBy.unshift 'diffLuma'
    if @sortBy.length > 0
      @mixed.sort SortUtils.dynamicMultiSort @sortBy
    @createTable()
    @fillTable()
    @drawColors()
    # @createGradient()
    # @print JSON.stringify @json
    @print @json
    return


  print: (buffer) ->
    FileSaver.saveAsTextFile buffer
    return


  drawColors: () ->
    size = 8
    @context.fillStyle = '#000'
    @contextAlt.fillStyle = '#000'
    @canvas.width = 17 * size * @scale
    @canvasAlt.width = 17 * size * @scale
    @canvas.height = 8 * size * @scale
    @canvasAlt.height = 8 * size * @scale
    HDPI.detectAndSetRatio @canvas
    HDPI.detectAndSetRatio @canvasAlt
    @context.imageSmoothingEnabled = false
    @contextAlt.imageSmoothingEnabled = false
    @context.fillRect 0, 0, @canvas.width, @canvas.height
    @contextAlt.fillRect 0, 0, @canvas.width, @canvas.height

    x = 0
    y = 0
    for obj in @mixed
      @[@ditherType] @canvas, obj.col1, obj.col2, size, size, x * size, y * size
      x++
      if x > 16
        x = 0
        y++
    return

  # Didn't make sense
  createGradient: () ->
    output = []

    numColors = @mixed.length
    colorRange = 4096 / (numColors - 1)
    colors = []

    for colorObj, index in @mixed
      colorRGB = ColorUtils.HEXtoRGBObject colorObj.mix
      colorStop =
        midpoint: 50
        type: 'userStop'
        location: Math.round(index * colorRange)
        color:
          red: colorRGB.r
          green: colorRGB.g
          blue: colorRGB.b
      colors.push colorStop

    gradientTemplate =
      name: "[#{numColors}]"
      gradientForm: 'customStops'
      interpolation: 4096
      colors: colors

    output.push gradientTemplate

    log JSON.stringify(output)
    @print JSON.stringify(output)
    return


  createTable: () ->
    @table = document.getElementById 'table'

    while @table.firstChild
      @table.removeChild @table.firstChild

    fields = [
      "# of "
      "mixed"
      "color1"
      "color2"
      "color1"
      "color2"
      "RGB distance"
      "hue"
      "saturation"
      "luma"
      "luma diff"
      "hex luma"
      "hex luma diff"
      "hex value"
    ]

    header = @table.createTHead()
    row = header.insertRow 0
    for field, i in fields
      row.insertCell(i).innerHTML = field
    return


  noDither: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    mix = ColorUtils.mixHEX col1, col2
    context = canvas.getContext '2d'
    context.fillStyle = mix
    context.fillRect offsetX * @scale, offsetY * @scale, w * @scale, h * @scale
    return

  lace: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    mix = ColorUtils.mixHEX col1, col2
    context = @canvas.getContext '2d'
    context.fillStyle = col1
    context.fillRect offsetX * @scale, offsetY * @scale, w * @scale, h * @scale
    contextAlt = @canvasAlt.getContext '2d'
    contextAlt.fillStyle = col2
    contextAlt.fillRect offsetX * @scale, offsetY * @scale, w * @scale, h * @scale
    return

  hiresDither: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    context = canvas.getContext '2d'
    for x in [0...w]
      for y in [0...h]
        context.fillStyle =
          if y % 2
            if x % 2 then col1 else col2
          else
            if x % 2 then col2 else col1
        context.fillRect (x + offsetX) * @scale, (y + offsetY) * @scale, @scale, @scale
    return


  lineDither: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    context = canvas.getContext '2d'
    for y in [0...h]
      context.fillStyle = if y % 2 then col1 else col2
      context.fillRect (offsetX) * @scale, (y + offsetY) * @scale, w * @scale, @scale
    return


  multiDither: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    context = canvas.getContext '2d'
    for x in [0...w]
      for y in [0...h]
        context.fillStyle =
          if y % 2
            if Math.ceil((x + 1) / 2) % 2 then col1 else col2
          else
            if Math.ceil((x + 1) / 2) % 2 then col2 else col1
        context.fillRect (x + offsetX) * @scale, (y + offsetY) * @scale, @scale, @scale
    return


  fillTable: () ->
    cellSize = 16
    body = @table.createTBody()
    for obj, i in @mixed
      row = body.insertRow i
      row.insertCell(0).innerHTML = i + 1
      if @ditherType is 'noDither'
        row.insertCell(1).innerHTML = "<div class='cell' style='background: #{obj.mix};'/>"
      else if @ditherType is 'lace'
        row.insertCell(1).innerHTML = "<div class='cell'><div class='cell-odd' style='background: #{obj.col1};'></div><div class='cell-even' style='background: #{obj.col2};'></div></div>"
      else
        row.insertCell(1).innerHTML = "<canvas class='dither' width='#{cellSize}' height='#{cellSize}' id='canvas-#{i}'/>"
        canvas = document.getElementById "canvas-#{i}"
        HDPI.detectAndSetRatio canvas
        context = canvas.getContext '2d'
        @[@ditherType] canvas, obj.col1, obj.col2, cellSize / @scale, cellSize / @scale
      row.insertCell(2).innerHTML = obj.index1
      row.insertCell(3).innerHTML = obj.index2
      row.insertCell(4).innerHTML = "<div class='cell' style='background: #{obj.col1}'/>"
      row.insertCell(5).innerHTML = "<div class='cell' style='background: #{obj.col2}'/>"
      row.insertCell(6).innerHTML = obj.distance.toFixed(0)
      row.insertCell(7).innerHTML = obj.h.toFixed(2)
      row.insertCell(8).innerHTML = obj.s.toFixed(2)
      row.insertCell(9).innerHTML = (obj.luma / 32).toFixed(2)
      row.insertCell(10).innerHTML = obj.diffLuma.toFixed(2)
      row.insertCell(11).innerHTML = obj.l.toFixed(2)
      row.insertCell(12).innerHTML = obj.diffL.toFixed(4)
      row.insertCell(13).innerHTML = obj.mix
      numCols = @table.querySelector('thead')?.childNodes[0]?.childNodes[0];
      numCols.innerHTML = '#/' + @mixed.length
    return


  loop: () ->
    @table.classList.toggle 'odd'
    @canvasContainer.classList.toggle 'odd'
    if @stopLoop then return
    requestAnimationFrame => @loop()
    return


# Bootstrap
main = new Main