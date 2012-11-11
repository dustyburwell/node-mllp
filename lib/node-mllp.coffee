net = require 'net'
{EventEmitter} = require 'events'

startBlock     = 0x0B
endBlock       = 0x1C
carriageReturn = 0x0D

extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin        
  obj

include = (klass, mixin) ->
  extend klass.prototype, mixin

Encoded =
  setEncoding: (@encoding) ->
  getEncoding: () ->
    @encoding  

MllpWriter =
  write: (data) ->
    @writeStart() unless @started
    @socket.write data

  end: (data) ->
    @write(data) if data
    @socket.write '\x1C'
    @socket.write '\x0D'

class ServerRequest extends EventEmitter
class ClientResponse extends EventEmitter

include(ServerRequest, Encoded)
include(ClientResponse, Encoded)

class ServerResponse
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

class ClientRequest
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

include(ServerResponse, MllpWriter)
include(ClientRequest, MllpWriter)


class ClientConnection
  constructor: (@socket) ->

  close: ->
    @socket.end()

  request: (callback) ->
    response = null

    @socket.on 'data', (data) ->
      for char, index in data
        if char is startBlock
          callback(response = new ClientResponse())
          startIndex = index

        if char is endBlock
          slice = 
            if response.getEncoding()
              data.toString(response.getEncoding(), startIndex, index)
            else
              data.slice(startIndex, index)

          response.emit('data', slice)
          response.emit('end')
          response = null
          continue;

      if response
        slice = 
          if response.getEncoding()
            data.toString(response.getEncoding(), startIndex, index)
          else
            data.slice(startIndex, index)
        startIndex = 0

        response.emit('data', slice)

    return new ClientRequest(@socket)

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

class Mllp
  createServer: (callback) ->
    return new MllpServer(callback)

  connect: (port, host..., callback) ->
    socket = net.connect port, host..., () ->
      callback(new ClientConnection(socket))

module.exports = new Mllp()