# encoding: utf-8
require 'nokogiri'

$: << File.dirname(__FILE__)
require 'util'
require 'find_photo_uri'

# FIXME: slow, maybe parallelize the requests?
def paginated_hatom_imgs(uri, depth = 0)
	final_uri, page = fetch(uri)
	doc = Nokogiri::parse(page.body)
	imgs = doc.search('.entry-content a').map do |el|
		next if el.attributes['rel'].to_s =~ /(?:^|\s)(?:tag|bookmark)(?:\s|$)/i
		next if el.attributes['class'].to_s =~ /(?:^|\s)(?:url|response|username|hashtag)(?:\s|$)/i
		relative_to_absolute(el.attributes['href'].to_s, final_uri)
	end.compact.uniq.map do |uri|
		find_photo_uri(uri) rescue nil
	end.compact.uniq.reject do |uri|
		uri =~ /logo|avatar/
	end

	if imgs.length < 10 && depth < 5
		if (n = doc.at('*[rel~="next"]'))
			imgs + paginated_hatom_imgs(relative_to_absolute(
				n.attributes['href'].to_s, final_uri), depth+1)
		end
	end

	imgs
end
