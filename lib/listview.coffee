
{View, $$} = require 'space-pen'
{Disposable, CompositeDisposable} = require 'atom'
Utils = require './utils'

module.exports =
class ListView extends View
  @content: ->
    @div class: 'listview', =>
      @ul class: 'root list-tree has-collapsable-children', outlet: 'root'

  setOnSelect: (func) ->
    @onselect = func

  clear: ->
    @root.html('')

  load: (data) ->
    @clear()

    if data.syntaxerrors and data.syntaxerrors.length
      mod_ul = @addModule({name: 'Syntax Errors', nr_error: data.syntaxerrors.length})
      for syntax in data.syntaxerrors
        @addSyntaxError(mod_ul, syntax)

    for mod in data.modules
      mod_ul = @addModule(mod)

      for tc in mod.testcases
        @addTestCase(mod_ul, tc)

  addModule: (mod) ->

    li = $$ ->
      @li class:'list-nested-item', =>
        @div class: 'list-item', =>
          @span mod.name
        @ul class:'list-tree'

    div = li.find('div')
    div.on 'click', =>
      li.toggleClass('collapsed')

    if mod.nr_success>0
      div.append(@createBadge(mod.nr_success, 'success'))

    if mod.nr_failed>0
      div.append(@createBadge(mod.nr_failed, 'warning'))

    if mod.nr_error>0
      div.append(@createBadge(mod.nr_error, 'error'))

    if mod.nr_error + mod.nr_failed == 0
      li.addClass('collapsed')

    @root.append(li)

    # return the child ul
    return li.find('ul')



  addSyntaxError: (ul, syntax) ->

    li = $$ ->
      @li class:'list-nested-item', =>
        @span syntax.name

    li.on 'click', =>
      @root.find('li').removeClass('active')
      li.addClass('active')

      Utils.open_traceback(syntax.error.traceback[0])

      @onselect(syntax)

    # add the testcase to the module
    ul.append(li)


  addTestCase: (ul, test) ->

    switch test.result
      when "success"
        title_class = 'text-success'
      when "failed"
        title_class = 'text-warning'
      when "error"
        title_class = 'text-error'
      else
        title_class = 'text-info'

    li = $$ ->
      @li class:'list-nested-item', =>
        @span class: title_class, test.name

    li.on 'click', =>
      @root.find('li').removeClass('active')
      li.addClass('active')
      @onselect(test)


    # add the testcase to the module
    ul.append(li)


  createBadge: (text, cls) ->

    span = document.createElement('span')
    span.textContent = text

    if atom.config.get('python-nosetests.colorfullBadges')
      span.classList.add('badge', 'badge-small', 'badge-'+cls)
    else
      span.classList.add('badge', 'badge-small', 'text-'+cls)



    return span
