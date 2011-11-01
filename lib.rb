# coding: UTF-8

#%w[mongo time digest/sha1 unicode_utils].each {|r| require r}

module Physcon
	class Lib
		#LIB_DOC_CLASS = 'LIB:DOC:PAPER'
		LIB_DOC_CLASS = 'LIB:DOC'
		LIB_DOC_FILE_CLASS = 'LIB:DOC:FILE'
		attr_reader :mongo, :lib
		def initialize model, config={}
			@db = model.mongo
			@model = model
			@docs = @db['docs']
			@grid = Mongo::Grid.new @db, 'docs'
			@files = @db['docs.files']
		end
		def new_doc parent, dir, info
			_id = Physcon::SEQ[]
			ts = Physcon::TS[]
			@docs.insert({
				_id: _id,
				_meta: {class: LIB_DOC_CLASS, parent: parent, dir: dir, ctime: ts, mtime: ts},
				info: info
			})
		#	{
		#		'_id' => _id
		#	}
			_id
		end
		def get_doc_info id
			res = @docs.find_one({'_meta.class' => LIB_DOC_CLASS, '_id' => id})
			res ? res['info'] : nil
		end
		def set_doc_info id, info
			@docs.update({'_meta.class' => LIB_DOC_CLASS, '_id' => id}, {'$set' => {'info' => info, '_meta.mtime' => Physcon::TS[]}})
		#	{_id: id}
			id
		end
		def get_doc_authors id
			res = @docs.find_one({'_meta.class' => LIB_DOC_CLASS, '_id' => id})
			res && res['authors'] ? res['authors'] : []
		end
		def set_doc_authors id, authors
			@docs.update({'_meta.class' => LIB_DOC_CLASS, '_id' => id}, {'$set' => {'authors' => authors, '_meta.mtime' => Physcon::TS[]}})
		#	{_id: id}
			id
		end
		def remove_doc id
			if get_doc_children(id).empty?
				remove_doc_file id
				@docs.remove({
					_id: id,
					'_meta.class' => LIB_DOC_CLASS
				})
			end
		end
		def remove_docs list
			list.each do |doc|
				remove_doc doc['_id']
			end
		end
		def put_doc_file doc_id, input, args={}
			remove_doc_file doc_id
			ts = Physcon::TS[]
			_id = Physcon::SEQ[]
			args.merge!({_id: _id, _meta: {
				class: LIB_DOC_FILE_CLASS,
				parent: doc_id,
				ctime: ts,
				mtime: ts
			}})
			@grid.put input, args
			_id
		end
		def get_doc_file id
			@grid.get id if id
		end
		def remove_doc_file doc_id
			id = find_doc_file(doc_id)
			@grid.delete id if id
		end
		def find_doc_file doc_id
			res = @files.find_one( {'_meta.class' => LIB_DOC_FILE_CLASS, '_meta.parent' => doc_id} )
			#res = @files.find_one( {} )
			res ? res['_id'] : nil
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
			doc_id = nil
			d = @model.coms.get_conf_paper_info context, papnum
			if d
				doc_id = new_doc(id, false, {title: d['title'], abstract: d['abstract']})
				file_info = @model.coms.get_conf_paper_file context, papnum
				if file_info
					File.open file_info[:file_path] do |f|
						put_doc_file doc_id, f, file_info
					end
				end
				authors = @model.coms.get_conf_paper_authors(context, papnum).map do |row|
					{
						fname: row['fname'],
						lname: row['lname'],
						pin: row['pin']
					}
				#	row
				end
				set_doc_authors doc_id, authors
			end
			doc_id
		end
		def import_docs_from_coms id, list
			list.each do |doc|
				import_doc_from_coms id, doc['context'], doc['papnum']
				#d = @model.coms.get_conf_paper_info doc['context'], doc['papnum']
				#new_doc(id, false, {title: d['title'], abstract: d['abstract']})
			end
		end
		def remove_doc id
			remove_doc_file id
			@docs.remove({
				_id: id,
				'_meta.class' => LIB_DOC_CLASS
			}) if get_doc_children(id).empty?
		end
		def remove_docs list
			list.each do |doc|
				remove_doc doc['_id']
			end
		end
	end
end

