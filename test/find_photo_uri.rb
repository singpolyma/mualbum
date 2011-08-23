# encoding: utf-8
require 'minitest/autorun'

$: << File.dirname(__FILE__) + '/../lib'
require 'find_photo_uri'

class FakeResponse
	attr_reader :body

	def initialize(f)
		@body = open(File.dirname(__FILE__) + '/' + f).read
	end

	def [](k)
		return 'text/html' if k =~ /^content-type$/i
	end
end

class TestFindPhotoURI < MiniTest::Unit::TestCase
	[
		['flickr', 'http://www.flickr.com/photos/500hats/50282408/',
		 'http://farm1.static.flickr.com/31/50282408_a362c542a5.jpg'],
		['twitpic', 'http://twitpic.com/6a4zlt',
		 'http://s3.amazonaws.com/twitpic/photos/large/379825985.jpg?AWSAccessKeyId=AKIAJF3XCCKACR3QDMOA&Expires=1314060517&Signature=nv188f%2FNqsJt8cyDE364Ax8pI7c%3D'],
		['yfrog', 'http://yfrog.com/h0sadtej',
		 'http://a.yfrog.com/img612/4825/sadte.jpg'],
		['google', 'http://google.com', nil],
		['techcrunch', 'http://techcrunch.com/2011/08/21/linuxcon-open-source-is-an-ecosystem-not-a-zero-sum-game/', nil],
		['identica', 'http://identi.ca/attachment/51334196',
		 'http://file.status.net/i/identica/mahmood-20110817T172308-lqy75yt.jpeg'],
		['zooomr', 'http://www.zooomr.com/photos/timelord25/10055468/',
		 'http://static.zooomr.com/images/10055468_705cb85f63.jpg'],
		['instagram', 'http://instagr.am/p/LArpD/',
		 'http://images.instagram.com/media/2011/08/22/6e72127c2b9e498d8a0426eb9424bfa4_7.jpg'],
		['imgur', 'http://imgur.com/gallery/vuQXR',
		 'http://i.imgur.com/vuQXR.png']
	].each do |(key, page, photo)|
		define_method("test_#{key}") {
			Object.send(:define_method, :fetch) { |uri|
				[page, FakeResponse.new("#{key}.html")]
			}

			assert_equal photo, find_photo_uri(page)
		}
	end
end
