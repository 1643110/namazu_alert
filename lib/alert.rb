# -*- coding: utf-8 -*-

require 'net/smtp'
require 'rubygems'
require 'tmail'
require 'tlsmail'
require 'nkf'
require File.expand_path('./namazu.rb', File.dirname(__FILE__))
require 'yaml'

yml = YAML::load(File.open('config/mail.yml'))
sender = yml["smtp_settings"]
receiver = yml["receiver"]

namazu = Namazu.new
recs = namazu.show
ary = namazu.to_array(recs)
csv_rec = namazu.read_csv
lastest_id = csv_rec[csv_rec.length - 1][0]

i = 0
ary.each {|r|
   i+=1 if(r[0] <= lastest_id) # CSV出力済みの最新レコードと比較
}
ary.slice!(0..i-1) if(i > 0) # CSV出力済のデータは除外
exit if(ary.length == 0)
namazu.create_csv(ary)

namazu_yml = YAML::load(File.open('config/namazu.yml'))
message = namazu_yml["message"]

MESSAGE = <<EndOfMail
From: #{sender["user_name"]} <#{sender["user_address"]}>
To:  #{receiver["user_name"]} <#{receiver["user_address"]}>
Subject: 地震速報test #{Time.now}
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

#{message["introduction"]}

#{message["detection_date"]} #{ary[0][2]}
#{message["epicenter_location_name"]} #{ary[0][3]}
#{message["epicenter_coor_lat"]} #{ary[0][4]}
#{message["epicenter_coor_long"]} #{ary[0][5]}
#{message["magnitude"]} #{ary[0][7]}
#{message["intensity"]} #{ary[0][8]}
#{message["url"]} #{ary[0][12]}

#{message["after_mentioned"]}

EndOfMail
smtpserver = Net::SMTP.new(sender["domain"], sender["port"])
smtpserver.enable_tls(OpenSSL::SSL::VERIFY_NONE)

smtpserver.start(sender["server_name"], sender["user_address"], sender["password"], :login) do |smtp|
  smtp.send_message(MESSAGE, sender["user_address"], receiver["user_address"])
end 
