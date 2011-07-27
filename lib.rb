# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Lib
		attr_reader :mongo, :lib
		def initialize model, config={}
#			if config['mongo'] && config['mongo']['host'] && config['mongo']['db_name']
#				@mongo = Mongo::Connection.new(config['mongo']['host']).db(config['mongo']['db_name'])
#			end
#			@lib = Lib.new config
		end
	end
end

