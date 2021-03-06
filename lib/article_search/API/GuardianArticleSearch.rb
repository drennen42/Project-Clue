require 'awesome_print'
require 'json'
require 'date'
require 'pry'
require_relative 'APIProcesser'

class GuardianArticleSearch < APIProcesser

  attr_reader :articles

  GUARDIAN_APP_KEY = "sfrv3wukd7uaw7amha8cd2e6"
  GUARDIAN_BASE_SEARCH_URL = "http://content.guardianapis.com/search?"
  POPULARITY_CUTOFF = 100

  def search(keywords, lookup_date=Date.today)
    response = get_raw_articles(keywords, lookup_date)
    format(response)
  end

  def get_raw_articles(keywords, lookup_date)
    begin_date = lookup_date.prev_day.strftime('%Y-%m-%d')
    end_date = lookup_date.strftime('%Y-%m-%d')
    @processed_url = GUARDIAN_BASE_SEARCH_URL + "api-key=" + GUARDIAN_APP_KEY + "&show-fields=main" + "&q=" + keywords.split(" ").join("%20") + "&from-date=" + begin_date + "&end-date=" + end_date
    return JSON.parse(get_request)["response"]["results"]
  end

  def format(response)
    @articles = []
    response.each do |item|
      article = { title: item["webTitle"],
        url: item["webUrl"],
        published_at: item["webPublicationDate"],
        source: "The Guardian"}
      if article[:image_url] == ""
        article[:image_url] = "http://www.thehaasbrothers.com/hsite/wp-content/uploads/2014/04/guardian-logo.jpg"
      end
      @articles << article
    end
    return @articles
  end
end