url = require 'url'
{CompositeDisposable} = require 'atom'
PythonNosetestsView = require './view'

Runner = require './runner'

module.exports = PythonNosetests =
  view: null
  subscriptions: null

  activate: () ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:hide': => @hide()



    atom.workspace.addOpener (uriToOpen) =>

      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      if protocol is 'python-nosetests:'
        if host is 'listview'
          return new PythonNosetestsView(@setErrorPane)



  deactivate: () ->
    @subscriptions.dispose()
    @view.destroy()



  getView: (callback) ->
    if @view and atom.workspace.paneForItem(@view)
      callback(@view)

    else
      location = 'python-nosetests://listview/'
      options = {split: 'right', searchAllPanes: true}
      atom.workspace.open(location, options).then (editor) =>
        @view = editor
        callback(@view)


  run: () ->

    Runner.run {
      success: (data) =>
        @getView (view) -> view.getListView().load(data)


      error: (message) =>
       atom.notifications.addWarning message, dismissable: true

     }


  hide: () ->
    atom.workspace.paneForItem(@view).destroyItem(@view)
    @view = null
