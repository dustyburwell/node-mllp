net = require 'net'

{ MllpServer } = require './server'
{ ClientConnection } = require './client'

class Mllp
  createServer: (callback) ->
    return new MllpServer(callback)

  connect: (port, host..., callback) ->
    socket = net.connect port, host..., () ->
      callback(new ClientConnection(socket))

module.exports = new Mllp()