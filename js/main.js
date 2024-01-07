var Main, main;

Main = (function() {
  class Main {
    constructor() {
      this.canvas = document.getElementById('canvas');
      this.context = this.canvas.getContext('2d');
      this.canvas.addEventListener('click', (event) => {
        this.scale = this.scale === 1 ? 2 : 1;
        return this.filter();
      });
      this.excludeCheckbox = document.getElementById('exclude');
      this.excludeCheckbox.onchange = (event) => {
        this.excludeNative = event.target.checked;
        return this.filter();
      };
      this.swapCheckbox = document.getElementById('swap');
      this.swapCheckbox.onchange = (event) => {
        this.swap = event.target.checked;
        return this.filter();
      };
      this.sortSelect = document.getElementById('sort');
      this.sortSelect.onchange = (event) => {
        this.sortBy = event.target.options[event.target.selectedIndex].value.split(',');
        return this.filter();
      };
      this.ditherSelect = document.getElementById('dither');
      this.ditherSelect.onchange = (event) => {
        this.ditherType = event.target.options[event.target.selectedIndex].value;
        if (this.ditherType === 'lace') {
          this.stopLoop = false;
          this.loop();
        } else {
          this.stopLoop = true;
        }
        return this.filter();
      };
      this.paletteSelect = document.getElementById('palette');
      this.paletteSelect.onchange = (event) => {
        this.paletteType = event.target.options[event.target.selectedIndex].value;
        this.palette = Palettes[this.paletteType];
        return this.filter();
      };
      this.text = document.getElementById('text');
      this.output = document.getElementById('output');
      this.slider = document.getElementById('slider');
      this.slider.oninput = (event) => {
        return this.text.value = event.target.value;
      };
      this.slider.onchange = (event) => {
        this.lumaDiffThreshold = event.target.value;
        return this.filter();
      };
      this.filter();
      return;
    }

    createData() {
      var col1, col1HSL, col2, col2HSL, diffL, diffLuma, distance, index1, index2, j, k, l, mix, mixHSL, mixIndex, r, ref, ref1, remainingRows, temp;
      this.output.value = `; Paint.NET Palette File
; Lines that start with a semicolon are comments
; Colors are written as 8-digit hexadecimal numbers: aarrggbb
; For example, this would specify green: FF00FF00
; The alpha ('aa') value specifies how transparent a color is. FF is fully opaque, 00 is fully transparent.
; A palette must consist of ninety six (96) colors. If there are less than this, the remaining color
; slots will be set to white (FFFFFFFF). If there are more, then the remaining colors will be ignored.
`;
      this.mixed = [];
      this.json = [];
      for (index1 = j = 0; j <= 15; index1 = ++j) {
        for (index2 = k = ref = index1; (ref <= 0xf ? k <= 0xf : k >= 0xf); index2 = ref <= 0xf ? ++k : --k) {
          col1 = ColorUtils.colorToHEX(this.palette[index1]);
          col2 = ColorUtils.colorToHEX(this.palette[index2]);
          mixIndex = (Palettes.lumaOrder.indexOf(index1) + Palettes.lumaOrder.indexOf(index2)) / 2;
          mix = ColorUtils.mixHEX(col1, col2);
          mixHSL = ColorUtils.HEXtoHSL(mix);
          col1HSL = ColorUtils.HEXtoHSL(col1);
          col2HSL = ColorUtils.HEXtoHSL(col2);
          distance = ColorUtils.getHEXDistance(col1, col2);
          diffLuma = Math.abs(Palettes.lumas[index1] - Palettes.lumas[index2]) / 32;
          diffL = Math.abs(col2HSL.l - col1HSL.l);
          if (this.paletteType === 'PICO8') {
            if (diffL > this.lumaDiffThreshold) {
              continue;
            }
          } else {
            if (diffLuma > this.lumaDiffThreshold) {
              continue;
            }
          }
          // if @excludeNative and (col1 is col2) then continue
          if (this.excludeNative && (col1 !== col2)) {
            continue;
          }
          if (this.swap) {
            // Switch colors
            if (col1HSL.l > col2HSL.l) {
              temp = col1;
              col1 = col2;
              col2 = temp;
            }
          }
          this.mixed.push({
            h: mixHSL.h,
            s: mixHSL.s,
            l: mixHSL.l,
            mixIndex: mixIndex,
            luma: (Palettes.lumas[index1] + Palettes.lumas[index2]) / 2,
            diffH: Math.abs(col2HSL.h - col1HSL.h),
            diffS: Math.abs(col2HSL.s - col1HSL.s),
            diffL: diffL,
            diffLuma: diffLuma,
            distance: distance,
            index1: index1.toString(16),
            index2: index2.toString(16),
            col1: col1,
            col2: col2,
            mix: mix,
            distTo0: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x0])),
            distTo1: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x1])),
            distTo2: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x2])),
            distTo3: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x3])),
            distTo4: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x4])),
            distTo5: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x5])),
            distTo6: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x6])),
            distTo7: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x7])),
            distTo8: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x8])),
            distTo9: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0x9])),
            distToA: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xA])),
            distToB: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xB])),
            distToC: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xC])),
            distToD: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xD])),
            distToE: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xE])),
            distToF: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(this.palette[0xF])),
            distToRed: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(0xff0000)),
            distToGreen: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(0x00ff00)),
            distToBlue: ColorUtils.getHEXDistance(mix, ColorUtils.colorToHEX(0x0000ff))
          });
          // @json.push
          //   index1: index1
          //   index2: index2
          //   mix: mix
          this.output.value += mix.split('#').join('ff').toUpperCase() + '\n';
        }
      }
      // Add remaining rows
      remainingRows = 96 - this.mixed.length;
      if (remainingRows > 0) {
        for (r = l = 0, ref1 = remainingRows; (0 <= ref1 ? l <= ref1 : l >= ref1); r = 0 <= ref1 ? ++l : --l) {
          this.output.value += 'FFFFFFFF' + '\n';
        }
      }
      this.json = this.output.value;
    }

    filter() {
      if (this.paletteType === 'PICO8') {
        this.sortBy = this.sortBy.join(',').replace('luma', 'l').split(',');
      }
      this.createData();
      this.sortBy.unshift('diffLuma');
      if (this.sortBy.length > 0) {
        this.mixed.sort(SortUtils.dynamicMultiSort(this.sortBy));
      }
      this.createTable();
      this.fillTable();
      this.drawColors();
      // @createGradient()
      // @print JSON.stringify @json
      this.print(this.json);
    }

    print(buffer) {
      FileSaver.saveAsTextFile(buffer);
    }

    drawColors() {
      var j, len, obj, ref, size, x, y;
      size = 8;
      this.context.fillStyle = '#000';
      this.canvas.width = 17 * size * this.scale;
      this.canvas.height = 8 * size * this.scale;
      HDPI.detectAndSetRatio(this.canvas);
      this.context.imageSmoothingEnabled = false;
      this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
      x = 0;
      y = 0;
      ref = this.mixed;
      for (j = 0, len = ref.length; j < len; j++) {
        obj = ref[j];
        this[this.ditherType](this.canvas, obj.col1, obj.col2, size, size, x * size, y * size);
        x++;
        if (x > 16) {
          x = 0;
          y++;
        }
      }
    }

    // Didn't make sense
    createGradient() {
      var colorObj, colorRGB, colorRange, colorStop, colors, gradientTemplate, index, j, len, numColors, output, ref;
      output = [];
      numColors = this.mixed.length;
      colorRange = 4096 / (numColors - 1);
      colors = [];
      ref = this.mixed;
      for (index = j = 0, len = ref.length; j < len; index = ++j) {
        colorObj = ref[index];
        colorRGB = ColorUtils.HEXtoRGBObject(colorObj.mix);
        colorStop = {
          midpoint: 50,
          type: 'userStop',
          location: Math.round(index * colorRange),
          color: {
            red: colorRGB.r,
            green: colorRGB.g,
            blue: colorRGB.b
          }
        };
        colors.push(colorStop);
      }
      gradientTemplate = {
        name: `[${numColors}]`,
        gradientForm: 'customStops',
        interpolation: 4096,
        colors: colors
      };
      output.push(gradientTemplate);
      log(JSON.stringify(output));
      this.print(JSON.stringify(output));
    }

    createTable() {
      var field, fields, header, i, j, len, row;
      this.table = document.getElementById('table');
      while (this.table.firstChild) {
        this.table.removeChild(this.table.firstChild);
      }
      fields = ["#", "mixed", "color1", "color2", "color1", "color2", "RGB distance", "hue", "saturation", "luma", "luma diff", "hex luma", "hex luma diff", "hex value"];
      header = this.table.createTHead();
      row = header.insertRow(0);
      for (i = j = 0, len = fields.length; j < len; i = ++j) {
        field = fields[i];
        row.insertCell(i).innerHTML = field;
      }
    }

    noDither(canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) {
      var context, mix;
      mix = ColorUtils.mixHEX(col1, col2);
      context = canvas.getContext('2d');
      context.fillStyle = mix;
      context.fillRect(offsetX * this.scale, offsetY * this.scale, w * this.scale, h * this.scale);
    }

    lace(canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) {
      var context, mix;
      mix = ColorUtils.mixHEX(col1, col2);
      context = canvas.getContext('2d');
      context.fillStyle = mix;
      context.fillRect(offsetX * this.scale, offsetY * this.scale, w * this.scale, h * this.scale);
    }

    hiresDither(canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) {
      var context, j, k, ref, ref1, x, y;
      context = canvas.getContext('2d');
      for (x = j = 0, ref = w; (0 <= ref ? j < ref : j > ref); x = 0 <= ref ? ++j : --j) {
        for (y = k = 0, ref1 = h; (0 <= ref1 ? k < ref1 : k > ref1); y = 0 <= ref1 ? ++k : --k) {
          context.fillStyle = y % 2 ? x % 2 ? col1 : col2 : x % 2 ? col2 : col1;
          context.fillRect((x + offsetX) * this.scale, (y + offsetY) * this.scale, this.scale, this.scale);
        }
      }
    }

    lineDither(canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) {
      var context, j, ref, y;
      context = canvas.getContext('2d');
      for (y = j = 0, ref = h; (0 <= ref ? j < ref : j > ref); y = 0 <= ref ? ++j : --j) {
        context.fillStyle = y % 2 ? col1 : col2;
        context.fillRect(offsetX * this.scale, (y + offsetY) * this.scale, w * this.scale, this.scale);
      }
    }

    multiDither(canvas, col1, col2, w, h, offsetX = 0, offsetY = 0) {
      var context, j, k, ref, ref1, x, y;
      context = canvas.getContext('2d');
      for (x = j = 0, ref = w; (0 <= ref ? j < ref : j > ref); x = 0 <= ref ? ++j : --j) {
        for (y = k = 0, ref1 = h; (0 <= ref1 ? k < ref1 : k > ref1); y = 0 <= ref1 ? ++k : --k) {
          context.fillStyle = y % 2 ? Math.ceil((x + 1) / 2) % 2 ? col1 : col2 : Math.ceil((x + 1) / 2) % 2 ? col2 : col1;
          context.fillRect((x + offsetX) * this.scale, (y + offsetY) * this.scale, this.scale, this.scale);
        }
      }
    }

    fillTable() {
      var body, canvas, cellSize, context, i, j, len, obj, ref, row;
      cellSize = 16;
      body = this.table.createTBody();
      ref = this.mixed;
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        obj = ref[i];
        row = body.insertRow(i);
        row.insertCell(0).innerHTML = i + 1;
        if (this.ditherType === 'noDither') {
          row.insertCell(1).innerHTML = `<div class='cell' style='background: ${obj.mix};'/>`;
        } else if (this.ditherType === 'lace') {
          row.insertCell(1).innerHTML = `<div class='cell'><div class='cell-odd' style='background: ${obj.col1};'></div><div class='cell-even' style='background: ${obj.col2};'></div></div>`;
        } else {
          row.insertCell(1).innerHTML = `<canvas class='dither' width='${cellSize}' height='${cellSize}' id='canvas-${i}'/>`;
          canvas = document.getElementById(`canvas-${i}`);
          HDPI.detectAndSetRatio(canvas);
          context = canvas.getContext('2d');
          this[this.ditherType](canvas, obj.col1, obj.col2, cellSize / this.scale, cellSize / this.scale);
        }
        row.insertCell(2).innerHTML = obj.index1;
        row.insertCell(3).innerHTML = obj.index2;
        row.insertCell(4).innerHTML = `<div class='cell' style='background: ${obj.col1}'/>`;
        row.insertCell(5).innerHTML = `<div class='cell' style='background: ${obj.col2}'/>`;
        row.insertCell(6).innerHTML = obj.distance.toFixed(0);
        row.insertCell(7).innerHTML = obj.h.toFixed(2);
        row.insertCell(8).innerHTML = obj.s.toFixed(2);
        row.insertCell(9).innerHTML = (obj.luma / 32).toFixed(2);
        row.insertCell(10).innerHTML = obj.diffLuma.toFixed(2);
        row.insertCell(11).innerHTML = obj.l.toFixed(2);
        row.insertCell(12).innerHTML = obj.diffL.toFixed(4);
        row.insertCell(13).innerHTML = obj.mix;
      }
    }

    loop() {
      this.table.classList.toggle('odd');
      if (this.stopLoop) {
        return;
      }
      requestAnimationFrame(() => {
        return this.loop();
      });
    }

  };

  Main.prototype.palette = Palettes.PEPTO;

  Main.prototype.paletteType = 'PEPTO';

  Main.prototype.sortBy = ['luma'];

  Main.prototype.lumaDiffThreshold = 1;

  Main.prototype.ditherType = 'noDither';

  Main.prototype.excludeNative = false;

  Main.prototype.scale = 2;

  Main.prototype.swap = true;

  Main.prototype.stopLoop = false;

  return Main;

}).call(this);

// Bootstrap
main = new Main();
