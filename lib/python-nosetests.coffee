PythonNosetestsListView = require './python-nosetests-listview'
PythonNosetestsErrorView = require './python-nosetests-errorview'
{CompositeDisposable} = require 'atom'
Runner = require './python-nosetests-runner'

module.exports = PythonNosetests =
  listview: null
  panel: null
  subscriptions: null

  activate: () ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:hide': => @hide()


    @listview = new PythonNosetestsListView(@setErrorPane)
    @errorview = new PythonNosetestsErrorView()


    @mainelement = document.createElement('div')
    @mainelement.classList.add('python-nosetests')
    @mainelement.appendChild(@listview.getElement())
    @mainelement.appendChild(@errorview.getElement())
    @errorview.hide()

    @panel = atom.workspace.addRightPanel(item: @mainelement, visible: false)

  deactivate: () ->
    @panel.destroy()
    @subscriptions.dispose()
    @listview.destroy()

  setErrorPane: (error) =>
    PythonNosetests.errorview.load(error)

  setBusy: (value)->
    if value
      @mainelement.classList.add('busy')
    else
      @mainelement.classList.remove('busy')

  run: () ->

    @setBusy(true)

    Runner.run {
               success: (data) =>
                 @listview.load(data)
                 @panel.show()
                 @setBusy(false)
                 @errorview.hide()

               error: (message) =>
                 atom.notifications.addWarning message, dismissable: true
                 @hide()
                 @setBusy(false)
                 @errorview.hide()
               }


  hide: () ->
    @panel.hide()
