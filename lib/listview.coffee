
{View} = require 'space-pen'
{Disposable, CompositeDisposable} = require 'atom'

module.exports =
class ListView extends View
  @content: ->
    @div class: 'listview', =>
      @ul class: 'root list-tree has-collapsable-children'

  setOnClickError: (func) ->
    @onclickerror = func

  clear: ->
    @find('.root').html('')

  load: (data) ->
    @clear()

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
      span_success = @createBadge(mod.nr_success, 'success')
      div.appendChild(span_success)


    if mod.nr_failed>0
      span_failed = @createBadge(mod.nr_failed, 'warning')
      div.appendChild(span_failed)

    if mod.nr_error>0
      span_error =  @createBadge(mod.nr_error, 'error')
      div.appendChild(span_error)

    li.appendChild(div)

    child_ul = document.createElement('ul')
    child_ul.classList.add('list-tree')
    li.appendChild(child_ul)

    @find('.root').append(li)



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
        @onclickerror(test.error)


    ul.appendChild(li)


  createBadge: (text, cls) ->

    span = document.createElement('span')
    span.textContent = text

    if atom.config.get('python-nosetests.colorfullBadges')
      span.classList.add('badge', 'badge-small', 'badge-'+cls)
    else
      span.classList.add('badge', 'badge-small', 'text-'+cls)



    return span
