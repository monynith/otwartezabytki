$.ajaxSetup(dataType: 'html')

observed_selectors = {}



jQuery.initializer = (selector, callback) ->
  jQuery -> $(selector).each -> callback.call($(this))
  observed_selectors[selector] = [] if typeof observed_selectors[selector] == 'undefined'
  observed_selectors[selector].push(callback)

jQuery.fn.initialize = ->
  $.each observed_selectors, (selector, callbacks) =>
    this.each ->
      if $(this).is(selector)
        $.each callbacks, (_, callback) => callback.call($(this))

    $(this).find(selector).each ->
    $(this).find(selector).each ->
      $.each callbacks, (_, callback) => callback.call($(this))

popping_state = false
last_xhr = null
window.ajax_callback = (data, status, xhr) ->
  $('#fancybox_loader_container').hide()
  if xhr.getResponseHeader('Content-Type').match(/text\/javascript/)
    jQuery.globalEval data
  else if xhr.getResponseHeader('Content-Type').match(/text\/html/)
    last_xhr = xhr
    window.map = null # hack for location view...
    $parsed_data = $('<div>').append($(data))

    float_fancybox = last_xhr.getResponseHeader('x-float')?

    try # gon script hack
      jQuery.globalEval $parsed_data.find('script:contains(window.gon)').text()

    if last_xhr.getResponseHeader('x-csrf-token')?
      $('input[name=authenticity_token]').val(last_xhr.getResponseHeader('x-csrf-token'))
      $('meta[name="csrf-token"]').attr('content', last_xhr.getResponseHeader('x-csrf-token'))

    show_fancybox = (node) ->
      #node to jest to: <div data-replace=".main-container" class="container main-container in" style="display: block; padding-right: 0px;">
      window.before_fancybox_url = document.location.href

      $.fancybox $(node),
        padding: 3
        fitToView: float_fancybox
        fixed: float_fancybox
        scrolling: if float_fancybox then 'auto' else 'no'
        autoCenter: float_fancybox
        autoHeight: !float_fancybox
        afterShow: ->
          #$('#fancybox_loader_container').hide()
          $.fancybox.wrap.bind 'onReset', (e) ->
            $('body > .main-container:last').remove()
          $('.fancybox-overlay').height($(document).height())
        beforeClose: ->
          $form = $('.fancybox-wrap form:first')
          if serialized_data = $form.data('serialized')
            if serialized_data != $form.serialize()
              return confirm("Jeśli wyjdziesz zmiany nie zostaną zapisane. Kontynuować?")

          return true
        afterClose: ->
          # history.pushState { autoreload: true, path: window.before_fancybox_url }, $('title').text(), window.before_fancybox_url
          # if last_xhr.getResponseHeader('x-logged')? && $('body').data('logged')? && $('body').data('logged').toString() != last_xhr.getResponseHeader('x-logged').toString()
          #   window.location.href = window.location.pathname

          if $('#fancybox').length && !$('a.translation-mode.on').length
            $('#fancybox_loader_container').show()
            $.ajax(window.location.href).success(ajax_callback).complete(-> popping_state = false)
        afterLoad: ->
          if !float_fancybox && ($('.fancybox-wrap').position().top - 20) < $(window).scrollTop()
            $(window).scrollTop($('.fancybox-wrap').position().top - 20)

    try_to_process_replace = (node) ->
      # if node to replace is not found, redirect
      unless node?
        $('#fancybox_loader_container').show()
        window.location.href = xhr.getResponseHeader('x-path')
      data_replace_parent = $(node).parents('[data-replace]:first')[0]

      if xhr.getResponseHeader('x-fancybox')
        to_replace = $('.fancybox-wrap').find($(node).data('replace'))

        if to_replace.length
          to_replace.replaceWith(node)
          $(node).initialize()
          $.fancybox.trigger('afterLoad')
          $.fancybox.update()
          $('.fancybox-overlay').height($(document).height())
        else
          if data_replace_parent && !$(node).is('[data-fancybox]')
            try_to_process_replace(data_replace_parent)
          else

            if !(((data.indexOf("oz-edit-relic")) > -1 ) || ((data.indexOf("edit-relic")) > -1))
#            if data.find('.jcarousel-skin-midi')
              show_fancybox(node)
              $(node).initialize()
            else
              relic_modal = $('#edit-relic-modal') #get div of modal
              relic_modal_body = relic_modal.find('.modal-body') #get boy of modal
              relic_modal_body.html(node) #put content in modal body
              relic_modal.modal() #show modal

              set_modal = $('.js-set-static-modal-width').css('content') #add static with for nonresponsive, remove it for location and photos
              if set_modal == undefined
                relic_modal.removeClass 'static-modal-width'
              else
                relic_modal.addClass 'static-modal-width'
              relic_modal.initialize() #initialize JQuery.initialize() functions
      else if last_xhr.getResponseHeader('x-logged')? && $('body').data('logged')? && $('body').data('logged').toString() != last_xhr.getResponseHeader('x-logged').toString()
        $('#fancybox_loader_container').show()
        window.location.reload()
      else
        to_replace = $('#root').find($(node).data('replace'))

        if to_replace.length
          to_replace.replaceWith(node)
          $.fancybox.close() if $.fancybox
          $(node).initialize()

          unless popping_state
            path = xhr.getResponseHeader('x-path')
            history.pushState { autoreload: true, path: path }, $parsed_data.find('title').text(), xhr.getResponseHeader('x-path')
        else
          try_to_process_replace(data_replace_parent)

    if $parsed_data.find('[data-replace]').length
      $parsed_data.find('[data-replace]').each ->
        unless $(this).find('[data-replace]').length
          try_to_process_replace(this)
    else
      $('#fancybox_loader_container').show()
      window.location.href = xhr.getResponseHeader('x-path')

jQuery.initializer "form[data-ajax-form]", ->
  $form = $(this)
  $form.ajaxForm
    beforeSubmit: (obj...) -> $form.trigger('ajax:beforeSend', obj)
    success:      (obj...) -> $form.trigger('ajax:success', obj)
    error:        (obj...) -> $form.trigger('ajax:error', obj)

$(document).on 'ajax:beforeSend', 'form[data-ajax-form], form[data-remote], a[data-remote]', ->
  $('#fancybox_loader_container').show() unless window.location.pathname.match(/^(\/[a-z]{2})?\/relics/)

$(document).on 'ajax:success', 'form[data-ajax-form], form[data-remote], a[data-remote]', (e, data, status, xhr) ->
  $('#fancybox_loader_container').hide()
  popping_state = false
  ajax_callback.call(this, data, status, xhr)
  e.stopPropagation()

$(document).on 'ajax:error', 'form[data-ajax-form], form[data-remote], a[data-remote]', (e, xhr, status, error) ->
  popping_state = false
  if error == "Unauthorized"
    window.location.href = Routes.new_user_session_path()
  else
    $('#fancybox_loader_container').hide()

  e.stopPropagation()

$(window).load ->
  setTimeout ->
    $(window).bind 'popstate', (event) ->
      state = event.originalEvent.state
      popping_state = true
      if state && state.autoreload
        $.ajax(state.path).success(ajax_callback).complete(-> popping_state = false)
      else
        $.ajax(document.location).success(ajax_callback).complete(-> popping_state = false)

    if window.location.hash.slice(1).match(/^\//)
      $("a[href$='#{window.location.hash.slice(1)}']").click()
  , 500
