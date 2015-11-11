{View} = require 'space-pen'

ResizablePanel = require './resizablepanel'
SplitView = require './splitview'
ListView = require './listview'
ErrorView = require './errorview'

module.exports =
class PythonNosetestsView extends View

  @content: ->
    @div class: 'python-nosetests', =>
      @div class: 'resizable-panel-handle'
      @div class: 'mainview', =>
        @subview 'headerview', new HeaderView()
        @subview 'listview', new ListView()
        @div class: 'bar'
        @subview 'errorview', new ErrorView()

  initialize: ->

    new ResizablePanel(@find('.resizable-panel-handle'))
    @splitview = new SplitView(@find('.bar'))


    @listview.setOnSelect (test) =>
      if 'error' of test
        @errorview.load(test.error)
        @splitview.setRatio()
      else
        @splitview.full_a()

  constructor:  ->
    super

  mute: ->
    @find('.mainview').addClass('muted')

  unmute: ->
    @find('.mainview').removeClass('muted')

  load: (data) ->

    if not data.syntaxerrors?
      msg = 'Warning: not using latest nose plugin. Please install using:\npip install nosetests_json_extended --upgrade'
      @headerview.setWarning(msg)
    else
      @headerview.clearWarning()

    @listview.load(data)
    @errorview.clear()
    @splitview.full_a()
    @unmute()


class HeaderView extends View
  @content: ->
    @div class: 'header', =>
      @div class: 'title', =>
        @text 'Python Nosetests'
      @div class: 'warning hidden', =>
        @text ''

  setWarning: (message) ->
    warning = @find('.warning')
    warning.removeClass('hidden')
    warning.text(message)

  clearWarning: (message) ->
    warning = @find('.warning')
    warning.addClass('hidden')
    warning.text('')
