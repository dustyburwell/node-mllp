class MllpWriter
  write: (data) ->
    @writeStart() unless @started
    @socket.write data

  end: (data) ->
    @write(data) if data
    @socket.write '\x1C'
    @socket.write '\x0D'

module.exports = MllpWriter