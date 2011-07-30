# coding: UTF-8

module Physcon

	curr_path =  File.expand_path('../', __FILE__)
	%w[model lib].each{ |r| require "#{curr_path}/#{r}" }

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


