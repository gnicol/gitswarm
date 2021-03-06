# Intercept turbolinks body replacement, in order to update the header area of the page

lastProcessedDoc     = null
processing           = false
originalReplaceChild = window.HTMLElement::replaceChild

# Override the HTMLElement replaceChild method so we can capture the document
# that turbolinks has recieved
window.HTMLElement::replaceChild = (newElement, oldElement) ->
  # Capture the document if turbolinks is currently processing and the replaced
  # element is the body tag. We store the document back onto the body element
  # so it doesn't get lost when turoblinks stores only the body.
  if processing and newElement instanceof HTMLElement and newElement.nodeName is 'BODY'
    lastProcessedDoc       = newElement.originalDoc || newElement.ownerDocument
    newElement.originalDoc = lastProcessedDoc

  # Call the original replaceChild method
  originalReplaceChild.apply(this, arguments)

# Listen for when turbolinks is triggered, in order to flag it as processing
document.addEventListener('page:receive', (-> processing = true), false)
window.addEventListener('popstate', ((event) -> processing = true if event.state?.turbolinks), false)

# Process page header when turbolinks changes the page
document.addEventListener(
  'page:change'
  ->
    if processing and lastProcessedDoc
      processing = false
      updateHead(lastProcessedDoc)

    # Turbolinks fires page:change for intial browser loaded page as well.
    # Take this oportunity to reference the original document so history works.
    document.body.originalDoc = document unless lastProcessedDoc
    return
  false
)

# Update the current page, with data from the passed document
updateHead = (doc) ->
  # Locate the gon script in the head, and run it.
  for script in doc.querySelectorAll('head script') when script.text.match(/window\.gon\=\{\}\;/)
    $.globalEval(script.text) if $
