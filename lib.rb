# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Lib
		#LIB_DOC_CLASS = 'LIB:DOC:PAPER'
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
				#info: {'title' => 'qqq %', 'abstract' => 'www %'}
			})
			{
				'_id' => _id
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
					'_id' => d['_id'],
					'info' => d['info']
				}
			end
		end
		def get_doc_ancestors id
			rez = []
			while true do
				doc = @docs.find_one( {'_meta.class' => LIB_DOC_CLASS, '_id' => id} )
				d = nil
				if doc && doc['_meta']
					d = {
						'_id' => id,
						'title' => doc['info']['title']
					}
					id = doc['_meta']['parent']
				end
				break unless d
				rez.unshift d
			end
			rez
		end
		def import_doc_from_coms id, context, papnum
			d = @model.coms.get_conf_paper_info context, papnum
			new_doc(id, false, {title: d['title'], abstract: d['abstract']})
		end
		def import_docs_from_coms id, list
			list.each do |doc|
				import_doc_from_coms id, doc['context'], doc['papnum']
				#d = @model.coms.get_conf_paper_info doc['context'], doc['papnum']
				#new_doc(id, false, {title: d['title'], abstract: d['abstract']})
			end
		end
	end
end

