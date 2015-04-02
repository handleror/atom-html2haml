# Html2hamlView = require './html2haml-view'
{CompositeDisposable} = require 'atom'

module.exports = Html2haml =
  # html2hamlView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # @html2hamlView = new Html2hamlView(state.html2hamlViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @html2hamlView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'html2haml:convert': => @convert()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    # @html2hamlView.destroy()

  serialize: ->
    # html2hamlViewState: @html2hamlView.serialize()

  convert: ->
    editor = atom.workspace.activePaneItem
    selection = editor.getSelection()

    html = selection.getText()
    post_data = JSON.stringify({'page': {'html': html}})


    http = require("http")
    options =
      host: "html2haml-attributes.herokuapp.com"
      path: "/api.json"
      method: "POST"
      headers:
        "Content-Type": 'text/html;charset=utf-8'
        "Content-Length": post_data.length

    callback = (response) ->
      str = ""
      response.on "data", (chunk) ->
        str += chunk

      response.on "end", ->
        result = JSON.parse(str)
        editor.insertText(result.page.haml)

    request = http.request(options, callback)
    request.write(post_data, encoding = 'utf8')

    request.end()
