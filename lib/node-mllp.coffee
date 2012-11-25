net = require 'net'
{EventEmitter} = require 'events'
MllpWriter = require './mllpwriter'
{ startBlock, endBlock, carriageReturn } = require './constants'
{ ServerResponse, ServerRequest } = require './server'

extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin        
  obj

include = (klass, mixin) ->
  extend klass.prototype, mixin

class Encoded extends EventEmitter
  setEncoding: (@encoding) ->
  getEncoding: () ->
    @encoding  

class ClientResponse extends Encoded

class ClientRequest extends MllpWriter
  constructor: (@socket) ->
    @started = false

    @writeStart = =>
      @socket.write '\x0B'
      @started = true

class ClientConnection
  constructor: (@socket) ->

  close: ->
    @socket.end()

  request: (callback) ->
    response = null

    ondata = (data) =>
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
          @socket.removeListener 'data', ondata
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

    @socket.on 'data', ondata

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