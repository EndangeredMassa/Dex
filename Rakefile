task :test do
  exec({"NODE_ENV"=>"test"}, "./node_modules/.bin/mocha --compilers coffee:coffee-script --reporter dot --require coffee-script --require test/test_helper.coffee --colors")
end
