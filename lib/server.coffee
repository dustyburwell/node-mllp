net = require 'net'

MllpWriter = require './mllpwriter'
Encoded = require './encoded'
{ startBlock, endBlock, carriageReturn } = require './constants'

module.exports = server = {}

class ServerResponse extends MllpWriter
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

class ServerRequest extends Encoded

class MllpServer
  constructor: (callback) ->
    @server = net.createServer (socket) ->
      request = null
      startIndex = 0
      requestId = 0

      socket.on 'data', (data) ->
        for char, index in data
          if char is startBlock
            callback(request = new ServerRequest(), new ServerResponse(socket))
            startIndex = index

          if char is endBlock
            slice = 
              if request.getEncoding()
                data.toString(request.getEncoding(), startIndex, index)
              else
                data.slice(startIndex, index)

            request.emit('data', slice)
            request.emit('end')
            request = null
            continue;

        if request
          slice =
            if request.getEncoding()
              data.toString(request.getEncoding(), startIndex, index)
            else
              data.slice(startIndex, index)
          startIndex = 0

          request.emit('data', slice)

      socket.on 'error', (exception) ->
        console.log 'there was an error'

  listen: (port, host) ->
    @server.listen(port, host)

server.MllpServer = MllpServer