require "sinatra/activerecord/rake"
require_relative './app.rb'

task :default => :start

app = 'app'

desc "Start #{app} using the Thin webserver"
task :start do
  system('thin -p 4567 start')
end

desc "Start #{app} using the default webserver"
task :rackup do
  rackup
end

task :dbclean do
  system('test -f db/db.sql && rm -v db/db.sql')
end

