PythonNosetestsView = require './python-nosetests-view'
{CompositeDisposable} = require 'atom'
child_process = require 'child_process'
fs = require 'fs'

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

  deactivate: () ->
    @panel.destroy()
    @subscriptions.dispose()
    @listview.destroy()

  setErrorPane: (error) ->
    alert(error.message)

  run: () ->

    if not @listview
      @listview = new PythonNosetestsView(@setErrorPane)
      @panel = atom.workspace.addRightPanel(item: @listview.getElement())
      @panel.show()

    @listview.setBusy()

    start_time = new Date().getTime()/1000;

    root = @getProjectRoot()
    nosetestsfile = root.getFile('nosetests.json')

    command = null
    cwd = null

    if not command
      if nosetestsfile.existsSync()
        filecontent = fs.readFileSync(nosetestsfile.getPath(), 'UTF8');
        data = JSON.parse(filecontent)
        command = data.metadata.command
        cwd = data.metadata.cwd

    if not command
      script = root.getFile('test')
      if script.existsSync()
        command = script.getPath()
        cwd = root.getPath()

    if not command
      return @warn "Could not determine how to run nosetests."


    child_process.exec command, cwd: cwd, =>

      if not nosetestsfile.existsSync()
        return @warn("Could not find '"+nosetestsfile.getPath()+"' after running the tests")

      filecontent = fs.readFileSync(nosetestsfile.getPath(), 'UTF8');
      data = JSON.parse(filecontent)

      if data.metadata.time < start_time
        return @warn('Error: timestamp of nosetests.json file is before starting time.')

      @listview.load(data)
      @panel.show()


  warn: (message) ->
    atom.notifications.addWarning message, dismissable: true

  hide: () ->
    @panel.hide()


  getProjectRoot: () ->
    # Returns a {Directory} object

    current_editor_path = atom.workspace.getActiveTextEditor().getPath()

    for dir in atom.project.getDirectories()
       if dir.contains(current_editor_path)
         return dir
