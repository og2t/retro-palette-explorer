// https://github.com/adamschwartz/log/

// italic — log('this is *italic*')
// bold — log('this word _bold_')
// code — log('this word `code`')
// Use a custom syntax to style text however you want: log('this is [c="color: red"]red[c]').
var _log, exportedLog, ffSupport, formats, getOrderedMatches, hasMatches, isFF, isIE, isOpera, isSafari, log, makeArray, operaSupport, safariSupport, stringToArgs;

if (window.console && window.console.log) {
  log = function() {
    var args, arrayArguments;
    args = [];
    arrayArguments = makeArray(arguments);
    if (!/^\w\s/.test(arrayArguments[0])) {
      arrayArguments.unshift('t ');
    }
    arrayArguments.forEach(function(arg) {
      if (typeof arg === 'string') {
        return args = args.concat(stringToArgs(arg));
      } else {
        return args.push(arg);
      }
    });
    return _log.apply(window, args);
  };
  _log = function() {
    return console.log.apply(console, makeArray(arguments));
  };
  makeArray = function(arrayLikeThing) {
    return Array.prototype.slice.call(arrayLikeThing);
  };
  formats = [
    {
      // Italic
      regex: /\*([^\*]+)\*/,
      replacer: function(m,
    p1) {
        return `%c${p1}%c`;
      },
      styles: function() {
        return ['font-style: italic',
    ''];
      }
    },
    {
      // Bold
      regex: /\__([^\_]+)\__/,
      replacer: function(m,
    p1) {
        return `%c${p1}%c`;
      },
      styles: function() {
        return ['font-weight: bold',
    ''];
      }
    },
    {
      // Crirical
      regex: /^c\s/,
      replacer: function(m,
    p1) {
        return "%c CRITICAL%c";
      },
      styles: function() {
        return ['color: #FF0000',
    ''];
      }
    },
    {
      // Error
      regex: /^e\s/,
      replacer: function(m,
    p1) {
        return "%c    ERROR%c";
      },
      styles: function() {
        return ['color: #CC0000',
    ''];
      }
    },
    {
      // Warning
      regex: /^w\s/,
      replacer: function(m,
    p1) {
        return "%c  WARNING%c";
      },
      styles: function() {
        return ['color: #E7A930',
    ''];
      }
    },
    {
      // Info
      regex: /^i\s/,
      replacer: function(m,
    p1) {
        return "%c     INFO%c";
      },
      styles: function() {
        return ['color: #3D98E7',
    ''];
      }
    },
    {
      // Debug
      regex: /^d\s/,
      replacer: function(m,
    p1) {
        return "%c    DEBUG%c";
      },
      styles: function() {
        return ['color: #65B043',
    ''];
      }
    },
    {
      // Temporary
      regex: /^t\s/,
      replacer: function(m,
    p1) {
        return "%cTEMPORARY%c";
      },
      styles: function() {
        return ['color: #CB64D1',
    ''];
      }
    },
    {
      // Action
      regex: /^a\s/,
      replacer: function(m,
    p1) {
        return "%c   ACTION%c";
      },
      styles: function() {
        return ['color: #F7CA02',
    ''];
      }
    },
    {
      // Code
      regex: /\`([^\`]+)\`/,
      replacer: function(m,
    p1) {
        return `%c${p1}%c`;
      },
      styles: function() {
        return ['background: rgb(255, 255, 219); padding: 1px 5px; border: 1px solid rgba(0, 0, 0, 0.1)',
    ''];
      }
    },
    {
      // Custom syntax: [c="color: red"]red[c]
      regex: /\[c\=(?:\"|\')?((?:(?!(?:\"|\')\]).)*)(?:\"|\')?\]((?:(?!\[c\]).)*)\[c\]/,
      replacer: function(m,
    p1,
    p2) {
        return `%c${p2}%c`;
      },
      styles: function(match) {
        return [match[1],
    ''];
      }
    }
  ];
  hasMatches = function(str) {
    var _hasMatches;
    _hasMatches = false;
    formats.forEach(function(format) {
      if (format.regex.test(str)) {
        return _hasMatches = true;
      }
    });
    return _hasMatches;
  };
  getOrderedMatches = function(str) {
    var matches;
    matches = [];
    formats.forEach(function(format) {
      var match;
      match = str.match(format.regex);
      if (match) {
        return matches.push({
          format: format,
          match: match
        });
      }
    });
    return matches.sort(function(a, b) {
      return a.match.index - b.match.index;
    });
  };
  stringToArgs = function(str) {
    var firstMatch, matches, styles;
    styles = [];
    while (hasMatches(str)) {
      matches = getOrderedMatches(str);
      firstMatch = matches[0];
      str = str.replace(firstMatch.format.regex, firstMatch.format.replacer);
      styles = styles.concat(firstMatch.format.styles(firstMatch.match));
    }
    return [str].concat(styles);
  };
  // Browser detection
  // https://twitter.com/paul_irish/status/384789864396226560
  isSafari = function() {
    return /Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor);
  };
  isOpera = function() {
    return /OPR/.test(navigator.userAgent) && /Opera/.test(navigator.vendor);
  };
  isFF = function() {
    return /Firefox/.test(navigator.userAgent);
  };
  isIE = function() {
    return /MSIE/.test(navigator.userAgent);
  };
  // Safari starting supporting stylized logs in Nightly 537.38+
  // See https://github.com/adamschwartz/log/issues/6
  safariSupport = function() {
    var m;
    m = navigator.userAgent.match(/AppleWebKit\/(\d+)\.(\d+)(\.|\+|\s)/);
    if (!m) {
      return false;
    }
    return 537.38 <= parseInt(m[1], 10) + (parseInt(m[2], 10) / 100);
  };
  // Opera
  operaSupport = function() {
    var m;
    m = navigator.userAgent.match(/OPR\/(\d+)\./);
    if (!m) {
      return false;
    }
    return 15 <= parseInt(m[1], 10);
  };
  // Detect for Firebug http://stackoverflow.com/a/398120/131898
  ffSupport = function() {
    return window.console.firebug || window.console.exception;
  };
  // Export
  if (isIE() || (isFF() && !ffSupport()) || (isOpera() && !operaSupport()) || (isSafari() && !safariSupport())) {
    exportedLog = _log;
  } else {
    exportedLog = log;
  }
  exportedLog.l = _log;
  if (typeof define === 'function' && define.amd) {
    define(exportedLog);
  } else if (typeof exports !== 'undefined') {
    module.exports = exportedLog;
  } else {
    window.log = exportedLog;
  }
  window.log = exportedLog;
  window.logTest = function() {
    log('c Crirical');
    log('e Error');
    log('w Warning');
    log('i Info');
    log('d Debug');
    log('Anything');
  };
}
