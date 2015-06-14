child_process = require 'child_process'
fs = require 'fs'

module.exports = PythonNosetestsRunner =

  run: (settings) ->

    start_time = new Date().getTime()/1000;

    try
      root = @getProjectRoot()
    catch
      settings.error "Could not determine the active project root."
      return

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
      settings.error "Could not find 'nosetests.json' or 'test' script in the project root folder."
      return


    child_process.exec command, cwd: cwd, =>

      if not nosetestsfile.existsSync()
        settings.error "Could not find '"+nosetestsfile.getPath()+"' after running the tests."
        return

      filecontent = fs.readFileSync(nosetestsfile.getPath(), 'UTF8');
      data = JSON.parse(filecontent)

      if data.metadata.time < start_time
        settings.error 'Error: timestamp of nosetests.json file is before starting time.'
        return

      settings.success data

  getProjectRoot: () ->
    # Returns a {Directory} object for the project folder that contains the file of the active editor
    current_editor_path = atom.workspace.getActiveTextEditor().getPath()

    for dir in atom.project.getDirectories()
       if dir.contains(current_editor_path)
         return dir
