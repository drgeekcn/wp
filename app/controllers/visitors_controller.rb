require 'faraday'

class VisitorsController < ApplicationController
  def index
    @res = []
    @page = []
    wp = YAML.load_file(Rails.root.join('config', 'wordpower.yml'))
    wp.try(:each) do |page|
      @page << page[0]
    end

    p = params['p']
    word = wp["#{p}"]
    word.try(:each) do |w|
      tw = []
      w.split('/').each do |sw|
        tw << JSON.parse(translate(sw).body)
      end
      @res << { w: w, tw: tw }
    end
  end

  private

  def translate (q)
    curtime = Time.now.to_i.to_s
    appKey = '07ecdb39602879db'
    salt = SecureRandom.uuid
    secretKey = '8r02NTGupU72wdrA3vDPBmhekS11qx1z'
    input = q.length <= 20 ? q : q.first(10).to_s + q.length.to_s + q.last(10).to_s
    sign = Digest::SHA256.hexdigest("#{appKey}#{input}#{salt}#{curtime}#{secretKey}")
    url = "https://openapi.youdao.com/api?q=#{q}&from=en&to=zh-CHS&appKey=#{appKey}&salt=#{salt}&sign=#{sign}&signType=v3&curtime=#{curtime}&ext=mp3&voice=0&strict=false"
    res = Faraday.get(URI.encode(url))
  end


end
