{ScrollView} = require 'atom-space-pen-views'

module.exports =
class PythonNosetestsErrorView extends ScrollView

  @content: ->
    @div class: 'errorview', =>
      @ul class: 'root'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->

  clear: ->
    @find('.root').html('')

  load: (error) ->
    @clear()


    for tb in error.traceback
      @addTrace(tb)

    @addMessage(error.message)


  addTrace: (tb) ->

    div_filename = document.createElement('div')
    div_filename.textContent = tb.filename+':'+tb.linenr
    div_filename.classList.add('filename')


    span_functionname = document.createElement('span')
    span_functionname.textContent = tb.function

    div_function = document.createElement('div')
    div_function.classList.add('function')
    div_function.appendChild(document.createTextNode("In function "))
    div_function.appendChild(span_functionname)
    div_function.appendChild(document.createTextNode(":"))

    code = document.createElement('div')
    code.classList.add('code')
    code.textContent = tb.line


    li = document.createElement('li')
    li.appendChild(div_filename)
    li.appendChild(div_function)
    li.appendChild(code)

    if not @isProjectFile(tb.filename)
      li.classList.add('mute')

    li.onclick = () =>
      # li.classList.toggle('selected')
      atom.workspace.open tb.filename, initialLine: tb.linenr-1, searchAllPanes: true, split: 'left'


    @find('.root').append(li)


  addMessage: (message) ->

    code = document.createElement('div')
    code.classList.add('code')
    code.textContent = message

    li = document.createElement('li')
    li.classList.add('message')
    li.appendChild(code)

    @find('.root').append(li)

  isProjectFile: (filename) ->

    for dir in atom.project.getDirectories()
       if dir.contains(filename)
         return true
    return false
