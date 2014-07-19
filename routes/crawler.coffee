crawler = require('crawler').Crawler

c = new C
  maxConnections: 3

exports.update_artist = (req, res, next) ->
  res.send 200