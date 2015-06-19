{View, $$} = require 'space-pen'

module.exports =
class ErrorView extends View

  @content: ->
    @div class: 'errorview', =>
      @ul class: 'root', outlet:'root'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  clear: ->
    @root.html('')

  load: (error) ->
    @clear()


    @addMessage(error.message)

    for tb in error.traceback by -1
      @addTrace(tb)

  addTrace: (tb) ->

    li = $$ ->
      @li =>
        @div class: 'filename', tb.filename+':'+tb.linenr
        @div class: 'function', =>
          @text "In function "
          @span tb.function
          @text ":"
        @div class: 'code', tb.line



    if not @isProjectFile(tb.filename)
      li.addClass('mute')

    li.on 'click', =>
      atom.workspace.open tb.filename, initialLine: tb.linenr-1, searchAllPanes: true

    @root.append(li)

  addMessage: (message) ->

    li = $$ ->
      @li class: 'message', =>
        @div class: 'code', message

    @root.append(li)

  isProjectFile: (filename) ->

    for dir in atom.project.getDirectories()
       if dir.contains(filename)
         return true
    return false
