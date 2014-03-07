Html2hamlView = require './html2haml-view'

module.exports =
  html2hamlView: null

  activate: (state) ->
    @html2hamlView = new Html2hamlView(state.html2hamlViewState)
    atom.workspaceView.command "html2haml:convert", => @convert()

  deactivate: ->
    @html2hamlView.destroy()

  serialize: ->
    html2hamlViewState: @html2hamlView.serialize()

  convert: ->
    editor = atom.workspace.activePaneItem
    selection = editor.getSelection()

    html = selection.getText()
    post_data = JSON.stringify({'page': {'html': html}})
    # post_data = unescape(encodeURIComponent(post_data))


    http = require("http")
    #The url we want is `www.nodejitsu.com:1337/`
    options =
      host: "html2haml.heroku.com"
      path: "/api.json"
      #This is what changes the request to a POST request
      method: "POST"
      headers:
        "Content-Type": 'text/html;charset=utf-8'
        "Content-Length": post_data.length

    callback = (response) ->
      str = ""
      response.on "data", (chunk) ->

        str += chunk
        return

      response.on "end", ->
        console.log str
        result = JSON.parse(str)
        editor.insertText(result.page.haml)
        return

      return

    request = http.request(options, callback)

    request.end()
    request.write(post_data, encoding = 'utf8')
