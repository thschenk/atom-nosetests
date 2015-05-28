fs = require 'fs'

module.exports =
class PythonNosetestsView
  constructor: (callbackErrorPane) ->

    @callbackErrorPane = callbackErrorPane

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('python-nosetests')

    # Create message element
    @root_ul = document.createElement('ul')
    @root_ul.classList.add('list-tree')
    @root_ul.classList.add('has-collapsable-children')
    @element.appendChild(@root_ul)


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  clear: ->
    @root_ul.innerHTML = ""

  load: (filename) ->
    @clear()

    filecontent = fs.readFileSync(filename, 'UTF8');
    data = JSON.parse(filecontent)

    for mod in data.modules
      mod_ul = @addModule(mod)

      for tc in mod.testcases
        @addTestCase(mod_ul, tc)


  addModule: (mod) ->
    li = document.createElement('li')
    li.classList.add('list-nested-item')

    div = document.createElement('div')
    div.classList.add('list-item')

    div.onclick = () ->
      li.classList.toggle('collapsed')

    span_title = document.createElement('span')
    span_title.textContent = mod.name
    #span_title.classList.add('text-subtle')
    div.appendChild(span_title)

    if mod.nr_success>0
      span_success = document.createElement('span')
      span_success.textContent = mod.nr_success
      span_success.classList.add('badge', 'badge-small', 'text-success')
      div.appendChild(span_success)


    if mod.nr_failed>0
      span_failed = document.createElement('span')
      span_failed.classList.add('badge', 'badge-small', 'text-warning')
      span_failed.textContent = mod.nr_failed
      div.appendChild(span_failed)

    if mod.nr_error>0
      span_failed = document.createElement('span')
      span_failed.classList.add('badge', 'badge-small', 'text-error')
      span_failed.textContent = mod.nr_error
      div.appendChild(span_failed)

    li.appendChild(div)

    child_ul = document.createElement('ul')
    child_ul.classList.add('list-tree')
    li.appendChild(child_ul)

    @root_ul.appendChild(li)



    if mod.nr_error + mod.nr_failed == 0
      li.classList.add('collapsed')

    # return the child ul
    child_ul



  addTestCase: (ul, test) ->
    li = document.createElement('li')
    li.classList.add('list-nested-item')

    title = document.createElement('span')
    title.textContent = test.name
    li.appendChild(title)


    switch test.result
      when "success"
        title.classList.add('text-success')
      when "failed"
        title.classList.add('text-warning')
      when "error"
        title.classList.add('text-error')
      else
        title.classList.add('text-info')

    li.onclick = () =>
      if 'error' of test
        @callbackErrorPane(test.error)


    ul.appendChild(li)
