#!/usr/bin/ruby
# encoding: utf-8

# Pass this script the URI of your microblog
# It will print out an HTML gallery of photos

$: << File.dirname(__FILE__) + '/lib'
require 'util'
require 'paginated_hatom_imgs'

# XXX: Maybe use a real templating engine?
puts '<!DOCTYPE html>'
puts '<html xmlns="http://www.w3.org/1999/xhtml"><head><title>µalbum</title>'
puts '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
puts '<style type="text/css">'
puts open('style.css').read
puts '</style>'
puts '</head><body>'
puts '<h1>µalbum</h1>'
puts '<ol>'
paginated_hatom_imgs(ARGV[0]).each do |img|
	puts "<li><img src='#{h img}' alt='' /></li>"
end
puts '</ol>'
puts '</body></html>'
