require "jumpstart_auth"
require "bitly"
require "klout"

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
			when "q" then puts "Goodbye!"
			when "t" then tweet(parts[1..-1].join(" "))
			when "dm" then dm(parts[1], parts[2..-1].join(" "))
			when "spam" then spam_my_followers(parts[1..-1].join(" "))
			when "elt" then everyones_last_tweet
			when "s" then shorten(parts[-1])
			when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
			when "k" then klout_score
			else
				puts "Sorry, I don't know to #{command}"
			end
		end
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else
			puts "You exceeded the permitted length for a tweet!"
		end
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?(target)
			puts "Trying to send #{target} this direct message:"
			puts message
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "You can only dm your followers!"
		end
	end

	def followers_list
		screen_names = [] 
		@client.followers.each do |follower|
			screen_names << @client.user(follower).screen_name
		end
		return screen_names
	end

	def spam_my_followers(message)
		followers_list.each { |follower| dm(follower, message) }
	end

	def everyones_last_tweet
		friends = @client.friends
		friends = friends.sort_by { |friend| @client.user(friend).screen_name.downcase }
		friends.each do |friend|
			timestamp = @client.user(friend).status.created_at
			puts "#{@client.user(friend).screen_name} said this on #{timestamp.strftime("%A, %b %d")}"
			puts @client.user(friend).status.from_user
			puts "\n"
		end
	end

	def shorten(original_url)
		puts "Shortening this URL: #{original_url}"
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		return bitly.shorten(original_url).short_url
	end

	def klout_score
		Klout.api_key = "xu9ztgnacmjx3bu82warbr3h"
		screen_names = @client.friends.collect { |follower| @client.user(follower).screen_name }
		screen_names.each do |name|
			identity = Klout::Identity.find_by_screen_name(name)
			user = Klout::User.new(identity.id)
			puts "#{name}'s Klout score is #{user.score.score}"
			puts "\n"
		end
	end
end

blogger = MicroBlogger.new
blogger.run