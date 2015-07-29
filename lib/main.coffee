url = require 'url'
{CompositeDisposable} = require 'atom'
PythonNosetestsView = require './view'

Runner = require './runner'

module.exports = PythonNosetests =
  view: null
  panel: null
  subscriptions: null

  activate: () ->

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:run': => @run()
    @subscriptions.add atom.commands.add 'atom-workspace', 'python-nosetests:hide': => @hide()

  deactivate: () ->
    @subscriptions.dispose()
    @view.destroy()
    @panel.destroy()

  run: () ->

    if @view
      @view.mute()

    running_notification = atom.notifications.addInfo "Running nose tests...", dismissable: true

    Runner.run {
      success: (data) =>
        running_notification.dismiss()
        if not @view
          @view = new PythonNosetestsView()

        if not @panel
          @panel = atom.workspace.addRightPanel item: @view, visible: false

        @panel.show()
        @view.load(data)



      error: (message) =>
       running_notification.dismiss()
       atom.notifications.addWarning message, dismissable: true

       if @view
         @view.unmute()
     }


  hide: () ->
    @panel.hide()

  config:
    colorfullBadges:
      title: 'Colorfull Badges'
      description: 'If enabled, the background color of the badges indicating the number of succeeded, failed and error test cases will be colorfull.'
      type: 'boolean'
      default: false
    env:
      title: 'Environment variables'
      description: 'Additional environment variables passed with nosetests (valid json string required), for example: {"DJANGO_SETTINGS_MODULE": "project.settings"}'
      type: 'string'
      default: '{}'
    useCustomCommand:
      title: 'Custom command'
      description: 'If enabled, it will run the custom command instead of standard nose tests'
      type: 'boolean'
      default: false
    customCommand:
      title: 'Custom command to run nosetests'
      description: 'It can be used for example with django_nose. Instead of running `nosetests` directly you can run `./manage.py test` in root of your project'
      type: 'string'
      default: '$PROJECT/env/bin/python $PROJECT/manage.py test'
