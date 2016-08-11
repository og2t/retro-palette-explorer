drawVoxelLarge = (x, y, top, left, right, scale = 1) ->

  y += 0.5

  # top
  context.beginPath()
  context.moveTo x + 6, y + 0
  context.lineTo x + 6 + 4, y + 0
  context.moveTo x + 4, y + 1
  context.lineTo x + 4 + 8, y + 1
  context.moveTo x + 2, y + 2
  context.lineTo x + 2 + 12, y + 2
  context.moveTo x + 0, y + 3
  context.lineTo x + 0 + 16, y + 3
  context.moveTo x + 2, y + 4
  context.lineTo x + 2 + 12, y + 4
  context.moveTo x + 4, y + 5
  context.lineTo x + 4 + 8, y + 5
  context.moveTo x + 6, y + 6
  context.lineTo x + 6 + 4, y + 6
  context.strokeStyle = top
  context.stroke()

  # left
  context.beginPath()
  context.moveTo x + 0, y + 4
  context.lineTo x + 0 + 2, y + 4
  context.moveTo x + 0, y + 5
  context.lineTo x + 0 + 4, y + 5
  context.moveTo x + 0, y + 6
  context.lineTo x + 0 + 6, y + 6

  context.moveTo x + 2, y + 12
  context.lineTo x + 2 + 6, y + 12
  context.moveTo x + 4, y + 13
  context.lineTo x + 4 + 4, y + 13
  context.moveTo x + 6, y + 14
  context.lineTo x + 6 + 2, y + 14

  context.strokeStyle = left
  context.stroke()
  context.rect(x, y + 7 - 0.5, 8, 5)
  context.fillStyle = left
  context.fill()

  # right
  context.beginPath()
  context.moveTo x + 14, y + 4
  context.lineTo x + 14 + 2, y + 4
  context.moveTo x + 12, y + 5
  context.lineTo x + 12 + 4, y + 5
  context.moveTo x + 10, y + 6
  context.lineTo x + 10 + 6, y + 6

  context.moveTo x + 8, y + 12
  context.lineTo x + 8 + 6, y + 12
  context.moveTo x + 8, y + 13
  context.lineTo x + 8 + 4, y + 13
  context.moveTo x + 8, y + 14
  context.lineTo x + 8 + 2, y + 14

  context.strokeStyle = right
  context.stroke()
  context.rect(x + 8, y + 7 - 0.5, 8, 5)
  context.fillStyle = right
  context.fill()

  return


drawVoxelSmall = (x, y, top, left, right, scale = 1) ->

  y += 0.5

  # top
  context.beginPath()
  context.moveTo x + 2, y + 0
  context.lineTo x + 2 + 4, y + 0
  context.moveTo x + 0, y + 1
  context.lineTo x + 0 + 8, y + 1
  context.moveTo x + 2, y + 2
  context.lineTo x + 2 + 4, y + 2
  context.strokeStyle = top
  context.stroke()

  # left
  context.beginPath()
  context.moveTo x + 0, y + 2
  context.lineTo x + 0 + 2, y + 2
  context.moveTo x + 2, y + 6
  context.lineTo x + 2 + 2, y + 6

  context.strokeStyle = left
  context.stroke()
  context.rect(x, y + 3 - 0.5, 4, 3)
  context.fillStyle = left
  context.fill()

  # right
  context.beginPath()
  context.moveTo x + 6, y + 2
  context.lineTo x + 6 + 2, y + 2
  context.moveTo x + 4, y + 6
  context.lineTo x + 4 + 2, y + 6
  context.strokeStyle = right
  context.stroke()
  context.rect(x + 4, y + 3 - 0.5, 4, 3)
  context.fillStyle = right
  context.fill()

  return