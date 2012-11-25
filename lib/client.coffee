MllpWriter = require './mllpwriter'
Encoded = require './encoded'

module.exports = client = {}

class ClientResponse extends Encoded

class ClientRequest extends MllpWriter
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

client.ClientResponse = ClientResponse
client.ClientRequest = ClientRequest