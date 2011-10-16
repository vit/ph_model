# coding: UTF-8

module Physcon

	curr_path =  File.expand_path('../', __FILE__)
	%w[model lib].each{ |r| require "#{curr_path}/#{r}" }

	TS = -> { Time.now.utc.iso8601(10) }
	IdSeq = -> args=({}) {
		domain = (args[:domain] || 'localhost').to_s
		limit = (args[:size] || 40).to_i - 1
		-> { ( Digest::SHA1.new << domain+rand.to_s+TS[] ).to_s[0..limit] }
	}
	SEQ = IdSeq[domain: 'localhost', size: 12]

	class App
		class << self
		#	attr_reader :config, :model
			attr_reader :config
			def model
			#	@model = Model.new @config unless @model
				@model ||= Model.new @config
				@model
			end
		end
		def self.init file
			config0 = YAML::load( open(file, "r:UTF-8") )
		#	puts config0
			env = Rails.env
			@config = config0 && config0[env] ? config0[env] : {}
	#		@model = Model.new @config
		#	puts @config
		#	puts Rails.env
		end
	end

end


