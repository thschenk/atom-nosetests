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


    @listview.setOnClickError (error) =>
      @errorview.load(error)
      @splitview.setRatio()

  constructor:  ->
    super

  load: (data) ->
    @listview.load(data)
    @errorview.clear()
    @splitview.full_a()

    #@fixLastHeight()



class HeaderView extends View
  @content: ->
    @div class: 'header', =>
      @text 'Python Nosetests'
