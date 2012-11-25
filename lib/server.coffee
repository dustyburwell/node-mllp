MllpWriter = require './mllpwriter'
Encoded = require './encoded'

module.exports = server = {}

class ServerResponse extends MllpWriter
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

class ServerRequest extends Encoded

server.ServerResponse = ServerResponse
server.ServerRequest = ServerRequest