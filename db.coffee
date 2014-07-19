mysql = require('mysql')

module.exports.pool = mysql.createPool {
  host: 'localhost'
  user: process.env.ECESLY_DB_ID
  password: process.env.ECESLY_DB_PW
  database: process.env.ECESLY_DB_SCHEME
  # debug: true
}

module.exports.multipleStatementsPool = mysql.createPool {
  host: 'localhost'
  user: process.env.ECESLY_DB_ID
  password: process.env.ECESLY_DB_PW
  database: process.env.ECESLY_DB_SCHEME
  # debug: true
  multipleStatements: true
}