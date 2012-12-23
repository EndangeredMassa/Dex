apiPermalink = =>
  window.location.search.replace(/edit=[^&]+&?/, "")

togglePreviewWrapText = (e) =>
  if $('.preview-wrap-text input').is(':checked')
    $('.preview').css('word-wrap', 'break-word')
    $('.preview pre').css('white-space', 'pre-wrap')
  else
    $('.preview').css('word-wrap', 'normal')
    $('.preview pre').css('white-space', 'pre')

$ =>
  console?.log "Initialize API editor..."
  hljs.highlightBlock($(".preview pre")[0])
  $('.preview-wrap-text input').change(togglePreviewWrapText)
  $(".api-permalink").click =>
    window.location.search = apiPermalink()
