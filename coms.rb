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
		def get_conf_accepted_papers_list id
			id = id.to_i
			#@res_list = Physcon::App.model.pg.query_inject [], "SELECT * FROM paper where context=%s and finaldecision>1", id do |acc, row|
#			@res_list = Physcon::App.model.pg.query_inject [], "SELECT p.*, concatpaperauthors(%s, p.papnum) as authors FROM paper as p where p.context=%s and p.finaldecision>1", id, id do |acc, row|
			@res_list = Physcon::App.model.pg.query_inject [], "SELECT p.*, concatpaperauthors(%s, p.papnum) as authors FROM paper as p where p.context=%s and p.finaldecision>1 order by p.papnum desc", id, id do |acc, row|
				acc << row
				acc
			end
		end
		def get_conf_paper_info id, papnum
			id = id.to_i
			papnum = papnum.to_i
			Physcon::App.model.pg.query_one "SELECT p.*, concatpaperauthors(%s, p.papnum) as authors FROM paper as p where p.context=%s and p.papnum=%s and p.finaldecision>1", id, id, papnum
		end
		def get_conf_paper_authors id, papnum
			id = id.to_i
			papnum = papnum.to_i
			@model.pg.query_inject [], "
				SELECT a.*, u.*, t.shortstr AS usertitle, c.name AS countryname
				FROM
					((author AS a LEFT JOIN userpin AS u ON a.autpin=u.pin) 
					LEFT JOIN title AS t ON u.title=t.titleid)
					LEFT JOIN country AS c ON u.country=c.cid
				WHERE a.context=%s AND a.papnum=%s
				ORDER BY u.pin", id, papnum do |acc, row|
				acc << row
				acc
			end
		end
		def get_conf_paper_file id, papnum
			id = id.to_i
			papnum = papnum.to_i
			rez = nil
	#		row = Physcon::App.model.pg.query_one "SELECT * FROM paper WHERE context=%s AND papnum=%s", id, papnum
			row = @model.pg.query_one "SELECT * FROM paper WHERE context=%s AND papnum=%s", id, papnum
			if row && row['filetype'] && row['filetype'].length > 0
				file_path = Physcon::App.config['coms']['papers_path']+"c#{id}p#{papnum}"
	#			#file = File.open file_path
				rez = {
					file_path: file_path,
					#file: file,
					original_filename: row['filename'],
					content_type: row['filetype']
				}# if file
			end
			rez
		end

	end
end

