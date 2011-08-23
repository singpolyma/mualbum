# encoding: utf-8
require 'net/https'

# HTML/XML escape a string, based on CGI module
def h(string)
	string.to_s.gsub(/&/, '&amp;').gsub(/\"/, '&quot;').gsub(/>/, '&gt;').gsub(/</, '&lt;')
end

# Convert relative URI to absolute URI
def relative_to_absolute(uri, relative_to)
	return nil if uri.nil?
	uri = URI::parse(uri) unless uri.is_a?(URI)
	relative_to = URI::parse(relative_to) unless relative_to.is_a?(URI)
	return uri.to_s if uri.scheme
	uri.scheme = relative_to.scheme
	uri.host = relative_to.host
	if uri.path.to_s[0,1] != '/'
		uri.path = "/#{uri.path}" unless relative_to.path[-1,1] == '/'
		uri.path = "#{relative_to.path}#{uri.path}"
	end
	uri.to_s
end

# Basic HTTP recursive fetch function (follows redirects)
def fetch(topic, fetch=nil, temp=false)
	fetch = topic unless fetch
	fetch = URI::parse(fetch) unless fetch.is_a?(URI)
	fetch.path = '/' if fetch.path.to_s == ''
	response = nil
	http = Net::HTTP.new(fetch.host, fetch.port)
	http.use_ssl = true if fetch.scheme == 'https'
	http.start {
		response = http.get("#{fetch.path || '/'}#{"?#{fetch.query}" if fetch.query}", {
			'User-Agent' => 'µalbum',
			'Accept' => 'image/*, application/xhtml+xml; q=0.9, text/html; q=0.8'
		})
	}
	case response.code.to_i
		when 301 # Treat 301 as 302 if we have temp redirected already
			fetch(temp ? topic : response['location'], response['location'], temp)
		when 302, 303, 307
			fetch(topic, response['location'], true)
		when 200
			[topic, response]
		else
			raise response.body
	end
end
