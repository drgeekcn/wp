require 'faraday'

class VisitorsController < ApplicationController
  def index
    @res = []
    @wp = YAML.load_file(Rails.root.join('config', 'wordpower.yml'))
    p = params['p']
    word = @wp["#{p}"]
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
    input = q.length <= 20 ? q : q[0..9] + q.length + q[q.length - 11, q.length - 1]
    sign = Digest::SHA256.hexdigest("#{appKey}#{input}#{salt}#{curtime}#{secretKey}")
    url = "https://openapi.youdao.com/api?q=#{q}&from=en&to=zh-CHS&appKey=#{appKey}&salt=#{salt}&sign=#{sign}&signType=v3&curtime=#{curtime}&ext=mp3&voice=0&strict=false"
    res = Faraday.get(URI.encode(url))
  end


end
