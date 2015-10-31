{View, $$} = require 'space-pen'
Utils = require './utils'


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

    if error.traceback
      for tb in error.traceback by -1
        @addTrace(tb)

  addTrace: (tb) ->

    if @matchTracebackFilter(tb.filename)
      return

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

    if not tb.function
      li.find('.function').hide()

    li.on 'click', =>
      Utils.open_traceback(tb)

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

  matchTracebackFilter: (filename) ->

    filterstring = atom.config.get('python-nosetests.hiddenTracebackFilter')

    for filter in filterstring.split(' ')
      if filter.length
        if filename.endsWith(filter)
          return true

    return false
