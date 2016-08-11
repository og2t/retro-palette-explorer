class HDPI

  @detectAndSetRatio: (canvas) ->
    # query the various pixel ratios
    context = canvas.getContext '2d'
    devicePixelRatio = window.devicePixelRatio or 1
    backingStoreRatio = context.webkitBackingStorePixelRatio \
                        or context.mozBackingStorePixelRatio \
                        or context.msBackingStorePixelRatio \
                        or context.oBackingStorePixelRatio \
                        or context.backingStorePixelRatio \
                        or 1

    # Find the ratio
    ratio = devicePixelRatio / backingStoreRatio

    # Upscale the canvas if ratios don't match
    if devicePixelRatio isnt backingStoreRatio
      oldWidth = canvas.width
      oldHeight = canvas.height
      canvas.width = oldWidth * ratio
      canvas.height = oldHeight * ratio
      canvas.style.width = oldWidth + "px"
      canvas.style.height = oldHeight + "px"

      # Now scale the context to counter the fact that we've manually scaled our canvas element
      context.scale ratio, ratio

    return ratio