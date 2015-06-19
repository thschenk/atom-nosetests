
{$, View} = require 'space-pen'

module.exports =
class SplitView

  last_ratio: 0.5

  constructor: (@bar)->
    @parent = @bar.parent()
    @child_a = @bar.prev()
    @child_b = @bar.next()

    @bar.on 'mousedown', (e) => @childResizeStarted(e)

    @setRatio(0.5)

  childResizeStarted: (event) =>

    @start_pageY = @bar.offset().top + @bar.outerHeight() - event.pageY

    $(document).on('mousemove', @childResize)
    $(document).on('mouseup', @childResizeStopped)

  childResizeStopped: =>
    $(document).off('mousemove', @childResize)
    $(document).off('mouseup', @childResizeStopped)

  childResize: ({pageY, which}) =>
    return @childResizeStopped() unless which is 1

    total = @child_a.outerHeight() + @child_b.outerHeight()
    ratio = ((pageY - @child_a.offset().top) + (@start_pageY / 2 - @bar.outerHeight())) / total

    @setRatio(ratio)



  setRatio: (ratio) ->
    if not ratio?
      ratio = @last_ratio

    @child_a.css('flex', ratio.toString());
    @child_b.css('flex', (1.0-ratio).toString());
    @last_ratio =  ratio


  full_a: ->
    @child_a.css('flex', '1.0');
    @child_b.css('flex', '0.0');
