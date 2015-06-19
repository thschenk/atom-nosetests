url = require 'url'
{CompositeDisposable} = require 'atom'
PythonNosetestsView = require './view'

Runner = require './runner'

module.exports = PythonNosetests =
  view: null
  panel: null
  subscriptions: null

  activate: () ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:hide': => @hide()

  deactivate: () ->
    @subscriptions.dispose()
    @view.destroy()
    @panel.destroy()

  run: () ->

    if @view
      @view.mute()

    Runner.run {
      success: (data) =>
        if not @view
          @view = new PythonNosetestsView()

        if not @panel
          @panel = atom.workspace.addRightPanel item: @view, visible: false

        @panel.show()
        @view.load(data)



      error: (message) =>
       atom.notifications.addWarning message, dismissable: true

       if @view
         @view.unmute()
     }


  hide: () ->
    @panel.hide()

  config:
    colorfullBadges:
      title: 'Colorfull Badges'
      description: 'If enabled, the background color of the badges indicating the number of succeeded, failed and error test cases will be colorfull.'
      type: 'boolean'
      default: false
