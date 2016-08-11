class MultiVoxel

	constructor: (@canvas, readyCallback, @cols = 40, @rows = 25) ->
		@cells = @rows * @cols

		# Attributes lists
		@lh = Utils.getArray @cells
		@cr = Utils.getArray @cells
		@ll = Utils.getArray @cells

		# Address lists
		@mapping = new Array @cells

		for i in [0...@cells]
			@mapping[i] = lh: null, cr: null, ll: null

		@image = new Image
		@image.onload = readyCallback
		@image.src = 'assets/iso-blocks.png'

		# Get context
		@context = @canvas.getContext '2d'

		# Retina fix
		devicePixelRatio = window.devicePixelRatio || 1
		backingStoreRatio = @context.backingStorePixelRatio || 1

		@ratio = devicePixelRatio / backingStoreRatio

		oldWidth = @canvas.width
		oldHeight = @canvas.height

		@canvas.width = oldWidth * @ratio
		@canvas.height = oldHeight * @ratio

		@canvas.style.width = oldWidth + 'px'
		@canvas.style.height = oldHeight + 'px'
		return


	# Fill the memory with a given color
	clear: (color = 0) =>
		for i in [0...@cells]
			@lh[i] = color
			@cr[i] = color
			@ll[i] = color
		return


	drawVoxel: (x, y, topColor, leftColor, rightColor, textureOffset) ->
		# draw right top
		@drawTop x, y, topColor, 1, textureOffset
		# draw left top
		@drawTop x, y, topColor, 0, textureOffset
		# draw side right
		@drawSide x, y, rightColor, 1, textureOffset
		# draw left side
		@drawSide x, y, leftColor, 0, textureOffset
		return


	drawTop: (x, y, color, isRight, textureOffset) ->
		addr = y * @cols
		offset = x + isRight

		line1 = addr + offset
		line2 = addr + offset + 40

		if (x & 1) is 0
			# even
			@cr[line1] = color
			@mapping[line1].cr = read: textureOffset, side: 'T'

		else
			# odd
			@ll[line1] = color
			@lh[line2] = color
			@mapping[line1].ll = read: textureOffset, side: 'T'
			@mapping[line2].lh = read: textureOffset, side: 'T'
		return


	drawSide: (x, y, color, isRight, textureOffset) ->
		addr = y * @cols
		offset = x + isRight

		line1 = addr + offset
		line2 = addr + offset + 40
		line3 = addr + offset + 80

		if (x & 1) is 0
			# even
			@ll[line1] = color
			@lh[line2] = color
			@cr[line2] = color
			@mapping[line1].ll = read: textureOffset, side: if isRight then 'R' else 'L'
			@mapping[line2].lh = read: textureOffset, side: if isRight then 'R' else 'L'
			@mapping[line2].cr = read: textureOffset, side: if isRight then 'R' else 'L'

		else
			# odd
			@ll[line2] = color
			@cr[line2] = color
			@lh[line3] = color
			@mapping[line2].ll = read: textureOffset, side: if isRight then 'R' else 'L'
			@mapping[line2].cr = read: textureOffset, side: if isRight then 'R' else 'L'
			@mapping[line3].lh = read: textureOffset, side: if isRight then 'R' else 'L'
		return


	toWord: (number, offset = 0x0000) ->
		return ("0000" + (parseInt(number) + offset).toString(16)).substr(-4)


	getByWriteSideAndNibble: (write, side, cell) ->
		for obj, index in @writes
			if obj.write is write and obj.side is side and obj.cell is cell
				return @writes.splice(index, 1)[0]


	printAddr: () ->
		writes = 0
		crPrevObj = {}
		loPrevObj = {}
		hiPrevObj = {}

		reads = 0
		writes = 0

		@writes = []

		for obj, write in @mapping
			if obj.cr?
				@writes.push cell: 'C', write: write, read: obj.cr.read, side: obj.cr.side, ram: 'C'
			if obj.lh?
				@writes.push cell: 'H', write: write, read: obj.lh.read, side: obj.lh.side, ram: 'S'
			if obj.ll?
				@writes.push cell: 'L', write: write, read: obj.ll.read, side: obj.ll.side, ram: 'S'

		# console.log 'writes.length', @writes.length

		@writes.sort Utils.dynamicMultiSort('read', 'side', 'cell', 'write')
		# @writes.sort Utils.dynamicMultiSort('read', 'side', 'write', 'cell')


		lastRead = null
		for obj in @writes
			if obj.read isnt lastRead
				console.log '----------------------------------------------'
			console.log 'read:', '$' + @toWord(obj.read), '  side:', obj.side, '  write:', '$' + @toWord(obj.write), '  cell:', obj.cell
			lastRead = obj.read


		# try to find and store H nibble straight away

		@written = {}
		for i in [0...@cells]
			@written[i] = false

		lastObj = side: null, read: null

		buffer = ''
		buffer += 'routine:\nldy offset\n'

		while @writes.length > 0
			obj = @writes.shift()

			asm = ''
			read = ''

			if obj.side isnt lastObj.side or obj.read isnt lastObj.read

				if obj.read isnt lastObj.read
					read += "ldx texture + $#{@toWord obj.read},y\n"

				# When side or read address changes, make a new texture read
				console.log "%c read:  $#{@toWord(obj.read)} side: #{obj.side} ", 'background: #060; color: #fff'
				read += "lda #{obj.side.toLowerCase()}LUT,x\n"
				console.log read
				reads++

			writes++
			lastObj = obj
			console.log "%c write: $#{@toWord(obj.write)} cell: #{obj.cell} ", 'background: #a00; color: #fff'

			# Color RAM
			if obj.cell is 'C'
				asm += "sta $d800   + $#{@toWord obj.write}\n"

			# # Hi nibble Screen RAM
			if obj.cell is 'H'
				asm += "sta screen1 + $#{@toWord obj.write}\n"

			# Lo nibble Screen RAM
			if obj.cell is 'L'
				asm += "sta screen2 + $#{@toWord obj.write}\n"

			buffer += read
			buffer += asm
			console.log asm

		buffer += 'rts\n'

		# for id, obj of @written
			# log obj
		console.log 'Reads:', reads
		console.log 'Writes:', writes
		# console.log buffer
		FileSaver.saveAsTextFile buffer
		return


	# Fake the VIC here, go thorugh the arrays and draw individual cube sides
	render: () ->
		sw = 8
		sh = 8
		dw = 8
		dh = 8

		# Define offsets in the image
		sshL = 0 * 8
		scrL = 1 * 8
		ssLL = 2 * 8
		sshR = 3 * 8
		scrR = 4 * 8
		sslR = 5 * 8

		@context.save()
		# Scale up for retina

		@context.imageSmoothingEnabled = false
		@context.scale @ratio, @ratio

		# Draw
		for i in [0...@cells]
			dx = i % @cols * 8
			dy = Math.floor(i / 40) * 8

			ssh = @lh[i] * 8
			scr = @cr[i] * 8
			ssl = @ll[i] * 8

			if (i % 2) is 0
				# left
				@context.drawImage @image, ssh, sshL, sw, sh, dx, dy, dw, dh
				@context.drawImage @image, scr, scrL, sw, sh, dx, dy, dw, dh
				@context.drawImage @image, ssl, ssLL, sw, sh, dx, dy, dw, dh
			else
				# right
				@context.drawImage @image, ssh, sshR, sw, sh, dx, dy, dw, dh
				@context.drawImage @image, scr, scrR, sw, sh, dx, dy, dw, dh
				@context.drawImage @image, ssl, sslR, sw, sh, dx, dy, dw, dh

		@context.restore()

		return