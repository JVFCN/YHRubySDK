# YHRubySDK
这是一个适用于[云湖](https://www.yhchat.com)的**Ruby**SDK  
使用此SDK, 您可以轻松的创建云湖机器人  
---
下面是一个简单的示例:

```ruby
require 'sinatra'
require 'json'
require_relative '../lib/lib'

set :port, 7888

TOKEN = 'TOKEN'
client = OpenApi.new(TOKEN)

def handle_message_normal(event)
  puts "Received normal message: #{event}"
  OpenApi.new(TOKEN).send_message(event["sender"]["senderId"], "user", { "text": "Hello World!" })
end

def handle_message_instruction(event)
  puts "Received instruction message: #{event}"
end

subscription = Subscription.new
subscription.on_message_normal_subscriber = method(:handle_message_normal)
subscription.on_message_instruction_subscriber = method(:handle_message_instruction)

post '/sub' do
  request_body = request.body.read
  incoming_event = JSON.parse(request_body)

  subscription.listen(incoming_event)

  status 200
  body 'OK'
end
```
