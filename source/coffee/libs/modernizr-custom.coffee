window.Modernizr = (a, b, c) ->
  C = (a) ->
    j.cssText = a
  D = (a, b) ->
    C n.join(a + ";") + (b or "")
  E = (a, b) ->
    typeof a is b
  F = (a, b) ->
    !!~("" + a).indexOf(b)
  G = (a, b) ->
    for d of a
      return (if b is "pfx" then a[d] else not 0)  if j[a[d]] isnt c
    not 1
  H = (a, b, d) ->
    for e of a
      f = b[a[e]]
      return (if d is not 1 then a[e] else (if E(f, "function") then f.bind(d or b) else f))  if f isnt c
    not 1
  I = (a, b, c) ->
    d = a.charAt(0).toUpperCase() + a.substr(1)
    e = (a + " " + p.join(d + " ") + d).split(" ")
    (if E(b, "string") or E(b, "undefined") then G(e, b) else (e = (a + " " + q.join(d + " ") + d).split(" ")
    H(e, b, c)
    ))
  K = ->
    e.input = (c) ->
      d = 0
      e = c.length

      while d < e
        t[c[d]] = c[d] of k
        d++
      t.list and (t.list = !!b.createElement("datalist") and !!a.HTMLDataListElement)
      t
    ("autocomplete autofocus list placeholder max min multiple pattern required step".split(" "))
    e.inputtypes = (a) ->
      d = 0
      e = undefined
      f = undefined
      h = undefined
      i = a.length

      while d < i
        k.setAttribute("type", f = a[d])
        e = k.type isnt "text"
        e and (k.value = l
        k.style.cssText = "position:absolute;visibility:hidden;"
        (if /^range$/.test(f) and k.style.WebkitAppearance isnt c then (g.appendChild(k)
        h = b.defaultView
        e = h.getComputedStyle and h.getComputedStyle(k, null).WebkitAppearance isnt "textfield" and k.offsetHeight isnt 0
        g.removeChild(k)
        ) else /^(search|tel)$/.test(f) or (if /^(url|email)$/.test(f) then e = k.checkValidity and k.checkValidity() is not 1 else (if /^color$/.test(f) then (g.appendChild(k)
        g.offsetWidth
        e = k.value isnt l
        g.removeChild(k)
        ) else e = k.value isnt l)))
        )
        s[a[d]] = !!e
        d++
      s
    ("search tel url email datetime date month week time datetime-local number range color".split(" "))
  d = "2.5.2"
  e = {}
  f = not 0
  g = b.documentElement
  h = "modernizr"
  i = b.createElement(h)
  j = i.style
  k = b.createElement("input")
  l = ":)"
  m = {}.toString
  n = " -webkit- -moz- -o- -ms- ".split(" ")
  o = "Webkit Moz O ms"
  p = o.split(" ")
  q = o.toLowerCase().split(" ")
  r = {}
  s = {}
  t = {}
  u = []
  v = u.slice
  w = undefined
  x = (a, c, d, e) ->
    f = undefined
    i = undefined
    j = undefined
    k = b.createElement("div")
    l = b.body
    m = (if l then l else b.createElement("body"))
    if parseInt(d, 10)
      while d--
        j = b.createElement("div")
        j.id = (if e then e[d] else h + (d + 1))
        k.appendChild(j)
    f = [ "&#173;", "<style>", a, "</style>" ].join("")
    k.id = h
    m.innerHTML += f
    m.appendChild(k)
    l or g.appendChild(m)
    i = c(k, a)
    (if l then k.parentNode.removeChild(k) else m.parentNode.removeChild(m))
    !!i

  y = (b) ->
    c = a.matchMedia or a.msMatchMedia
    return c(b).matches  if c
    d = undefined
    x("@media " + b + " { #" + h + " { position: absolute; } }", (b) ->
      d = (if a.getComputedStyle then getComputedStyle(b, null) else b.currentStyle)["position"] is "absolute"
    )
    d

  z = ->
    d = (d, e) ->
      e = e or b.createElement(a[d] or "div")
      d = "on" + d

      f = d of e
      f or (e.setAttribute or (e = b.createElement("div"))
      e.setAttribute and e.removeAttribute and (e.setAttribute(d, "")
      f = E(e[d], "function")
      E(e[d], "undefined") or (e[d] = c)
      e.removeAttribute(d)
      )
      )
      e = null
      f
    a =
      select: "input"
      change: "input"
      submit: "form"
      reset: "form"
      error: "img"
      load: "img"
      abort: "img"

    d
  ()
  A = {}.hasOwnProperty
  B = undefined
  (if not E(A, "undefined") and not E(A.call, "undefined") then B = (a, b) ->
    A.call a, b
   else B = (a, b) ->
    b of a and E(a.constructor::[b], "undefined")
  )
  Function::bind or (Function::bind = (b) ->
    c = this
    throw new TypeError  unless typeof c is "function"
    d = v.call(arguments, 1)
    e = ->
      if this instanceof e
        a = ->

        a:: = c::
        f = new a
        g = c.apply(f, d.concat(v.call(arguments)))
        return (if Object(g) is g then g else f)
      c.apply b, d.concat(v.call(arguments))

    e
  )

  J = (a, c) ->
    d = a.join("")
    f = c.length
    x d, ((a, c) ->
      d = b.styleSheets[b.styleSheets.length - 1]
      g = (if d then (if d.cssRules and d.cssRules[0] then d.cssRules[0].cssText else d.cssText or "") else "")
      h = a.childNodes
      i = {}
      i[h[f].id] = h[f]  while f--
      e.generatedcontent = (i.generatedcontent and i.generatedcontent.offsetHeight) >= 1
      e.fontface = /src/i.test(g) and g.indexOf(c.split(" ")[0]) is 0
    ), f, c
  ([ "@font-face {font-family:\"font\";src:url(\"https://\")}", [ "#generatedcontent:after{content:\"", l, "\";visibility:hidden}" ].join("") ], [ "fontface", "generatedcontent" ])
  r.hashchange = ->
    z("hashchange", a) and (b.documentMode is c or b.documentMode > 7)

  r.rgba = ->
    C("background-color:rgba(150,255,150,.5)")
    F(j.backgroundColor, "rgba")

  r.borderradius = ->
    I "borderRadius"

  r.boxshadow = ->
    I "boxShadow"

  r.textshadow = ->
    b.createElement("div").style.textShadow is ""

  r.opacity = ->
    D("opacity:.55")
    /^0.55$/.test(j.opacity)

  r.cssanimations = ->
    I "animationName"

  r.cssgradients = ->
    a = "background-image:"
    b = "gradient(linear,left top,right bottom,from(#9f9),to(white));"
    c = "linear-gradient(left top,#9f9, white);"
    C((a + "-webkit- ".split(" ").join(b + a) + n.join(c + a)).slice(0, -a.length))
    F(j.backgroundImage, "gradient")

  r.csstransforms = ->
    !!I("transform")

  r.csstransitions = ->
    I "transition"

  r.fontface = ->
    e.fontface

  r.generatedcontent = ->
    e.generatedcontent


  for L of r
    B(r, L) and (w = L.toLowerCase()
    e[w] = r[L]()
    u.push((if e[w] then "" else "no-") + w)
    )
  e.input or K()
  C("")
  i = k = null
  (a, b) ->
    g = (a, b) ->
      c = a.createElement("p")
      d = a.getElementsByTagName("head")[0] or a.documentElement
      c.innerHTML = "x<style>" + b + "</style>"
      d.insertBefore(c.lastChild, d.firstChild)
    h = ->
      a = k.elements
      (if typeof a is "string" then a.split(" ") else a)
    i = (a) ->
      m = ->
        a = j.cloneNode(not 1)
        (if k.shivMethods then (i(a)
        a
        ) else a)
      n = (a) ->
        b = (c[a] or (c[a] = e(a))).cloneNode(not 1)
        (if k.shivMethods and not d.test(a) then j.appendChild(b) else b)
      b = undefined
      c = {}
      e = a.createElement
      f = a.createDocumentFragment
      g = h()
      j = f()
      l = g.length
      while l--
        b = g[l]
        c[b] = e(b)
        j.createElement(b)
      a.createElement = n
      a.createDocumentFragment = m
    j = (a) ->
      b = undefined
      (if a.documentShived then a else (k.shivCSS and not e and (b = !!g(a, "article,aside,details,figcaption,figure,footer,header,hgroup,nav,section{display:block}audio{display:none}canvas,video{display:inline-block;*display:inline;*zoom:1}[hidden]{display:none}audio[controls]{display:inline-block;*display:inline;*zoom:1}mark{background:#FF0;color:#000}"))
      k.shivMethods and not f and (b = not i(a))
      b and (a.documentShived = b)
      a
      ))
    c = a.html5 or {}
    d = /^<|^(?:button|iframe|input|script|textarea)$/i
    e = undefined
    f = undefined
    (->
      c = undefined
      d = b.createElement("a")
      g = a.getComputedStyle
      h = b.documentElement
      i = b.body or (c = h.insertBefore(b.createElement("body"), h.firstChild))
      i.insertBefore(d, i.firstChild)
      d.hidden = not 0
      d.innerHTML = "<xyz></xyz>"
      e = (d.currentStyle or g(d, null)).display is "none"
      f = d.childNodes.length is 1 or ->
        try
          b.createElement "a"
        catch a
          return not 0
        c = b.createDocumentFragment()
        typeof c.cloneNode is "undefined" or typeof c.createDocumentFragment is "undefined" or typeof c.createElement is "undefined"
      ()
      i.removeChild(d)
      c and h.removeChild(c)
    )()
    k =
      elements: c.elements or "abbr article aside audio bdi canvas data datalist details figcaption figure footer header hgroup mark meter nav output progress section summary time video".split(" ")
      shivCSS: c.shivCSS isnt not 1
      shivMethods: c.shivMethods isnt not 1
      type: "default"
      shivDocument: j

    a.html5 = k
    j(b)
  (this, b)
  e._version = d
  e._prefixes = n
  e._domPrefixes = q
  e._cssomPrefixes = p
  e.mq = y
  e.hasEvent = z
  e.testProp = (a) ->
    G [ a ]

  e.testAllProps = I
  e.testStyles = x
  g.className = g.className.replace(/(^|\s)no-js(\s|$)/, "$1$2") + (if f then " js " + u.join(" ") else "")
  e
(this, @document)
(a, b, c) ->
  d = (a) ->
    o.call(a) is "[object Function]"
  e = (a) ->
    typeof a is "string"
  f = ->
  g = (a) ->
    not a or a is "loaded" or a is "complete" or a is "uninitialized"
  h = ->
    a = p.shift()
    q = 1
    (if a then (if a.t then m(->
      (if a.t is "c" then B.injectCss else B.injectJs) a.s, 0, a.a, a.x, a.e, 1
    , 0) else (a()
    h()
    )) else q = 0)
  i = (a, c, d, e, f, i, j) ->
    k = (b) ->
      if not o and g(l.readyState) and (u.r = o = 1
      not q and h()
      l.onload = l.onreadystatechange = null
      b
      )
        a isnt "img" and m(->
          t.removeChild l
        , 50)
        for d of y[c]
          y[c].hasOwnProperty(d) and y[c][d].onload()
    j = j or B.errorTimeout
    l = {}
    o = 0
    r = 0
    u =
      t: d
      s: c
      e: f
      a: i
      x: j

    y[c] is 1 and (r = 1
    y[c] = []
    l = b.createElement(a)
    )
    (if a is "object" then l.data = c else (l.src = c
    l.type = a
    ))
    l.width = l.height = "0"
    l.onerror = l.onload = l.onreadystatechange = ->
      k.call this, r

    p.splice(e, 0, u)
    a isnt "img" and (if r or y[c] is 2 then (t.insertBefore(l, (if s then null else n))
    m(k, j)
    ) else y[c].push(l))
  j = (a, b, c, d, f) ->
    q = 0
    b = b or "j"
    (if e(a) then i((if b is "c" then v else u), a, b, @i++, c, d, f) else (p.splice(@i++, 0, a)
    p.length is 1 and h()
    ))
    this
  k = ->
    a = B
    a.loader =
      load: j
      i: 0

    a
  l = b.documentElement
  m = a.setTimeout
  n = b.getElementsByTagName("script")[0]
  o = {}.toString
  p = []
  q = 0
  r = "MozAppearance" of l.style
  s = r and !!b.createRange().compareNode
  t = (if s then l else n.parentNode)
  l = !!b.attachEvent
  u = (if r then "object" else (if l then "script" else "img"))
  v = (if l then "script" else u)
  w = Array.isArray or (a) ->
    o.call(a) is "[object Array]"

  x = []
  y = {}
  z = timeout: (a, b) ->
    b.length and (a.timeout = b[0])
    a

  A = undefined
  B = undefined
  B = (a) ->
    b = (a) ->
      a = a.split("!")
      b = x.length
      c = a.pop()
      d = a.length
      c =
        url: c
        origUrl: c
        prefixes: a

      e = undefined
      f = undefined
      g = undefined
      f = 0
      while f < d
        g = a[f].split("=")
        (e = z[g.shift()]) and (c = e(c, g))
        f++
      f = 0
      while f < b
        c = x[f](c)
        f++
      c
    g = (a, e, f, g, i) ->
      j = b(a)
      l = j.autoCallback
      j.url.split(".").pop().split("?").shift()
      j.bypass or (e and (e = (if d(e) then e else e[a] or e[g] or e[a.split("/").pop().split("?")[0]] or h))
      (if j.instead then j.instead(a, e, f, g, i) else ((if y[j.url] then j.noexec = not 0 else y[j.url] = 1)
      f.load(j.url, (if j.forceCSS or not j.forceJS and "css" is j.url.split(".").pop().split("?").shift() then "c" else c), j.noexec, j.attrs, j.timeout)
      (d(e) or d(l)) and f.load(->
        k()
        e and e(j.origUrl, i, g)
        l and l(j.origUrl, i, g)
        y[j.url] = 2
      )
      ))
      )
    i = (a, b) ->
      c = (a, c) ->
        if a
          if e(a)
            c or (j = ->
              a = [].slice.call(arguments)
              k.apply(this, a)
              l()
            )
            g(a, j, b, 0, h)
          else if Object(a) is a
            for n of m = ->
              b = 0
              c = undefined
              for c of a
                a.hasOwnProperty(c) and b++
              b
            ()
            a
              a.hasOwnProperty(n) and (not c and not --m and (if d(j) then j = ->
                a = [].slice.call(arguments)
                k.apply(this, a)
                l()
               else j[n] = (a) ->
                ->
                  b = [].slice.call(arguments)
                  a and a.apply(this, b)
                  l()
              (k[n]))
              g(a[n], j, b, n, h)
              )
        else
          not c and l()
      h = !!a.test
      i = a.load or a.both
      j = a.callback or f
      k = j
      l = a.complete or f
      m = undefined
      n = undefined
      c((if h then a.yep else a.nope), !!i)
      i and c(i)
    j = undefined
    l = undefined
    m = @yepnope.loader
    if e(a)
      g a, 0, m, 0
    else if w(a)
      j = 0
      while j < a.length
        l = a[j]
        (if e(l) then g(l, 0, m, 0) else (if w(l) then B(l) else Object(l) is l and i(l, m)))
        j++
    else
      Object(a) is a and i(a, m)

  B.addPrefix = (a, b) ->
    z[a] = b

  B.addFilter = (a) ->
    x.push a

  B.errorTimeout = 1e4
  not b.readyState? and b.addEventListener and (b.readyState = "loading"
  b.addEventListener("DOMContentLoaded", A = ->
    b.removeEventListener("DOMContentLoaded", A, 0)
    b.readyState = "complete"
  , 0)
  )
  a.yepnope = k()
  a.yepnope.executeStack = h
  a.yepnope.injectJs = (a, c, d, e, i, j) ->
    k = b.createElement("script")
    l = undefined
    o = undefined
    e = e or B.errorTimeout
    k.src = a
    for o of d
      k.setAttribute o, d[o]
    c = (if j then h else c or f)
    k.onreadystatechange = k.onload = ->
      not l and g(k.readyState) and (l = 1
      c()
      k.onload = k.onreadystatechange = null
      )

    m(->
      l or (l = 1
      c(1)
      )
    , e)
    (if i then k.onload() else n.parentNode.insertBefore(k, n))

  a.yepnope.injectCss = (a, c, d, e, g, i) ->
    e = b.createElement("link")
    j = undefined
    c = (if i then h else c or f)
    e.href = a
    e.rel = "stylesheet"
    e.type = "text/css"

    for j of d
      e.setAttribute j, d[j]
    g or (n.parentNode.insertBefore(e, n)
    m(c, 0)
    )
(this, document)
Modernizr.load = ->
  yepnope.apply window, [].slice.call(arguments, 0)