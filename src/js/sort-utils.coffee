class SortUtils

  @dynamicSort: (property) -> (a, b) ->
    if a[property] < b[property] then -1
    else if a[property] > b[property] then 1
    else 0

  @dynamicMultiSort: (props) ->
    #save the arguments object as it will be overwritten
    #note that arguments object is an array-like object
    #consisting of the names of the properties to sort by
    (a, b) ->
      i = 0
      result = 0
      numberOfProps = if Array.isArray(props) then props.length else props[0] = props
      # try getting a different result from 0 (equal)
      # as long as we have extra properties to compare
      while result == 0 and i < numberOfProps
        log props[i]
        result = SortUtils.dynamicSort(props[i])(a, b)
        i++
      return result
