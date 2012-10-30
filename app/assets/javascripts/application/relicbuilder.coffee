jQuery('body.relicbuilders textarea.redactor').redactor
  focus: false
  buttons: ['bold', 'italic', 'link', 'unorderedlist']
  lang: 'pl'

jQuery.initializer 'div.administrative-level', ->
  self = this
  this.find("#relic_voivodeship_id").select2
    minimumResultsForSearch: 20
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'

  this.find("#relic_district_id").select2
    minimumResultsForSearch: 50
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'

  this.find("#relic_commune_id").select2
    minimumResultsForSearch: 50
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '175px'

  this.find("#relic_place_id").select2
    minimumResultsForSearch: 20
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '555px'

  this.on 'change', 'select', (e) ->
    params = "#{$(this).attr('name')}=#{$(this).find('option:selected').val()}"
    unless params.match(/place_id/)
      $.get '/relicbuilder/administrative_level', params, (data, status, xhr) ->
        self.replaceWith(data)
        $('div.administrative-level').initialize()

jQuery.initializer 'div.new_relic section.main', ->
  this.on 'click', 'div.places-wrapper ul li a', (e) ->
    e.preventDefault()
    $('form.relic .actions').hide()
    $('#relic_place_id').val $(this).data('place_id')
    lat = $(this).data('coordinates').split(',')[0]
    lng = $(this).data('coordinates').split(',')[1]

    $('#map_canvas').zoom_at(lat, lng)
    map.removeMarkers()
    $('#map_canvas').circle_marker(lat, lng)


  $("#location_country_code, #relic_country_code").select2
    minimumResultsForSearch: 250
    dropdownCssClass: 'search-order-dropdown'
    containerCssClass: 'search-order-container'
    width: '170px'

  $('#location_foreign_relic').change ->
    if $(this).is(':checked')
      $('.polish-location').hide()
      $('.foreign-location').show()
    else
      $('.foreign-location').hide()
      $('.polish-location').show()

  window.ensuring_google_maps_loaded ->
    do window.ensure_geolocation
    $('#marker').draggable
      revert: true

    $('#map_canvas').droppable
      drop: (event, ui) ->

        x_offset = (ui.offset.left - $(this).offset().left + 39)
        y_offset = (ui.offset.top - $(this).offset().top + 55)

        lng = map.map.getBounds().getSouthWest().lng()
        lat = map.map.getBounds().getNorthEast().lat()
        width = map.map.getBounds().getNorthEast().lng() - map.map.getBounds().getSouthWest().lng()
        height = map.map.getBounds().getSouthWest().lat() - map.map.getBounds().getNorthEast().lat()
        marker_lat = lat + height * y_offset / $(this).height()
        marker_lng = lng + width * x_offset / $(this).width()
        $('#map_canvas').set_marker(marker_lat, marker_lng)
        $('form.relic .actions').show()

    $('#map_canvas').auto_zoom()
    $('#map_canvas').blinking()