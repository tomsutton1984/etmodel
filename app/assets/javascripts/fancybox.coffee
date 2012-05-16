$ ->
  $.fancybox.defaults.helpers.overlay.opacity = 0.4
  
  $(".valuees a.label, a.fancybox").live 'click', (e) ->
    e.preventDefault()
    $.fancybox.open
      type: 'ajax'
      href: $(this).attr('href')
      autoSize: true

  $("a.tutorial_button").live 'click', (e) ->
    e.preventDefault()
    $.fancybox.open
      type: 'ajax'
      href: $(this).attr('href')
      width    : 940
      padding  : 0
      opacity: false
      scrolling: 'no'

  $("a.select_chart").live 'click', (e) ->
    e.preventDefault()
    $.fancybox.open
      href: $(this).attr('href')
      type: 'ajax'
      width    : 960
      height   : 600
      padding: 0

  $("a.prediction").live 'click', (e) ->
    e.preventDefault()
    $.fancybox.open
      href: $(this).attr('href')
      width    : 960
      height   : 650
      padding  : 0
      type     : 'iframe'

  $('#overlay_container a').live 'click', (i,el) ->
    if !$(this).hasClass('no_target')
      window.open($(this).attr('href'), '_blank')
    return null

window.close_fancybox = ->
  $.fancybox.close()
