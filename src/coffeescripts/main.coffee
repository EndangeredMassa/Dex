apiPermalink = =>
  window.location.search.replace(/edit=[^&]+&?/, "")

$ =>
  console?.log "Initialize API editor..."
  hljs.highlightBlock($(".preview pre")[0])
  $(".api-permalink").click =>
    window.location.search = apiPermalink()
