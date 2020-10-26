require 'faraday'
require 'open-uri'

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
        filename = "#{p}_#{sw}"
        mp3_file_path = '/tmp/' + filename + '.mp3'
        translate_file_path = Rails.root.join('public', 'tmp', filename + '.txt').to_s
        break unless File.exist?(translate_file_path)
        translate_text = File.read(translate_file_path)
        tw << { query: sw, translate_text: translate_text, speakUrl: mp3_file_path }
      end
      @res << { w: w, tw: tw }
    end

    # 生成文件
    if params['g']
      word.try(:each) do |w|
        tw = []
        w.split('/').each do |sw|
          t = JSON.parse(translate(sw).body)
          filename = "#{p}_#{sw}"
          save_translate(t, filename)
        end
      end
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

  def save_translate(translate, filename)
    mp3_file_path = Rails.root.join('public', 'tmp', filename + '.mp3').to_s
    translate_file_path = Rails.root.join('public', 'tmp', filename + '.txt').to_s

    File.open(translate_file_path, 'wb') do |f|
      if translate['web']
        f.write(translate['web'][0]['value'].join('，'))
      else
        f.write(translate['translation'].join('，'))
      end
    end

    File.open(mp3_file_path, 'wb') do |f|
      f << open(translate['speakUrl']).read
    end

  end


end
