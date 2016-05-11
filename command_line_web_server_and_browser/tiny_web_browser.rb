require "socket"
require "json"

host = "localhost"
port = 2000
path = "/index.html"
puts "What type of request would you like to make [GET/POST]?"
verb = gets.chomp.upcase

case verb
when "POST"
	puts "What is your viking's name?"
	name = gets.chomp
	puts "What is your viking's email?"
	email = gets.chomp
	params = {:viking => {:name => name, :email => email}}
	request = "#{verb} HTTP/1.0\nContent-Length: #{params.to_json.size}\n#{params.to_json}\r\n\r\n"
when "GET"
	request = "#{verb} #{path} HTTP/1.0\r\n\r\n"
end

socket = TCPSocket.open(host, port)
socket.print(request)
response = socket.read
headers, body = response.split("\n\n", 2)

puts headers.split.include?("200") ? body : headers