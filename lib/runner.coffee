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

    useCustomCommand = atom.config.get("python-nosetests.useCustomCommand")

    if not useCustomCommand

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
    else
      command = atom.config.get("python-nosetests.customCommand")
      project_paths = atom.project.getPaths()

      if command.match(/\$PROJECT/)

        if project_paths.length is 1
          # only one project path, no need for any additional searches
          project_path = project_paths[0]
          command = command.replace(/\$PROJECT/g, project_path)
          cwd = project_path
        else
          # we've got multiple project paths, we need to find out which one to use
          command_split = command.split(" ")
          project_path_found = false
          # here the code goes through all arguments to find which one got $PROJECT var
          for arg in command_split
            if arg.match(/\$PROJECT/)
              # when arg matches then it goes through project paths to try and find the file specified in argument
              # if file is found then, we assume that this is the project path we are looking for
              for project_path in project_paths
                if fs.existsSync(arg.replace(/\$PROJECT/g, project_path))
                  command = command.replace(/\$PROJECT/g, project_path)
                  cwd = project_path
                  # this will break the arg loop
                  project_path_found = true
                  break
              if project_path_found
                break
            else
              # not $PROJECT found go, to the next arg
              continue

            # let's try to find out which one is the one we want to use
            for projectPath in projectPaths
              cmd = command.replace('$PROJECT', projectPath)
              first_arg = cmd.split(" ")[0]
              if fs.existsSync(first_arg)
                command = cmd
                break
      else
        # let's determine the cwd
        if project_paths.length is 1
          # only one project path, pretty straight forward here
          cwd = project_paths[0]
        else
          # we've got more project paths, let's find a proper one
          found_cwd = false
          for arg in command.split(" ")
            if not arg.match(/^\//) and arg.match(/\//)
              # this argument doesn't start with / and contains / character(s)
              # this might be a path, let's check if we have it in
              for project_path in project_paths
                if fs.existsSync(path.join(project_path, arg))
                  cwd = project_path
                  found_cwd = true
                  break
              if found_cwd
                break
          if not found_cwd
            # we didn't find anything, grab first project path
            cwd = project_paths[0]

      nosetestsfile = path.join(cwd, "nosetests.json")

    env_string = atom.config.get("python-nosetests.env")
    env = JSON.parse(env_string)
    child_process.exec command, {cwd: cwd, env: env}, =>

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
