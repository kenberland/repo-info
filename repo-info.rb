#!/usr/bin/env ruby

require 'bundler'

Bundler.require


class RepoReport
  def get_url path
    HTTParty.get(path,
                     :headers =>
                     {
                       'User-Agent' => 'Ruby Silly',
                       'Authorization' => "token #{ENV['TOKEN']}"
                     })
  end

  def report
    url = 'https://api.github.com/orgs/postmates/repos'
    loop do
      r = get_url(url)
      repos = JSON.parse(r.body)
      repos.each do |repo|
        lang = JSON.parse(get_url(repo['languages_url']).body)
        lang.each do|k,v|
          puts "#{repo['name']},#{k},#{v}"
        end
      end
      link = LinkHeader.parse(r.headers['Link']).links.select{ |l| l.attr_pairs.first.include?('next') }
      url = link.first.href rescue nil
      break unless url
    end
  end
end


rr = RepoReport.new
rr.report
