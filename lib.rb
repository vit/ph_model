# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Lib
		attr_reader :mongo, :lib
		def initialize model, config={}
			@model = model
			@docs = model.mongo['docs']
		end
		def new_doc id
			_id = Physcon::SEQ[]
			{
				_id: _id
			}
		end
		def get_doc_info id
			{
				title: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
				abstract: 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
			}
		end
	end
end

