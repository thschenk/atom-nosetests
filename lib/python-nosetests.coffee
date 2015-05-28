PythonNosetestsView = require './python-nosetests-view'
{CompositeDisposable} = require 'atom'

module.exports = PythonNosetests =
  view: null
  panel: null
  subscriptions: null
  active: false

  activate: () ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:toggle': => @toggle()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @view.destroy()

  setErrorPane: (error) ->
    alert(error.message)

  toggle: ->

    if @active
      @view.destroy()
      @panel.hide()
      @active = false

    else
      @active = true

      @view = new PythonNosetestsView(@setErrorPane)
      @view.load('/home/thijs/Projects/Python/mediaserver/nosetests.json')
      @panel = atom.workspace.addRightPanel(item: @view.getElement())
      @panel.show()
