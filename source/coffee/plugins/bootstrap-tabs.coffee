not ($) ->
  "use strict"
  Tab = (element) ->
    @element = $(element)

  Tab:: =
    constructor: Tab
    show: ->
      $this = @element
      $ul = $this.closest("ul:not(.dropdown-menu)")
      selector = $this.attr("data-target")
      previous = undefined
      $target = undefined
      unless selector
        selector = $this.attr("href")
        selector = selector and selector.replace(/.*(?=#[^\s]*$)/, "")
      return previous = $ul.find(".active a").last()[0]  if $this.parent("li").hasClass("active")
      $this.trigger
        type: "show"
        relatedTarget: previous

      $target = $(selector)
      @activate $this.parent("li"), $ul
      @activate $target, $target.parent(), ->
        $this.trigger
          type: "shown"
          relatedTarget: previous

    activate: (element, container, callback) ->
      next = ->
        $active.removeClass("active").find("> .dropdown-menu > .active").removeClass "active"
        element.addClass "active"
        if transition
          element[0].offsetWidth
          element.addClass "in"
        else
          element.removeClass "fade"
        element.closest("li.dropdown").addClass "active"  if element.parent(".dropdown-menu")
        callback and callback()
      $active = container.find("> .active")
      transition = callback and $.support.transition and $active.hasClass("fade")
      (if transition then $active.one($.support.transition.end, next) else next())
      $active.removeClass "in"

  $.fn.tab = (option) ->
    @each ->
      $this = $(this)
      data = $this.data("tab")
      $this.data "tab", (data = new Tab(this))  unless data
      data[option]()  if typeof option is "string"

  $.fn.tab.Constructor = Tab
  $ ->
    $("body").on "click.tab.data-api", "[data-toggle=\"tab\"], [data-toggle=\"pill\"]", (e) ->
      e.preventDefault()
      $(this).tab "show"
(window.jQuery)