require 'rubygems'
require 'mechanize'
require 'pg'

require './db/connection'
require './db/model_base'
require './db/resource'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# puts a.resolve('https://medium.com/').to_s
page = a.get('https://medium.com/')
# page.links.each do |link|
#   puts [link.text, link.uri]
# end
#   search_result.links.each do |link|
#     puts link.text
#   end
# end

conn = DB::Connection.create_connection #PG.connect( dbname: 'site_crawler', user: 'site_crawler' )
# conn.create_resources
puts conn.query_resources.inspect

Resource.find_by({})
# res = conn.query("SELECT * FROM resources")
# puts res.inspect
# conn.query("SELECT * FROM resources")  do |result|
#         puts result.to_a.inspect
#       end


