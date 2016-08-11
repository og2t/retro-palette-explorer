class Main

  palette: Palettes.PEPTO
  paletteType: 'PEPTO'
  sortBy: ['luma']
  lumaDiffThreshold: 1
  ditherType: 'hiresDither'
  excludeNative: false
  scale: 2
  swap: true

  constructor: () ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.addEventListener 'click', (event) =>
      @scale = if @scale is 1 then 2 else 1
      @filter()

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
      @filter()

    @paletteSelect = document.getElementById 'palette'
    @paletteSelect.onchange = (event) =>
      @paletteType = (event.target.options[event.target.selectedIndex].value)
      @palette = Palettes[@paletteType]
      @filter()

    @text = document.getElementById 'text'

    @slider = document.getElementById 'slider'
    @slider.oninput = (event) =>
      @text.value = event.target.value
    @slider.onchange = (event) =>
      @lumaDiffThreshold = event.target.value
      @filter()

    @filter()
    return

  createData: () ->
    @mixed = []
    @json = []
    for index1 in [0..0xf]
      for index2 in [index1..0xf]
        col1 = ColorUtils.colorToHEX @palette[index1]
        col2 = ColorUtils.colorToHEX @palette[index2]
        mix = ColorUtils.mixHEX col1, col2
        mixHSL = ColorUtils.HEXtoHSL mix
        col1HSL = ColorUtils.HEXtoHSL col1
        col2HSL = ColorUtils.HEXtoHSL col2
        distance = ColorUtils.getHEXDistance col1, col2
        diffLuma = Math.abs(Palettes.lumas[index1] - Palettes.lumas[index2]) / 32
        diffL = Math.abs(col2HSL.l - col1HSL.l)

        if @paletteType is 'PICO8'
          if diffL > @lumaDiffThreshold then continue
        else
          if diffLuma > @lumaDiffThreshold then continue

        if @excludeNative and (col1 is col2) then continue

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

        @json.push
          index1: index1
          index2: index2
          mix: mix

    return


  filter: () ->
    if @paletteType is 'PICO8'
      @sortBy = @sortBy.join(',').replace('luma', 'l').split(',')
    @createData()
    if @sortBy.length > 0
      @mixed.sort SortUtils.dynamicMultiSort @sortBy
    @createTable()
    @fillTable()
    @drawColors()
    @print JSON.stringify @json
    return


  print: (buffer) ->
    FileSaver.saveAsTextFile buffer
    return


  drawColors: () ->
    size = 8
    @context.fillStyle = '#000'
    @canvas.width = 16 * size * @scale
    @canvas.height = 8 * size * @scale
    @context.scale @scale, @scale
    HDPI.detectAndSetRatio @canvas
    @context.imageSmoothingEnabled = false
    @context.fillRect 0, 0, @canvas.width, @canvas.height

    x = 0
    y = 0
    for obj in @mixed
      @[@ditherType] @canvas, obj.col1, obj.col2, size, size, x * size, y * size
      x++
      if x > 16
        x = 0
        y++
    return


  createTable: () ->
    @table = document.getElementById 'table'

    while @table.firstChild
      @table.removeChild @table.firstChild

    fields = [
      "#"
      "mixed"
      "color1"
      "color2"
      "color1"
      "color2"
      "RGB distance"
      "hue"
      "saturation"
      "CBM luma"
      "CBM luma diff"
      "luma"
      "luma diff"
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
    context.fillRect offsetX, offsetY, w, h
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
        context.fillRect x + offsetX, y + offsetY, 1, 1
    return


  lineDither: (canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) ->
    context = canvas.getContext '2d'
    for y in [0...h]
      context.fillStyle = if y % 2 then col1 else col2
      context.fillRect offsetX, y + offsetY, w, 1
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
        context.fillRect x + offsetX, y + offsetY, 1, 1
    return


  fillTable: () ->
    cellSize = 16
    body = @table.createTBody()
    for obj, i in @mixed
      row = body.insertRow i
      row.insertCell(0).innerHTML = i + 1
      # row.insertCell(1).innerHTML = "<div class='cell' style='background: #{obj.mix}'/>"
      row.insertCell(1).innerHTML = "<canvas class='dither' width='#{cellSize}' height='#{cellSize}' id='canvas-#{i}'/>"
      row.insertCell(2).innerHTML = obj.index1
      row.insertCell(3).innerHTML = obj.index2
      row.insertCell(4).innerHTML = "<div class='cell' style='background: #{obj.col1}'/>"
      row.insertCell(5).innerHTML = "<div class='cell' style='background: #{obj.col2}'/>"
      row.insertCell(6).innerHTML = obj.distance.toFixed(0)
      row.insertCell(7).innerHTML = obj.h.toFixed(2)
      row.insertCell(8).innerHTML = obj.s.toFixed(2)
      row.insertCell(9).innerHTML = obj.luma.toFixed(2)
      row.insertCell(10).innerHTML = obj.diffLuma.toFixed(2)
      row.insertCell(11).innerHTML = obj.l.toFixed(2)
      row.insertCell(12).innerHTML = obj.diffL.toFixed(2)
      row.insertCell(13).innerHTML = obj.mix
      canvas = document.getElementById "canvas-#{i}"
      HDPI.detectAndSetRatio canvas
      context = canvas.getContext '2d'
      context.scale @scale, @scale
      @[@ditherType] canvas, obj.col1, obj.col2, cellSize, cellSize
    return

# Bootstrap
main = new Main