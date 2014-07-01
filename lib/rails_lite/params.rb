require 'uri'

class Params
	# use your initialize to merge params from
	# 1. query string
	# 2. post body
	# 3. route params
	def initialize(req, route_params = {})
		@params = {}
		@permitted_keys = []
		@params.merge!(parse_www_encoded_form(req.body)) if req.body
		@params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
		@params.merge!(route_params)
	end

	def [](key)
		@params[key]
	end

	def permit(*keys)
		@permitted_keys += keys
	end

	def require(key)
		raise AttributeNotFoundError unless @params.keys.include? key
	end

	def permitted?(key)
		@params.keys.each do |key|
			@params.delete(key) unless @permitted_keys.include? key
		end
		@params.include? key
	end

	def to_s
		@params.to_s
	end

	class AttributeNotFoundError < ArgumentError; end;

	# private
	# this should return deeply nested hash
	# argument format
	# user[address][street]=main&user[address][zip]=89436
	# should return
	# { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
	def parse_www_encoded_form(www_encoded_form)
		query_array = URI.decode_www_form(www_encoded_form)
		query_hash = {}

		query_array.each do |key_pair|
			inner_hash = query_hash
			keys = key_pair.first
			value = key_pair.last
			keys = keys.split(/\]\[|\[|\]/)
			keys.each_with_index do |key, index|
				if index == keys.length - 1
					inner_hash[key] = value
				else
					inner_hash[key] ||= {}
					inner_hash = inner_hash[key]
				end
			end
		end
		query_hash
	end

	# this should return an array
	# user[address][street] should return ['user', 'address', 'street']
	def parse_key(key)
		
	end
end
