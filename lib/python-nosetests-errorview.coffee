
module.exports =
class PythonNosetestsErrorView
  constructor: () ->

    # Create message element
    @traceback_ul = document.createElement('ul')
    @traceback_ul.classList.add('errorview')


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @traceback_ul.remove()

  getElement: ->
    @traceback_ul

  hide: ->
    @traceback_ul.classList.add('hide')

  clear: ->
    @traceback_ul.innerHTML = ""

  load: (error) ->
    @clear()


    for tb in error.traceback
      @addTrace(tb)

    @addMessage(error.message)

    @traceback_ul.classList.remove('hide')

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
    li.onclick = () =>
      li.classList.toggle('selected')


    @traceback_ul.appendChild(li)


  addMessage: (message) ->

    code = document.createElement('div')
    code.classList.add('code')
    code.textContent = message

    li = document.createElement('li')
    li.classList.add('message')
    li.appendChild(code)


    @traceback_ul.appendChild(li)
