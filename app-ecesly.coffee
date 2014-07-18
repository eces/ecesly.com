###

███████╗ ██████╗███████╗███████╗██╗  ██╗   ██╗
██╔════╝██╔════╝██╔════╝██╔════╝██║  ╚██╗ ██╔╝
█████╗  ██║     █████╗  ███████╗██║   ╚████╔╝ 
██╔══╝  ██║     ██╔══╝  ╚════██║██║    ╚██╔╝  
███████╗╚██████╗███████╗███████║███████╗██║   
╚══════╝ ╚═════╝╚══════╝╚══════╝╚══════╝╚═╝   
                                              
###

express = require 'express'
morgan = require 'morgan'
errorHandler = require 'errorhandler'
bodyParser = require 'body-parser'
serveStatic = require 'serve-static'
cookieParser = require 'cookie-parser'
methodOverride = require 'method-override'
cookieSession = require 'cookie-session'
routes =
  user: require './routes/user'

http = require 'http'
path = require 'path'

# sessions = require 'client-sessions'
i18n = require 'i18n'

secret = 'B_l6O>i{lk_"tI-HI6^e<zx3S2q$G3'

_ = require 'lodash'

app = module.exports.app = express()

app.set 'port', process.env.PORT || 9000
app.enable 'trust proxy'

app.use cookieSession {
  keys: ['CJD0fB54987_wr7/!dul=R$rpTHhj|', 'u9"!160lge{!@AJ6gAkpQz4U6=w1<m']
  httpOnly: true
  signed: true
}


# app.use (req, res, next) ->
#   # flash messages
#   res.locals.error = req.session.error || ''
#   res.locals.message = req.session.success || ''
#   delete req.session.error
#   delete req.session.success

#   res.locals.signed = req.session.id || false
#   req.session.roles = if req.session.role then req.session.role.split(',') else []

#   res.locals.moment = require 'moment'
#   res.locals.moment.lang 'ko'
#   res.locals.dev = if 'development' is app.get('env') then true else false
#   res.locals.session = req.session
#   res.locals.uri = req.url
#   res.locals._ = _

#   i18n.setLocale( req.session.locale || 'ko' )
#   res.locals.__ = res.__ = ->
#     return i18n.__.apply req, arguments
#   next()

if 'development' is app.get('env')
  app.use morgan('dev')
  app.use errorHandler()
  app.disable 'etag'
else if 'production' is app.get('env')
  app.use morgan('tiny')
  newrelic = require 'newrelic'
else if 'test' is app.get('env')
  # 
else if 'test-verbose' is app.get('env')
  # 
else
  console.log '[app-ecesly.js] NODE_ENV not set.'

if 'production' is app.get('env')
  i18n.configure
    locales: [ 'ko', 'en' ]
    defaultLocale: 'ko'
    directory: __dirname + '/locales'
    extension: '.json'
    updateFiles: false
else
  i18n.configure
    locales: [ 'ko', 'en' ]
    defaultLocale: 'ko'
    directory: __dirname + '/locales'
    extension: '.json'
    updateFiles: true
app.use bodyParser.json()
app.use bodyParser.urlencoded
  extended: true
app.use methodOverride()
app.use cookieParser(secret)
app.use '/bower_components', express.static(path.join(__dirname, 'public', 'bower_components'))
app.use '/locales', express.static(path.join(__dirname, 'locales'))
app.use '/public', express.static(path.join(__dirname, 'public'))

app.engine 'jade', require('jade').__express

app.route '/'
  .all (req, res) ->
    res.send 'It works!'

server = http.createServer(app)
server.listen app.get('port'), () ->
  if 'test' isnt app.get('env')
    console.log('[app-ecesly.js] Express server listening on port ' + app.get('port'))
  console.log('[app-ecesly.js] Database ID not configured.') if process.env.ECESLY_DB_ID is undefined
  console.log('[app-ecesly.js] Database Password not configured.') if process.env.ECESLY_DB_PW is undefined
  console.log('[app-ecesly.js] Database Scheme not selected.') if process.env.ECESLY_DB_SCHEME is undefined
    
