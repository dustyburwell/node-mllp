mllp = require('../lib/node-mllp')

mllp.connect 9000, (connection) ->
  req = connection.request (res) ->
    res.setEncoding 'utf8'
    res.on 'data', (data) ->
      for line in data.split '\x0D'
        console.log line
    res.on 'end', ->
      connection.close()

  req.write "MSH|^~\\&|EPIC|EPICADT|SMS|SMSADT|199912271408|CHARRIS|ADT^A04|1817457|D|2.5|\x0D
PID||0493575^^^2^ID 1|454721||DOE^JOHN^^^^|DOE^JOHN^^^^|19480203|M||B|254 MYSTREET AVE^^MYTOWN^OH^44123^USA||(216)123-4567|||M|NON|400003403~1129086|\x0D
NK1||ROE^MARIE^^^^|SPO||(216)123-4567||EC|||||||||||||||||||||||||||\x0D
PV1||O|168 ~219~C~PMA^^^^^^^^^||||277^ALLEN MYLASTNAME^BONNIE^^^^|||||||||| ||2688684|||||||||||||||||||||||||199912271408||||||002376853\x0D"
  req.end()