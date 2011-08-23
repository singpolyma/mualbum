# encoding: utf-8
$: << File.dirname(__FILE__)
require 'util'
require 'nokogiri'

def get_attr(doc, selector, attr, filter=nil)
	nodes = doc.search(selector)
	node = (filter ? nodes.select(&filter) : nodes).first
	return nil if node.nil?
	if (a = node.attributes[attr])
		a.to_s
	end
end

def find_photo_uri(uri)
	final_uri, response = fetch(uri)
	type = response['content-type'].split(/;/,2).first.strip
	relative_to_absolute(case type
		when /^image\//
			final_uri
		when /html/
			get = method(:get_attr).to_proc.curry[Nokogiri::parse(response.body)]
			# If I use a block instead of a lambda argument, it stays bound
			get.call('*[rel~="alternate"]', 'src', lambda {|el| el.attributes['type'] =~ /^image\// }) ||
			get.call('.entry-content > img:first-child', 'src') ||
			get.call('img#photo, #photo img.photo, #photo img, #PhotoContainer img', 'src') ||
			get.call('meta[property="og:image"]', 'content') ||
			get.call('link[rel~="image_src"]', 'href')
		else
			raise "Unsupported MIME type: #{type}"
	end, final_uri)
end
