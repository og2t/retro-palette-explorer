# https://github.com/adamschwartz/log/

# italic — log('this is *italic*')
# bold — log('this word _bold_')
# code — log('this word `code`')
# Use a custom syntax to style text however you want: log('this is [c="color: red"]red[c]').
if window.console and window.console.log

    log = ->
        args = []

        arrayArguments = makeArray(arguments)

        if not /^\w\s/.test(arrayArguments[0])
            arrayArguments.unshift 't '

        arrayArguments.forEach (arg) ->
            if typeof arg is 'string'
                args = args.concat stringToArgs arg

            else
                args.push arg

        _log.apply window, args

    _log = ->
        console.log.apply console, makeArray(arguments)

    makeArray = (arrayLikeThing) ->
        Array::slice.call arrayLikeThing

    formats = [{
        # Italic
        regex: /\*([^\*]+)\*/
        replacer: (m, p1) -> "%c#{p1}%c"
        styles: -> ['font-style: italic', '']
    }, {
        # Bold
        regex: /\__([^\_]+)\__/
        replacer: (m, p1) -> "%c#{p1}%c"
        styles: -> ['font-weight: bold', '']
    }, {
        # Crirical
        regex: /^c\s/
        replacer: (m, p1) -> "%c CRITICAL%c"
        styles: -> ['color: #FF0000', '']
    }, {
        # Error
        regex: /^e\s/
        replacer: (m, p1) -> "%c    ERROR%c"
        styles: -> ['color: #CC0000', '']
    }, {
        # Warning
        regex: /^w\s/
        replacer: (m, p1) -> "%c  WARNING%c"
        styles: -> ['color: #E7A930', '']
    }, {
        # Info
        regex: /^i\s/
        replacer: (m, p1) -> "%c     INFO%c"
        styles: -> ['color: #3D98E7', '']
    }, {
        # Debug
        regex: /^d\s/
        replacer: (m, p1) -> "%c    DEBUG%c"
        styles: -> ['color: #65B043', '']
    }, {
        # Temporary
        regex: /^t\s/
        replacer: (m, p1) -> "%cTEMPORARY%c"
        styles: -> ['color: #CB64D1', '']
    }, {
        # Action
        regex: /^a\s/
        replacer: (m, p1) -> "%c   ACTION%c"
        styles: -> ['color: #F7CA02', '']
    }, {
        # Code
        regex: /\`([^\`]+)\`/
        replacer: (m, p1) -> "%c#{p1}%c"
        styles: -> ['background: rgb(255, 255, 219); padding: 1px 5px; border: 1px solid rgba(0, 0, 0, 0.1)', '']
    }, {
        # Custom syntax: [c="color: red"]red[c]
        regex: /\[c\=(?:\"|\')?((?:(?!(?:\"|\')\]).)*)(?:\"|\')?\]((?:(?!\[c\]).)*)\[c\]/
        replacer: (m, p1, p2) -> "%c#{p2}%c"
        styles: (match) -> [match[1], '']
    }]

    hasMatches = (str) ->
        _hasMatches = false

        formats.forEach (format) ->
            if format.regex.test str
                _hasMatches = true

        return _hasMatches

    getOrderedMatches = (str) ->
        matches = []

        formats.forEach (format) ->
            match = str.match format.regex
            if match
                matches.push
                    format: format
                    match: match

        return matches.sort((a, b) -> a.match.index - b.match.index)

    stringToArgs = (str) ->
        styles = []

        while hasMatches str
            matches = getOrderedMatches str
            firstMatch = matches[0]
            str = str.replace firstMatch.format.regex, firstMatch.format.replacer
            styles = styles.concat firstMatch.format.styles(firstMatch.match)

        [str].concat styles

    # Browser detection
    # https://twitter.com/paul_irish/status/384789864396226560

    isSafari = -> /Safari/.test(navigator.userAgent) and /Apple Computer/.test(navigator.vendor)
    isOpera = -> /OPR/.test(navigator.userAgent) and /Opera/.test(navigator.vendor)
    isFF = -> /Firefox/.test(navigator.userAgent)
    isIE = -> /MSIE/.test(navigator.userAgent)

    # Safari starting supporting stylized logs in Nightly 537.38+
    # See https://github.com/adamschwartz/log/issues/6
    safariSupport = ->
        m = navigator.userAgent.match /AppleWebKit\/(\d+)\.(\d+)(\.|\+|\s)/
        return false unless m
        return 537.38 <= parseInt(m[1], 10) + (parseInt(m[2], 10) / 100)

    # Opera
    operaSupport = ->
        m = navigator.userAgent.match /OPR\/(\d+)\./
        return false unless m
        return 15 <= parseInt(m[1], 10)

    # Detect for Firebug http://stackoverflow.com/a/398120/131898
    ffSupport = ->
        window.console.firebug or window.console.exception

    # Export

    if isIE() or (isFF() and not ffSupport()) or (isOpera() and not operaSupport()) or (isSafari() and not safariSupport())
        exportedLog = _log
    else
        exportedLog = log

    exportedLog.l = _log

    if typeof define is 'function' and define.amd
      define exportedLog
    else if typeof exports isnt 'undefined'
      module.exports = exportedLog
    else
      window.log = exportedLog

    window.log = exportedLog

    window.logTest = ->
      log 'c Crirical'
      log 'e Error'
      log 'w Warning'
      log 'i Info'
      log 'd Debug'
      log 'Anything'
      return