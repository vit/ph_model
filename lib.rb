# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Lib
		LIB_DOC_CLASS = 'LIB:DOC'
		attr_reader :mongo, :lib
		def initialize model, config={}
			@model = model
			@docs = model.mongo['docs']
		end
		def new_doc parent, dir, info
			_id = Physcon::SEQ[]
			ts = Physcon::TS[]
			@docs.insert({
				_id: _id,
				_meta: {class: LIB_DOC_CLASS, parent: parent, dir: dir, ctime: ts, mtime: ts},
				info: info
			})
			{
				_id: _id
			}
		end
		def get_doc_info id
			res = @docs.find_one({'_meta.class' => LIB_DOC_CLASS, '_id' => id})
			res ? res['info'] : nil
		end
		def get_doc_children id
			@docs.find(
				{'_meta.class' => LIB_DOC_CLASS, '_meta.parent' => id}
			).map do |d|
				{
					_id: d['_id'],
					info: d['info']
				}
			end
		end
	end
end

