=begin
module Physcon
	class Model
		def initialize args={}
		end
	end
	class App
		class << self
			attr_reader :config, :model
		end
		def self.init file
			config0 = YAML::load( open(file, "r:UTF-8") )
		#	puts config0
			env = Rails.env
			@config = config0 && config0[env] ? config0[env] : {}
			@model = Model.new @config
		#	puts @config
		#	puts Rails.env
		end
	end
end

=end
