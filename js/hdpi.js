var HDPI;

HDPI = class HDPI {
  static detectAndSetRatio(canvas) {
    var backingStoreRatio, context, devicePixelRatio, oldHeight, oldWidth, ratio;
    // query the various pixel ratios
    context = canvas.getContext('2d');
    devicePixelRatio = window.devicePixelRatio || 1;
    backingStoreRatio = context.webkitBackingStorePixelRatio || context.mozBackingStorePixelRatio || context.msBackingStorePixelRatio || context.oBackingStorePixelRatio || context.backingStorePixelRatio || 1;
    // Find the ratio
    ratio = devicePixelRatio / backingStoreRatio;
    // Upscale the canvas if ratios don't match
    if (devicePixelRatio !== backingStoreRatio) {
      oldWidth = canvas.width;
      oldHeight = canvas.height;
      canvas.width = oldWidth * ratio;
      canvas.height = oldHeight * ratio;
      canvas.style.width = oldWidth + "px";
      canvas.style.height = oldHeight + "px";
      // Now scale the context to counter the fact that we've manually scaled our canvas element
      context.scale(ratio, ratio);
    }
    return ratio;
  }

};
