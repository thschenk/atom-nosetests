
{$, View} = require 'space-pen'
{Emitter, Disposable, CompositeDisposable} = require 'atom'

module.exports =
class ResizablePanel

  constructor: (@handle) ->
    @handle.on 'mousedown', (e) => @panelResizeStarted(e)

  # Panel resize functions
  panelResizeStarted: =>
    $(document).on('mousemove', @panelResize)
    $(document).on('mouseup', @panelResizeStopped)

  panelResizeStopped: =>
    $(document).off('mousemove', @panelResize)
    $(document).off('mouseup', @panelResizeStopped)

  panelResize: ({pageX, which}) =>
    return @panelResizeStopped() unless which is 1
    @handle.parent().width($(document.body).width() - pageX)
