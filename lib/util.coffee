module.exports =
  capitalize: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  punctuate: (string) ->
    if string.match(/[\.,:;]$/)
      string
    else
      string + '.'
