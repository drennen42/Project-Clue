# Use these within this file:
# require "./../GetKeywords"
# require "./../Requests_and_Responses"

# Use these when calling this from an external file:
require_relative 'TwitterWordSearch'
require "./GetKeywords"
require "./Requests_and_Responses"
require 'pry'
require 'date'

require 'awesome_print'
# require 'Date'
class NewYorkTimesSearch
  attr_accessor :searched_articles
  attr_reader :followers

  NYT_APP_KEY = "295f07d2db55fce19a6bdd330412d2ff:0:70154133"
  NY_BASE_SEARCH_URL = "http://api.nytimes.com/svc/search/v2/articlesearch.json?"
  include GetKeywords
  include Requests_and_Responses

  def initialize
    @searched_articles = []
    search = TwitterWordSearch.new
    @followers = search.get_follower_count("nytimes")/1000000
  end

  def search(keyword)
    searched_articles = []
    timespan = Date.today.prev_day.strftime.gsub(/-/, "")
    # http://api.nytimes.com/svc/search/v2/articlesearch.json?q=Ebola&begin_date=20141110&api-key=295f07d2db55fce19a6bdd330412d2ff:0:70154133
    url = NY_BASE_SEARCH_URL + "q=" + keyword.split(" ").join("+") + "&begin_date=" + timespan + "&api-key=" + NYT_APP_KEY
    response = JSON.parse(get_request(url))["response"]
    response["docs"].each do |item|
      if item["multimedia"].length < 2
        2.times do #most hacky thing ever
          yolo = "http://blog.mpp.org/wp-content/uploads/2014/01/New-York-Times-Logo.png"
        end
      else
        yolo = "http://static01.nyt.com/" + item["multimedia"][1]["url"]
      end

      article = { title: item["headline"]["main"],
                  url: item["web_url"],
                  image_url: yolo,
                  abstract: item["snippet"],
                  published_at: item["pub_date"],
                  source: "New York Times"
                }

      searched_articles << article
    end
    # return get_popularity(searched_articles)
    searched_articles.each do |article|
      article[:twitter_pop] = get_twitter_popularity(article[:url]).to_i/followers
      unless article[:twitter_pop] == nil && article[:facebook_pop] == nil
        article[:total_popularity] = article[:twitter_pop].to_i + article[:facebook_pop].to_i
      end
    end
    sorted = searched_articles.sort_by!{ |article| article[:twitter_pop] }
    sorted.reverse!
    return sorted
  end

  def search_with_date(keyword, breakout_date)
    searched_articles = []
    begin_date = breakout_date.prev_day.strftime.gsub(/-/, "")
    end_date = breakout_date.next_day.strftime.gsub(/-/, "")
    # http://api.nytimes.com/svc/search/v2/articlesearch.json?q=Ebola&begin_date=20141110&api-key=295f07d2db55fce19a6bdd330412d2ff:0:70154133
    url = NY_BASE_SEARCH_URL + "q=" + keyword.split(" ").join("+") + "&begin_date=" + begin_date + "&end_date=" + end_date + "&api-key=" + NYT_APP_KEY
    response = JSON.parse(get_request(url))["response"]
    #build the hash
    response["docs"].each do |item|
      if item["multimedia"].length < 2
        2.times do #most hacky thing ever
          yolo = "http://blog.mpp.org/wp-content/uploads/2014/01/New-York-Times-Logo.png"
        end
      else
        yolo = "http://static01.nyt.com/" + item["multimedia"][1]["url"]
      end

      article = { title: item["headline"]["main"],
                  url: item["web_url"],
                  abstract: item["snippet"],
                  image_url: yolo,
                  published_at: item["pub_date"],
                  source: "New York Times"
                }
      searched_articles << article
    end

    #get twitter popularity
    searched_articles.each do |article|
      article[:twitter_pop] = get_twitter_popularity(article[:url]).to_i/followers
    end
    sorted_articles = searched_articles[0..9].sort_by!{ |article| article[:twitter_pop] }
    sorted_articles.reverse!

    #get rid of articles with < 100 tweets
    sorted_articles.select!{|article| article[:twitter_pop].to_i > 100}
    sorted_articles[0..3]
  end

  def get_popularity(articles)
    articles.each do |article|
      article[:twitter_pop] = get_twitter_popularity(article[:url])
      article[:facebook_pop] = get_facebook_popularity(article[:url])

      unless article[:twitter_pop] == nil && article[:facebook_pop] == nil
        article[:total_popularity] = article[:twitter_pop].to_i + article[:facebook_pop].to_i
      end
    end
    return sort_by_pop
  end

  def sort_by_pop
    sorted = @searched_articles.sort_by!{ |article| article[:total_popularity] }
    # @searched_articles = sorted.reverse
    return @searched_articles
  end
end

# nyt_search = NewYorkTimesSearch.new
# nyt_search.search("Ebola")
# ap nyt_search.searched_articles
