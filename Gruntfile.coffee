module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    ###
    https://github.com/gruntjs/grunt-contrib-coffee
    dev, prod 모드 공통. coffee를 js로 컴파일
    ###
    coffee:
      dev:
        expand: true
        flatten: false
        cwd: ''
        src: [
          '*.coffee'
          'routes/*.coffee'
          'migrations/*.coffee'
          'tests/*.coffee'
        ]
        ext: '.js'
      prod:
        compile_all:
          expand: true
          flatten: false
          cwd: ''
          src: [
            '*.coffee'
            'routes/*.coffee'
            'migrations/*.coffee'
          ]
          ext: '.js'
      # migration:
      #   expand: true
      #   flatten: false
      #   cwd: ''
      #   src: [
      #     'migration.coffee'
      #   ]
      #   ext: '.js'
    ###
    https://github.com/gruntjs/grunt-contrib-uglify
    prod 모드에서만, js 파일을 minify 시킴
    ###
    uglify:
      options: 
        report: 'gzip'
        wrap: false
        mangle: false
        compress:
          drop_console: true
        # banner: "/* <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today('yyyy-mm-dd') %> */"
      minify_all:
        files: [
          {
            expand: true
            cwd: ''
            src: [
              '*.js'
              'routes/*.js'
              '!newrelic.js'
              '!Gruntfile.js'
            ]
          }
        ]
    
    ###
    https://github.com/ChrisWren/grunt-nodemon
    dev 모드에서만, coffee 변경시 서버 재시작
    ###
    nodemon:
      dev:
        script: 'app-ecesly.js'
        options:
          ignore: [ 'node_modules/**', 'public/**' ]
          ext: 'coffee'
          watch: [ __dirname ]
          delay: 2000
              
    ###
    https://github.com/gruntjs/grunt-contrib-watch
    dev 모드에서만, coffee를 watch하여 다시 컴파일
    ###
    watch:
      coffee:
        files: [
          'locales/**/*.coffee'
          'migrations/**/*.coffee'
          'routes/**/*.coffee'
          'tests/**/*.coffee'
          '*.coffee'
        ]
        tasks: [ 'coffee:dev' ]

    ###
    https://github.com/sindresorhus/grunt-concurrent
    dev 모드에서만 이용함. 여러개의 task를 동시에 실행시킴
    ###
    concurrent:
      debug: 
        tasks: [ 'nodemon', 'watch' ]
        options:
          logConcurrentOutput: true

    env:
      # options:
      dev:
        NODE_ENV: 'development'
      test:
        NODE_ENV: 'test'
      'test-verbose':
        NODE_ENV: 'test-verbose'
      prod:
        NODE_ENV: 'production'

    mochaTest:
      test:
        options:
          reporter: 'spec'
        src: [ 'tests/*.js' ]
      coverage: 
        options:
          reporter: 'html-cov'
          quiet: true
          captureFile: 'coverage.html'
        src: [ 'tests/*.js' ]

    exec:
      # migration: 'node migration.js'
      deploy: 
        cmd: (port = 9000) ->
          return  """ ssh ecesly "cd ~/ecesly; git pull; npm update; bower update; grunt compile; export PORT=#{port}; migrate; forever restart -l ecesly.log -o out.log -e err.log -a app-ecesly.js" """


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-exec'

  grunt.registerTask 'default', () ->
    grunt.log.writeln 'You can use: \n\tgrunt compile\n\tgrunt serve'
  grunt.registerTask 'compile', ['env:prod', 'coffee', 'uglify']
  grunt.registerTask 'test', ['env:test', 'coffee:dev', 'mochaTest:test']
  grunt.registerTask 'test-verbose', ['env:test-verbose', 'coffee:dev', 'mochaTest:test']
  # grunt.registerTask 'migrate', ['coffee:migration', 'exec:migration']
  grunt.registerTask 'coverage', ['env:test', 'coffee:dev', 'mochaTest:coverage']
  grunt.registerTask 'deploy', ['exec:deploy']
  grunt.registerTask 'serve', ['env:dev', 'coffee:dev', 'concurrent:debug']