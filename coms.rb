# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Coms
		#LIB_DOC_CLASS = 'LIB:DOC:PAPER'
		LIB_DOC_CLASS = 'LIB:DOC'
		attr_reader :mongo, :lib
		def initialize model, config={}
			@model = model
		end
		def get_confs_list
			#@res_list = Physcon::App.model.pg.query_inject [], "SELECT * FROM context WHERE status>100 and cont_type=2 ORDER BY contid DESC" do |acc, row|
			@res_list = Physcon::App.model.pg.query_inject [], "SELECT * FROM context ORDER BY contid DESC" do |acc, row|
				acc << row
				acc
			end
		end
	end
end
