mllp = require('../lib/node-mllp')

server = mllp.createServer (request, response) ->
   message = ''

   request.setEncoding 'utf8'
   request.on 'data', (data) ->
      message += data

   request.on 'end', ->
      for line in message.split('\x0D')
         console.log line

      console.log 'Writing a response'
      response.write 'MSH|^~\\&|\x0DMSA|AA|234242|Message Received Successfully|\x0D'
      response.end()

server.listen(9000)
console.log 'listening on port 9000'