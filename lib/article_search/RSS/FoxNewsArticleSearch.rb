require_relative '../TwitterWordSearch'
require_relative 'RSSGrabber'
require_relative 'RSSsearch'
require 'pry'

class FoxNewsArticleSearch < RSSGrabber
	include RSS_topic_search

	attr_reader :articles, :followers

	def initialize
		search = TwitterWordSearch.new
		@articles = get_response("http://feeds.foxnews.com/foxnews/most-popular")	
		@followers = search.get_follower_count("FoxNews")/1000000		
		@image = :media_content_url
		@articles = convert(self.articles)
		@articles.each do |article|
   			article[:source] = "Fox"

 		end 
	end

end

