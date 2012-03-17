# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection].each {|r| require r}
%w[mongo time digest/sha1 unicode_utils raser/utils/db/pgconnection raser/utils/db/myconnection].each {|r| require r}

module Physcon
	class Model
		attr_reader :mongo, :pg, :sphinx, :lib, :coms
		def initialize config={}
			if config['mongo'] && config['mongo']['host'] && config['mongo']['dbname']
				@mongo = Mongo::Connection.new(config['mongo']['host']).db(config['mongo']['dbname'])
			end
			if config['pg']
				@pg = Raser::Db::PgConnection.new(config['pg'])
				@pg.query "SET CLIENT_ENCODING TO 'WIN1251';"
			end
			if config['sphinx']
				@sphinx = Raser::Db::MyConnection.new(config['sphinx'])
			end
			@lib = Lib.new self, config
			@coms = Coms.new self, config
		end
	end
end

