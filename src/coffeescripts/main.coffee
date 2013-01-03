apiPermalink = =>
  query = window.location.search.replace(/edit=[^&]+&?/, "")
  "#{window.location.protocol}//#{window.location.host}/#{query}"

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
    $('.preview pre').css('white-space', 'pre-wrap')
  else
    $('.preview').css('word-wrap', 'normal')
    $('.preview pre').css('white-space', 'pre')

nestableHtmlFromParams = (rules, html="") =>
  html += "<ol class='dd-list'>"
  for rule in rules
    console.log "RULE", rule
    html += "<li class='dd-item'>"
    html += "<div class='dd-handle'>#{rule.s}</div>"
    if rule.r?.length > 0
      html = nestableHtmlFromParams(rule.r, html)
    html += "</li>"
  html += "</ol>"
  html

refreshNestable = (rules) =>
  $(".dd").html(nestableHtmlFromParams(rules))
  $(".dd").nestable
    listClass: "dd-list"
    itemClass: "dd-item"

$ =>
  console?.log "Initialize API editor..."
  hljs.highlightBlock($(".preview pre")[0])
  $('.preview-wrap-text input').change(togglePreviewWrapText)
  $(".api-permalink").click =>
    window.location.href = apiPermalink()

  params = JSON.parse($(".raw-params").text())
  console.log "PARAMS",params
  refreshNestable(params.r)
