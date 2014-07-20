pool = require('../db.js').pool
moment = require 'moment'

exports.index = (req, res) ->
  pool.getConnection (cErr, db) ->
    if cErr
      throw cErr
      return res.send 500

    lastweek = moment().subtract(1, 'week').format('YYYY-MM-DD')
    tomorrow = moment().add(1, 'day').format('YYYY-MM-DD')

    options =
      sql: "
      SELECT * FROM `album`, `artist` 
      WHERE `album`.`updatedAt` BETWEEN '#{lastweek}' AND '#{tomorrow}'
        AND `album`.`publisher` = '미러볼뮤직'
        AND `album`.`artistId` = `artist`.`id`
      ORDER BY `album`.`publishedAt` DESC
      LIMIT 5
      "
      nestTables: true
    db.query options, (e, r) ->
      if e
        db.release()
        throw e
        return res.send 500

      options =
        sql: "
        SELECT * FROM `album`, `artist` 
        WHERE `album`.`updatedAt` BETWEEN '#{lastweek}' AND '#{tomorrow}'
          AND `album`.`style` LIKE '%인디%'
          AND `album`.`artistId` = `artist`.`id`
        ORDER BY `album`.`publishedAt` DESC
        LIMIT 20
        "
        nestTables: true
      db.query options, (e, r2) ->
        db.release()
        if e
          throw e
          return res.send 500
        res.render 'artist_index.jade', 
          publisher: r
          artist: r2
