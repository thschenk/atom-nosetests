child_process = require 'child_process'
fs = require 'fs'
path = require 'path'

module.exports = PythonNosetestsRunner =

  last_nosetestsfile: null

  run: (settings) ->
    # Finds out which tests to run and run them asynchronously
    # callbacks:
    #   - settings.success( <content of nosetests.json> )
    #   - settings.error( <errormessage> )

    start_time = new Date().getTime()/1000;

    current_dir = @getCurrentDir()

    if current_dir
      nosetestsfile = @findNoseTestsJson(current_dir)

    # if no nosetests file is found, use the file found in a previous run.
    if not nosetestsfile
      if @last_nosetestsfile
        if fs.existsSync(@last_nosetestsfile)
          nosetestsfile = @last_nosetestsfile

    if nosetestsfile
      filecontent = fs.readFileSync(nosetestsfile, 'UTF8');
      data = JSON.parse(filecontent)
      command = data.metadata.command
      cwd = data.metadata.cwd
      @last_nosetestsfile = nosetestsfile

    else
      settings.error "Could not find 'nosetests.json' in any of the parent folders of the active file."
      return


    child_process.exec command, cwd: cwd, =>

      if not fs.existsSync(nosetestsfile)
        settings.error "Could not find '"+nosetestsfile+"' after running the tests."
        return

      filecontent = fs.readFileSync(nosetestsfile, 'UTF8');
      data = JSON.parse(filecontent)

      if data.metadata.time < start_time
        settings.error 'Error: timestamp of nosetests.json file is before starting time.'
        return

      settings.success data

  findNoseTestsJson: (dir) ->
    # Searches for a 'nosetests.json' file in the given directory or in it's parent directories
    # It stops searching if none of the active projects contain this directory.
    # Returns null if no nosetests.json file can be found.

    nosetestsfile = path.join(dir,'nosetests.json')

    # check whether this file would be in one of the active projects
    if not @pathInAnyProject(nosetestsfile)
      return null

    # return the filename if the file exists
    if fs.existsSync(nosetestsfile)
      return nosetestsfile

    else
      # call this function recursively on the parent directory
      return @findNoseTestsJson(path.dirname(dir))


  getCurrentDir: ->
    # Returns the directory of the file in the currently active editor
    active_editor = atom.workspace.getActiveTextEditor()

    if active_editor
      return path.dirname(active_editor.getPath())
    else
      return null



  pathInAnyProject: (directory) ->
    # Returns true if any of the active project directories contain the given directory.
    # Otherwise it returns false.

    for project_dir in atom.project.getDirectories()
       if project_dir.contains(directory)
         return true

    return false
