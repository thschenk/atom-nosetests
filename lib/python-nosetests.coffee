url = require 'url'
PythonNosetestsListView = require './python-nosetests-listview'
PythonNosetestsErrorView = require './python-nosetests-errorview'
{CompositeDisposable} = require 'atom'
Runner = require './python-nosetests-runner'

module.exports = PythonNosetests =
  listview: null
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
          return new PythonNosetestsListView(@setErrorPane)



  deactivate: () ->
    @subscriptions.dispose()
    @listview.destroy()

  setErrorPane: (error) =>
    alert(error.message)


  getListView: (callback) ->
    if @listview
      callback(@listview)

    else
      location = 'python-nosetests://listview/'
      options = {split: 'right', searchAllPanes: true}
      atom.workspace.open(location, options).then (editor) =>
        @listview = editor
        callback(@listview)


  run: () ->

    Runner.run {
      success: (data) =>
        @getListView (listview) -> listview.load(data)


      error: (message) =>
       atom.notifications.addWarning message, dismissable: true

     }


  hide: () ->
    if @listitem
     atom.workspace.paneForItem(@listview).destroyItem(@listview)
