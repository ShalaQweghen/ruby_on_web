require "socket"
require "json"

server = TCPServer.open(2000)

loop {
	client = server.accept
	request = client.gets
	verb = request.scan(/^\w+/)
	file = request.scan(/\w+\.\w+/)
	response = File.read("index.html")
	
	if verb[0] == "GET" && file[0] == "index.html"
  		client.puts("HTTP/1.0 200 OK")
  		client.puts("Date: #{Time.now.ctime}")
  		client.puts("Content-Type: text/html")
  		client.puts("Content-Length: #{response.size}")
  		client.puts
  		client.puts("#{response}")
  	elsif verb[0] == "POST"
		while line = client.gets
			request << line.chomp
			break if line =~ /^\s*$/
		end

  		length = request.scan(/Content-Length: \w+/).first.split.last.to_i
  		json_line = request.slice(-length..-1)

  		params = JSON.parse(json_line)
  		info = "<li>Name: #{params["viking"]["name"]}</li><li>Email: #{params["viking"]["email"]}</li>"
  		form = File.read("thanks.html").gsub(/<%= yield %>/, info)

  		client.puts("HTTP/1.0 200 OK")
  		client.puts("Date: #{Time.now.ctime}")
  		client.puts("Content-Type: text/html")
  		client.puts("Content-Length: #{form.size}")
  		client.puts
  		client.puts("#{form}")
  	else
  		client.puts("HTTP/1.0 404 Not Found")
  	end
  	client.close
}