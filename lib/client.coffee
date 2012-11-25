MllpWriter = require './mllpwriter'
Encoded    = require './encoded'
{ startBlock, endBlock, carriageReturn } = require './constants'

module.exports = client = {}

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

client.ClientConnection = ClientConnection