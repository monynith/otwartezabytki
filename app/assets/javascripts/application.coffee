# TODO: move all vendor requires to files where they're actually used
#= require vendor/browser-update
#= require jquery
#= require jquery_ujs
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse
#= require jquery.ui.position
#= require jquery.ui.draggable
#= require jquery.ui.droppable
#= require jquery.ui.button
#= require jquery.ui.dialog
#= require jquery.ui.autocomplete
#= require jquery.ui.tabs
#= require jquery.ui.progressbar
#= require jquery.ui.sortable
#= require_tree ./vendor
#= require js-routes
#= require twitter/bootstrap/bootstrap-tooltip
#= require twitter/bootstrap/bootstrap-popover
#= require variables
#= require_tree ./libraries
#= require profile
#= require rails-timeago
#= require locales/jquery.timeago.pl.js
#= require_tree ./application

# FIX data-dismiss
$(document).on 'click', '[data-dismiss]', (e) ->
  e.preventDefault()
  el = $(this).attr('data-dismiss')
  $(".#{el}").slideUp()

# bootstrap-like popovers
jQuery.initializer '.main-container', ->
  this.find('a.js-popover').popover
    title: -> $("##{$(this).data("title-id")}").html()
    content: -> $("##{$(this).data("content-id")}").html()
    delay: 100000

  this.on "click", "a.close_popover", ->
    $("##{$(this).data('popover-id')}").popover('hide')
    false

  this.on "click", "a.js-popover", ->
    $(this).popover('toggle')
    false

jQuery ->
  opts =
    lines: 13, # The number of lines to draw
    length: 7, # The length of each line
    width: 4, # The line thickness
    radius: 10, # The radius of the inner circle
    corners: 1, # Corner roundness (0..1)
    rotate: 0, # The rotation offset
    color: '#fff', # #rgb or #rrggbb
    speed: 1, # Rounds per second
    trail: 60, # Afterglow percentage
    shadow: false, # Whether to render a shadow
    hwaccel: false, # Whether to use hardware acceleration
    className: 'spinner', # The CSS class to assign to the spinner
    zIndex: 2e9, # The z-index (defaults to 2000000000)
    top: 30, # Top position relative to parent in px
    left: 30 # Left position relative to parent in px

  target = document.getElementById('fancybox_loader');
  spinner = new Spinner(opts).spin(target);

  $('a.translation-mode').click (e) ->
    e.preventDefault()
    $el = $(this)
    if $el.hasClass('on')
      $el.removeClass('on')
      $('i18n').removeClass('on')
      $(document).off 'click', 'i18n'
    else
      $el.addClass('on')
      $('i18n').addClass('on')
      $(document).on 'click', 'i18n', (e) ->
        e.preventDefault()
        e.stopPropagation()
        $i18n = $(this)
        path = Routes.edit_translation_path({id: $i18n.data('key')})
        $.ajax(path, data: $i18n.data('options')).success(ajax_callback)

  $('select#lang').select2
    minimumResultsForSearch: 20
    width: '100px'

  $('select#lang').change (e) ->
    e.preventDefault()
    name = $(this).find('option:selected').attr('name')
    search = window.location.search
    window.location.search = if /\?/.test(search)
      if /locale/.test(search)
        search.replace(/locale=[a-z]{2}/, "locale=#{name}")
      else
        search += "&locale=#{name}"
    else
      "locale=#{name}"



