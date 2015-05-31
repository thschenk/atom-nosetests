PythonNosetestsView = require './python-nosetests-view'
{CompositeDisposable} = require 'atom'
child_process = require 'child_process'
fs = require 'fs'

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
    @panel.destroy()
    @subscriptions.dispose()
    @view.destroy()

  setErrorPane: (error) ->
    alert(error.message)

  run: () ->

    if not @view
      @view = new PythonNosetestsView(@setErrorPane)
      @panel = atom.workspace.addRightPanel(item: @view.getElement())
      @panel.show()

    @view.setBusy()

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
      alert("Could not determine how to run nosetests.")
      return


    child_process.exec command, cwd: cwd, =>

      if not nosetestsfile.existsSync()
        alert("Could not find '"+nosetestsfile.getPath()+"' after running the tests")
        return

      filecontent = fs.readFileSync(nosetestsfile.getPath(), 'UTF8');
      data = JSON.parse(filecontent)

      if data.metadata.time < start_time
        alert('Error: timestamp of nosetests.json file is before starting time.')
        return

      @view.load(data)


  hide: () ->
    @panel.hide()


  getProjectRoot: () ->
    # Returns a {Directory} object

    current_editor_path = atom.workspace.getActiveTextEditor().getPath()

    for dir in atom.project.getDirectories()
       if dir.contains(current_editor_path)
         return dir
