((window, undefined_) ->
  createFlags = (flags) ->
    object = flagsCache[flags] = {}
    i = undefined
    length = undefined
    flags = flags.split(/\s+/)
    i = 0
    length = flags.length

    while i < length
      object[flags[i]] = true
      i++
    object
  dataAttr = (elem, key, data) ->
    if data is `undefined` and elem.nodeType is 1
      name = "data-" + key.replace(rmultiDash, "-$1").toLowerCase()
      data = elem.getAttribute(name)
      if typeof data is "string"
        try
          data = (if data is "true" then true else (if data is "false" then false else (if data is "null" then null else (if jQuery.isNumeric(data) then parseFloat(data) else (if rbrace.test(data) then jQuery.parseJSON(data) else data)))))
        jQuery.data elem, key, data
      else
        data = `undefined`
    data
  isEmptyDataObject = (obj) ->
    for name of obj
      continue  if name is "data" and jQuery.isEmptyObject(obj[name])
      return false  if name isnt "toJSON"
    true
  handleQueueMarkDefer = (elem, type, src) ->
    deferDataKey = type + "defer"
    queueDataKey = type + "queue"
    markDataKey = type + "mark"
    defer = jQuery._data(elem, deferDataKey)
    if defer and (src is "queue" or not jQuery._data(elem, queueDataKey)) and (src is "mark" or not jQuery._data(elem, markDataKey))
      setTimeout (->
        if not jQuery._data(elem, queueDataKey) and not jQuery._data(elem, markDataKey)
          jQuery.removeData elem, deferDataKey, true
          defer.fire()
      ), 0
  returnFalse = ->
    false
  returnTrue = ->
    true
  isDisconnected = (node) ->
    not node or not node.parentNode or node.parentNode.nodeType is 11
  winnow = (elements, qualifier, keep) ->
    qualifier = qualifier or 0
    if jQuery.isFunction(qualifier)
      return jQuery.grep(elements, (elem, i) ->
        retVal = !!qualifier.call(elem, i, elem)
        retVal is keep
      )
    else if qualifier.nodeType
      return jQuery.grep(elements, (elem, i) ->
        (elem is qualifier) is keep
      )
    else if typeof qualifier is "string"
      filtered = jQuery.grep(elements, (elem) ->
        elem.nodeType is 1
      )
      if isSimple.test(qualifier)
        return jQuery.filter(qualifier, filtered, not keep)
      else
        qualifier = jQuery.filter(qualifier, filtered)
    jQuery.grep elements, (elem, i) ->
      (jQuery.inArray(elem, qualifier) >= 0) is keep
  createSafeFragment = (document) ->
    list = nodeNames.split("|")
    safeFrag = document.createDocumentFragment()
    safeFrag.createElement list.pop()  while list.length  if safeFrag.createElement
    safeFrag
  root = (elem, cur) ->
    (if jQuery.nodeName(elem, "table") then (elem.getElementsByTagName("tbody")[0] or elem.appendChild(elem.ownerDocument.createElement("tbody"))) else elem)
  cloneCopyEvent = (src, dest) ->
    return  if dest.nodeType isnt 1 or not jQuery.hasData(src)
    type = undefined
    i = undefined
    l = undefined
    oldData = jQuery._data(src)
    curData = jQuery._data(dest, oldData)
    events = oldData.events
    if events
      delete curData.handle

      curData.events = {}
      for type of events
        i = 0
        l = events[type].length

        while i < l
          jQuery.event.add dest, type + (if events[type][i].namespace then "." else "") + events[type][i].namespace, events[type][i], events[type][i].data
          i++
    curData.data = jQuery.extend({}, curData.data)  if curData.data
  cloneFixAttributes = (src, dest) ->
    nodeName = undefined
    return  if dest.nodeType isnt 1
    dest.clearAttributes()  if dest.clearAttributes
    dest.mergeAttributes src  if dest.mergeAttributes
    nodeName = dest.nodeName.toLowerCase()
    if nodeName is "object"
      dest.outerHTML = src.outerHTML
    else if nodeName is "input" and (src.type is "checkbox" or src.type is "radio")
      dest.defaultChecked = dest.checked = src.checked  if src.checked
      dest.value = src.value  if dest.value isnt src.value
    else if nodeName is "option"
      dest.selected = src.defaultSelected
    else dest.defaultValue = src.defaultValue  if nodeName is "input" or nodeName is "textarea"
    dest.removeAttribute jQuery.expando
  getAll = (elem) ->
    if typeof elem.getElementsByTagName isnt "undefined"
      elem.getElementsByTagName "*"
    else if typeof elem.querySelectorAll isnt "undefined"
      elem.querySelectorAll "*"
    else
      []
  fixDefaultChecked = (elem) ->
    elem.defaultChecked = elem.checked  if elem.type is "checkbox" or elem.type is "radio"
  findInputs = (elem) ->
    nodeName = (elem.nodeName or "").toLowerCase()
    if nodeName is "input"
      fixDefaultChecked elem
    else jQuery.grep elem.getElementsByTagName("input"), fixDefaultChecked  if nodeName isnt "script" and typeof elem.getElementsByTagName isnt "undefined"
  shimCloneNode = (elem) ->
    div = document.createElement("div")
    safeFragment.appendChild div
    div.innerHTML = elem.outerHTML
    div.firstChild
  evalScript = (i, elem) ->
    if elem.src
      jQuery.ajax
        url: elem.src
        async: false
        dataType: "script"
    else
      jQuery.globalEval (elem.text or elem.textContent or elem.innerHTML or "").replace(rcleanScript, "/*$0*/")
    elem.parentNode.removeChild elem  if elem.parentNode
  getWH = (elem, name, extra) ->
    val = (if name is "width" then elem.offsetWidth else elem.offsetHeight)
    which = (if name is "width" then cssWidth else cssHeight)
    i = 0
    len = which.length
    if val > 0
      if extra isnt "border"
        while i < len
          val -= parseFloat(jQuery.css(elem, "padding" + which[i])) or 0  unless extra
          if extra is "margin"
            val += parseFloat(jQuery.css(elem, extra + which[i])) or 0
          else
            val -= parseFloat(jQuery.css(elem, "border" + which[i] + "Width")) or 0
          i++
      return val + "px"
    val = curCSS(elem, name, name)
    val = elem.style[name] or 0  if val < 0 or not val?
    val = parseFloat(val) or 0
    if extra
      while i < len
        val += parseFloat(jQuery.css(elem, "padding" + which[i])) or 0
        val += parseFloat(jQuery.css(elem, "border" + which[i] + "Width")) or 0  if extra isnt "padding"
        val += parseFloat(jQuery.css(elem, extra + which[i])) or 0  if extra is "margin"
        i++
    val + "px"
  addToPrefiltersOrTransports = (structure) ->
    (dataTypeExpression, func) ->
      if typeof dataTypeExpression isnt "string"
        func = dataTypeExpression
        dataTypeExpression = "*"
      if jQuery.isFunction(func)
        dataTypes = dataTypeExpression.toLowerCase().split(rspacesAjax)
        i = 0
        length = dataTypes.length
        dataType = undefined
        list = undefined
        placeBefore = undefined
        while i < length
          dataType = dataTypes[i]
          placeBefore = /^\+/.test(dataType)
          dataType = dataType.substr(1) or "*"  if placeBefore
          list = structure[dataType] = structure[dataType] or []
          list[(if placeBefore then "unshift" else "push")] func
          i++
  inspectPrefiltersOrTransports = (structure, options, originalOptions, jqXHR, dataType, inspected) ->
    dataType = dataType or options.dataTypes[0]
    inspected = inspected or {}
    inspected[dataType] = true
    list = structure[dataType]
    i = 0
    length = (if list then list.length else 0)
    executeOnly = (structure is prefilters)
    selection = undefined
    while i < length and (executeOnly or not selection)
      selection = list[i](options, originalOptions, jqXHR)
      if typeof selection is "string"
        if not executeOnly or inspected[selection]
          selection = `undefined`
        else
          options.dataTypes.unshift selection
          selection = inspectPrefiltersOrTransports(structure, options, originalOptions, jqXHR, selection, inspected)
      i++
    selection = inspectPrefiltersOrTransports(structure, options, originalOptions, jqXHR, "*", inspected)  if (executeOnly or not selection) and not inspected["*"]
    selection
  ajaxExtend = (target, src) ->
    key = undefined
    deep = undefined
    flatOptions = jQuery.ajaxSettings.flatOptions or {}
    for key of src
      (if flatOptions[key] then target else (deep or (deep = {})))[key] = src[key]  if src[key] isnt `undefined`
    jQuery.extend true, target, deep  if deep
  buildParams = (prefix, obj, traditional, add) ->
    if jQuery.isArray(obj)
      jQuery.each obj, (i, v) ->
        if traditional or rbracket.test(prefix)
          add prefix, v
        else
          buildParams prefix + "[" + (if typeof v is "object" or jQuery.isArray(v) then i else "") + "]", v, traditional, add
    else if not traditional and obj? and typeof obj is "object"
      for name of obj
        buildParams prefix + "[" + name + "]", obj[name], traditional, add
    else
      add prefix, obj
  ajaxHandleResponses = (s, jqXHR, responses) ->
    contents = s.contents
    dataTypes = s.dataTypes
    responseFields = s.responseFields
    ct = undefined
    type = undefined
    finalDataType = undefined
    firstDataType = undefined
    for type of responseFields
      jqXHR[responseFields[type]] = responses[type]  if type of responses
    while dataTypes[0] is "*"
      dataTypes.shift()
      ct = s.mimeType or jqXHR.getResponseHeader("content-type")  if ct is `undefined`
    if ct
      for type of contents
        if contents[type] and contents[type].test(ct)
          dataTypes.unshift type
          break
    if dataTypes[0] of responses
      finalDataType = dataTypes[0]
    else
      for type of responses
        if not dataTypes[0] or s.converters[type + " " + dataTypes[0]]
          finalDataType = type
          break
        firstDataType = type  unless firstDataType
      finalDataType = finalDataType or firstDataType
    if finalDataType
      dataTypes.unshift finalDataType  if finalDataType isnt dataTypes[0]
      responses[finalDataType]
  ajaxConvert = (s, response) ->
    response = s.dataFilter(response, s.dataType)  if s.dataFilter
    dataTypes = s.dataTypes
    converters = {}
    i = undefined
    key = undefined
    length = dataTypes.length
    tmp = undefined
    current = dataTypes[0]
    prev = undefined
    conversion = undefined
    conv = undefined
    conv1 = undefined
    conv2 = undefined
    i = 1
    while i < length
      if i is 1
        for key of s.converters
          converters[key.toLowerCase()] = s.converters[key]  if typeof key is "string"
      prev = current
      current = dataTypes[i]
      if current is "*"
        current = prev
      else if prev isnt "*" and prev isnt current
        conversion = prev + " " + current
        conv = converters[conversion] or converters["* " + current]
        unless conv
          conv2 = `undefined`
          for conv1 of converters
            tmp = conv1.split(" ")
            if tmp[0] is prev or tmp[0] is "*"
              conv2 = converters[tmp[1] + " " + current]
              if conv2
                conv1 = converters[conv1]
                if conv1 is true
                  conv = conv2
                else conv = conv1  if conv2 is true
                break
        jQuery.error "No conversion from " + conversion.replace(" ", " to ")  unless conv or conv2
        response = (if conv then conv(response) else conv2(conv1(response)))  if conv isnt true
      i++
    response
  createStandardXHR = ->
    try
      return new window.XMLHttpRequest()
  createActiveXHR = ->
    try
      return new window.ActiveXObject("Microsoft.XMLHTTP")
  createFxNow = ->
    setTimeout clearFxNow, 0
    fxNow = jQuery.now()
  clearFxNow = ->
    fxNow = `undefined`
  genFx = (type, num) ->
    obj = {}
    jQuery.each fxAttrs.concat.apply([], fxAttrs.slice(0, num)), ->
      obj[this] = type

    obj
  defaultDisplay = (nodeName) ->
    unless elemdisplay[nodeName]
      body = document.body
      elem = jQuery("<" + nodeName + ">").appendTo(body)
      display = elem.css("display")
      elem.remove()
      if display is "none" or display is ""
        unless iframe
          iframe = document.createElement("iframe")
          iframe.frameBorder = iframe.width = iframe.height = 0
        body.appendChild iframe
        if not iframeDoc or not iframe.createElement
          iframeDoc = (iframe.contentWindow or iframe.contentDocument).document
          iframeDoc.write (if document.compatMode is "CSS1Compat" then "<!doctype html>" else "") + "<html><body>"
          iframeDoc.close()
        elem = iframeDoc.createElement(nodeName)
        iframeDoc.body.appendChild elem
        display = jQuery.css(elem, "display")
        body.removeChild iframe
      elemdisplay[nodeName] = display
    elemdisplay[nodeName]
  getWindow = (elem) ->
    (if jQuery.isWindow(elem) then elem else (if elem.nodeType is 9 then elem.defaultView or elem.parentWindow else false))
  document = window.document
  navigator = window.navigator
  location = window.location
  jQuery = (->
    doScrollCheck = ->
      return  if jQuery.isReady
      try
        document.documentElement.doScroll "left"
      catch e
        setTimeout doScrollCheck, 1
        return
      jQuery.ready()
    jQuery = (selector, context) ->
      new jQuery.fn.init(selector, context, rootjQuery)

    _jQuery = window.jQuery
    _$ = window.$
    rootjQuery = undefined
    quickExpr = /^(?:[^#<]*(<[\w\W]+>)[^>]*$|#([\w\-]*)$)/
    rnotwhite = /\S/
    trimLeft = /^\s+/
    trimRight = /\s+$/
    rsingleTag = /^<(\w+)\s*\/?>(?:<\/\1>)?$/
    rvalidchars = /^[\],:{}\s]*$/
    rvalidescape = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g
    rvalidtokens = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g
    rvalidbraces = /(?:^|:|,)(?:\s*\[)+/g
    rwebkit = /(webkit)[ \/]([\w.]+)/
    ropera = /(opera)(?:.*version)?[ \/]([\w.]+)/
    rmsie = /(msie) ([\w.]+)/
    rmozilla = /(mozilla)(?:.*? rv:([\w.]+))?/
    rdashAlpha = /-([a-z]|[0-9])/g
    rmsPrefix = /^-ms-/
    fcamelCase = (all, letter) ->
      (letter + "").toUpperCase()

    userAgent = navigator.userAgent
    browserMatch = undefined
    readyList = undefined
    DOMContentLoaded = undefined
    toString = Object::toString
    hasOwn = Object::hasOwnProperty
    push = Array::push
    slice = Array::slice
    trim = String::trim
    indexOf = Array::indexOf
    class2type = {}
    jQuery.fn = jQuery:: =
      constructor: jQuery
      init: (selector, context, rootjQuery) ->
        match = undefined
        elem = undefined
        ret = undefined
        doc = undefined
        return this  unless selector
        if selector.nodeType
          @context = this[0] = selector
          @length = 1
          return this
        if selector is "body" and not context and document.body
          @context = document
          this[0] = document.body
          @selector = selector
          @length = 1
          return this
        if typeof selector is "string"
          if selector.charAt(0) is "<" and selector.charAt(selector.length - 1) is ">" and selector.length >= 3
            match = [ null, selector, null ]
          else
            match = quickExpr.exec(selector)
          if match and (match[1] or not context)
            if match[1]
              context = (if context instanceof jQuery then context[0] else context)
              doc = (if context then context.ownerDocument or context else document)
              ret = rsingleTag.exec(selector)
              if ret
                if jQuery.isPlainObject(context)
                  selector = [ document.createElement(ret[1]) ]
                  jQuery.fn.attr.call selector, context, true
                else
                  selector = [ doc.createElement(ret[1]) ]
              else
                ret = jQuery.buildFragment([ match[1] ], [ doc ])
                selector = (if ret.cacheable then jQuery.clone(ret.fragment) else ret.fragment).childNodes
              return jQuery.merge(this, selector)
            else
              elem = document.getElementById(match[2])
              if elem and elem.parentNode
                return rootjQuery.find(selector)  if elem.id isnt match[2]
                @length = 1
                this[0] = elem
              @context = document
              @selector = selector
              return this
          else if not context or context.jquery
            return (context or rootjQuery).find(selector)
          else
            return @constructor(context).find(selector)
        else return rootjQuery.ready(selector)  if jQuery.isFunction(selector)
        if selector.selector isnt `undefined`
          @selector = selector.selector
          @context = selector.context
        jQuery.makeArray selector, this

      selector: ""
      jquery: "1.7.1"
      length: 0
      size: ->
        @length

      toArray: ->
        slice.call this, 0

      get: (num) ->
        (if not num? then @toArray() else (if num < 0 then this[@length + num] else this[num]))

      pushStack: (elems, name, selector) ->
        ret = @constructor()
        if jQuery.isArray(elems)
          push.apply ret, elems
        else
          jQuery.merge ret, elems
        ret.prevObject = this
        ret.context = @context
        if name is "find"
          ret.selector = @selector + (if @selector then " " else "") + selector
        else ret.selector = @selector + "." + name + "(" + selector + ")"  if name
        ret

      each: (callback, args) ->
        jQuery.each this, callback, args

      ready: (fn) ->
        jQuery.bindReady()
        readyList.add fn
        this

      eq: (i) ->
        i = +i
        (if i is -1 then @slice(i) else @slice(i, i + 1))

      first: ->
        @eq 0

      last: ->
        @eq -1

      slice: ->
        @pushStack slice.apply(this, arguments), "slice", slice.call(arguments).join(",")

      map: (callback) ->
        @pushStack jQuery.map(this, (elem, i) ->
          callback.call elem, i, elem
        )

      end: ->
        @prevObject or @constructor(null)

      push: push
      sort: [].sort
      splice: [].splice

    jQuery.fn.init:: = jQuery.fn
    jQuery.extend = jQuery.fn.extend = ->
      options = undefined
      name = undefined
      src = undefined
      copy = undefined
      copyIsArray = undefined
      clone = undefined
      target = arguments[0] or {}
      i = 1
      length = arguments.length
      deep = false
      if typeof target is "boolean"
        deep = target
        target = arguments[1] or {}
        i = 2
      target = {}  if typeof target isnt "object" and not jQuery.isFunction(target)
      if length is i
        target = this
        --i
      while i < length
        if (options = arguments[i])?
          for name of options
            src = target[name]
            copy = options[name]
            continue  if target is copy
            if deep and copy and (jQuery.isPlainObject(copy) or (copyIsArray = jQuery.isArray(copy)))
              if copyIsArray
                copyIsArray = false
                clone = (if src and jQuery.isArray(src) then src else [])
              else
                clone = (if src and jQuery.isPlainObject(src) then src else {})
              target[name] = jQuery.extend(deep, clone, copy)
            else target[name] = copy  if copy isnt `undefined`
        i++
      target

    jQuery.extend
      noConflict: (deep) ->
        window.$ = _$  if window.$ is jQuery
        window.jQuery = _jQuery  if deep and window.jQuery is jQuery
        jQuery

      isReady: false
      readyWait: 1
      holdReady: (hold) ->
        if hold
          jQuery.readyWait++
        else
          jQuery.ready true

      ready: (wait) ->
        if (wait is true and not --jQuery.readyWait) or (wait isnt true and not jQuery.isReady)
          return setTimeout(jQuery.ready, 1)  unless document.body
          jQuery.isReady = true
          return  if wait isnt true and --jQuery.readyWait > 0
          readyList.fireWith document, [ jQuery ]
          jQuery(document).trigger("ready").off "ready"  if jQuery.fn.trigger

      bindReady: ->
        return  if readyList
        readyList = jQuery.Callbacks("once memory")
        return setTimeout(jQuery.ready, 1)  if document.readyState is "complete"
        if document.addEventListener
          document.addEventListener "DOMContentLoaded", DOMContentLoaded, false
          window.addEventListener "load", jQuery.ready, false
        else if document.attachEvent
          document.attachEvent "onreadystatechange", DOMContentLoaded
          window.attachEvent "onload", jQuery.ready
          toplevel = false
          try
            toplevel = not window.frameElement?
          doScrollCheck()  if document.documentElement.doScroll and toplevel

      isFunction: (obj) ->
        jQuery.type(obj) is "function"

      isArray: Array.isArray or (obj) ->
        jQuery.type(obj) is "array"

      isWindow: (obj) ->
        obj and typeof obj is "object" and "setInterval" of obj

      isNumeric: (obj) ->
        not isNaN(parseFloat(obj)) and isFinite(obj)

      type: (obj) ->
        (if not obj? then String(obj) else class2type[toString.call(obj)] or "object")

      isPlainObject: (obj) ->
        return false  if not obj or jQuery.type(obj) isnt "object" or obj.nodeType or jQuery.isWindow(obj)
        try
          return false  if obj.constructor and not hasOwn.call(obj, "constructor") and not hasOwn.call(obj.constructor::, "isPrototypeOf")
        catch e
          return false
        key = undefined
        for key of obj

        key is `undefined` or hasOwn.call(obj, key)

      isEmptyObject: (obj) ->
        for name of obj
          return false
        true

      error: (msg) ->
        throw new Error(msg)

      parseJSON: (data) ->
        return null  if typeof data isnt "string" or not data
        data = jQuery.trim(data)
        return window.JSON.parse(data)  if window.JSON and window.JSON.parse
        return (new Function("return " + data))()  if rvalidchars.test(data.replace(rvalidescape, "@").replace(rvalidtokens, "]").replace(rvalidbraces, ""))
        jQuery.error "Invalid JSON: " + data

      parseXML: (data) ->
        xml = undefined
        tmp = undefined
        try
          if window.DOMParser
            tmp = new DOMParser()
            xml = tmp.parseFromString(data, "text/xml")
          else
            xml = new ActiveXObject("Microsoft.XMLDOM")
            xml.async = "false"
            xml.loadXML data
        catch e
          xml = `undefined`
        jQuery.error "Invalid XML: " + data  if not xml or not xml.documentElement or xml.getElementsByTagName("parsererror").length
        xml

      noop: ->

      globalEval: (data) ->
        if data and rnotwhite.test(data)
          (window.execScript or (data) ->
            window["eval"].call window, data
          ) data

      camelCase: (string) ->
        string.replace(rmsPrefix, "ms-").replace rdashAlpha, fcamelCase

      nodeName: (elem, name) ->
        elem.nodeName and elem.nodeName.toUpperCase() is name.toUpperCase()

      each: (object, callback, args) ->
        name = undefined
        i = 0
        length = object.length
        isObj = length is `undefined` or jQuery.isFunction(object)
        if args
          if isObj
            for name of object
              break  if callback.apply(object[name], args) is false
          else
            while i < length
              break  if callback.apply(object[i++], args) is false
        else
          if isObj
            for name of object
              break  if callback.call(object[name], name, object[name]) is false
          else
            while i < length
              break  if callback.call(object[i], i, object[i++]) is false
        object

      trim: (if trim then (text) ->
        (if not text? then "" else trim.call(text))
       else (text) ->
        (if not text? then "" else text.toString().replace(trimLeft, "").replace(trimRight, ""))
      )
      makeArray: (array, results) ->
        ret = results or []
        if array?
          type = jQuery.type(array)
          if not array.length? or type is "string" or type is "function" or type is "regexp" or jQuery.isWindow(array)
            push.call ret, array
          else
            jQuery.merge ret, array
        ret

      inArray: (elem, array, i) ->
        len = undefined
        if array
          return indexOf.call(array, elem, i)  if indexOf
          len = array.length
          i = (if i then (if i < 0 then Math.max(0, len + i) else i) else 0)
          while i < len
            return i  if i of array and array[i] is elem
            i++
        -1

      merge: (first, second) ->
        i = first.length
        j = 0
        if typeof second.length is "number"
          l = second.length

          while j < l
            first[i++] = second[j]
            j++
        else
          first[i++] = second[j++]  while second[j] isnt `undefined`
        first.length = i
        first

      grep: (elems, callback, inv) ->
        ret = []
        retVal = undefined
        inv = !!inv
        i = 0
        length = elems.length

        while i < length
          retVal = !!callback(elems[i], i)
          ret.push elems[i]  if inv isnt retVal
          i++
        ret

      map: (elems, callback, arg) ->
        value = undefined
        key = undefined
        ret = []
        i = 0
        length = elems.length
        isArray = elems instanceof jQuery or length isnt `undefined` and typeof length is "number" and (length > 0 and elems[0] and elems[length - 1]) or length is 0 or jQuery.isArray(elems)
        if isArray
          while i < length
            value = callback(elems[i], i, arg)
            ret[ret.length] = value  if value?
            i++
        else
          for key of elems
            value = callback(elems[key], key, arg)
            ret[ret.length] = value  if value?
        ret.concat.apply [], ret

      guid: 1
      proxy: (fn, context) ->
        if typeof context is "string"
          tmp = fn[context]
          context = fn
          fn = tmp
        return `undefined`  unless jQuery.isFunction(fn)
        args = slice.call(arguments, 2)
        proxy = ->
          fn.apply context, args.concat(slice.call(arguments))

        proxy.guid = fn.guid = fn.guid or proxy.guid or jQuery.guid++
        proxy

      access: (elems, key, value, exec, fn, pass) ->
        length = elems.length
        if typeof key is "object"
          for k of key
            jQuery.access elems, k, key[k], exec, fn, value
          return elems
        if value isnt `undefined`
          exec = not pass and exec and jQuery.isFunction(value)
          i = 0

          while i < length
            fn elems[i], key, (if exec then value.call(elems[i], i, fn(elems[i], key)) else value), pass
            i++
          return elems
        (if length then fn(elems[0], key) else `undefined`)

      now: ->
        (new Date()).getTime()

      uaMatch: (ua) ->
        ua = ua.toLowerCase()
        match = rwebkit.exec(ua) or ropera.exec(ua) or rmsie.exec(ua) or ua.indexOf("compatible") < 0 and rmozilla.exec(ua) or []
        browser: match[1] or ""
        version: match[2] or "0"

      sub: ->
        jQuerySub = (selector, context) ->
          new jQuerySub.fn.init(selector, context)
        jQuery.extend true, jQuerySub, this
        jQuerySub.superclass = this
        jQuerySub.fn = jQuerySub:: = this()
        jQuerySub.fn.constructor = jQuerySub
        jQuerySub.sub = @sub
        jQuerySub.fn.init = init = (selector, context) ->
          context = jQuerySub(context)  if context and context instanceof jQuery and (context not instanceof jQuerySub)
          jQuery.fn.init.call this, selector, context, rootjQuerySub

        jQuerySub.fn.init:: = jQuerySub.fn
        rootjQuerySub = jQuerySub(document)
        jQuerySub

      browser: {}

    jQuery.each "Boolean Number String Function Array Date RegExp Object".split(" "), (i, name) ->
      class2type["[object " + name + "]"] = name.toLowerCase()

    browserMatch = jQuery.uaMatch(userAgent)
    if browserMatch.browser
      jQuery.browser[browserMatch.browser] = true
      jQuery.browser.version = browserMatch.version
    jQuery.browser.safari = true  if jQuery.browser.webkit
    if rnotwhite.test(" ")
      trimLeft = /^[\s\xA0]+/
      trimRight = /[\s\xA0]+$/
    rootjQuery = jQuery(document)
    if document.addEventListener
      DOMContentLoaded = ->
        document.removeEventListener "DOMContentLoaded", DOMContentLoaded, false
        jQuery.ready()
    else if document.attachEvent
      DOMContentLoaded = ->
        if document.readyState is "complete"
          document.detachEvent "onreadystatechange", DOMContentLoaded
          jQuery.ready()
    jQuery
  )()
  flagsCache = {}
  jQuery.Callbacks = (flags) ->
    flags = (if flags then (flagsCache[flags] or createFlags(flags)) else {})
    list = []
    stack = []
    memory = undefined
    firing = undefined
    firingStart = undefined
    firingLength = undefined
    firingIndex = undefined
    add = (args) ->
      i = undefined
      length = undefined
      elem = undefined
      type = undefined
      actual = undefined
      i = 0
      length = args.length

      while i < length
        elem = args[i]
        type = jQuery.type(elem)
        if type is "array"
          add elem
        else list.push elem  if not flags.unique or not self.has(elem)  if type is "function"
        i++

    fire = (context, args) ->
      args = args or []
      memory = not flags.memory or [ context, args ]
      firing = true
      firingIndex = firingStart or 0
      firingStart = 0
      firingLength = list.length
      while list and firingIndex < firingLength
        if list[firingIndex].apply(context, args) is false and flags.stopOnFalse
          memory = true
          break
        firingIndex++
      firing = false
      if list
        unless flags.once
          if stack and stack.length
            memory = stack.shift()
            self.fireWith memory[0], memory[1]
        else if memory is true
          self.disable()
        else
          list = []

    self =
      add: ->
        if list
          length = list.length
          add arguments
          if firing
            firingLength = list.length
          else if memory and memory isnt true
            firingStart = length
            fire memory[0], memory[1]
        this

      remove: ->
        if list
          args = arguments
          argIndex = 0
          argLength = args.length
          while argIndex < argLength
            i = 0

            while i < list.length
              if args[argIndex] is list[i]
                if firing
                  if i <= firingLength
                    firingLength--
                    firingIndex--  if i <= firingIndex
                list.splice i--, 1
                break  if flags.unique
              i++
            argIndex++
        this

      has: (fn) ->
        if list
          i = 0
          length = list.length
          while i < length
            return true  if fn is list[i]
            i++
        false

      empty: ->
        list = []
        this

      disable: ->
        list = stack = memory = `undefined`
        this

      disabled: ->
        not list

      lock: ->
        stack = `undefined`
        self.disable()  if not memory or memory is true
        this

      locked: ->
        not stack

      fireWith: (context, args) ->
        if stack
          if firing
            stack.push [ context, args ]  unless flags.once
          else fire context, args  unless flags.once and memory
        this

      fire: ->
        self.fireWith this, arguments
        this

      fired: ->
        !!memory

    self

  sliceDeferred = [].slice
  jQuery.extend
    Deferred: (func) ->
      doneList = jQuery.Callbacks("once memory")
      failList = jQuery.Callbacks("once memory")
      progressList = jQuery.Callbacks("memory")
      state = "pending"
      lists =
        resolve: doneList
        reject: failList
        notify: progressList

      promise =
        done: doneList.add
        fail: failList.add
        progress: progressList.add
        state: ->
          state

        isResolved: doneList.fired
        isRejected: failList.fired
        then: (doneCallbacks, failCallbacks, progressCallbacks) ->
          deferred.done(doneCallbacks).fail(failCallbacks).progress progressCallbacks
          this

        always: ->
          deferred.done.apply(deferred, arguments).fail.apply deferred, arguments
          this

        pipe: (fnDone, fnFail, fnProgress) ->
          jQuery.Deferred((newDefer) ->
            jQuery.each
              done: [ fnDone, "resolve" ]
              fail: [ fnFail, "reject" ]
              progress: [ fnProgress, "notify" ]
            , (handler, data) ->
              fn = data[0]
              action = data[1]
              returned = undefined
              if jQuery.isFunction(fn)
                deferred[handler] ->
                  returned = fn.apply(this, arguments)
                  if returned and jQuery.isFunction(returned.promise)
                    returned.promise().then newDefer.resolve, newDefer.reject, newDefer.notify
                  else
                    newDefer[action + "With"] (if this is deferred then newDefer else this), [ returned ]
              else
                deferred[handler] newDefer[action]
          ).promise()

        promise: (obj) ->
          unless obj?
            obj = promise
          else
            for key of promise
              obj[key] = promise[key]
          obj

      deferred = promise.promise({})
      key = undefined
      for key of lists
        deferred[key] = lists[key].fire
        deferred[key + "With"] = lists[key].fireWith
      deferred.done(->
        state = "resolved"
      , failList.disable, progressList.lock).fail (->
        state = "rejected"
      ), doneList.disable, progressList.lock
      func.call deferred, deferred  if func
      deferred

    when: (firstParam) ->
      resolveFunc = (i) ->
        (value) ->
          args[i] = (if arguments.length > 1 then sliceDeferred.call(arguments, 0) else value)
          deferred.resolveWith deferred, args  unless --count
      progressFunc = (i) ->
        (value) ->
          pValues[i] = (if arguments.length > 1 then sliceDeferred.call(arguments, 0) else value)
          deferred.notifyWith promise, pValues
      args = sliceDeferred.call(arguments, 0)
      i = 0
      length = args.length
      pValues = new Array(length)
      count = length
      pCount = length
      deferred = (if length <= 1 and firstParam and jQuery.isFunction(firstParam.promise) then firstParam else jQuery.Deferred())
      promise = deferred.promise()
      if length > 1
        while i < length
          if args[i] and args[i].promise and jQuery.isFunction(args[i].promise)
            args[i].promise().then resolveFunc(i), deferred.reject, progressFunc(i)
          else
            --count
          i++
        deferred.resolveWith deferred, args  unless count
      else deferred.resolveWith deferred, (if length then [ firstParam ] else [])  if deferred isnt firstParam
      promise

  jQuery.support = (->
    support = undefined
    all = undefined
    a = undefined
    select = undefined
    opt = undefined
    input = undefined
    marginDiv = undefined
    fragment = undefined
    tds = undefined
    events = undefined
    eventName = undefined
    i = undefined
    isSupported = undefined
    div = document.createElement("div")
    documentElement = document.documentElement
    div.setAttribute "className", "t"
    div.innerHTML = "   <link/><table></table><a href='/a' style='top:1px;float:left;opacity:.55;'>a</a><input type='checkbox'/>"
    all = div.getElementsByTagName("*")
    a = div.getElementsByTagName("a")[0]
    return {}  if not all or not all.length or not a
    select = document.createElement("select")
    opt = select.appendChild(document.createElement("option"))
    input = div.getElementsByTagName("input")[0]
    support =
      leadingWhitespace: (div.firstChild.nodeType is 3)
      tbody: not div.getElementsByTagName("tbody").length
      htmlSerialize: !!div.getElementsByTagName("link").length
      style: /top/.test(a.getAttribute("style"))
      hrefNormalized: (a.getAttribute("href") is "/a")
      opacity: /^0.55/.test(a.style.opacity)
      cssFloat: !!a.style.cssFloat
      checkOn: (input.value is "on")
      optSelected: opt.selected
      getSetAttribute: div.className isnt "t"
      enctype: !!document.createElement("form").enctype
      html5Clone: document.createElement("nav").cloneNode(true).outerHTML isnt "<:nav></:nav>"
      submitBubbles: true
      changeBubbles: true
      focusinBubbles: false
      deleteExpando: true
      noCloneEvent: true
      inlineBlockNeedsLayout: false
      shrinkWrapBlocks: false
      reliableMarginRight: true

    input.checked = true
    support.noCloneChecked = input.cloneNode(true).checked
    select.disabled = true
    support.optDisabled = not opt.disabled
    try
      delete div.test
    catch e
      support.deleteExpando = false
    if not div.addEventListener and div.attachEvent and div.fireEvent
      div.attachEvent "onclick", ->
        support.noCloneEvent = false

      div.cloneNode(true).fireEvent "onclick"
    input = document.createElement("input")
    input.value = "t"
    input.setAttribute "type", "radio"
    support.radioValue = input.value is "t"
    input.setAttribute "checked", "checked"
    div.appendChild input
    fragment = document.createDocumentFragment()
    fragment.appendChild div.lastChild
    support.checkClone = fragment.cloneNode(true).cloneNode(true).lastChild.checked
    support.appendChecked = input.checked
    fragment.removeChild input
    fragment.appendChild div
    div.innerHTML = ""
    if window.getComputedStyle
      marginDiv = document.createElement("div")
      marginDiv.style.width = "0"
      marginDiv.style.marginRight = "0"
      div.style.width = "2px"
      div.appendChild marginDiv
      support.reliableMarginRight = (parseInt((window.getComputedStyle(marginDiv, null) or marginRight: 0).marginRight, 10) or 0) is 0
    if div.attachEvent
      for i of
        submit: 1
        change: 1
        focusin: 1
        eventName = "on" + i
        isSupported = (eventName of div)
        unless isSupported
          div.setAttribute eventName, "return;"
          isSupported = (typeof div[eventName] is "function")
        support[i + "Bubbles"] = isSupported
    fragment.removeChild div
    fragment = select = opt = marginDiv = div = input = null
    jQuery ->
      container = undefined
      outer = undefined
      inner = undefined
      table = undefined
      td = undefined
      offsetSupport = undefined
      conMarginTop = undefined
      ptlm = undefined
      vb = undefined
      style = undefined
      html = undefined
      body = document.getElementsByTagName("body")[0]
      return  unless body
      conMarginTop = 1
      ptlm = "position:absolute;top:0;left:0;width:1px;height:1px;margin:0;"
      vb = "visibility:hidden;border:0;"
      style = "style='" + ptlm + "border:5px solid #000;padding:0;'"
      html = "<div " + style + "><div></div></div>" + "<table " + style + " cellpadding='0' cellspacing='0'>" + "<tr><td></td></tr></table>"
      container = document.createElement("div")
      container.style.cssText = vb + "width:0;height:0;position:static;top:0;margin-top:" + conMarginTop + "px"
      body.insertBefore container, body.firstChild
      div = document.createElement("div")
      container.appendChild div
      div.innerHTML = "<table><tr><td style='padding:0;border:0;display:none'></td><td>t</td></tr></table>"
      tds = div.getElementsByTagName("td")
      isSupported = (tds[0].offsetHeight is 0)
      tds[0].style.display = ""
      tds[1].style.display = "none"
      support.reliableHiddenOffsets = isSupported and (tds[0].offsetHeight is 0)
      div.innerHTML = ""
      div.style.width = div.style.paddingLeft = "1px"
      jQuery.boxModel = support.boxModel = div.offsetWidth is 2
      if typeof div.style.zoom isnt "undefined"
        div.style.display = "inline"
        div.style.zoom = 1
        support.inlineBlockNeedsLayout = (div.offsetWidth is 2)
        div.style.display = ""
        div.innerHTML = "<div style='width:4px;'></div>"
        support.shrinkWrapBlocks = (div.offsetWidth isnt 2)
      div.style.cssText = ptlm + vb
      div.innerHTML = html
      outer = div.firstChild
      inner = outer.firstChild
      td = outer.nextSibling.firstChild.firstChild
      offsetSupport =
        doesNotAddBorder: (inner.offsetTop isnt 5)
        doesAddBorderForTableAndCells: (td.offsetTop is 5)

      inner.style.position = "fixed"
      inner.style.top = "20px"
      offsetSupport.fixedPosition = (inner.offsetTop is 20 or inner.offsetTop is 15)
      inner.style.position = inner.style.top = ""
      outer.style.overflow = "hidden"
      outer.style.position = "relative"
      offsetSupport.subtractsBorderForOverflowNotVisible = (inner.offsetTop is -5)
      offsetSupport.doesNotIncludeMarginInBodyOffset = (body.offsetTop isnt conMarginTop)
      body.removeChild container
      div = container = null
      jQuery.extend support, offsetSupport

    support
  )()
  rbrace = /^(?:\{.*\}|\[.*\])$/
  rmultiDash = /([A-Z])/g
  jQuery.extend
    cache: {}
    uuid: 0
    expando: "jQuery" + (jQuery.fn.jquery + Math.random()).replace(/\D/g, "")
    noData:
      embed: true
      object: "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
      applet: true

    hasData: (elem) ->
      elem = (if elem.nodeType then jQuery.cache[elem[jQuery.expando]] else elem[jQuery.expando])
      !!elem and not isEmptyDataObject(elem)

    data: (elem, name, data, pvt) ->
      return  unless jQuery.acceptData(elem)
      privateCache = undefined
      thisCache = undefined
      ret = undefined
      internalKey = jQuery.expando
      getByName = typeof name is "string"
      isNode = elem.nodeType
      cache = (if isNode then jQuery.cache else elem)
      id = (if isNode then elem[internalKey] else elem[internalKey] and internalKey)
      isEvents = name is "events"
      return  if (not id or not cache[id] or (not isEvents and not pvt and not cache[id].data)) and getByName and data is `undefined`
      unless id
        if isNode
          elem[internalKey] = id = ++jQuery.uuid
        else
          id = internalKey
      unless cache[id]
        cache[id] = {}
        cache[id].toJSON = jQuery.noop  unless isNode
      if typeof name is "object" or typeof name is "function"
        if pvt
          cache[id] = jQuery.extend(cache[id], name)
        else
          cache[id].data = jQuery.extend(cache[id].data, name)
      privateCache = thisCache = cache[id]
      unless pvt
        thisCache.data = {}  unless thisCache.data
        thisCache = thisCache.data
      thisCache[jQuery.camelCase(name)] = data  if data isnt `undefined`
      return privateCache.events  if isEvents and not thisCache[name]
      if getByName
        ret = thisCache[name]
        ret = thisCache[jQuery.camelCase(name)]  unless ret?
      else
        ret = thisCache
      ret

    removeData: (elem, name, pvt) ->
      return  unless jQuery.acceptData(elem)
      thisCache = undefined
      i = undefined
      l = undefined
      internalKey = jQuery.expando
      isNode = elem.nodeType
      cache = (if isNode then jQuery.cache else elem)
      id = (if isNode then elem[internalKey] else internalKey)
      return  unless cache[id]
      if name
        thisCache = (if pvt then cache[id] else cache[id].data)
        if thisCache
          unless jQuery.isArray(name)
            if name of thisCache
              name = [ name ]
            else
              name = jQuery.camelCase(name)
              if name of thisCache
                name = [ name ]
              else
                name = name.split(" ")
          i = 0
          l = name.length

          while i < l
            delete thisCache[name[i]]
            i++
          return  unless (if pvt then isEmptyDataObject else jQuery.isEmptyObject)(thisCache)
      unless pvt
        delete cache[id].data

        return  unless isEmptyDataObject(cache[id])
      if jQuery.support.deleteExpando or not cache.setInterval
        delete cache[id]
      else
        cache[id] = null
      if isNode
        if jQuery.support.deleteExpando
          delete elem[internalKey]
        else if elem.removeAttribute
          elem.removeAttribute internalKey
        else
          elem[internalKey] = null

    _data: (elem, name, data) ->
      jQuery.data elem, name, data, true

    acceptData: (elem) ->
      if elem.nodeName
        match = jQuery.noData[elem.nodeName.toLowerCase()]
        return not (match is true or elem.getAttribute("classid") isnt match)  if match
      true

  jQuery.fn.extend
    data: (key, value) ->
      parts = undefined
      attr = undefined
      name = undefined
      data = null
      if typeof key is "undefined"
        if @length
          data = jQuery.data(this[0])
          if this[0].nodeType is 1 and not jQuery._data(this[0], "parsedAttrs")
            attr = this[0].attributes
            i = 0
            l = attr.length

            while i < l
              name = attr[i].name
              if name.indexOf("data-") is 0
                name = jQuery.camelCase(name.substring(5))
                dataAttr this[0], name, data[name]
              i++
            jQuery._data this[0], "parsedAttrs", true
        return data
      else if typeof key is "object"
        return @each(->
          jQuery.data this, key
        )
      parts = key.split(".")
      parts[1] = (if parts[1] then "." + parts[1] else "")
      if value is `undefined`
        data = @triggerHandler("getData" + parts[1] + "!", [ parts[0] ])
        if data is `undefined` and @length
          data = jQuery.data(this[0], key)
          data = dataAttr(this[0], key, data)
        (if data is `undefined` and parts[1] then @data(parts[0]) else data)
      else
        @each ->
          self = jQuery(this)
          args = [ parts[0], value ]
          self.triggerHandler "setData" + parts[1] + "!", args
          jQuery.data this, key, value
          self.triggerHandler "changeData" + parts[1] + "!", args

    removeData: (key) ->
      @each ->
        jQuery.removeData this, key

  jQuery.extend
    _mark: (elem, type) ->
      if elem
        type = (type or "fx") + "mark"
        jQuery._data elem, type, (jQuery._data(elem, type) or 0) + 1

    _unmark: (force, elem, type) ->
      if force isnt true
        type = elem
        elem = force
        force = false
      if elem
        type = type or "fx"
        key = type + "mark"
        count = (if force then 0 else ((jQuery._data(elem, key) or 1) - 1))
        if count
          jQuery._data elem, key, count
        else
          jQuery.removeData elem, key, true
          handleQueueMarkDefer elem, type, "mark"

    queue: (elem, type, data) ->
      q = undefined
      if elem
        type = (type or "fx") + "queue"
        q = jQuery._data(elem, type)
        if data
          if not q or jQuery.isArray(data)
            q = jQuery._data(elem, type, jQuery.makeArray(data))
          else
            q.push data
        q or []

    dequeue: (elem, type) ->
      type = type or "fx"
      queue = jQuery.queue(elem, type)
      fn = queue.shift()
      hooks = {}
      fn = queue.shift()  if fn is "inprogress"
      if fn
        queue.unshift "inprogress"  if type is "fx"
        jQuery._data elem, type + ".run", hooks
        fn.call elem, (->
          jQuery.dequeue elem, type
        ), hooks
      unless queue.length
        jQuery.removeData elem, type + "queue " + type + ".run", true
        handleQueueMarkDefer elem, type, "queue"

  jQuery.fn.extend
    queue: (type, data) ->
      if typeof type isnt "string"
        data = type
        type = "fx"
      return jQuery.queue(this[0], type)  if data is `undefined`
      @each ->
        queue = jQuery.queue(this, type, data)
        jQuery.dequeue this, type  if type is "fx" and queue[0] isnt "inprogress"

    dequeue: (type) ->
      @each ->
        jQuery.dequeue this, type

    delay: (time, type) ->
      time = (if jQuery.fx then jQuery.fx.speeds[time] or time else time)
      type = type or "fx"
      @queue type, (next, hooks) ->
        timeout = setTimeout(next, time)
        hooks.stop = ->
          clearTimeout timeout

    clearQueue: (type) ->
      @queue type or "fx", []

    promise: (type, object) ->
      resolve = ->
        defer.resolveWith elements, [ elements ]  unless --count
      if typeof type isnt "string"
        object = type
        type = `undefined`
      type = type or "fx"
      defer = jQuery.Deferred()
      elements = this
      i = elements.length
      count = 1
      deferDataKey = type + "defer"
      queueDataKey = type + "queue"
      markDataKey = type + "mark"
      tmp = undefined
      while i--
        if tmp = jQuery.data(elements[i], deferDataKey, `undefined`, true) or (jQuery.data(elements[i], queueDataKey, `undefined`, true) or jQuery.data(elements[i], markDataKey, `undefined`, true)) and jQuery.data(elements[i], deferDataKey, jQuery.Callbacks("once memory"), true)
          count++
          tmp.add resolve
      resolve()
      defer.promise()

  rclass = /[\n\t\r]/g
  rspace = /\s+/
  rreturn = /\r/g
  rtype = /^(?:button|input)$/i
  rfocusable = /^(?:button|input|object|select|textarea)$/i
  rclickable = /^a(?:rea)?$/i
  rboolean = /^(?:autofocus|autoplay|async|checked|controls|defer|disabled|hidden|loop|multiple|open|readonly|required|scoped|selected)$/i
  getSetAttribute = jQuery.support.getSetAttribute
  nodeHook = undefined
  boolHook = undefined
  fixSpecified = undefined
  jQuery.fn.extend
    attr: (name, value) ->
      jQuery.access this, name, value, true, jQuery.attr

    removeAttr: (name) ->
      @each ->
        jQuery.removeAttr this, name

    prop: (name, value) ->
      jQuery.access this, name, value, true, jQuery.prop

    removeProp: (name) ->
      name = jQuery.propFix[name] or name
      @each ->
        try
          this[name] = `undefined`
          delete this[name]

    addClass: (value) ->
      classNames = undefined
      i = undefined
      l = undefined
      elem = undefined
      setClass = undefined
      c = undefined
      cl = undefined
      if jQuery.isFunction(value)
        return @each((j) ->
          jQuery(this).addClass value.call(this, j, @className)
        )
      if value and typeof value is "string"
        classNames = value.split(rspace)
        i = 0
        l = @length

        while i < l
          elem = this[i]
          if elem.nodeType is 1
            if not elem.className and classNames.length is 1
              elem.className = value
            else
              setClass = " " + elem.className + " "
              c = 0
              cl = classNames.length

              while c < cl
                setClass += classNames[c] + " "  unless ~setClass.indexOf(" " + classNames[c] + " ")
                c++
              elem.className = jQuery.trim(setClass)
          i++
      this

    removeClass: (value) ->
      classNames = undefined
      i = undefined
      l = undefined
      elem = undefined
      className = undefined
      c = undefined
      cl = undefined
      if jQuery.isFunction(value)
        return @each((j) ->
          jQuery(this).removeClass value.call(this, j, @className)
        )
      if (value and typeof value is "string") or value is `undefined`
        classNames = (value or "").split(rspace)
        i = 0
        l = @length

        while i < l
          elem = this[i]
          if elem.nodeType is 1 and elem.className
            if value
              className = (" " + elem.className + " ").replace(rclass, " ")
              c = 0
              cl = classNames.length

              while c < cl
                className = className.replace(" " + classNames[c] + " ", " ")
                c++
              elem.className = jQuery.trim(className)
            else
              elem.className = ""
          i++
      this

    toggleClass: (value, stateVal) ->
      type = typeof value
      isBool = typeof stateVal is "boolean"
      if jQuery.isFunction(value)
        return @each((i) ->
          jQuery(this).toggleClass value.call(this, i, @className, stateVal), stateVal
        )
      @each ->
        if type is "string"
          className = undefined
          i = 0
          self = jQuery(this)
          state = stateVal
          classNames = value.split(rspace)
          while (className = classNames[i++])
            state = (if isBool then state else not self.hasClass(className))
            self[(if state then "addClass" else "removeClass")] className
        else if type is "undefined" or type is "boolean"
          jQuery._data this, "__className__", @className  if @className
          @className = (if @className or value is false then "" else jQuery._data(this, "__className__") or "")

    hasClass: (selector) ->
      className = " " + selector + " "
      i = 0
      l = @length
      while i < l
        return true  if this[i].nodeType is 1 and (" " + this[i].className + " ").replace(rclass, " ").indexOf(className) > -1
        i++
      false

    val: (value) ->
      hooks = undefined
      ret = undefined
      isFunction = undefined
      elem = this[0]
      unless arguments.length
        if elem
          hooks = jQuery.valHooks[elem.nodeName.toLowerCase()] or jQuery.valHooks[elem.type]
          return ret  if hooks and "get" of hooks and (ret = hooks.get(elem, "value")) isnt `undefined`
          ret = elem.value
          return (if typeof ret is "string" then ret.replace(rreturn, "") else (if not ret? then "" else ret))
        return
      isFunction = jQuery.isFunction(value)
      @each (i) ->
        self = jQuery(this)
        val = undefined
        return  if @nodeType isnt 1
        if isFunction
          val = value.call(this, i, self.val())
        else
          val = value
        unless val?
          val = ""
        else if typeof val is "number"
          val += ""
        else if jQuery.isArray(val)
          val = jQuery.map(val, (value) ->
            (if not value? then "" else value + "")
          )
        hooks = jQuery.valHooks[@nodeName.toLowerCase()] or jQuery.valHooks[@type]
        @value = val  if not hooks or ("set" not of hooks) or hooks.set(this, val, "value") is `undefined`

  jQuery.extend
    valHooks:
      option:
        get: (elem) ->
          val = elem.attributes.value
          (if not val or val.specified then elem.value else elem.text)

      select:
        get: (elem) ->
          value = undefined
          i = undefined
          max = undefined
          option = undefined
          index = elem.selectedIndex
          values = []
          options = elem.options
          one = elem.type is "select-one"
          return null  if index < 0
          i = (if one then index else 0)
          max = (if one then index + 1 else options.length)
          while i < max
            option = options[i]
            if option.selected and (if jQuery.support.optDisabled then not option.disabled else option.getAttribute("disabled") is null) and (not option.parentNode.disabled or not jQuery.nodeName(option.parentNode, "optgroup"))
              value = jQuery(option).val()
              return value  if one
              values.push value
            i++
          return jQuery(options[index]).val()  if one and not values.length and options.length
          values

        set: (elem, value) ->
          values = jQuery.makeArray(value)
          jQuery(elem).find("option").each ->
            @selected = jQuery.inArray(jQuery(this).val(), values) >= 0

          elem.selectedIndex = -1  unless values.length
          values

    attrFn:
      val: true
      css: true
      html: true
      text: true
      data: true
      width: true
      height: true
      offset: true

    attr: (elem, name, value, pass) ->
      ret = undefined
      hooks = undefined
      notxml = undefined
      nType = elem.nodeType
      return  if not elem or nType is 3 or nType is 8 or nType is 2
      return jQuery(elem)[name](value)  if pass and name of jQuery.attrFn
      return jQuery.prop(elem, name, value)  if typeof elem.getAttribute is "undefined"
      notxml = nType isnt 1 or not jQuery.isXMLDoc(elem)
      if notxml
        name = name.toLowerCase()
        hooks = jQuery.attrHooks[name] or (if rboolean.test(name) then boolHook else nodeHook)
      if value isnt `undefined`
        if value is null
          jQuery.removeAttr elem, name
          return
        else if hooks and "set" of hooks and notxml and (ret = hooks.set(elem, value, name)) isnt `undefined`
          ret
        else
          elem.setAttribute name, "" + value
          value
      else if hooks and "get" of hooks and notxml and (ret = hooks.get(elem, name)) isnt null
        ret
      else
        ret = elem.getAttribute(name)
        (if ret is null then `undefined` else ret)

    removeAttr: (elem, value) ->
      propName = undefined
      attrNames = undefined
      name = undefined
      l = undefined
      i = 0
      if value and elem.nodeType is 1
        attrNames = value.toLowerCase().split(rspace)
        l = attrNames.length
        while i < l
          name = attrNames[i]
          if name
            propName = jQuery.propFix[name] or name
            jQuery.attr elem, name, ""
            elem.removeAttribute (if getSetAttribute then name else propName)
            elem[propName] = false  if rboolean.test(name) and propName of elem
          i++

    attrHooks:
      type:
        set: (elem, value) ->
          if rtype.test(elem.nodeName) and elem.parentNode
            jQuery.error "type property can't be changed"
          else if not jQuery.support.radioValue and value is "radio" and jQuery.nodeName(elem, "input")
            val = elem.value
            elem.setAttribute "type", value
            elem.value = val  if val
            value

      value:
        get: (elem, name) ->
          return nodeHook.get(elem, name)  if nodeHook and jQuery.nodeName(elem, "button")
          (if name of elem then elem.value else null)

        set: (elem, value, name) ->
          return nodeHook.set(elem, value, name)  if nodeHook and jQuery.nodeName(elem, "button")
          elem.value = value

    propFix:
      tabindex: "tabIndex"
      readonly: "readOnly"
      for: "htmlFor"
      class: "className"
      maxlength: "maxLength"
      cellspacing: "cellSpacing"
      cellpadding: "cellPadding"
      rowspan: "rowSpan"
      colspan: "colSpan"
      usemap: "useMap"
      frameborder: "frameBorder"
      contenteditable: "contentEditable"

    prop: (elem, name, value) ->
      ret = undefined
      hooks = undefined
      notxml = undefined
      nType = elem.nodeType
      return  if not elem or nType is 3 or nType is 8 or nType is 2
      notxml = nType isnt 1 or not jQuery.isXMLDoc(elem)
      if notxml
        name = jQuery.propFix[name] or name
        hooks = jQuery.propHooks[name]
      if value isnt `undefined`
        if hooks and "set" of hooks and (ret = hooks.set(elem, value, name)) isnt `undefined`
          ret
        else
          elem[name] = value
      else
        if hooks and "get" of hooks and (ret = hooks.get(elem, name)) isnt null
          ret
        else
          elem[name]

    propHooks:
      tabIndex:
        get: (elem) ->
          attributeNode = elem.getAttributeNode("tabindex")
          (if attributeNode and attributeNode.specified then parseInt(attributeNode.value, 10) else (if rfocusable.test(elem.nodeName) or rclickable.test(elem.nodeName) and elem.href then 0 else `undefined`))

  jQuery.attrHooks.tabindex = jQuery.propHooks.tabIndex
  boolHook =
    get: (elem, name) ->
      attrNode = undefined
      property = jQuery.prop(elem, name)
      (if property is true or typeof property isnt "boolean" and (attrNode = elem.getAttributeNode(name)) and attrNode.nodeValue isnt false then name.toLowerCase() else `undefined`)

    set: (elem, value, name) ->
      propName = undefined
      if value is false
        jQuery.removeAttr elem, name
      else
        propName = jQuery.propFix[name] or name
        elem[propName] = true  if propName of elem
        elem.setAttribute name, name.toLowerCase()
      name

  unless getSetAttribute
    fixSpecified =
      name: true
      id: true

    nodeHook = jQuery.valHooks.button =
      get: (elem, name) ->
        ret = undefined
        ret = elem.getAttributeNode(name)
        (if ret and (if fixSpecified[name] then ret.nodeValue isnt "" else ret.specified) then ret.nodeValue else `undefined`)

      set: (elem, value, name) ->
        ret = elem.getAttributeNode(name)
        unless ret
          ret = document.createAttribute(name)
          elem.setAttributeNode ret
        ret.nodeValue = value + ""

    jQuery.attrHooks.tabindex.set = nodeHook.set
    jQuery.each [ "width", "height" ], (i, name) ->
      jQuery.attrHooks[name] = jQuery.extend(jQuery.attrHooks[name],
        set: (elem, value) ->
          if value is ""
            elem.setAttribute name, "auto"
            value
      )

    jQuery.attrHooks.contenteditable =
      get: nodeHook.get
      set: (elem, value, name) ->
        value = "false"  if value is ""
        nodeHook.set elem, value, name
  unless jQuery.support.hrefNormalized
    jQuery.each [ "href", "src", "width", "height" ], (i, name) ->
      jQuery.attrHooks[name] = jQuery.extend(jQuery.attrHooks[name],
        get: (elem) ->
          ret = elem.getAttribute(name, 2)
          (if ret is null then `undefined` else ret)
      )
  unless jQuery.support.style
    jQuery.attrHooks.style =
      get: (elem) ->
        elem.style.cssText.toLowerCase() or `undefined`

      set: (elem, value) ->
        elem.style.cssText = "" + value
  unless jQuery.support.optSelected
    jQuery.propHooks.selected = jQuery.extend(jQuery.propHooks.selected,
      get: (elem) ->
        parent = elem.parentNode
        if parent
          parent.selectedIndex
          parent.parentNode.selectedIndex  if parent.parentNode
        null
    )
  jQuery.propFix.enctype = "encoding"  unless jQuery.support.enctype
  unless jQuery.support.checkOn
    jQuery.each [ "radio", "checkbox" ], ->
      jQuery.valHooks[this] = get: (elem) ->
        (if elem.getAttribute("value") is null then "on" else elem.value)
  jQuery.each [ "radio", "checkbox" ], ->
    jQuery.valHooks[this] = jQuery.extend(jQuery.valHooks[this],
      set: (elem, value) ->
        elem.checked = jQuery.inArray(jQuery(elem).val(), value) >= 0  if jQuery.isArray(value)
    )

  rformElems = /^(?:textarea|input|select)$/i
  rtypenamespace = /^([^\.]*)?(?:\.(.+))?$/
  rhoverHack = /\bhover(\.\S+)?\b/
  rkeyEvent = /^key/
  rmouseEvent = /^(?:mouse|contextmenu)|click/
  rfocusMorph = /^(?:focusinfocus|focusoutblur)$/
  rquickIs = /^(\w*)(?:#([\w\-]+))?(?:\.([\w\-]+))?$/
  quickParse = (selector) ->
    quick = rquickIs.exec(selector)
    if quick
      quick[1] = (quick[1] or "").toLowerCase()
      quick[3] = quick[3] and new RegExp("(?:^|\\s)" + quick[3] + "(?:\\s|$)")
    quick

  quickIs = (elem, m) ->
    attrs = elem.attributes or {}
    (not m[1] or elem.nodeName.toLowerCase() is m[1]) and (not m[2] or (attrs.id or {}).value is m[2]) and (not m[3] or m[3].test((attrs["class"] or {}).value))

  hoverHack = (events) ->
    (if jQuery.event.special.hover then events else events.replace(rhoverHack, "mouseenter$1 mouseleave$1"))

  jQuery.event =
    add: (elem, types, handler, data, selector) ->
      elemData = undefined
      eventHandle = undefined
      events = undefined
      t = undefined
      tns = undefined
      type = undefined
      namespaces = undefined
      handleObj = undefined
      handleObjIn = undefined
      quick = undefined
      handlers = undefined
      special = undefined
      return  if elem.nodeType is 3 or elem.nodeType is 8 or not types or not handler or not (elemData = jQuery._data(elem))
      if handler.handler
        handleObjIn = handler
        handler = handleObjIn.handler
      handler.guid = jQuery.guid++  unless handler.guid
      events = elemData.events
      elemData.events = events = {}  unless events
      eventHandle = elemData.handle
      unless eventHandle
        elemData.handle = eventHandle = (e) ->
          (if typeof jQuery isnt "undefined" and (not e or jQuery.event.triggered isnt e.type) then jQuery.event.dispatch.apply(eventHandle.elem, arguments) else `undefined`)

        eventHandle.elem = elem
      types = jQuery.trim(hoverHack(types)).split(" ")
      t = 0
      while t < types.length
        tns = rtypenamespace.exec(types[t]) or []
        type = tns[1]
        namespaces = (tns[2] or "").split(".").sort()
        special = jQuery.event.special[type] or {}
        type = (if selector then special.delegateType else special.bindType) or type
        special = jQuery.event.special[type] or {}
        handleObj = jQuery.extend(
          type: type
          origType: tns[1]
          data: data
          handler: handler
          guid: handler.guid
          selector: selector
          quick: quickParse(selector)
          namespace: namespaces.join(".")
        , handleObjIn)
        handlers = events[type]
        unless handlers
          handlers = events[type] = []
          handlers.delegateCount = 0
          if not special.setup or special.setup.call(elem, data, namespaces, eventHandle) is false
            if elem.addEventListener
              elem.addEventListener type, eventHandle, false
            else elem.attachEvent "on" + type, eventHandle  if elem.attachEvent
        if special.add
          special.add.call elem, handleObj
          handleObj.handler.guid = handler.guid  unless handleObj.handler.guid
        if selector
          handlers.splice handlers.delegateCount++, 0, handleObj
        else
          handlers.push handleObj
        jQuery.event.global[type] = true
        t++
      elem = null

    global: {}
    remove: (elem, types, handler, selector, mappedTypes) ->
      elemData = jQuery.hasData(elem) and jQuery._data(elem)
      t = undefined
      tns = undefined
      type = undefined
      origType = undefined
      namespaces = undefined
      origCount = undefined
      j = undefined
      events = undefined
      special = undefined
      handle = undefined
      eventType = undefined
      handleObj = undefined
      return  if not elemData or not (events = elemData.events)
      types = jQuery.trim(hoverHack(types or "")).split(" ")
      t = 0
      while t < types.length
        tns = rtypenamespace.exec(types[t]) or []
        type = origType = tns[1]
        namespaces = tns[2]
        unless type
          for type of events
            jQuery.event.remove elem, type + types[t], handler, selector, true
          continue
        special = jQuery.event.special[type] or {}
        type = (if selector then special.delegateType else special.bindType) or type
        eventType = events[type] or []
        origCount = eventType.length
        namespaces = (if namespaces then new RegExp("(^|\\.)" + namespaces.split(".").sort().join("\\.(?:.*\\.)?") + "(\\.|$)") else null)
        j = 0
        while j < eventType.length
          handleObj = eventType[j]
          if (mappedTypes or origType is handleObj.origType) and (not handler or handler.guid is handleObj.guid) and (not namespaces or namespaces.test(handleObj.namespace)) and (not selector or selector is handleObj.selector or selector is "**" and handleObj.selector)
            eventType.splice j--, 1
            eventType.delegateCount--  if handleObj.selector
            special.remove.call elem, handleObj  if special.remove
          j++
        if eventType.length is 0 and origCount isnt eventType.length
          jQuery.removeEvent elem, type, elemData.handle  if not special.teardown or special.teardown.call(elem, namespaces) is false
          delete events[type]
        t++
      if jQuery.isEmptyObject(events)
        handle = elemData.handle
        handle.elem = null  if handle
        jQuery.removeData elem, [ "events", "handle" ], true

    customEvent:
      getData: true
      setData: true
      changeData: true

    trigger: (event, data, elem, onlyHandlers) ->
      return  if elem and (elem.nodeType is 3 or elem.nodeType is 8)
      type = event.type or event
      namespaces = []
      cache = undefined
      exclusive = undefined
      i = undefined
      cur = undefined
      old = undefined
      ontype = undefined
      special = undefined
      handle = undefined
      eventPath = undefined
      bubbleType = undefined
      return  if rfocusMorph.test(type + jQuery.event.triggered)
      if type.indexOf("!") >= 0
        type = type.slice(0, -1)
        exclusive = true
      if type.indexOf(".") >= 0
        namespaces = type.split(".")
        type = namespaces.shift()
        namespaces.sort()
      return  if (not elem or jQuery.event.customEvent[type]) and not jQuery.event.global[type]
      event = (if typeof event is "object" then (if event[jQuery.expando] then event else new jQuery.Event(type, event)) else new jQuery.Event(type))
      event.type = type
      event.isTrigger = true
      event.exclusive = exclusive
      event.namespace = namespaces.join(".")
      event.namespace_re = (if event.namespace then new RegExp("(^|\\.)" + namespaces.join("\\.(?:.*\\.)?") + "(\\.|$)") else null)
      ontype = (if type.indexOf(":") < 0 then "on" + type else "")
      unless elem
        cache = jQuery.cache
        for i of cache
          jQuery.event.trigger event, data, cache[i].handle.elem, true  if cache[i].events and cache[i].events[type]
        return
      event.result = `undefined`
      event.target = elem  unless event.target
      data = (if data? then jQuery.makeArray(data) else [])
      data.unshift event
      special = jQuery.event.special[type] or {}
      return  if special.trigger and special.trigger.apply(elem, data) is false
      eventPath = [ [ elem, special.bindType or type ] ]
      if not onlyHandlers and not special.noBubble and not jQuery.isWindow(elem)
        bubbleType = special.delegateType or type
        cur = (if rfocusMorph.test(bubbleType + type) then elem else elem.parentNode)
        old = null
        while cur
          eventPath.push [ cur, bubbleType ]
          old = cur
          cur = cur.parentNode
        eventPath.push [ old.defaultView or old.parentWindow or window, bubbleType ]  if old and old is elem.ownerDocument
      i = 0
      while i < eventPath.length and not event.isPropagationStopped()
        cur = eventPath[i][0]
        event.type = eventPath[i][1]
        handle = (jQuery._data(cur, "events") or {})[event.type] and jQuery._data(cur, "handle")
        handle.apply cur, data  if handle
        handle = ontype and cur[ontype]
        event.preventDefault()  if handle and jQuery.acceptData(cur) and handle.apply(cur, data) is false
        i++
      event.type = type
      if not onlyHandlers and not event.isDefaultPrevented()
        if (not special._default or special._default.apply(elem.ownerDocument, data) is false) and not (type is "click" and jQuery.nodeName(elem, "a")) and jQuery.acceptData(elem)
          if ontype and elem[type] and ((type isnt "focus" and type isnt "blur") or event.target.offsetWidth isnt 0) and not jQuery.isWindow(elem)
            old = elem[ontype]
            elem[ontype] = null  if old
            jQuery.event.triggered = type
            elem[type]()
            jQuery.event.triggered = `undefined`
            elem[ontype] = old  if old
      event.result

    dispatch: (event) ->
      event = jQuery.event.fix(event or window.event)
      handlers = ((jQuery._data(this, "events") or {})[event.type] or [])
      delegateCount = handlers.delegateCount
      args = [].slice.call(arguments, 0)
      run_all = not event.exclusive and not event.namespace
      handlerQueue = []
      i = undefined
      j = undefined
      cur = undefined
      jqcur = undefined
      ret = undefined
      selMatch = undefined
      matched = undefined
      matches = undefined
      handleObj = undefined
      sel = undefined
      related = undefined
      args[0] = event
      event.delegateTarget = this
      if delegateCount and not event.target.disabled and not (event.button and event.type is "click")
        jqcur = jQuery(this)
        jqcur.context = @ownerDocument or this
        cur = event.target
        while cur isnt this
          selMatch = {}
          matches = []
          jqcur[0] = cur
          i = 0
          while i < delegateCount
            handleObj = handlers[i]
            sel = handleObj.selector
            selMatch[sel] = (if handleObj.quick then quickIs(cur, handleObj.quick) else jqcur.is(sel))  if selMatch[sel] is `undefined`
            matches.push handleObj  if selMatch[sel]
            i++
          if matches.length
            handlerQueue.push
              elem: cur
              matches: matches
          cur = cur.parentNode or this
      if handlers.length > delegateCount
        handlerQueue.push
          elem: this
          matches: handlers.slice(delegateCount)
      i = 0
      while i < handlerQueue.length and not event.isPropagationStopped()
        matched = handlerQueue[i]
        event.currentTarget = matched.elem
        j = 0
        while j < matched.matches.length and not event.isImmediatePropagationStopped()
          handleObj = matched.matches[j]
          if run_all or (not event.namespace and not handleObj.namespace) or event.namespace_re and event.namespace_re.test(handleObj.namespace)
            event.data = handleObj.data
            event.handleObj = handleObj
            ret = ((jQuery.event.special[handleObj.origType] or {}).handle or handleObj.handler).apply(matched.elem, args)
            if ret isnt `undefined`
              event.result = ret
              if ret is false
                event.preventDefault()
                event.stopPropagation()
          j++
        i++
      event.result

    props: "attrChange attrName relatedNode srcElement altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" ")
    fixHooks: {}
    keyHooks:
      props: "char charCode key keyCode".split(" ")
      filter: (event, original) ->
        event.which = (if original.charCode? then original.charCode else original.keyCode)  unless event.which?
        event

    mouseHooks:
      props: "button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" ")
      filter: (event, original) ->
        eventDoc = undefined
        doc = undefined
        body = undefined
        button = original.button
        fromElement = original.fromElement
        if not event.pageX? and original.clientX?
          eventDoc = event.target.ownerDocument or document
          doc = eventDoc.documentElement
          body = eventDoc.body
          event.pageX = original.clientX + (doc and doc.scrollLeft or body and body.scrollLeft or 0) - (doc and doc.clientLeft or body and body.clientLeft or 0)
          event.pageY = original.clientY + (doc and doc.scrollTop or body and body.scrollTop or 0) - (doc and doc.clientTop or body and body.clientTop or 0)
        event.relatedTarget = (if fromElement is event.target then original.toElement else fromElement)  if not event.relatedTarget and fromElement
        event.which = (if button & 1 then 1 else (if button & 2 then 3 else (if button & 4 then 2 else 0)))  if not event.which and button isnt `undefined`
        event

    fix: (event) ->
      return event  if event[jQuery.expando]
      i = undefined
      prop = undefined
      originalEvent = event
      fixHook = jQuery.event.fixHooks[event.type] or {}
      copy = (if fixHook.props then @props.concat(fixHook.props) else @props)
      event = jQuery.Event(originalEvent)
      i = copy.length
      while i
        prop = copy[--i]
        event[prop] = originalEvent[prop]
      event.target = originalEvent.srcElement or document  unless event.target
      event.target = event.target.parentNode  if event.target.nodeType is 3
      event.metaKey = event.ctrlKey  if event.metaKey is `undefined`
      (if fixHook.filter then fixHook.filter(event, originalEvent) else event)

    special:
      ready:
        setup: jQuery.bindReady

      load:
        noBubble: true

      focus:
        delegateType: "focusin"

      blur:
        delegateType: "focusout"

      beforeunload:
        setup: (data, namespaces, eventHandle) ->
          @onbeforeunload = eventHandle  if jQuery.isWindow(this)

        teardown: (namespaces, eventHandle) ->
          @onbeforeunload = null  if @onbeforeunload is eventHandle

    simulate: (type, elem, event, bubble) ->
      e = jQuery.extend(new jQuery.Event(), event,
        type: type
        isSimulated: true
        originalEvent: {}
      )
      if bubble
        jQuery.event.trigger e, null, elem
      else
        jQuery.event.dispatch.call elem, e
      event.preventDefault()  if e.isDefaultPrevented()

  jQuery.event.handle = jQuery.event.dispatch
  jQuery.removeEvent = (if document.removeEventListener then (elem, type, handle) ->
    elem.removeEventListener type, handle, false  if elem.removeEventListener
   else (elem, type, handle) ->
    elem.detachEvent "on" + type, handle  if elem.detachEvent
  )
  jQuery.Event = (src, props) ->
    return new jQuery.Event(src, props)  unless this instanceof jQuery.Event
    if src and src.type
      @originalEvent = src
      @type = src.type
      @isDefaultPrevented = (if (src.defaultPrevented or src.returnValue is false or src.getPreventDefault and src.getPreventDefault()) then returnTrue else returnFalse)
    else
      @type = src
    jQuery.extend this, props  if props
    @timeStamp = src and src.timeStamp or jQuery.now()
    this[jQuery.expando] = true

  jQuery.Event:: =
    preventDefault: ->
      @isDefaultPrevented = returnTrue
      e = @originalEvent
      return  unless e
      if e.preventDefault
        e.preventDefault()
      else
        e.returnValue = false

    stopPropagation: ->
      @isPropagationStopped = returnTrue
      e = @originalEvent
      return  unless e
      e.stopPropagation()  if e.stopPropagation
      e.cancelBubble = true

    stopImmediatePropagation: ->
      @isImmediatePropagationStopped = returnTrue
      @stopPropagation()

    isDefaultPrevented: returnFalse
    isPropagationStopped: returnFalse
    isImmediatePropagationStopped: returnFalse

  jQuery.each
    mouseenter: "mouseover"
    mouseleave: "mouseout"
  , (orig, fix) ->
    jQuery.event.special[orig] =
      delegateType: fix
      bindType: fix
      handle: (event) ->
        target = this
        related = event.relatedTarget
        handleObj = event.handleObj
        selector = handleObj.selector
        ret = undefined
        if not related or (related isnt target and not jQuery.contains(target, related))
          event.type = handleObj.origType
          ret = handleObj.handler.apply(this, arguments)
          event.type = fix
        ret

  unless jQuery.support.submitBubbles
    jQuery.event.special.submit =
      setup: ->
        return false  if jQuery.nodeName(this, "form")
        jQuery.event.add this, "click._submit keypress._submit", (e) ->
          elem = e.target
          form = (if jQuery.nodeName(elem, "input") or jQuery.nodeName(elem, "button") then elem.form else `undefined`)
          if form and not form._submit_attached
            jQuery.event.add form, "submit._submit", (event) ->
              jQuery.event.simulate "submit", @parentNode, event, true  if @parentNode and not event.isTrigger

            form._submit_attached = true

      teardown: ->
        return false  if jQuery.nodeName(this, "form")
        jQuery.event.remove this, "._submit"
  unless jQuery.support.changeBubbles
    jQuery.event.special.change =
      setup: ->
        if rformElems.test(@nodeName)
          if @type is "checkbox" or @type is "radio"
            jQuery.event.add this, "propertychange._change", (event) ->
              @_just_changed = true  if event.originalEvent.propertyName is "checked"

            jQuery.event.add this, "click._change", (event) ->
              if @_just_changed and not event.isTrigger
                @_just_changed = false
                jQuery.event.simulate "change", this, event, true
          return false
        jQuery.event.add this, "beforeactivate._change", (e) ->
          elem = e.target
          if rformElems.test(elem.nodeName) and not elem._change_attached
            jQuery.event.add elem, "change._change", (event) ->
              jQuery.event.simulate "change", @parentNode, event, true  if @parentNode and not event.isSimulated and not event.isTrigger

            elem._change_attached = true

      handle: (event) ->
        elem = event.target
        event.handleObj.handler.apply this, arguments  if this isnt elem or event.isSimulated or event.isTrigger or (elem.type isnt "radio" and elem.type isnt "checkbox")

      teardown: ->
        jQuery.event.remove this, "._change"
        rformElems.test @nodeName
  unless jQuery.support.focusinBubbles
    jQuery.each
      focus: "focusin"
      blur: "focusout"
    , (orig, fix) ->
      attaches = 0
      handler = (event) ->
        jQuery.event.simulate fix, event.target, jQuery.event.fix(event), true

      jQuery.event.special[fix] =
        setup: ->
          document.addEventListener orig, handler, true  if attaches++ is 0

        teardown: ->
          document.removeEventListener orig, handler, true  if --attaches is 0
  jQuery.fn.extend
    on: (types, selector, data, fn, one) ->
      origFn = undefined
      type = undefined
      if typeof types is "object"
        if typeof selector isnt "string"
          data = selector
          selector = `undefined`
        for type of types
          @on type, selector, data, types[type], one
        return this
      if not data? and not fn?
        fn = selector
        data = selector = `undefined`
      else unless fn?
        if typeof selector is "string"
          fn = data
          data = `undefined`
        else
          fn = data
          data = selector
          selector = `undefined`
      if fn is false
        fn = returnFalse
      else return this  unless fn
      if one is 1
        origFn = fn
        fn = (event) ->
          jQuery().off event
          origFn.apply this, arguments

        fn.guid = origFn.guid or (origFn.guid = jQuery.guid++)
      @each ->
        jQuery.event.add this, types, fn, data, selector

    one: (types, selector, data, fn) ->
      @on.call this, types, selector, data, fn, 1

    off: (types, selector, fn) ->
      if types and types.preventDefault and types.handleObj
        handleObj = types.handleObj
        jQuery(types.delegateTarget).off (if handleObj.namespace then handleObj.type + "." + handleObj.namespace else handleObj.type), handleObj.selector, handleObj.handler
        return this
      if typeof types is "object"
        for type of types
          @off type, selector, types[type]
        return this
      if selector is false or typeof selector is "function"
        fn = selector
        selector = `undefined`
      fn = returnFalse  if fn is false
      @each ->
        jQuery.event.remove this, types, fn, selector

    bind: (types, data, fn) ->
      @on types, null, data, fn

    unbind: (types, fn) ->
      @off types, null, fn

    live: (types, data, fn) ->
      jQuery(@context).on types, @selector, data, fn
      this

    die: (types, fn) ->
      jQuery(@context).off types, @selector or "**", fn
      this

    delegate: (selector, types, data, fn) ->
      @on types, selector, data, fn

    undelegate: (selector, types, fn) ->
      (if arguments.length is 1 then @off(selector, "**") else @off(types, selector, fn))

    trigger: (type, data) ->
      @each ->
        jQuery.event.trigger type, data, this

    triggerHandler: (type, data) ->
      jQuery.event.trigger type, data, this[0], true  if this[0]

    toggle: (fn) ->
      args = arguments
      guid = fn.guid or jQuery.guid++
      i = 0
      toggler = (event) ->
        lastToggle = (jQuery._data(this, "lastToggle" + fn.guid) or 0) % i
        jQuery._data this, "lastToggle" + fn.guid, lastToggle + 1
        event.preventDefault()
        args[lastToggle].apply(this, arguments) or false

      toggler.guid = guid
      args[i++].guid = guid  while i < args.length
      @click toggler

    hover: (fnOver, fnOut) ->
      @mouseenter(fnOver).mouseleave fnOut or fnOver

  jQuery.each ("blur focus focusin focusout load resize scroll unload click dblclick " + "mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave " + "change select submit keydown keypress keyup error contextmenu").split(" "), (i, name) ->
    jQuery.fn[name] = (data, fn) ->
      unless fn?
        fn = data
        data = null
      (if arguments.length > 0 then @on(name, null, data, fn) else @trigger(name))

    jQuery.attrFn[name] = true  if jQuery.attrFn
    jQuery.event.fixHooks[name] = jQuery.event.keyHooks  if rkeyEvent.test(name)
    jQuery.event.fixHooks[name] = jQuery.event.mouseHooks  if rmouseEvent.test(name)

  (->
    dirNodeCheck = (dir, cur, doneName, checkSet, nodeCheck, isXML) ->
      i = 0
      l = checkSet.length

      while i < l
        elem = checkSet[i]
        if elem
          match = false
          elem = elem[dir]
          while elem
            if elem[expando] is doneName
              match = checkSet[elem.sizset]
              break
            if elem.nodeType is 1 and not isXML
              elem[expando] = doneName
              elem.sizset = i
            if elem.nodeName.toLowerCase() is cur
              match = elem
              break
            elem = elem[dir]
          checkSet[i] = match
        i++
    dirCheck = (dir, cur, doneName, checkSet, nodeCheck, isXML) ->
      i = 0
      l = checkSet.length

      while i < l
        elem = checkSet[i]
        if elem
          match = false
          elem = elem[dir]
          while elem
            if elem[expando] is doneName
              match = checkSet[elem.sizset]
              break
            if elem.nodeType is 1
              unless isXML
                elem[expando] = doneName
                elem.sizset = i
              if typeof cur isnt "string"
                if elem is cur
                  match = true
                  break
              else if Sizzle.filter(cur, [ elem ]).length > 0
                match = elem
                break
            elem = elem[dir]
          checkSet[i] = match
        i++
    chunker = /((?:\((?:\([^()]+\)|[^()]+)+\)|\[(?:\[[^\[\]]*\]|['"][^'"]*['"]|[^\[\]'"]+)+\]|\\.|[^ >+~,(\[\\]+)+|[>+~])(\s*,\s*)?((?:.|\r|\n)*)/g
    expando = "sizcache" + (Math.random() + "").replace(".", "")
    done = 0
    toString = Object::toString
    hasDuplicate = false
    baseHasDuplicate = true
    rBackslash = /\\/g
    rReturn = /\r\n/g
    rNonWord = /\W/
    [ 0, 0 ].sort ->
      baseHasDuplicate = false
      0

    Sizzle = (selector, context, results, seed) ->
      results = results or []
      context = context or document
      origContext = context
      return []  if context.nodeType isnt 1 and context.nodeType isnt 9
      return results  if not selector or typeof selector isnt "string"
      m = undefined
      set = undefined
      checkSet = undefined
      extra = undefined
      ret = undefined
      cur = undefined
      pop = undefined
      i = undefined
      prune = true
      contextXML = Sizzle.isXML(context)
      parts = []
      soFar = selector
      loop
        chunker.exec ""
        m = chunker.exec(soFar)
        if m
          soFar = m[3]
          parts.push m[1]
          if m[2]
            extra = m[3]
            break
        break unless m
      if parts.length > 1 and origPOS.exec(selector)
        if parts.length is 2 and Expr.relative[parts[0]]
          set = posProcess(parts[0] + parts[1], context, seed)
        else
          set = (if Expr.relative[parts[0]] then [ context ] else Sizzle(parts.shift(), context))
          while parts.length
            selector = parts.shift()
            selector += parts.shift()  if Expr.relative[selector]
            set = posProcess(selector, set, seed)
      else
        if not seed and parts.length > 1 and context.nodeType is 9 and not contextXML and Expr.match.ID.test(parts[0]) and not Expr.match.ID.test(parts[parts.length - 1])
          ret = Sizzle.find(parts.shift(), context, contextXML)
          context = (if ret.expr then Sizzle.filter(ret.expr, ret.set)[0] else ret.set[0])
        if context
          ret = (if seed then
            expr: parts.pop()
            set: makeArray(seed)
           else Sizzle.find(parts.pop(), (if parts.length is 1 and (parts[0] is "~" or parts[0] is "+") and context.parentNode then context.parentNode else context), contextXML))
          set = (if ret.expr then Sizzle.filter(ret.expr, ret.set) else ret.set)
          if parts.length > 0
            checkSet = makeArray(set)
          else
            prune = false
          while parts.length
            cur = parts.pop()
            pop = cur
            unless Expr.relative[cur]
              cur = ""
            else
              pop = parts.pop()
            pop = context  unless pop?
            Expr.relative[cur] checkSet, pop, contextXML
        else
          checkSet = parts = []
      checkSet = set  unless checkSet
      Sizzle.error cur or selector  unless checkSet
      if toString.call(checkSet) is "[object Array]"
        unless prune
          results.push.apply results, checkSet
        else if context and context.nodeType is 1
          i = 0
          while checkSet[i]?
            results.push set[i]  if checkSet[i] and (checkSet[i] is true or checkSet[i].nodeType is 1 and Sizzle.contains(context, checkSet[i]))
            i++
        else
          i = 0
          while checkSet[i]?
            results.push set[i]  if checkSet[i] and checkSet[i].nodeType is 1
            i++
      else
        makeArray checkSet, results
      if extra
        Sizzle extra, origContext, results, seed
        Sizzle.uniqueSort results
      results

    Sizzle.uniqueSort = (results) ->
      if sortOrder
        hasDuplicate = baseHasDuplicate
        results.sort sortOrder
        if hasDuplicate
          i = 1

          while i < results.length
            results.splice i--, 1  if results[i] is results[i - 1]
            i++
      results

    Sizzle.matches = (expr, set) ->
      Sizzle expr, null, null, set

    Sizzle.matchesSelector = (node, expr) ->
      Sizzle(expr, null, null, [ node ]).length > 0

    Sizzle.find = (expr, context, isXML) ->
      set = undefined
      i = undefined
      len = undefined
      match = undefined
      type = undefined
      left = undefined
      return []  unless expr
      i = 0
      len = Expr.order.length

      while i < len
        type = Expr.order[i]
        if match = Expr.leftMatch[type].exec(expr)
          left = match[1]
          match.splice 1, 1
          if left.substr(left.length - 1) isnt "\\"
            match[1] = (match[1] or "").replace(rBackslash, "")
            set = Expr.find[type](match, context, isXML)
            if set?
              expr = expr.replace(Expr.match[type], "")
              break
        i++
      set = (if typeof context.getElementsByTagName isnt "undefined" then context.getElementsByTagName("*") else [])  unless set
      set: set
      expr: expr

    Sizzle.filter = (expr, set, inplace, not_) ->
      match = undefined
      anyFound = undefined
      type = undefined
      found = undefined
      item = undefined
      filter = undefined
      left = undefined
      i = undefined
      pass = undefined
      old = expr
      result = []
      curLoop = set
      isXMLFilter = set and set[0] and Sizzle.isXML(set[0])
      while expr and set.length
        for type of Expr.filter
          if (match = Expr.leftMatch[type].exec(expr))? and match[2]
            filter = Expr.filter[type]
            left = match[1]
            anyFound = false
            match.splice 1, 1
            continue  if left.substr(left.length - 1) is "\\"
            result = []  if curLoop is result
            if Expr.preFilter[type]
              match = Expr.preFilter[type](match, curLoop, inplace, result, not_, isXMLFilter)
              unless match
                anyFound = found = true
              else continue  if match is true
            if match
              i = 0
              while (item = curLoop[i])?
                if item
                  found = filter(item, match, i, curLoop)
                  pass = not_ ^ found
                  if inplace and found?
                    if pass
                      anyFound = true
                    else
                      curLoop[i] = false
                  else if pass
                    result.push item
                    anyFound = true
                i++
            if found isnt `undefined`
              curLoop = result  unless inplace
              expr = expr.replace(Expr.match[type], "")
              return []  unless anyFound
              break
        if expr is old
          unless anyFound?
            Sizzle.error expr
          else
            break
        old = expr
      curLoop

    Sizzle.error = (msg) ->
      throw new Error("Syntax error, unrecognized expression: " + msg)

    getText = Sizzle.getText = (elem) ->
      i = undefined
      node = undefined
      nodeType = elem.nodeType
      ret = ""
      if nodeType
        if nodeType is 1 or nodeType is 9
          if typeof elem.textContent is "string"
            return elem.textContent
          else if typeof elem.innerText is "string"
            return elem.innerText.replace(rReturn, "")
          else
            elem = elem.firstChild
            while elem
              ret += getText(elem)
              elem = elem.nextSibling
        else return elem.nodeValue  if nodeType is 3 or nodeType is 4
      else
        i = 0
        while (node = elem[i])
          ret += getText(node)  if node.nodeType isnt 8
          i++
      ret

    Expr = Sizzle.selectors =
      order: [ "ID", "NAME", "TAG" ]
      match:
        ID: /#((?:[\w\u00c0-\uFFFF\-]|\\.)+)/
        CLASS: /\.((?:[\w\u00c0-\uFFFF\-]|\\.)+)/
        NAME: /\[name=['"]*((?:[\w\u00c0-\uFFFF\-]|\\.)+)['"]*\]/
        ATTR: /\[\s*((?:[\w\u00c0-\uFFFF\-]|\\.)+)\s*(?:(\S?=)\s*(?:(['"])(.*?)\3|(#?(?:[\w\u00c0-\uFFFF\-]|\\.)*)|)|)\s*\]/
        TAG: /^((?:[\w\u00c0-\uFFFF\*\-]|\\.)+)/
        CHILD: /:(only|nth|last|first)-child(?:\(\s*(even|odd|(?:[+\-]?\d+|(?:[+\-]?\d*)?n\s*(?:[+\-]\s*\d+)?))\s*\))?/
        POS: /:(nth|eq|gt|lt|first|last|even|odd)(?:\((\d*)\))?(?=[^\-]|$)/
        PSEUDO: /:((?:[\w\u00c0-\uFFFF\-]|\\.)+)(?:\((['"]?)((?:\([^\)]+\)|[^\(\)]*)+)\2\))?/

      leftMatch: {}
      attrMap:
        class: "className"
        for: "htmlFor"

      attrHandle:
        href: (elem) ->
          elem.getAttribute "href"

        type: (elem) ->
          elem.getAttribute "type"

      relative:
        "+": (checkSet, part) ->
          isPartStr = typeof part is "string"
          isTag = isPartStr and not rNonWord.test(part)
          isPartStrNotTag = isPartStr and not isTag
          part = part.toLowerCase()  if isTag
          i = 0
          l = checkSet.length
          elem = undefined

          while i < l
            if elem = checkSet[i]
              continue  while (elem = elem.previousSibling) and elem.nodeType isnt 1
              checkSet[i] = (if isPartStrNotTag or elem and elem.nodeName.toLowerCase() is part then elem or false else elem is part)
            i++
          Sizzle.filter part, checkSet, true  if isPartStrNotTag

        ">": (checkSet, part) ->
          elem = undefined
          isPartStr = typeof part is "string"
          i = 0
          l = checkSet.length
          if isPartStr and not rNonWord.test(part)
            part = part.toLowerCase()
            while i < l
              elem = checkSet[i]
              if elem
                parent = elem.parentNode
                checkSet[i] = (if parent.nodeName.toLowerCase() is part then parent else false)
              i++
          else
            while i < l
              elem = checkSet[i]
              checkSet[i] = (if isPartStr then elem.parentNode else elem.parentNode is part)  if elem
              i++
            Sizzle.filter part, checkSet, true  if isPartStr

        "": (checkSet, part, isXML) ->
          nodeCheck = undefined
          doneName = done++
          checkFn = dirCheck
          if typeof part is "string" and not rNonWord.test(part)
            part = part.toLowerCase()
            nodeCheck = part
            checkFn = dirNodeCheck
          checkFn "parentNode", part, doneName, checkSet, nodeCheck, isXML

        "~": (checkSet, part, isXML) ->
          nodeCheck = undefined
          doneName = done++
          checkFn = dirCheck
          if typeof part is "string" and not rNonWord.test(part)
            part = part.toLowerCase()
            nodeCheck = part
            checkFn = dirNodeCheck
          checkFn "previousSibling", part, doneName, checkSet, nodeCheck, isXML

      find:
        ID: (match, context, isXML) ->
          if typeof context.getElementById isnt "undefined" and not isXML
            m = context.getElementById(match[1])
            (if m and m.parentNode then [ m ] else [])

        NAME: (match, context) ->
          if typeof context.getElementsByName isnt "undefined"
            ret = []
            results = context.getElementsByName(match[1])
            i = 0
            l = results.length

            while i < l
              ret.push results[i]  if results[i].getAttribute("name") is match[1]
              i++
            (if ret.length is 0 then null else ret)

        TAG: (match, context) ->
          context.getElementsByTagName match[1]  if typeof context.getElementsByTagName isnt "undefined"

      preFilter:
        CLASS: (match, curLoop, inplace, result, not_, isXML) ->
          match = " " + match[1].replace(rBackslash, "") + " "
          return match  if isXML
          i = 0
          elem = undefined

          while (elem = curLoop[i])?
            if elem
              if not_ ^ (elem.className and (" " + elem.className + " ").replace(/[\t\n\r]/g, " ").indexOf(match) >= 0)
                result.push elem  unless inplace
              else curLoop[i] = false  if inplace
            i++
          false

        ID: (match) ->
          match[1].replace rBackslash, ""

        TAG: (match, curLoop) ->
          match[1].replace(rBackslash, "").toLowerCase()

        CHILD: (match) ->
          if match[1] is "nth"
            Sizzle.error match[0]  unless match[2]
            match[2] = match[2].replace(/^\+|\s*/g, "")
            test = /(-?)(\d*)(?:n([+\-]?\d*))?/.exec(match[2] is "even" and "2n" or match[2] is "odd" and "2n+1" or not /\D/.test(match[2]) and "0n+" + match[2] or match[2])
            match[2] = (test[1] + (test[2] or 1)) - 0
            match[3] = test[3] - 0
          else Sizzle.error match[0]  if match[2]
          match[0] = done++
          match

        ATTR: (match, curLoop, inplace, result, not_, isXML) ->
          name = match[1] = match[1].replace(rBackslash, "")
          match[1] = Expr.attrMap[name]  if not isXML and Expr.attrMap[name]
          match[4] = (match[4] or match[5] or "").replace(rBackslash, "")
          match[4] = " " + match[4] + " "  if match[2] is "~="
          match

        PSEUDO: (match, curLoop, inplace, result, not_) ->
          if match[1] is "not"
            if (chunker.exec(match[3]) or "").length > 1 or /^\w/.test(match[3])
              match[3] = Sizzle(match[3], null, null, curLoop)
            else
              ret = Sizzle.filter(match[3], curLoop, inplace, true ^ not_)
              result.push.apply result, ret  unless inplace
              return false
          else return true  if Expr.match.POS.test(match[0]) or Expr.match.CHILD.test(match[0])
          match

        POS: (match) ->
          match.unshift true
          match

      filters:
        enabled: (elem) ->
          elem.disabled is false and elem.type isnt "hidden"

        disabled: (elem) ->
          elem.disabled is true

        checked: (elem) ->
          elem.checked is true

        selected: (elem) ->
          elem.parentNode.selectedIndex  if elem.parentNode
          elem.selected is true

        parent: (elem) ->
          !!elem.firstChild

        empty: (elem) ->
          not elem.firstChild

        has: (elem, i, match) ->
          !!Sizzle(match[3], elem).length

        header: (elem) ->
          (/h\d/i).test elem.nodeName

        text: (elem) ->
          attr = elem.getAttribute("type")
          type = elem.type
          elem.nodeName.toLowerCase() is "input" and "text" is type and (attr is type or attr is null)

        radio: (elem) ->
          elem.nodeName.toLowerCase() is "input" and "radio" is elem.type

        checkbox: (elem) ->
          elem.nodeName.toLowerCase() is "input" and "checkbox" is elem.type

        file: (elem) ->
          elem.nodeName.toLowerCase() is "input" and "file" is elem.type

        password: (elem) ->
          elem.nodeName.toLowerCase() is "input" and "password" is elem.type

        submit: (elem) ->
          name = elem.nodeName.toLowerCase()
          (name is "input" or name is "button") and "submit" is elem.type

        image: (elem) ->
          elem.nodeName.toLowerCase() is "input" and "image" is elem.type

        reset: (elem) ->
          name = elem.nodeName.toLowerCase()
          (name is "input" or name is "button") and "reset" is elem.type

        button: (elem) ->
          name = elem.nodeName.toLowerCase()
          name is "input" and "button" is elem.type or name is "button"

        input: (elem) ->
          (/input|select|textarea|button/i).test elem.nodeName

        focus: (elem) ->
          elem is elem.ownerDocument.activeElement

      setFilters:
        first: (elem, i) ->
          i is 0

        last: (elem, i, match, array) ->
          i is array.length - 1

        even: (elem, i) ->
          i % 2 is 0

        odd: (elem, i) ->
          i % 2 is 1

        lt: (elem, i, match) ->
          i < match[3] - 0

        gt: (elem, i, match) ->
          i > match[3] - 0

        nth: (elem, i, match) ->
          match[3] - 0 is i

        eq: (elem, i, match) ->
          match[3] - 0 is i

      filter:
        PSEUDO: (elem, match, i, array) ->
          name = match[1]
          filter = Expr.filters[name]
          if filter
            filter elem, i, match, array
          else if name is "contains"
            (elem.textContent or elem.innerText or getText([ elem ]) or "").indexOf(match[3]) >= 0
          else if name is "not"
            not_ = match[3]
            j = 0
            l = not_.length

            while j < l
              return false  if not_[j] is elem
              j++
            true
          else
            Sizzle.error name

        CHILD: (elem, match) ->
          first = undefined
          last = undefined
          doneName = undefined
          parent = undefined
          cache = undefined
          count = undefined
          diff = undefined
          type = match[1]
          node = elem
          switch type
            when "only", "first"
              return false  if node.nodeType is 1  while (node = node.previousSibling)
              return true  if type is "first"
              node = elem
            when "last"
              return false  if node.nodeType is 1  while (node = node.nextSibling)
              true
            when "nth"
              first = match[2]
              last = match[3]
              return true  if first is 1 and last is 0
              doneName = match[0]
              parent = elem.parentNode
              if parent and (parent[expando] isnt doneName or not elem.nodeIndex)
                count = 0
                node = parent.firstChild
                while node
                  node.nodeIndex = ++count  if node.nodeType is 1
                  node = node.nextSibling
                parent[expando] = doneName
              diff = elem.nodeIndex - last
              if first is 0
                diff is 0
              else
                diff % first is 0 and diff / first >= 0

        ID: (elem, match) ->
          elem.nodeType is 1 and elem.getAttribute("id") is match

        TAG: (elem, match) ->
          (match is "*" and elem.nodeType is 1) or !!elem.nodeName and elem.nodeName.toLowerCase() is match

        CLASS: (elem, match) ->
          (" " + (elem.className or elem.getAttribute("class")) + " ").indexOf(match) > -1

        ATTR: (elem, match) ->
          name = match[1]
          result = (if Sizzle.attr then Sizzle.attr(elem, name) else (if Expr.attrHandle[name] then Expr.attrHandle[name](elem) else (if elem[name]? then elem[name] else elem.getAttribute(name))))
          value = result + ""
          type = match[2]
          check = match[4]
          (if not result? then type is "!=" else (if not type and Sizzle.attr then result? else (if type is "=" then value is check else (if type is "*=" then value.indexOf(check) >= 0 else (if type is "~=" then (" " + value + " ").indexOf(check) >= 0 else (if not check then value and result isnt false else (if type is "!=" then value isnt check else (if type is "^=" then value.indexOf(check) is 0 else (if type is "$=" then value.substr(value.length - check.length) is check else (if type is "|=" then value is check or value.substr(0, check.length + 1) is check + "-" else false))))))))))

        POS: (elem, match, i, array) ->
          name = match[2]
          filter = Expr.setFilters[name]
          filter elem, i, match, array  if filter

    origPOS = Expr.match.POS
    fescape = (all, num) ->
      "\\" + (num - 0 + 1)

    for type of Expr.match
      Expr.match[type] = new RegExp(Expr.match[type].source + (/(?![^\[]*\])(?![^\(]*\))/.source))
      Expr.leftMatch[type] = new RegExp(/(^(?:.|\r|\n)*?)/.source + Expr.match[type].source.replace(/\\(\d+)/g, fescape))
    makeArray = (array, results) ->
      array = Array::slice.call(array, 0)
      if results
        results.push.apply results, array
        return results
      array

    try
      Array::slice.call(document.documentElement.childNodes, 0)[0].nodeType
    catch e
      makeArray = (array, results) ->
        i = 0
        ret = results or []
        if toString.call(array) is "[object Array]"
          Array::push.apply ret, array
        else
          if typeof array.length is "number"
            l = array.length

            while i < l
              ret.push array[i]
              i++
          else
            while array[i]
              ret.push array[i]
              i++
        ret
    sortOrder = undefined
    siblingCheck = undefined
    if document.documentElement.compareDocumentPosition
      sortOrder = (a, b) ->
        if a is b
          hasDuplicate = true
          return 0
        return (if a.compareDocumentPosition then -1 else 1)  if not a.compareDocumentPosition or not b.compareDocumentPosition
        (if a.compareDocumentPosition(b) & 4 then -1 else 1)
    else
      sortOrder = (a, b) ->
        if a is b
          hasDuplicate = true
          return 0
        else return a.sourceIndex - b.sourceIndex  if a.sourceIndex and b.sourceIndex
        al = undefined
        bl = undefined
        ap = []
        bp = []
        aup = a.parentNode
        bup = b.parentNode
        cur = aup
        if aup is bup
          return siblingCheck(a, b)
        else unless aup
          return -1
        else return 1  unless bup
        while cur
          ap.unshift cur
          cur = cur.parentNode
        cur = bup
        while cur
          bp.unshift cur
          cur = cur.parentNode
        al = ap.length
        bl = bp.length
        i = 0

        while i < al and i < bl
          return siblingCheck(ap[i], bp[i])  if ap[i] isnt bp[i]
          i++
        (if i is al then siblingCheck(a, bp[i], -1) else siblingCheck(ap[i], b, 1))

      siblingCheck = (a, b, ret) ->
        return ret  if a is b
        cur = a.nextSibling
        while cur
          return -1  if cur is b
          cur = cur.nextSibling
        1
    (->
      form = document.createElement("div")
      id = "script" + (new Date()).getTime()
      root = document.documentElement
      form.innerHTML = "<a name='" + id + "'/>"
      root.insertBefore form, root.firstChild
      if document.getElementById(id)
        Expr.find.ID = (match, context, isXML) ->
          if typeof context.getElementById isnt "undefined" and not isXML
            m = context.getElementById(match[1])
            (if m then (if m.id is match[1] or typeof m.getAttributeNode isnt "undefined" and m.getAttributeNode("id").nodeValue is match[1] then [ m ] else `undefined`) else [])

        Expr.filter.ID = (elem, match) ->
          node = typeof elem.getAttributeNode isnt "undefined" and elem.getAttributeNode("id")
          elem.nodeType is 1 and node and node.nodeValue is match
      root.removeChild form
      root = form = null
    )()
    (->
      div = document.createElement("div")
      div.appendChild document.createComment("")
      if div.getElementsByTagName("*").length > 0
        Expr.find.TAG = (match, context) ->
          results = context.getElementsByTagName(match[1])
          if match[1] is "*"
            tmp = []
            i = 0

            while results[i]
              tmp.push results[i]  if results[i].nodeType is 1
              i++
            results = tmp
          results
      div.innerHTML = "<a href='#'></a>"
      if div.firstChild and typeof div.firstChild.getAttribute isnt "undefined" and div.firstChild.getAttribute("href") isnt "#"
        Expr.attrHandle.href = (elem) ->
          elem.getAttribute "href", 2
      div = null
    )()
    if document.querySelectorAll
      (->
        oldSizzle = Sizzle
        div = document.createElement("div")
        id = "__sizzle__"
        div.innerHTML = "<p class='TEST'></p>"
        return  if div.querySelectorAll and div.querySelectorAll(".TEST").length is 0
        Sizzle = (query, context, extra, seed) ->
          context = context or document
          if not seed and not Sizzle.isXML(context)
            match = /^(\w+$)|^\.([\w\-]+$)|^#([\w\-]+$)/.exec(query)
            if match and (context.nodeType is 1 or context.nodeType is 9)
              if match[1]
                return makeArray(context.getElementsByTagName(query), extra)
              else return makeArray(context.getElementsByClassName(match[2]), extra)  if match[2] and Expr.find.CLASS and context.getElementsByClassName
            if context.nodeType is 9
              if query is "body" and context.body
                return makeArray([ context.body ], extra)
              else if match and match[3]
                elem = context.getElementById(match[3])
                if elem and elem.parentNode
                  return makeArray([ elem ], extra)  if elem.id is match[3]
                else
                  return makeArray([], extra)
              try
                return makeArray(context.querySelectorAll(query), extra)
            else if context.nodeType is 1 and context.nodeName.toLowerCase() isnt "object"
              oldContext = context
              old = context.getAttribute("id")
              nid = old or id
              hasParent = context.parentNode
              relativeHierarchySelector = /^\s*[+~]/.test(query)
              unless old
                context.setAttribute "id", nid
              else
                nid = nid.replace(/'/g, "\\$&")
              context = context.parentNode  if relativeHierarchySelector and hasParent
              try
                return makeArray(context.querySelectorAll("[id='" + nid + "'] " + query), extra)  if not relativeHierarchySelector or hasParent
              finally
                oldContext.removeAttribute "id"  unless old
          oldSizzle query, context, extra, seed

        for prop of oldSizzle
          Sizzle[prop] = oldSizzle[prop]
        div = null
      )()
    (->
      html = document.documentElement
      matches = html.matchesSelector or html.mozMatchesSelector or html.webkitMatchesSelector or html.msMatchesSelector
      if matches
        disconnectedMatch = not matches.call(document.createElement("div"), "div")
        pseudoWorks = false
        try
          matches.call document.documentElement, "[test!='']:sizzle"
        catch pseudoError
          pseudoWorks = true
        Sizzle.matchesSelector = (node, expr) ->
          expr = expr.replace(/\=\s*([^'"\]]*)\s*\]/g, "='$1']")
          unless Sizzle.isXML(node)
            try
              if pseudoWorks or not Expr.match.PSEUDO.test(expr) and not /!=/.test(expr)
                ret = matches.call(node, expr)
                return ret  if ret or not disconnectedMatch or node.document and node.document.nodeType isnt 11
          Sizzle(expr, null, null, [ node ]).length > 0
    )()
    (->
      div = document.createElement("div")
      div.innerHTML = "<div class='test e'></div><div class='test'></div>"
      return  if not div.getElementsByClassName or div.getElementsByClassName("e").length is 0
      div.lastChild.className = "e"
      return  if div.getElementsByClassName("e").length is 1
      Expr.order.splice 1, 0, "CLASS"
      Expr.find.CLASS = (match, context, isXML) ->
        context.getElementsByClassName match[1]  if typeof context.getElementsByClassName isnt "undefined" and not isXML

      div = null
    )()
    if document.documentElement.contains
      Sizzle.contains = (a, b) ->
        a isnt b and (if a.contains then a.contains(b) else true)
    else if document.documentElement.compareDocumentPosition
      Sizzle.contains = (a, b) ->
        !!(a.compareDocumentPosition(b) & 16)
    else
      Sizzle.contains = ->
        false
    Sizzle.isXML = (elem) ->
      documentElement = (if elem then elem.ownerDocument or elem else 0).documentElement
      (if documentElement then documentElement.nodeName isnt "HTML" else false)

    posProcess = (selector, context, seed) ->
      match = undefined
      tmpSet = []
      later = ""
      root = (if context.nodeType then [ context ] else context)
      while (match = Expr.match.PSEUDO.exec(selector))
        later += match[0]
        selector = selector.replace(Expr.match.PSEUDO, "")
      selector = (if Expr.relative[selector] then selector + "*" else selector)
      i = 0
      l = root.length

      while i < l
        Sizzle selector, root[i], tmpSet, seed
        i++
      Sizzle.filter later, tmpSet

    Sizzle.attr = jQuery.attr
    Sizzle.selectors.attrMap = {}
    jQuery.find = Sizzle
    jQuery.expr = Sizzle.selectors
    jQuery.expr[":"] = jQuery.expr.filters
    jQuery.unique = Sizzle.uniqueSort
    jQuery.text = Sizzle.getText
    jQuery.isXMLDoc = Sizzle.isXML
    jQuery.contains = Sizzle.contains
  )()
  runtil = /Until$/
  rparentsprev = /^(?:parents|prevUntil|prevAll)/
  rmultiselector = /,/
  isSimple = /^.[^:#\[\.,]*$/
  slice = Array::slice
  POS = jQuery.expr.match.POS
  guaranteedUnique =
    children: true
    contents: true
    next: true
    prev: true

  jQuery.fn.extend
    find: (selector) ->
      self = this
      i = undefined
      l = undefined
      if typeof selector isnt "string"
        return jQuery(selector).filter(->
          i = 0
          l = self.length

          while i < l
            return true  if jQuery.contains(self[i], this)
            i++
        )
      ret = @pushStack("", "find", selector)
      length = undefined
      n = undefined
      r = undefined
      i = 0
      l = @length

      while i < l
        length = ret.length
        jQuery.find selector, this[i], ret
        if i > 0
          n = length
          while n < ret.length
            r = 0
            while r < length
              if ret[r] is ret[n]
                ret.splice n--, 1
                break
              r++
            n++
        i++
      ret

    has: (target) ->
      targets = jQuery(target)
      @filter ->
        i = 0
        l = targets.length

        while i < l
          return true  if jQuery.contains(this, targets[i])
          i++

    not: (selector) ->
      @pushStack winnow(this, selector, false), "not", selector

    filter: (selector) ->
      @pushStack winnow(this, selector, true), "filter", selector

    is: (selector) ->
      !!selector and (if typeof selector is "string" then (if POS.test(selector) then jQuery(selector, @context).index(this[0]) >= 0 else jQuery.filter(selector, this).length > 0) else @filter(selector).length > 0)

    closest: (selectors, context) ->
      ret = []
      i = undefined
      l = undefined
      cur = this[0]
      if jQuery.isArray(selectors)
        level = 1
        while cur and cur.ownerDocument and cur isnt context
          i = 0
          while i < selectors.length
            if jQuery(cur).is(selectors[i])
              ret.push
                selector: selectors[i]
                elem: cur
                level: level
            i++
          cur = cur.parentNode
          level++
        return ret
      pos = (if POS.test(selectors) or typeof selectors isnt "string" then jQuery(selectors, context or @context) else 0)
      i = 0
      l = @length

      while i < l
        cur = this[i]
        while cur
          if (if pos then pos.index(cur) > -1 else jQuery.find.matchesSelector(cur, selectors))
            ret.push cur
            break
          else
            cur = cur.parentNode
            break  if not cur or not cur.ownerDocument or cur is context or cur.nodeType is 11
        i++
      ret = (if ret.length > 1 then jQuery.unique(ret) else ret)
      @pushStack ret, "closest", selectors

    index: (elem) ->
      return (if (this[0] and this[0].parentNode) then @prevAll().length else -1)  unless elem
      return jQuery.inArray(this[0], jQuery(elem))  if typeof elem is "string"
      jQuery.inArray (if elem.jquery then elem[0] else elem), this

    add: (selector, context) ->
      set = (if typeof selector is "string" then jQuery(selector, context) else jQuery.makeArray((if selector and selector.nodeType then [ selector ] else selector)))
      all = jQuery.merge(@get(), set)
      @pushStack (if isDisconnected(set[0]) or isDisconnected(all[0]) then all else jQuery.unique(all))

    andSelf: ->
      @add @prevObject

  jQuery.each
    parent: (elem) ->
      parent = elem.parentNode
      (if parent and parent.nodeType isnt 11 then parent else null)

    parents: (elem) ->
      jQuery.dir elem, "parentNode"

    parentsUntil: (elem, i, until_) ->
      jQuery.dir elem, "parentNode", until_

    next: (elem) ->
      jQuery.nth elem, 2, "nextSibling"

    prev: (elem) ->
      jQuery.nth elem, 2, "previousSibling"

    nextAll: (elem) ->
      jQuery.dir elem, "nextSibling"

    prevAll: (elem) ->
      jQuery.dir elem, "previousSibling"

    nextUntil: (elem, i, until_) ->
      jQuery.dir elem, "nextSibling", until_

    prevUntil: (elem, i, until_) ->
      jQuery.dir elem, "previousSibling", until_

    siblings: (elem) ->
      jQuery.sibling elem.parentNode.firstChild, elem

    children: (elem) ->
      jQuery.sibling elem.firstChild

    contents: (elem) ->
      (if jQuery.nodeName(elem, "iframe") then elem.contentDocument or elem.contentWindow.document else jQuery.makeArray(elem.childNodes))
  , (name, fn) ->
    jQuery.fn[name] = (until_, selector) ->
      ret = jQuery.map(this, fn, until_)
      selector = until_  unless runtil.test(name)
      ret = jQuery.filter(selector, ret)  if selector and typeof selector is "string"
      ret = (if @length > 1 and not guaranteedUnique[name] then jQuery.unique(ret) else ret)
      ret = ret.reverse()  if (@length > 1 or rmultiselector.test(selector)) and rparentsprev.test(name)
      @pushStack ret, name, slice.call(arguments).join(",")

  jQuery.extend
    filter: (expr, elems, not_) ->
      expr = ":not(" + expr + ")"  if not_
      (if elems.length is 1 then (if jQuery.find.matchesSelector(elems[0], expr) then [ elems[0] ] else []) else jQuery.find.matches(expr, elems))

    dir: (elem, dir, until_) ->
      matched = []
      cur = elem[dir]
      while cur and cur.nodeType isnt 9 and (until_ is `undefined` or cur.nodeType isnt 1 or not jQuery(cur).is(until_))
        matched.push cur  if cur.nodeType is 1
        cur = cur[dir]
      matched

    nth: (cur, result, dir, elem) ->
      result = result or 1
      num = 0
      while cur
        break  if cur.nodeType is 1 and ++num is result
        cur = cur[dir]
      cur

    sibling: (n, elem) ->
      r = []
      while n
        r.push n  if n.nodeType is 1 and n isnt elem
        n = n.nextSibling
      r

  nodeNames = "abbr|article|aside|audio|canvas|datalist|details|figcaption|figure|footer|" + "header|hgroup|mark|meter|nav|output|progress|section|summary|time|video"
  rinlinejQuery = RegExp(" jQuery\\d+=\"(?:\\d+|null)\"", "g")
  rleadingWhitespace = /^\s+/
  rxhtmlTag = /<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/g
  rtagName = /<([\w:]+)/
  rtbody = /<tbody/i
  rhtml = /<|&#?\w+;/
  rnoInnerhtml = /<(?:script|style)/i
  rnocache = /<(?:script|object|embed|option|style)/i
  rnoshimcache = new RegExp("<(?:" + nodeNames + ")", "i")
  rchecked = /checked\s*(?:[^=]|=\s*.checked.)/i
  rscriptType = /\/(java|ecma)script/i
  rcleanScript = /^\s*<!(?:\[CDATA\[|\-\-)/
  wrapMap =
    option: [ 1, "<select multiple='multiple'>", "</select>" ]
    legend: [ 1, "<fieldset>", "</fieldset>" ]
    thead: [ 1, "<table>", "</table>" ]
    tr: [ 2, "<table><tbody>", "</tbody></table>" ]
    td: [ 3, "<table><tbody><tr>", "</tr></tbody></table>" ]
    col: [ 2, "<table><tbody></tbody><colgroup>", "</colgroup></table>" ]
    area: [ 1, "<map>", "</map>" ]
    _default: [ 0, "", "" ]

  safeFragment = createSafeFragment(document)
  wrapMap.optgroup = wrapMap.option
  wrapMap.tbody = wrapMap.tfoot = wrapMap.colgroup = wrapMap.caption = wrapMap.thead
  wrapMap.th = wrapMap.td
  wrapMap._default = [ 1, "div<div>", "</div>" ]  unless jQuery.support.htmlSerialize
  jQuery.fn.extend
    text: (text) ->
      if jQuery.isFunction(text)
        return @each((i) ->
          self = jQuery(this)
          self.text text.call(this, i, self.text())
        )
      return @empty().append((this[0] and this[0].ownerDocument or document).createTextNode(text))  if typeof text isnt "object" and text isnt `undefined`
      jQuery.text this

    wrapAll: (html) ->
      if jQuery.isFunction(html)
        return @each((i) ->
          jQuery(this).wrapAll html.call(this, i)
        )
      if this[0]
        wrap = jQuery(html, this[0].ownerDocument).eq(0).clone(true)
        wrap.insertBefore this[0]  if this[0].parentNode
        wrap.map(->
          elem = this
          elem = elem.firstChild  while elem.firstChild and elem.firstChild.nodeType is 1
          elem
        ).append this
      this

    wrapInner: (html) ->
      if jQuery.isFunction(html)
        return @each((i) ->
          jQuery(this).wrapInner html.call(this, i)
        )
      @each ->
        self = jQuery(this)
        contents = self.contents()
        if contents.length
          contents.wrapAll html
        else
          self.append html

    wrap: (html) ->
      isFunction = jQuery.isFunction(html)
      @each (i) ->
        jQuery(this).wrapAll (if isFunction then html.call(this, i) else html)

    unwrap: ->
      @parent().each(->
        jQuery(this).replaceWith @childNodes  unless jQuery.nodeName(this, "body")
      ).end()

    append: ->
      @domManip arguments, true, (elem) ->
        @appendChild elem  if @nodeType is 1

    prepend: ->
      @domManip arguments, true, (elem) ->
        @insertBefore elem, @firstChild  if @nodeType is 1

    before: ->
      if this[0] and this[0].parentNode
        @domManip arguments, false, (elem) ->
          @parentNode.insertBefore elem, this
      else if arguments.length
        set = jQuery.clean(arguments)
        set.push.apply set, @toArray()
        @pushStack set, "before", arguments

    after: ->
      if this[0] and this[0].parentNode
        @domManip arguments, false, (elem) ->
          @parentNode.insertBefore elem, @nextSibling
      else if arguments.length
        set = @pushStack(this, "after", arguments)
        set.push.apply set, jQuery.clean(arguments)
        set

    remove: (selector, keepData) ->
      i = 0
      elem = undefined

      while (elem = this[i])?
        if not selector or jQuery.filter(selector, [ elem ]).length
          if not keepData and elem.nodeType is 1
            jQuery.cleanData elem.getElementsByTagName("*")
            jQuery.cleanData [ elem ]
          elem.parentNode.removeChild elem  if elem.parentNode
        i++
      this

    empty: ->
      i = 0
      elem = undefined

      while (elem = this[i])?
        jQuery.cleanData elem.getElementsByTagName("*")  if elem.nodeType is 1
        elem.removeChild elem.firstChild  while elem.firstChild
        i++
      this

    clone: (dataAndEvents, deepDataAndEvents) ->
      dataAndEvents = (if not dataAndEvents? then false else dataAndEvents)
      deepDataAndEvents = (if not deepDataAndEvents? then dataAndEvents else deepDataAndEvents)
      @map ->
        jQuery.clone this, dataAndEvents, deepDataAndEvents

    html: (value) ->
      if value is `undefined`
        return (if this[0] and this[0].nodeType is 1 then this[0].innerHTML.replace(rinlinejQuery, "") else null)
      else if typeof value is "string" and not rnoInnerhtml.test(value) and (jQuery.support.leadingWhitespace or not rleadingWhitespace.test(value)) and not wrapMap[(rtagName.exec(value) or [ "", "" ])[1].toLowerCase()]
        value = value.replace(rxhtmlTag, "<$1></$2>")
        try
          i = 0
          l = @length

          while i < l
            if this[i].nodeType is 1
              jQuery.cleanData this[i].getElementsByTagName("*")
              this[i].innerHTML = value
            i++
        catch e
          @empty().append value
      else if jQuery.isFunction(value)
        @each (i) ->
          self = jQuery(this)
          self.html value.call(this, i, self.html())
      else
        @empty().append value
      this

    replaceWith: (value) ->
      if this[0] and this[0].parentNode
        if jQuery.isFunction(value)
          return @each((i) ->
            self = jQuery(this)
            old = self.html()
            self.replaceWith value.call(this, i, old)
          )
        value = jQuery(value).detach()  if typeof value isnt "string"
        @each ->
          next = @nextSibling
          parent = @parentNode
          jQuery(this).remove()
          if next
            jQuery(next).before value
          else
            jQuery(parent).append value
      else
        (if @length then @pushStack(jQuery((if jQuery.isFunction(value) then value() else value)), "replaceWith", value) else this)

    detach: (selector) ->
      @remove selector, true

    domManip: (args, table, callback) ->
      results = undefined
      first = undefined
      fragment = undefined
      parent = undefined
      value = args[0]
      scripts = []
      if not jQuery.support.checkClone and arguments.length is 3 and typeof value is "string" and rchecked.test(value)
        return @each(->
          jQuery(this).domManip args, table, callback, true
        )
      if jQuery.isFunction(value)
        return @each((i) ->
          self = jQuery(this)
          args[0] = value.call(this, i, (if table then self.html() else `undefined`))
          self.domManip args, table, callback
        )
      if this[0]
        parent = value and value.parentNode
        if jQuery.support.parentNode and parent and parent.nodeType is 11 and parent.childNodes.length is @length
          results = fragment: parent
        else
          results = jQuery.buildFragment(args, this, scripts)
        fragment = results.fragment
        if fragment.childNodes.length is 1
          first = fragment = fragment.firstChild
        else
          first = fragment.firstChild
        if first
          table = table and jQuery.nodeName(first, "tr")
          i = 0
          l = @length
          lastIndex = l - 1

          while i < l
            callback.call (if table then root(this[i], first) else this[i]), (if results.cacheable or (l > 1 and i < lastIndex) then jQuery.clone(fragment, true, true) else fragment)
            i++
        jQuery.each scripts, evalScript  if scripts.length
      this

  jQuery.buildFragment = (args, nodes, scripts) ->
    fragment = undefined
    cacheable = undefined
    cacheresults = undefined
    doc = undefined
    first = args[0]
    doc = nodes[0].ownerDocument or nodes[0]  if nodes and nodes[0]
    doc = document  unless doc.createDocumentFragment
    if args.length is 1 and typeof first is "string" and first.length < 512 and doc is document and first.charAt(0) is "<" and not rnocache.test(first) and (jQuery.support.checkClone or not rchecked.test(first)) and (jQuery.support.html5Clone or not rnoshimcache.test(first))
      cacheable = true
      cacheresults = jQuery.fragments[first]
      fragment = cacheresults  if cacheresults and cacheresults isnt 1
    unless fragment
      fragment = doc.createDocumentFragment()
      jQuery.clean args, doc, fragment, scripts
    jQuery.fragments[first] = (if cacheresults then fragment else 1)  if cacheable
    fragment: fragment
    cacheable: cacheable

  jQuery.fragments = {}
  jQuery.each
    appendTo: "append"
    prependTo: "prepend"
    insertBefore: "before"
    insertAfter: "after"
    replaceAll: "replaceWith"
  , (name, original) ->
    jQuery.fn[name] = (selector) ->
      ret = []
      insert = jQuery(selector)
      parent = @length is 1 and this[0].parentNode
      if parent and parent.nodeType is 11 and parent.childNodes.length is 1 and insert.length is 1
        insert[original] this[0]
        this
      else
        i = 0
        l = insert.length

        while i < l
          elems = (if i > 0 then @clone(true) else this).get()
          jQuery(insert[i])[original] elems
          ret = ret.concat(elems)
          i++
        @pushStack ret, name, insert.selector

  jQuery.extend
    clone: (elem, dataAndEvents, deepDataAndEvents) ->
      srcElements = undefined
      destElements = undefined
      i = undefined
      clone = (if jQuery.support.html5Clone or not rnoshimcache.test("<" + elem.nodeName) then elem.cloneNode(true) else shimCloneNode(elem))
      if (not jQuery.support.noCloneEvent or not jQuery.support.noCloneChecked) and (elem.nodeType is 1 or elem.nodeType is 11) and not jQuery.isXMLDoc(elem)
        cloneFixAttributes elem, clone
        srcElements = getAll(elem)
        destElements = getAll(clone)
        i = 0
        while srcElements[i]
          cloneFixAttributes srcElements[i], destElements[i]  if destElements[i]
          ++i
      if dataAndEvents
        cloneCopyEvent elem, clone
        if deepDataAndEvents
          srcElements = getAll(elem)
          destElements = getAll(clone)
          i = 0
          while srcElements[i]
            cloneCopyEvent srcElements[i], destElements[i]
            ++i
      srcElements = destElements = null
      clone

    clean: (elems, context, fragment, scripts) ->
      checkScriptType = undefined
      context = context or document
      context = context.ownerDocument or context[0] and context[0].ownerDocument or document  if typeof context.createElement is "undefined"
      ret = []
      j = undefined
      i = 0
      elem = undefined

      while (elem = elems[i])?
        elem += ""  if typeof elem is "number"
        continue  unless elem
        if typeof elem is "string"
          unless rhtml.test(elem)
            elem = context.createTextNode(elem)
          else
            elem = elem.replace(rxhtmlTag, "<$1></$2>")
            tag = (rtagName.exec(elem) or [ "", "" ])[1].toLowerCase()
            wrap = wrapMap[tag] or wrapMap._default
            depth = wrap[0]
            div = context.createElement("div")
            if context is document
              safeFragment.appendChild div
            else
              createSafeFragment(context).appendChild div
            div.innerHTML = wrap[1] + elem + wrap[2]
            div = div.lastChild  while depth--
            unless jQuery.support.tbody
              hasBody = rtbody.test(elem)
              tbody = (if tag is "table" and not hasBody then div.firstChild and div.firstChild.childNodes else (if wrap[1] is "<table>" and not hasBody then div.childNodes else []))
              j = tbody.length - 1
              while j >= 0
                tbody[j].parentNode.removeChild tbody[j]  if jQuery.nodeName(tbody[j], "tbody") and not tbody[j].childNodes.length
                --j
            div.insertBefore context.createTextNode(rleadingWhitespace.exec(elem)[0]), div.firstChild  if not jQuery.support.leadingWhitespace and rleadingWhitespace.test(elem)
            elem = div.childNodes
        len = undefined
        unless jQuery.support.appendChecked
          if elem[0] and typeof (len = elem.length) is "number"
            j = 0
            while j < len
              findInputs elem[j]
              j++
          else
            findInputs elem
        if elem.nodeType
          ret.push elem
        else
          ret = jQuery.merge(ret, elem)
        i++
      if fragment
        checkScriptType = (elem) ->
          not elem.type or rscriptType.test(elem.type)

        i = 0
        while ret[i]
          if scripts and jQuery.nodeName(ret[i], "script") and (not ret[i].type or ret[i].type.toLowerCase() is "text/javascript")
            scripts.push (if ret[i].parentNode then ret[i].parentNode.removeChild(ret[i]) else ret[i])
          else
            if ret[i].nodeType is 1
              jsTags = jQuery.grep(ret[i].getElementsByTagName("script"), checkScriptType)
              ret.splice.apply ret, [ i + 1, 0 ].concat(jsTags)
            fragment.appendChild ret[i]
          i++
      ret

    cleanData: (elems) ->
      data = undefined
      id = undefined
      cache = jQuery.cache
      special = jQuery.event.special
      deleteExpando = jQuery.support.deleteExpando
      i = 0
      elem = undefined

      while (elem = elems[i])?
        continue  if elem.nodeName and jQuery.noData[elem.nodeName.toLowerCase()]
        id = elem[jQuery.expando]
        if id
          data = cache[id]
          if data and data.events
            for type of data.events
              if special[type]
                jQuery.event.remove elem, type
              else
                jQuery.removeEvent elem, type, data.handle
            data.handle.elem = null  if data.handle
          if deleteExpando
            delete elem[jQuery.expando]
          else elem.removeAttribute jQuery.expando  if elem.removeAttribute
          delete cache[id]
        i++

  ralpha = /alpha\([^)]*\)/i
  ropacity = /opacity=([^)]*)/
  rupper = /([A-Z]|^ms)/g
  rnumpx = /^-?\d+(?:px)?$/i
  rnum = /^-?\d/
  rrelNum = /^([\-+])=([\-+.\de]+)/
  cssShow =
    position: "absolute"
    visibility: "hidden"
    display: "block"

  cssWidth = [ "Left", "Right" ]
  cssHeight = [ "Top", "Bottom" ]
  curCSS = undefined
  getComputedStyle = undefined
  currentStyle = undefined
  jQuery.fn.css = (name, value) ->
    return this  if arguments.length is 2 and value is `undefined`
    jQuery.access this, name, value, true, (elem, name, value) ->
      (if value isnt `undefined` then jQuery.style(elem, name, value) else jQuery.css(elem, name))

  jQuery.extend
    cssHooks:
      opacity:
        get: (elem, computed) ->
          if computed
            ret = curCSS(elem, "opacity", "opacity")
            (if ret is "" then "1" else ret)
          else
            elem.style.opacity

    cssNumber:
      fillOpacity: true
      fontWeight: true
      lineHeight: true
      opacity: true
      orphans: true
      widows: true
      zIndex: true
      zoom: true

    cssProps:
      float: (if jQuery.support.cssFloat then "cssFloat" else "styleFloat")

    style: (elem, name, value, extra) ->
      return  if not elem or elem.nodeType is 3 or elem.nodeType is 8 or not elem.style
      ret = undefined
      type = undefined
      origName = jQuery.camelCase(name)
      style = elem.style
      hooks = jQuery.cssHooks[origName]
      name = jQuery.cssProps[origName] or origName
      if value isnt `undefined`
        type = typeof value
        if type is "string" and (ret = rrelNum.exec(value))
          value = (+(ret[1] + 1) * +ret[2]) + parseFloat(jQuery.css(elem, name))
          type = "number"
        return  if not value? or type is "number" and isNaN(value)
        value += "px"  if type is "number" and not jQuery.cssNumber[origName]
        if not hooks or ("set" of hooks) or (value = hooks.set(elem, value)) isnt `undefined`
          try
            style[name] = value
      else
        return ret  if hooks and "get" of hooks and (ret = hooks.get(elem, false, extra)) isnt `undefined`
        style[name]

    css: (elem, name, extra) ->
      ret = undefined
      hooks = undefined
      name = jQuery.camelCase(name)
      hooks = jQuery.cssHooks[name]
      name = jQuery.cssProps[name] or name
      name = "float"  if name is "cssFloat"
      if hooks and "get" of hooks and (ret = hooks.get(elem, true, extra)) isnt `undefined`
        ret
      else curCSS elem, name  if curCSS

    swap: (elem, options, callback) ->
      old = {}
      for name of options
        old[name] = elem.style[name]
        elem.style[name] = options[name]
      callback.call elem
      for name of options
        elem.style[name] = old[name]

  jQuery.curCSS = jQuery.css
  jQuery.each [ "height", "width" ], (i, name) ->
    jQuery.cssHooks[name] =
      get: (elem, computed, extra) ->
        val = undefined
        if computed
          if elem.offsetWidth isnt 0
            return getWH(elem, name, extra)
          else
            jQuery.swap elem, cssShow, ->
              val = getWH(elem, name, extra)
          val

      set: (elem, value) ->
        if rnumpx.test(value)
          value = parseFloat(value)
          value + "px"  if value >= 0
        else
          value

  unless jQuery.support.opacity
    jQuery.cssHooks.opacity =
      get: (elem, computed) ->
        (if ropacity.test((if computed and elem.currentStyle then elem.currentStyle.filter else elem.style.filter) or "") then (parseFloat(RegExp.$1) / 100) + "" else (if computed then "1" else ""))

      set: (elem, value) ->
        style = elem.style
        currentStyle = elem.currentStyle
        opacity = (if jQuery.isNumeric(value) then "alpha(opacity=" + value * 100 + ")" else "")
        filter = currentStyle and currentStyle.filter or style.filter or ""
        style.zoom = 1
        if value >= 1 and jQuery.trim(filter.replace(ralpha, "")) is ""
          style.removeAttribute "filter"
          return  if currentStyle and not currentStyle.filter
        style.filter = (if ralpha.test(filter) then filter.replace(ralpha, opacity) else filter + " " + opacity)
  jQuery ->
    unless jQuery.support.reliableMarginRight
      jQuery.cssHooks.marginRight = get: (elem, computed) ->
        ret = undefined
        jQuery.swap elem,
          display: "inline-block"
        , ->
          if computed
            ret = curCSS(elem, "margin-right", "marginRight")
          else
            ret = elem.style.marginRight

        ret

  if document.defaultView and document.defaultView.getComputedStyle
    getComputedStyle = (elem, name) ->
      ret = undefined
      defaultView = undefined
      computedStyle = undefined
      name = name.replace(rupper, "-$1").toLowerCase()
      if (defaultView = elem.ownerDocument.defaultView) and (computedStyle = defaultView.getComputedStyle(elem, null))
        ret = computedStyle.getPropertyValue(name)
        ret = jQuery.style(elem, name)  if ret is "" and not jQuery.contains(elem.ownerDocument.documentElement, elem)
      ret
  if document.documentElement.currentStyle
    currentStyle = (elem, name) ->
      left = undefined
      rsLeft = undefined
      uncomputed = undefined
      ret = elem.currentStyle and elem.currentStyle[name]
      style = elem.style
      ret = uncomputed  if ret is null and style and (uncomputed = style[name])
      if not rnumpx.test(ret) and rnum.test(ret)
        left = style.left
        rsLeft = elem.runtimeStyle and elem.runtimeStyle.left
        elem.runtimeStyle.left = elem.currentStyle.left  if rsLeft
        style.left = (if name is "fontSize" then "1em" else (ret or 0))
        ret = style.pixelLeft + "px"
        style.left = left
        elem.runtimeStyle.left = rsLeft  if rsLeft
      (if ret is "" then "auto" else ret)
  curCSS = getComputedStyle or currentStyle
  if jQuery.expr and jQuery.expr.filters
    jQuery.expr.filters.hidden = (elem) ->
      width = elem.offsetWidth
      height = elem.offsetHeight
      (width is 0 and height is 0) or (not jQuery.support.reliableHiddenOffsets and (elem.style and elem.style.display) or jQuery.css(elem, "display") is "none")

    jQuery.expr.filters.visible = (elem) ->
      not jQuery.expr.filters.hidden(elem)
  r20 = /%20/g
  rbracket = /\[\]$/
  rCRLF = /\r?\n/g
  rhash = /#.*$/
  rheaders = /^(.*?):[ \t]*([^\r\n]*)\r?$/g
  rinput = /^(?:color|date|datetime|datetime-local|email|hidden|month|number|password|range|search|tel|text|time|url|week)$/i
  rlocalProtocol = /^(?:about|app|app\-storage|.+\-extension|file|res|widget):$/
  rnoContent = /^(?:GET|HEAD)$/
  rprotocol = /^\/\//
  rquery = /\?/
  rscript = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/g
  rselectTextarea = /^(?:select|textarea)/i
  rspacesAjax = /\s+/
  rts = /([?&])_=[^&]*/
  rurl = /^([\w\+\.\-]+:)(?:\/\/([^\/?#:]*)(?::(\d+))?)?/
  _load = jQuery.fn.load
  prefilters = {}
  transports = {}
  ajaxLocation = undefined
  ajaxLocParts = undefined
  allTypes = [ "*/" ] + [ "*" ]
  try
    ajaxLocation = location.href
  catch e
    ajaxLocation = document.createElement("a")
    ajaxLocation.href = ""
    ajaxLocation = ajaxLocation.href
  ajaxLocParts = rurl.exec(ajaxLocation.toLowerCase()) or []
  jQuery.fn.extend
    load: (url, params, callback) ->
      if typeof url isnt "string" and _load
        return _load.apply(this, arguments)
      else return this  unless @length
      off_ = url.indexOf(" ")
      if off_ >= 0
        selector = url.slice(off_, url.length)
        url = url.slice(0, off_)
      type = "GET"
      if params
        if jQuery.isFunction(params)
          callback = params
          params = `undefined`
        else if typeof params is "object"
          params = jQuery.param(params, jQuery.ajaxSettings.traditional)
          type = "POST"
      self = this
      jQuery.ajax
        url: url
        type: type
        dataType: "html"
        data: params
        complete: (jqXHR, status, responseText) ->
          responseText = jqXHR.responseText
          if jqXHR.isResolved()
            jqXHR.done (r) ->
              responseText = r

            self.html (if selector then jQuery("<div>").append(responseText.replace(rscript, "")).find(selector) else responseText)
          self.each callback, [ responseText, status, jqXHR ]  if callback

      this

    serialize: ->
      jQuery.param @serializeArray()

    serializeArray: ->
      @map(->
        (if @elements then jQuery.makeArray(@elements) else this)
      ).filter(->
        @name and not @disabled and (@checked or rselectTextarea.test(@nodeName) or rinput.test(@type))
      ).map((i, elem) ->
        val = jQuery(this).val()
        (if not val? then null else (if jQuery.isArray(val) then jQuery.map(val, (val, i) ->
          name: elem.name
          value: val.replace(rCRLF, "\r\n")
        ) else
          name: elem.name
          value: val.replace(rCRLF, "\r\n")
        ))
      ).get()

  jQuery.each "ajaxStart ajaxStop ajaxComplete ajaxError ajaxSuccess ajaxSend".split(" "), (i, o) ->
    jQuery.fn[o] = (f) ->
      @on o, f

  jQuery.each [ "get", "post" ], (i, method) ->
    jQuery[method] = (url, data, callback, type) ->
      if jQuery.isFunction(data)
        type = type or callback
        callback = data
        data = `undefined`
      jQuery.ajax
        type: method
        url: url
        data: data
        success: callback
        dataType: type

  jQuery.extend
    getScript: (url, callback) ->
      jQuery.get url, `undefined`, callback, "script"

    getJSON: (url, data, callback) ->
      jQuery.get url, data, callback, "json"

    ajaxSetup: (target, settings) ->
      if settings
        ajaxExtend target, jQuery.ajaxSettings
      else
        settings = target
        target = jQuery.ajaxSettings
      ajaxExtend target, settings
      target

    ajaxSettings:
      url: ajaxLocation
      isLocal: rlocalProtocol.test(ajaxLocParts[1])
      global: true
      type: "GET"
      contentType: "application/x-www-form-urlencoded"
      processData: true
      async: true
      accepts:
        xml: "application/xml, text/xml"
        html: "text/html"
        text: "text/plain"
        json: "application/json, text/javascript"
        "*": allTypes

      contents:
        xml: /xml/
        html: /html/
        json: /json/

      responseFields:
        xml: "responseXML"
        text: "responseText"

      converters:
        "* text": window.String
        "text html": true
        "text json": jQuery.parseJSON
        "text xml": jQuery.parseXML

      flatOptions:
        context: true
        url: true

    ajaxPrefilter: addToPrefiltersOrTransports(prefilters)
    ajaxTransport: addToPrefiltersOrTransports(transports)
    ajax: (url, options) ->
      done = (status, nativeStatusText, responses, headers) ->
        return  if state is 2
        state = 2
        clearTimeout timeoutTimer  if timeoutTimer
        transport = `undefined`
        responseHeadersString = headers or ""
        jqXHR.readyState = (if status > 0 then 4 else 0)
        isSuccess = undefined
        success = undefined
        error = undefined
        statusText = nativeStatusText
        response = (if responses then ajaxHandleResponses(s, jqXHR, responses) else `undefined`)
        lastModified = undefined
        etag = undefined
        if status >= 200 and status < 300 or status is 304
          if s.ifModified
            jQuery.lastModified[ifModifiedKey] = lastModified  if lastModified = jqXHR.getResponseHeader("Last-Modified")
            jQuery.etag[ifModifiedKey] = etag  if etag = jqXHR.getResponseHeader("Etag")
          if status is 304
            statusText = "notmodified"
            isSuccess = true
          else
            try
              success = ajaxConvert(s, response)
              statusText = "success"
              isSuccess = true
            catch e
              statusText = "parsererror"
              error = e
        else
          error = statusText
          if not statusText or status
            statusText = "error"
            status = 0  if status < 0
        jqXHR.status = status
        jqXHR.statusText = "" + (nativeStatusText or statusText)
        if isSuccess
          deferred.resolveWith callbackContext, [ success, statusText, jqXHR ]
        else
          deferred.rejectWith callbackContext, [ jqXHR, statusText, error ]
        jqXHR.statusCode statusCode
        statusCode = `undefined`
        globalEventContext.trigger "ajax" + (if isSuccess then "Success" else "Error"), [ jqXHR, s, (if isSuccess then success else error) ]  if fireGlobals
        completeDeferred.fireWith callbackContext, [ jqXHR, statusText ]
        if fireGlobals
          globalEventContext.trigger "ajaxComplete", [ jqXHR, s ]
          jQuery.event.trigger "ajaxStop"  unless --jQuery.active
      if typeof url is "object"
        options = url
        url = `undefined`
      options = options or {}
      s = jQuery.ajaxSetup({}, options)
      callbackContext = s.context or s
      globalEventContext = (if callbackContext isnt s and (callbackContext.nodeType or callbackContext instanceof jQuery) then jQuery(callbackContext) else jQuery.event)
      deferred = jQuery.Deferred()
      completeDeferred = jQuery.Callbacks("once memory")
      statusCode = s.statusCode or {}
      ifModifiedKey = undefined
      requestHeaders = {}
      requestHeadersNames = {}
      responseHeadersString = undefined
      responseHeaders = undefined
      transport = undefined
      timeoutTimer = undefined
      parts = undefined
      state = 0
      fireGlobals = undefined
      i = undefined
      jqXHR =
        readyState: 0
        setRequestHeader: (name, value) ->
          unless state
            lname = name.toLowerCase()
            name = requestHeadersNames[lname] = requestHeadersNames[lname] or name
            requestHeaders[name] = value
          this

        getAllResponseHeaders: ->
          (if state is 2 then responseHeadersString else null)

        getResponseHeader: (key) ->
          match = undefined
          if state is 2
            unless responseHeaders
              responseHeaders = {}
              responseHeaders[match[1].toLowerCase()] = match[2]  while (match = rheaders.exec(responseHeadersString))
            match = responseHeaders[key.toLowerCase()]
          (if match is `undefined` then null else match)

        overrideMimeType: (type) ->
          s.mimeType = type  unless state
          this

        abort: (statusText) ->
          statusText = statusText or "abort"
          transport.abort statusText  if transport
          done 0, statusText
          this

      deferred.promise jqXHR
      jqXHR.success = jqXHR.done
      jqXHR.error = jqXHR.fail
      jqXHR.complete = completeDeferred.add
      jqXHR.statusCode = (map) ->
        if map
          tmp = undefined
          if state < 2
            for tmp of map
              statusCode[tmp] = [ statusCode[tmp], map[tmp] ]
          else
            tmp = map[jqXHR.status]
            jqXHR.then tmp, tmp
        this

      s.url = ((url or s.url) + "").replace(rhash, "").replace(rprotocol, ajaxLocParts[1] + "//")
      s.dataTypes = jQuery.trim(s.dataType or "*").toLowerCase().split(rspacesAjax)
      unless s.crossDomain?
        parts = rurl.exec(s.url.toLowerCase())
        s.crossDomain = !!(parts and (parts[1] isnt ajaxLocParts[1] or parts[2] isnt ajaxLocParts[2] or (parts[3] or (if parts[1] is "http:" then 80 else 443)) isnt (ajaxLocParts[3] or (if ajaxLocParts[1] is "http:" then 80 else 443))))
      s.data = jQuery.param(s.data, s.traditional)  if s.data and s.processData and typeof s.data isnt "string"
      inspectPrefiltersOrTransports prefilters, s, options, jqXHR
      return false  if state is 2
      fireGlobals = s.global
      s.type = s.type.toUpperCase()
      s.hasContent = not rnoContent.test(s.type)
      jQuery.event.trigger "ajaxStart"  if fireGlobals and jQuery.active++ is 0
      unless s.hasContent
        if s.data
          s.url += (if rquery.test(s.url) then "&" else "?") + s.data
          delete s.data
        ifModifiedKey = s.url
        if s.cache is false
          ts = jQuery.now()
          ret = s.url.replace(rts, "$1_=" + ts)
          s.url = ret + (if (ret is s.url) then (if rquery.test(s.url) then "&" else "?") + "_=" + ts else "")
      jqXHR.setRequestHeader "Content-Type", s.contentType  if s.data and s.hasContent and s.contentType isnt false or options.contentType
      if s.ifModified
        ifModifiedKey = ifModifiedKey or s.url
        jqXHR.setRequestHeader "If-Modified-Since", jQuery.lastModified[ifModifiedKey]  if jQuery.lastModified[ifModifiedKey]
        jqXHR.setRequestHeader "If-None-Match", jQuery.etag[ifModifiedKey]  if jQuery.etag[ifModifiedKey]
      jqXHR.setRequestHeader "Accept", (if s.dataTypes[0] and s.accepts[s.dataTypes[0]] then s.accepts[s.dataTypes[0]] + (if s.dataTypes[0] isnt "*" then ", " + allTypes + "; q=0.01" else "") else s.accepts["*"])
      for i of s.headers
        jqXHR.setRequestHeader i, s.headers[i]
      if s.beforeSend and (s.beforeSend.call(callbackContext, jqXHR, s) is false or state is 2)
        jqXHR.abort()
        return false
      for i of
        success: 1
        error: 1
        complete: 1
        jqXHR[i] s[i]
      transport = inspectPrefiltersOrTransports(transports, s, options, jqXHR)
      unless transport
        done -1, "No Transport"
      else
        jqXHR.readyState = 1
        globalEventContext.trigger "ajaxSend", [ jqXHR, s ]  if fireGlobals
        if s.async and s.timeout > 0
          timeoutTimer = setTimeout(->
            jqXHR.abort "timeout"
          , s.timeout)
        try
          state = 1
          transport.send requestHeaders, done
        catch e
          if state < 2
            done -1, e
          else
            throw e
      jqXHR

    param: (a, traditional) ->
      s = []
      add = (key, value) ->
        value = (if jQuery.isFunction(value) then value() else value)
        s[s.length] = encodeURIComponent(key) + "=" + encodeURIComponent(value)

      traditional = jQuery.ajaxSettings.traditional  if traditional is `undefined`
      if jQuery.isArray(a) or (a.jquery and not jQuery.isPlainObject(a))
        jQuery.each a, ->
          add @name, @value
      else
        for prefix of a
          buildParams prefix, a[prefix], traditional, add
      s.join("&").replace r20, "+"

  jQuery.extend
    active: 0
    lastModified: {}
    etag: {}

  jsc = jQuery.now()
  jsre = /(\=)\?(&|$)|\?\?/i
  jQuery.ajaxSetup
    jsonp: "callback"
    jsonpCallback: ->
      jQuery.expando + "_" + (jsc++)

  jQuery.ajaxPrefilter "json jsonp", (s, originalSettings, jqXHR) ->
    inspectData = s.contentType is "application/x-www-form-urlencoded" and (typeof s.data is "string")
    if s.dataTypes[0] is "jsonp" or s.jsonp isnt false and (jsre.test(s.url) or inspectData and jsre.test(s.data))
      responseContainer = undefined
      jsonpCallback = s.jsonpCallback = (if jQuery.isFunction(s.jsonpCallback) then s.jsonpCallback() else s.jsonpCallback)
      previous = window[jsonpCallback]
      url = s.url
      data = s.data
      replace = "$1" + jsonpCallback + "$2"
      if s.jsonp isnt false
        url = url.replace(jsre, replace)
        if s.url is url
          data = data.replace(jsre, replace)  if inspectData
          url += (if /\?/.test(url) then "&" else "?") + s.jsonp + "=" + jsonpCallback  if s.data is data
      s.url = url
      s.data = data
      window[jsonpCallback] = (response) ->
        responseContainer = [ response ]

      jqXHR.always ->
        window[jsonpCallback] = previous
        window[jsonpCallback] responseContainer[0]  if responseContainer and jQuery.isFunction(previous)

      s.converters["script json"] = ->
        jQuery.error jsonpCallback + " was not called"  unless responseContainer
        responseContainer[0]

      s.dataTypes[0] = "json"
      "script"

  jQuery.ajaxSetup
    accepts:
      script: "text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"

    contents:
      script: /javascript|ecmascript/

    converters:
      "text script": (text) ->
        jQuery.globalEval text
        text

  jQuery.ajaxPrefilter "script", (s) ->
    s.cache = false  if s.cache is `undefined`
    if s.crossDomain
      s.type = "GET"
      s.global = false

  jQuery.ajaxTransport "script", (s) ->
    if s.crossDomain
      script = undefined
      head = document.head or document.getElementsByTagName("head")[0] or document.documentElement
      send: (_, callback) ->
        script = document.createElement("script")
        script.async = "async"
        script.charset = s.scriptCharset  if s.scriptCharset
        script.src = s.url
        script.onload = script.onreadystatechange = (_, isAbort) ->
          if isAbort or not script.readyState or /loaded|complete/.test(script.readyState)
            script.onload = script.onreadystatechange = null
            head.removeChild script  if head and script.parentNode
            script = `undefined`
            callback 200, "success"  unless isAbort

        head.insertBefore script, head.firstChild

      abort: ->
        script.onload 0, 1  if script

  xhrOnUnloadAbort = (if window.ActiveXObject then ->
    for key of xhrCallbacks
      xhrCallbacks[key] 0, 1
   else false)
  xhrId = 0
  xhrCallbacks = undefined
  jQuery.ajaxSettings.xhr = (if window.ActiveXObject then ->
    not @isLocal and createStandardXHR() or createActiveXHR()
   else createStandardXHR)
  ((xhr) ->
    jQuery.extend jQuery.support,
      ajax: !!xhr
      cors: !!xhr and ("withCredentials" of xhr)
  ) jQuery.ajaxSettings.xhr()
  if jQuery.support.ajax
    jQuery.ajaxTransport (s) ->
      if not s.crossDomain or jQuery.support.cors
        callback = undefined
        send: (headers, complete) ->
          xhr = s.xhr()
          handle = undefined
          i = undefined
          if s.username
            xhr.open s.type, s.url, s.async, s.username, s.password
          else
            xhr.open s.type, s.url, s.async
          if s.xhrFields
            for i of s.xhrFields
              xhr[i] = s.xhrFields[i]
          xhr.overrideMimeType s.mimeType  if s.mimeType and xhr.overrideMimeType
          headers["X-Requested-With"] = "XMLHttpRequest"  if not s.crossDomain and not headers["X-Requested-With"]
          try
            for i of headers
              xhr.setRequestHeader i, headers[i]
          xhr.send (s.hasContent and s.data) or null
          callback = (_, isAbort) ->
            status = undefined
            statusText = undefined
            responseHeaders = undefined
            responses = undefined
            xml = undefined
            try
              if callback and (isAbort or xhr.readyState is 4)
                callback = `undefined`
                if handle
                  xhr.onreadystatechange = jQuery.noop
                  delete xhrCallbacks[handle]  if xhrOnUnloadAbort
                if isAbort
                  xhr.abort()  if xhr.readyState isnt 4
                else
                  status = xhr.status
                  responseHeaders = xhr.getAllResponseHeaders()
                  responses = {}
                  xml = xhr.responseXML
                  responses.xml = xml  if xml and xml.documentElement
                  responses.text = xhr.responseText
                  try
                    statusText = xhr.statusText
                  catch e
                    statusText = ""
                  if not status and s.isLocal and not s.crossDomain
                    status = (if responses.text then 200 else 404)
                  else status = 204  if status is 1223
            catch firefoxAccessException
              complete -1, firefoxAccessException  unless isAbort
            complete status, statusText, responses, responseHeaders  if responses

          if not s.async or xhr.readyState is 4
            callback()
          else
            handle = ++xhrId
            if xhrOnUnloadAbort
              unless xhrCallbacks
                xhrCallbacks = {}
                jQuery(window).unload xhrOnUnloadAbort
              xhrCallbacks[handle] = callback
            xhr.onreadystatechange = callback

        abort: ->
          callback 0, 1  if callback
  elemdisplay = {}
  iframe = undefined
  iframeDoc = undefined
  rfxtypes = /^(?:toggle|show|hide)$/
  rfxnum = /^([+\-]=)?([\d+.\-]+)([a-z%]*)$/i
  timerId = undefined
  fxAttrs = [ [ "height", "marginTop", "marginBottom", "paddingTop", "paddingBottom" ], [ "width", "marginLeft", "marginRight", "paddingLeft", "paddingRight" ], [ "opacity" ] ]
  fxNow = undefined
  jQuery.fn.extend
    show: (speed, easing, callback) ->
      elem = undefined
      display = undefined
      if speed or speed is 0
        @animate genFx("show", 3), speed, easing, callback
      else
        i = 0
        j = @length

        while i < j
          elem = this[i]
          if elem.style
            display = elem.style.display
            display = elem.style.display = ""  if not jQuery._data(elem, "olddisplay") and display is "none"
            jQuery._data elem, "olddisplay", defaultDisplay(elem.nodeName)  if display is "" and jQuery.css(elem, "display") is "none"
          i++
        i = 0
        while i < j
          elem = this[i]
          if elem.style
            display = elem.style.display
            elem.style.display = jQuery._data(elem, "olddisplay") or ""  if display is "" or display is "none"
          i++
        this

    hide: (speed, easing, callback) ->
      if speed or speed is 0
        @animate genFx("hide", 3), speed, easing, callback
      else
        elem = undefined
        display = undefined
        i = 0
        j = @length
        while i < j
          elem = this[i]
          if elem.style
            display = jQuery.css(elem, "display")
            jQuery._data elem, "olddisplay", display  if display isnt "none" and not jQuery._data(elem, "olddisplay")
          i++
        i = 0
        while i < j
          this[i].style.display = "none"  if this[i].style
          i++
        this

    _toggle: jQuery.fn.toggle
    toggle: (fn, fn2, callback) ->
      bool = typeof fn is "boolean"
      if jQuery.isFunction(fn) and jQuery.isFunction(fn2)
        @_toggle.apply this, arguments
      else if not fn? or bool
        @each ->
          state = (if bool then fn else jQuery(this).is(":hidden"))
          jQuery(this)[(if state then "show" else "hide")]()
      else
        @animate genFx("toggle", 3), fn, fn2, callback
      this

    fadeTo: (speed, to, easing, callback) ->
      @filter(":hidden").css("opacity", 0).show().end().animate
        opacity: to
      , speed, easing, callback

    animate: (prop, speed, easing, callback) ->
      doAnimation = ->
        jQuery._mark this  if optall.queue is false
        opt = jQuery.extend({}, optall)
        isElement = @nodeType is 1
        hidden = isElement and jQuery(this).is(":hidden")
        name = undefined
        val = undefined
        p = undefined
        e = undefined
        parts = undefined
        start = undefined
        end = undefined
        unit = undefined
        method = undefined
        opt.animatedProperties = {}
        for p of prop
          name = jQuery.camelCase(p)
          if p isnt name
            prop[name] = prop[p]
            delete prop[p]
          val = prop[name]
          if jQuery.isArray(val)
            opt.animatedProperties[name] = val[1]
            val = prop[name] = val[0]
          else
            opt.animatedProperties[name] = opt.specialEasing and opt.specialEasing[name] or opt.easing or "swing"
          return opt.complete.call(this)  if val is "hide" and hidden or val is "show" and not hidden
          if isElement and (name is "height" or name is "width")
            opt.overflow = [ @style.overflow, @style.overflowX, @style.overflowY ]
            if jQuery.css(this, "display") is "inline" and jQuery.css(this, "float") is "none"
              if not jQuery.support.inlineBlockNeedsLayout or defaultDisplay(@nodeName) is "inline"
                @style.display = "inline-block"
              else
                @style.zoom = 1
        @style.overflow = "hidden"  if opt.overflow?
        for p of prop
          e = new jQuery.fx(this, opt, p)
          val = prop[p]
          if rfxtypes.test(val)
            method = jQuery._data(this, "toggle" + p) or (if val is "toggle" then (if hidden then "show" else "hide") else 0)
            if method
              jQuery._data this, "toggle" + p, (if method is "show" then "hide" else "show")
              e[method]()
            else
              e[val]()
          else
            parts = rfxnum.exec(val)
            start = e.cur()
            if parts
              end = parseFloat(parts[2])
              unit = parts[3] or (if jQuery.cssNumber[p] then "" else "px")
              if unit isnt "px"
                jQuery.style this, p, (end or 1) + unit
                start = (end or 1) / e.cur() * start
                jQuery.style this, p, start + unit
              end = ((if parts[1] is "-=" then -1 else 1) * end) + start  if parts[1]
              e.custom start, end, unit
            else
              e.custom start, val, ""
        true
      optall = jQuery.speed(speed, easing, callback)
      return @each(optall.complete, [ false ])  if jQuery.isEmptyObject(prop)
      prop = jQuery.extend({}, prop)
      (if optall.queue is false then @each(doAnimation) else @queue(optall.queue, doAnimation))

    stop: (type, clearQueue, gotoEnd) ->
      if typeof type isnt "string"
        gotoEnd = clearQueue
        clearQueue = type
        type = `undefined`
      @queue type or "fx", []  if clearQueue and type isnt false
      @each ->
        stopQueue = (elem, data, index) ->
          hooks = data[index]
          jQuery.removeData elem, index, true
          hooks.stop gotoEnd
        index = undefined
        hadTimers = false
        timers = jQuery.timers
        data = jQuery._data(this)
        jQuery._unmark true, this  unless gotoEnd
        unless type?
          for index of data
            stopQueue this, data, index  if data[index] and data[index].stop and index.indexOf(".run") is index.length - 4
        else stopQueue this, data, index  if data[index = type + ".run"] and data[index].stop
        index = timers.length
        while index--
          if timers[index].elem is this and (not type? or timers[index].queue is type)
            if gotoEnd
              timers[index] true
            else
              timers[index].saveState()
            hadTimers = true
            timers.splice index, 1
        jQuery.dequeue this, type  unless gotoEnd and hadTimers

  jQuery.each
    slideDown: genFx("show", 1)
    slideUp: genFx("hide", 1)
    slideToggle: genFx("toggle", 1)
    fadeIn:
      opacity: "show"

    fadeOut:
      opacity: "hide"

    fadeToggle:
      opacity: "toggle"
  , (name, props) ->
    jQuery.fn[name] = (speed, easing, callback) ->
      @animate props, speed, easing, callback

  jQuery.extend
    speed: (speed, easing, fn) ->
      opt = (if speed and typeof speed is "object" then jQuery.extend({}, speed) else
        complete: fn or not fn and easing or jQuery.isFunction(speed) and speed
        duration: speed
        easing: fn and easing or easing and not jQuery.isFunction(easing) and easing
      )
      opt.duration = (if jQuery.fx.off then 0 else (if typeof opt.duration is "number" then opt.duration else (if opt.duration of jQuery.fx.speeds then jQuery.fx.speeds[opt.duration] else jQuery.fx.speeds._default)))
      opt.queue = "fx"  if not opt.queue? or opt.queue is true
      opt.old = opt.complete
      opt.complete = (noUnmark) ->
        opt.old.call this  if jQuery.isFunction(opt.old)
        if opt.queue
          jQuery.dequeue this, opt.queue
        else jQuery._unmark this  if noUnmark isnt false

      opt

    easing:
      linear: (p, n, firstNum, diff) ->
        firstNum + diff * p

      swing: (p, n, firstNum, diff) ->
        ((-Math.cos(p * Math.PI) / 2) + 0.5) * diff + firstNum

    timers: []
    fx: (elem, options, prop) ->
      @options = options
      @elem = elem
      @prop = prop
      options.orig = options.orig or {}

  jQuery.fx:: =
    update: ->
      @options.step.call @elem, @now, this  if @options.step
      (jQuery.fx.step[@prop] or jQuery.fx.step._default) this

    cur: ->
      return @elem[@prop]  if @elem[@prop]? and (not @elem.style or not @elem.style[@prop]?)
      parsed = undefined
      r = jQuery.css(@elem, @prop)
      (if isNaN(parsed = parseFloat(r)) then (if not r or r is "auto" then 0 else r) else parsed)

    custom: (from, to, unit) ->
      t = (gotoEnd) ->
        self.step gotoEnd
      self = this
      fx = jQuery.fx
      @startTime = fxNow or createFxNow()
      @end = to
      @now = @start = from
      @pos = @state = 0
      @unit = unit or @unit or (if jQuery.cssNumber[@prop] then "" else "px")
      t.queue = @options.queue
      t.elem = @elem
      t.saveState = ->
        jQuery._data self.elem, "fxshow" + self.prop, self.start  if self.options.hide and jQuery._data(self.elem, "fxshow" + self.prop) is `undefined`

      timerId = setInterval(fx.tick, fx.interval)  if t() and jQuery.timers.push(t) and not timerId

    show: ->
      dataShow = jQuery._data(@elem, "fxshow" + @prop)
      @options.orig[@prop] = dataShow or jQuery.style(@elem, @prop)
      @options.show = true
      if dataShow isnt `undefined`
        @custom @cur(), dataShow
      else
        @custom (if @prop is "width" or @prop is "height" then 1 else 0), @cur()
      jQuery(@elem).show()

    hide: ->
      @options.orig[@prop] = jQuery._data(@elem, "fxshow" + @prop) or jQuery.style(@elem, @prop)
      @options.hide = true
      @custom @cur(), 0

    step: (gotoEnd) ->
      p = undefined
      n = undefined
      complete = undefined
      t = fxNow or createFxNow()
      done = true
      elem = @elem
      options = @options
      if gotoEnd or t >= options.duration + @startTime
        @now = @end
        @pos = @state = 1
        @update()
        options.animatedProperties[@prop] = true
        for p of options.animatedProperties
          done = false  if options.animatedProperties[p] isnt true
        if done
          if options.overflow? and not jQuery.support.shrinkWrapBlocks
            jQuery.each [ "", "X", "Y" ], (index, value) ->
              elem.style["overflow" + value] = options.overflow[index]
          jQuery(elem).hide()  if options.hide
          if options.hide or options.show
            for p of options.animatedProperties
              jQuery.style elem, p, options.orig[p]
              jQuery.removeData elem, "fxshow" + p, true
              jQuery.removeData elem, "toggle" + p, true
          complete = options.complete
          if complete
            options.complete = false
            complete.call elem
        return false
      else
        if options.duration is Infinity
          @now = t
        else
          n = t - @startTime
          @state = n / options.duration
          @pos = jQuery.easing[options.animatedProperties[@prop]](@state, n, 0, 1, options.duration)
          @now = @start + ((@end - @start) * @pos)
        @update()
      true

  jQuery.extend jQuery.fx,
    tick: ->
      timer = undefined
      timers = jQuery.timers
      i = 0
      while i < timers.length
        timer = timers[i]
        timers.splice i--, 1  if not timer() and timers[i] is timer
        i++
      jQuery.fx.stop()  unless timers.length

    interval: 13
    stop: ->
      clearInterval timerId
      timerId = null

    speeds:
      slow: 600
      fast: 200
      _default: 400

    step:
      opacity: (fx) ->
        jQuery.style fx.elem, "opacity", fx.now

      _default: (fx) ->
        if fx.elem.style and fx.elem.style[fx.prop]?
          fx.elem.style[fx.prop] = fx.now + fx.unit
        else
          fx.elem[fx.prop] = fx.now

  jQuery.each [ "width", "height" ], (i, prop) ->
    jQuery.fx.step[prop] = (fx) ->
      jQuery.style fx.elem, prop, Math.max(0, fx.now) + fx.unit

  if jQuery.expr and jQuery.expr.filters
    jQuery.expr.filters.animated = (elem) ->
      jQuery.grep(jQuery.timers, (fn) ->
        elem is fn.elem
      ).length
  rtable = /^t(?:able|d|h)$/i
  rroot = /^(?:body|html)$/i
  if "getBoundingClientRect" of document.documentElement
    jQuery.fn.offset = (options) ->
      elem = this[0]
      box = undefined
      if options
        return @each((i) ->
          jQuery.offset.setOffset this, options, i
        )
      return null  if not elem or not elem.ownerDocument
      return jQuery.offset.bodyOffset(elem)  if elem is elem.ownerDocument.body
      try
        box = elem.getBoundingClientRect()
      doc = elem.ownerDocument
      docElem = doc.documentElement
      if not box or not jQuery.contains(docElem, elem)
        return (if box then
          top: box.top
          left: box.left
         else
          top: 0
          left: 0
        )
      body = doc.body
      win = getWindow(doc)
      clientTop = docElem.clientTop or body.clientTop or 0
      clientLeft = docElem.clientLeft or body.clientLeft or 0
      scrollTop = win.pageYOffset or jQuery.support.boxModel and docElem.scrollTop or body.scrollTop
      scrollLeft = win.pageXOffset or jQuery.support.boxModel and docElem.scrollLeft or body.scrollLeft
      top = box.top + scrollTop - clientTop
      left = box.left + scrollLeft - clientLeft
      top: top
      left: left
  else
    jQuery.fn.offset = (options) ->
      elem = this[0]
      if options
        return @each((i) ->
          jQuery.offset.setOffset this, options, i
        )
      return null  if not elem or not elem.ownerDocument
      return jQuery.offset.bodyOffset(elem)  if elem is elem.ownerDocument.body
      computedStyle = undefined
      offsetParent = elem.offsetParent
      prevOffsetParent = elem
      doc = elem.ownerDocument
      docElem = doc.documentElement
      body = doc.body
      defaultView = doc.defaultView
      prevComputedStyle = (if defaultView then defaultView.getComputedStyle(elem, null) else elem.currentStyle)
      top = elem.offsetTop
      left = elem.offsetLeft
      while (elem = elem.parentNode) and elem isnt body and elem isnt docElem
        break  if jQuery.support.fixedPosition and prevComputedStyle.position is "fixed"
        computedStyle = (if defaultView then defaultView.getComputedStyle(elem, null) else elem.currentStyle)
        top -= elem.scrollTop
        left -= elem.scrollLeft
        if elem is offsetParent
          top += elem.offsetTop
          left += elem.offsetLeft
          if jQuery.support.doesNotAddBorder and not (jQuery.support.doesAddBorderForTableAndCells and rtable.test(elem.nodeName))
            top += parseFloat(computedStyle.borderTopWidth) or 0
            left += parseFloat(computedStyle.borderLeftWidth) or 0
          prevOffsetParent = offsetParent
          offsetParent = elem.offsetParent
        if jQuery.support.subtractsBorderForOverflowNotVisible and computedStyle.overflow isnt "visible"
          top += parseFloat(computedStyle.borderTopWidth) or 0
          left += parseFloat(computedStyle.borderLeftWidth) or 0
        prevComputedStyle = computedStyle
      if prevComputedStyle.position is "relative" or prevComputedStyle.position is "static"
        top += body.offsetTop
        left += body.offsetLeft
      if jQuery.support.fixedPosition and prevComputedStyle.position is "fixed"
        top += Math.max(docElem.scrollTop, body.scrollTop)
        left += Math.max(docElem.scrollLeft, body.scrollLeft)
      top: top
      left: left
  jQuery.offset =
    bodyOffset: (body) ->
      top = body.offsetTop
      left = body.offsetLeft
      if jQuery.support.doesNotIncludeMarginInBodyOffset
        top += parseFloat(jQuery.css(body, "marginTop")) or 0
        left += parseFloat(jQuery.css(body, "marginLeft")) or 0
      top: top
      left: left

    setOffset: (elem, options, i) ->
      position = jQuery.css(elem, "position")
      elem.style.position = "relative"  if position is "static"
      curElem = jQuery(elem)
      curOffset = curElem.offset()
      curCSSTop = jQuery.css(elem, "top")
      curCSSLeft = jQuery.css(elem, "left")
      calculatePosition = (position is "absolute" or position is "fixed") and jQuery.inArray("auto", [ curCSSTop, curCSSLeft ]) > -1
      props = {}
      curPosition = {}
      curTop = undefined
      curLeft = undefined
      if calculatePosition
        curPosition = curElem.position()
        curTop = curPosition.top
        curLeft = curPosition.left
      else
        curTop = parseFloat(curCSSTop) or 0
        curLeft = parseFloat(curCSSLeft) or 0
      options = options.call(elem, i, curOffset)  if jQuery.isFunction(options)
      props.top = (options.top - curOffset.top) + curTop  if options.top?
      props.left = (options.left - curOffset.left) + curLeft  if options.left?
      if "using" of options
        options.using.call elem, props
      else
        curElem.css props

  jQuery.fn.extend
    position: ->
      return null  unless this[0]
      elem = this[0]
      offsetParent = @offsetParent()
      offset = @offset()
      parentOffset = (if rroot.test(offsetParent[0].nodeName) then
        top: 0
        left: 0
       else offsetParent.offset())
      offset.top -= parseFloat(jQuery.css(elem, "marginTop")) or 0
      offset.left -= parseFloat(jQuery.css(elem, "marginLeft")) or 0
      parentOffset.top += parseFloat(jQuery.css(offsetParent[0], "borderTopWidth")) or 0
      parentOffset.left += parseFloat(jQuery.css(offsetParent[0], "borderLeftWidth")) or 0
      top: offset.top - parentOffset.top
      left: offset.left - parentOffset.left

    offsetParent: ->
      @map ->
        offsetParent = @offsetParent or document.body
        offsetParent = offsetParent.offsetParent  while offsetParent and (not rroot.test(offsetParent.nodeName) and jQuery.css(offsetParent, "position") is "static")
        offsetParent

  jQuery.each [ "Left", "Top" ], (i, name) ->
    method = "scroll" + name
    jQuery.fn[method] = (val) ->
      elem = undefined
      win = undefined
      if val is `undefined`
        elem = this[0]
        return null  unless elem
        win = getWindow(elem)
        return (if win then (if ("pageXOffset" of win) then win[(if i then "pageYOffset" else "pageXOffset")] else jQuery.support.boxModel and win.document.documentElement[method] or win.document.body[method]) else elem[method])
      @each ->
        win = getWindow(this)
        if win
          win.scrollTo (if not i then val else jQuery(win).scrollLeft()), (if i then val else jQuery(win).scrollTop())
        else
          this[method] = val

  jQuery.each [ "Height", "Width" ], (i, name) ->
    type = name.toLowerCase()
    jQuery.fn["inner" + name] = ->
      elem = this[0]
      (if elem then (if elem.style then parseFloat(jQuery.css(elem, type, "padding")) else this[type]()) else null)

    jQuery.fn["outer" + name] = (margin) ->
      elem = this[0]
      (if elem then (if elem.style then parseFloat(jQuery.css(elem, type, (if margin then "margin" else "border"))) else this[type]()) else null)

    jQuery.fn[type] = (size) ->
      elem = this[0]
      return (if not size? then null else this)  unless elem
      if jQuery.isFunction(size)
        return @each((i) ->
          self = jQuery(this)
          self[type] size.call(this, i, self[type]())
        )
      if jQuery.isWindow(elem)
        docElemProp = elem.document.documentElement["client" + name]
        body = elem.document.body
        elem.document.compatMode is "CSS1Compat" and docElemProp or body and body["client" + name] or docElemProp
      else if elem.nodeType is 9
        Math.max elem.documentElement["client" + name], elem.body["scroll" + name], elem.documentElement["scroll" + name], elem.body["offset" + name], elem.documentElement["offset" + name]
      else if size is `undefined`
        orig = jQuery.css(elem, type)
        ret = parseFloat(orig)
        (if jQuery.isNumeric(ret) then ret else orig)
      else
        @css type, (if typeof size is "string" then size else size + "px")

  window.jQuery = window.$ = jQuery
  if typeof define is "function" and define.amd and define.amd.jQuery
    define "jquery", [], ->
      jQuery
) window