require 'rubygems'
require 'twilio-ruby'
require 'sinatra'
require 'httparty'
require 'pry-byebug'
require 'clockwork'
require 'date'
include Clockwork

def send_to_twilio(listing)
  account_sid='your key'
  auth_token='your token'
  client = Twilio::REST::Client.new account_sid, auth_token
  from = '+your phone '

  friends = {
    '+another phone' => 'chap'
  }
  friends.each do |key,value|
    client.messages.create(
      from: from,
      to: key,
      body: listing
    )
    puts "Sent message to #{value}"
  end
end

def get_reddit_JSON()
  url = 'https://www.reddit.com/r/frugalmalefashion/new.json?sort=new'
  response = HTTParty.get(url)
  response.parsed_response["data"]["children"].each do |x| 
    listing = x["data"]["title"]
    reddit_unix_timestamp = x["data"]["created_utc"].to_i
    current_timestamp=Time.now.to_i
    #all listings in the last minute +/- seconds error
    if ((reddit_unix_timestamp+300)>=current_timestamp)
      puts reddit_unix_timestamp
      puts "!!!!!!!!!!!!!!!!!!!"
      send_to_twilio(listing)
    end 
    puts listing
    puts current_timestamp
  end
  puts "done"
end

handler do |job|
    get_reddit_JSON()
    puts "Running #{job}"
end

def autoRun()
  every(5.minutes, 'job')
end

autoRun()








