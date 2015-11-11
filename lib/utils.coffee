
module.exports = PythonNosetestsUtils =

  open_traceback: (tb) ->

      if tb.filename

        settings = {searchAllPanes: true}
        if tb.linenr
          settings.initialLine = tb.linenr-1
        if tb.column
          settings.initialColumn = tb.column-1

        atom.workspace.open(tb.filename, settings)
