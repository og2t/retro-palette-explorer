var ColorUtils;

ColorUtils = class ColorUtils {
  /*
   * Color (value)
   */
  static colorToHEX(color) {
    return '#' + ("000000" + color.toString(16)).substr(-6);
  }

  // Converts numeric value into r, g, b object
  static colorToRGB(color) {
    return {
      r: color >> 16 & 0xff,
      g: color >> 8 & 0xff,
      b: color & 0xff
    };
  }

  static colorToRGBArray(color) {
    var rgb;
    rgb = this.colorToRGB(color);
    return [rgb.r, rgb.g, rgb.b];
  }

  static colorToRGBString(color) {
    return `rgb(${this.colorToRGBArray(color).join(',')})`;
  }

  static RGBToColor(r, g, b) {
    return (r << 16) + (g << 8) + b;
  }

  // Mixes two colors
  static mixColors(color1, color2) {
    var b, g, r, rgb1, rgb2;
    rgb1 = this.colorToRGB(color1);
    rgb2 = this.colorToRGB(color2);
    r = Math.floor((rgb1.r + rgb2.r) / 2);
    g = Math.floor((rgb1.g + rgb2.g) / 2);
    b = Math.floor((rgb1.b + rgb2.b) / 2);
    return this.RGBToColor(r, g, b);
  }

  // Returns distance between two colors [0..1]
  // The more similar, the closer to 1
  static getColorSimilarity(color1, color2) {
    var b, g, r, rgb1, rgb2;
    rgb1 = this.colorToRGB(color1);
    rgb2 = this.colorToRGB(color2);
    r = (rgb2.r - rgb1.r) * (rgb2.r - rgb1.r);
    g = (rgb2.g - rgb1.g) * (rgb2.g - rgb1.g);
    b = (rgb2.b - rgb1.b) * (rgb2.b - rgb1.b);
    return 1 - Math.sqrt(r + g + b) / 441.6729559300637;
  }

  static getNearestColorIndex(hex, array) {
    var arrayLength, b1, b2, distance, g1, g2, i, j, minDistance, nearestColor, r1, r2, ref;
    r1 = hex >> 16 & 0xff;
    g1 = hex >> 8 & 0xff;
    b1 = hex & 0xff;
    minDistance = 0x1000;
    nearestColor = 0;
    arrayLength = array.length;
    for (i = j = 0, ref = arrayLength; (0 <= ref ? j <= ref : j >= ref); i = 0 <= ref ? ++j : --j) {
      r2 = array[i] >> 16 & 0xff;
      g2 = array[i] >> 8 & 0xff;
      b2 = array[i] & 0xff;
      distance = (r2 - r1) * (r2 - r1) + (g2 - g1) * (g2 - g1) + (b2 - b1) * (b2 - b1);
      distance = Math.sqrt(distance);
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = i;
      }
    }
    return nearestColor;
  }

  /*
   * RGB
   */
  static RGBtoHEX(r, g, b) {
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  static RGBtoHSL(r, g, b) {
    var d, h, l, max, min, s;
    r /= 255;
    g /= 255;
    b /= 255;
    max = Math.max(r, g, b);
    min = Math.min(r, g, b);
    h = (max + min) / 2;
    s = (max + min) / 2;
    l = (max + min) / 2;
    if (max === min) {
      h = s = 0; // achromatic
    } else {
      d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
      }
      h /= 6;
    }
    return {
      h: h,
      s: s,
      l: l
    };
  }

  /*
   * HSL
   */
  static hueToRGB(p, q, t) {
    if (t < 0) {
      t += 1;
    }
    if (t > 1) {
      t -= 1;
    }
    if (t < 1 / 6) {
      return p + (q - p) * 6 * t;
    }
    if (t < 1 / 2) {
      return q;
    }
    if (t < 2 / 3) {
      return p + (q - p) * (2 / 3 - t) * 6;
    }
    return p;
  }

  static HSLtoRGB(h, s, l) {
    var b, g, p, q, r;
    if (s === 0) {
      // Monochromatic
      r = g = b = l;
    } else {
      q = (l < 0.5 ? l * (1 + s) : l + s - l * s);
      p = 2 * l - q;
      h = h / 360;
      r = this.hueToRGB(p, q, h + 1 / 3);
      g = this.hueToRGB(p, q, h);
      b = this.hueToRGB(p, q, h - 1 / 3);
    }
    return [r * 255, g * 255, b * 255];
  }

  static HSLtoRGBArray(h, s, l) {
    return HSLtoRGB(h, s, l);
  }

  static HSLtoRGBObject(h, s, l) {
    var result;
    result = this.HSLtoRGB(h, s, l);
    return {
      r: result[0],
      g: result[1],
      b: result[2]
    };
  }

  static HSLtoRGBString(h, s, l) {
    var rgb;
    rgb = this.HSLtoRGB(h, s, l);
    return [Math.floor(rgb[0]), Math.floor(rgb[1]), Math.floor(rgb[2])].join(',');
  }

  /*
   * HEX
   */
  static HEXtoHSL(hex) {
    var rgb;
    rgb = this.HEXtoRGBObject(hex);
    return this.RGBtoHSL(rgb.r, rgb.g, rgb.b);
  }

  static HEXtoRGBArray(hex) {
    var b, color, g, r;
    color = parseInt(hex.replace('#', ''), 16);
    r = color >> 16 & 0xff;
    g = color >> 8 & 0xff;
    b = color & 0xff;
    return [r, g, b];
  }

  static getHEXDistance(hex1, hex2) {
    var b, g, r, rgb1, rgb2;
    rgb1 = this.HEXtoRGBObject(hex1);
    rgb2 = this.HEXtoRGBObject(hex2);
    r = (rgb2.r - rgb1.r) * (rgb2.r - rgb1.r);
    g = (rgb2.g - rgb1.g) * (rgb2.g - rgb1.g);
    b = (rgb2.b - rgb1.b) * (rgb2.b - rgb1.b);
    return Math.sqrt(r + g + b);
  }

  static HEXtoRGBObject(hex) {
    var result;
    result = this.HEXtoRGBArray(hex);
    return {
      r: result[0],
      g: result[1],
      b: result[2]
    };
  }

  static mixHEX(hex1, hex2) {
    var b, g, r, rgb1, rgb2;
    rgb1 = this.HEXtoRGBObject(hex1);
    rgb2 = this.HEXtoRGBObject(hex2);
    r = Math.floor((rgb1.r + rgb2.r) / 2);
    g = Math.floor((rgb1.g + rgb2.g) / 2);
    b = Math.floor((rgb1.b + rgb2.b) / 2);
    return this.RGBtoHEX(r, g, b);
  }

  static HEXtoRGBString(hex) {
    return `rgb(${this.HEXtoRGBArray(hex).join(',')})`;
  }

};
