u = up.util
e = up.element

PRESERVE_KEYS = ['selectionStart', 'selectionEnd', 'scrollLeft', 'scrollTop', 'oldElement']

transferProps = (from, to) ->
  u.assign(to, u.pick(from, PRESERVE_KEYS))

focusedElementWithin = (scopeElement) ->
  focusedElement = document.activeElement
  if e.isInSubtree(scopeElement, focusedElement)
    return focusedElement

class up.FocusCapsule extends up.Record
  keys: ->
    ['selector'].concat(PRESERVE_KEYS)

  restore: (scope, options) ->
    if @oldElement && focusedElementWithin(@oldElement)
      # If the old element was never detached (e.g. because it was kept),
      # and still has focused, we don't need to do anything.
      return

    if rediscoveredElement = e.get(scope, @selector)
      up.focus(rediscoveredElement, options)
      transferProps(this, rediscoveredElement)
      # Signals callers that we could restore
      return true

  @preserveWithin: (oldElement) ->
    if focusedElement = focusedElementWithin(oldElement)
      plan = { oldElement, selector: up.fragment.toTarget(focusedElement) }
      transferProps(focusedElement, plan)
      return new @(plan)