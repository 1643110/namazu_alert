require 'rexml/document'
require 'open-uri'
require 'csv'
require 'yaml'

class Namazu

  def initialize
    yml = YAML::load(File.open('config/namazu.yml'))
    @file_name = yml["csv"]["file_name"]
  end
 
  def show
    url = 'http://nmz.mogken.com/api?c=10&f=xml'
    result = open(url)
    doc = REXML::Document.new(result).elements['result']
    results = xml2sym(doc)
    results
  end

  def create_csv(recs)
    CSV.open(@file_name, "a") do |writer|
      recs.each {|rec| writer << rec }
    end
  end

  def read_csv
    recs = CSV.read(@file_name)
    recs
  end

  def to_array(results)
    i = 0
    ary = Array.new(results.length,13)
    results.each do |ret|
      ary[i] = Array.new
      ary[i][0] = ret[:jishin_id]
      ary[i][1] = ret[:report_date]
      ary[i][2] = ret[:detection_date]
      ary[i][3] = ret[:epicenter_location_name]
      ary[i][4] = ret[:epicenter_coor_lat]
      ary[i][5] = ret[:epicenter_coor_long]
      ary[i][6] = ret[:depth]
      ary[i][7] = ret[:magnitude]
      ary[i][8] = ret[:intensity]
      ary[i][9] = ret[:epicenter_position]
      ary[i][10] = ret[:update_date]
      ary[i][11] = ret[:reach_estimations]
      ary[i][12] = ret[:url]
      ary[i][13] = ret[:short_url]
      i += 1
    end
    ret = ary.sort{|a,b| a[0] <=> b[0]}   #sort by jishin_id
    ret
  end

  private
  def xml2sym(doc)
    res = Array.new
    return res if doc.nil?
    doc.each_element{|item|
      hash = Hash.new
      item.each_element{|e|
        hash[e.name.to_sym] = e.text
      }
      res << hash
    }
    res
  end
 
end
