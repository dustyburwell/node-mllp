{EventEmitter} = require 'events'

class Encoded extends EventEmitter
  setEncoding: (@encoding) ->
  getEncoding: () ->
    @encoding  

module.exports = Encoded