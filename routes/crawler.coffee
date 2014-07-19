pool = require('../db.js').pool
async = require 'async'
Crawler = require('crawler').Crawler

c = new Crawler
  maxConnections: 10
  userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.77.5 (KHTML, like Gecko) Version/7.0 Safari/537.77.4'
  forceUTF8: true
  autoWindowClose: true

exports.update_artist = (req, res, next) ->
  page = req.param('page') || 1
  pool.getConnection (cErr, db) ->
    if cErr
      throw cErr
      res.send 500
      return next()

    total = 0
    newly = 0
    # update list
    res.write "Fetching new albums and artists ... \n"
    c.queue
      uri: 'http://music.bugs.co.kr/newest/track/total?page=' + page
      jQuery: true
      timeout: 5000
      callback: (error, result, $) ->
        $artist = $('.artistname')
        $album = $('.albumtitle')
        total = $artist.length
        for i in [0..total-1]
          do (i) ->
            res.write "#{i+1} / #{total}\n"
            artist =
              bugsUrl: $artist[i].href
              name: $artist[i].title
            album = 
              # artistId: artistId
              name: $album[i].title
              bugsUrl: $album[i].href
            
            db.query "
            SELECT COUNT(`id`) as `c` FROM `artist` WHERE `bugsUrl` = ?
            ", [artist.bugsUrl], (e, r) ->
              if e
                throw e
              if r[0].c is 0
                db.query "
                INSERT INTO `artist` SET ?, `createdAt` = NOW()
                ", [artist], (e, r) ->
                  if e
                    throw e
                  album.artistId = r.insertId
                  db.query "
                  SELECT COUNT(`id`) as `c` FROM `album` WHERE `bugsUrl` = ?
                  ", [album.bugsUrl], (e, r) ->
                    if e
                      throw e
                    if r[0].c is 0
                      db.query "
                      INSERT INTO `album` SET ?, `createdAt` = NOW()
                      ", [album], (e, r) ->
                        if e
                          throw e
                
        res.write "Done\n"

        total = 0
        res.write "Fetching artist info ... \n"
        db.query "
        SELECT `id`, `bugsUrl` FROM `artist` WHERE `updatedAt` IS NULL
        ", (e, r) ->
          if e
            throw e
            return res.send 500
          total = r.length
          if total
            for i in [0..total-1]
              do (i) ->
                res.write "#{i+1} / #{total}\n"
                c.queue
                  uri: r[i].bugsUrl
                  jQuery: true
                  timeout: 5000
                  callback: (error, result, $) ->
                    artist =
                      category: $('div.info dt.category').next().text()
                      debut: $('div.info dt.debut').next().text().replace(/\s+/g, '')
                      genre: $('div.info dt.genre').next().text().replace(/\s+/g, '')
                      style: $('div.info dt.style').next().text().replace(/\s+/g, '')
                      imageUrl: $('div.thumbnailBox img')[0].src
                        
                    db.query "
                    UPDATE `artist` SET ?, `updatedAt` = NOW()
                    WHERE `id` = ?
                    ", [artist, r[i].id], (e, r) ->
                      if e
                        throw e
                      true

        res.write "Done\n"

        total = 0
        res.write "Fetching album info ... \n"
        db.query "
        SELECT `id`, `bugsUrl` FROM `album` WHERE `updatedAt` IS NULL
        ", (e, r) ->
          if e
            throw e
            return res.send 500
          total = r.length
          if total
            for i in [0..total-1]
              do (i) ->
                res.write "#{i+1} / #{total}\n"
                c.queue
                  uri: r[i].bugsUrl
                  jQuery: true
                  timeout: 5000
                  callback: (error, result, $) ->
                    album =
                      category: $('div.info dt.albumsort').next().text().replace(/\s+/g, '')
                      genre: $('div.info dt.genre').next().text().replace(/\s+/g, '')
                      style: $('div.info dt.style').next().text().replace(/\s+/g, '')
                      publishedAt: $('div.info dt.date').next().text().replace(/\s+/g, '')
                      publisher: $('div.info dt.company').next().text().replace(/\s+/g, '')
                      publisher: $('div.info dt.company').next().text().replace(/\s+/g, '')
                      review: ( $('div.albumReview p').html() || '  ').replace(/<br\s*\/?>/mg,"\n").trim()
                      imageUrl: $('div.thumbnailBox img')[0].src
                      titleName: $('dl.trackInfo a.title')[0].title
                        
                    db.query "
                    UPDATE `album` SET ?, `updatedAt` = NOW()
                    WHERE `id` = ?
                    ", [album, r[i].id], (e, r) ->
                      if e
                        throw e
                      true

        res.end()
        # setTimeout ->
        # , 10000
        db.release()
        next()