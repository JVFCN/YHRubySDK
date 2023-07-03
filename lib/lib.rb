require 'json'
require 'net/http'
require 'uri'

class OpenApi
  attr_accessor :token

  BASE_URL = 'https://chat-go.jwzhd.com/open-apis/v1'

  def initialize(token)
    @token = token
  end

  def send_message(recv_id, recv_type, content)
    send_message_content(recv_id, recv_type, 'text', content)
  end

  def send_markdown_message(recv_id, recv_type, content)
    send_message_content(recv_id, recv_type, 'markdown', content)
  end

  def send_message_content(recv_id, recv_type, content_type, content)
    params = {
      recvId: recv_id,
      recvType: recv_type,
      contentType: content_type,
      content: content
    }
    headers = {'Content-Type' => 'application/json'}
    uri = URI("#{BASE_URL}/bot/send?token=#{@token}")
    http_post(uri, headers, params)
  end

  def batch_send_text_message(recv_ids, recv_type, content)
    batch_send_message(recv_ids, recv_type, 'text', content)
  end

  def batch_send_markdown_message(recv_ids, recv_type, content)
    batch_send_message(recv_ids, recv_type, 'markdown', content)
  end

  def batch_send_message(recv_ids, recv_type, content_type, content)
    params = {
      recvIds: recv_ids,
      recvType: recv_type,
      contentType: content_type,
      content: content
    }
    headers = {'Content-Type' => 'application/json'}
    uri = URI("#{BASE_URL}/bot/batch_send?token=#{@token}")
    http_post(uri, headers, params)
  end

  def edit_message(msg_id, recv_id, recv_type, content_type, content)
    params = {
      msgId: msg_id,
      recvId: recv_id,
      recvType: recv_type,
      contentType: content_type,
      content: content
    }
    headers = {'Content-Type' => 'application/json'}
    uri = URI("#{BASE_URL}/bot/edit?token=#{@token}")
    http_post(uri, headers, params)
  end

  private

  def http_post(uri, headers, params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = params.to_json
    http.request(request)
  end
end

class Subscription
  attr_accessor :on_message_normal_subscriber,
                :on_message_instruction_subscriber,
                :on_group_join_subscriber,
                :on_group_leave_subscriber,
                :on_bot_followed_subscriber,
                :on_bot_unfollowed_subscriber,
                :on_button_report_inline_subscriber

  def initialize
  end

  def listen(request)
    event_type = request['header']['eventType']
    event = request['event']

    case event_type
    when 'message.receive.normal'
      on_message_normal_subscriber.call(event)
    when 'message.receive.instruction'
      on_message_instruction_subscriber.call(event)
    when 'group.join'
      on_group_join_subscriber.call(event)
    when 'group.leave'
      on_group_leave_subscriber.call(event)
    when 'bot.followed'
      on_bot_followed_subscriber.call(event)
    when 'bot.unfollowed'
      on_bot_unfollowed_subscriber.call(event)
    when 'button.report.inline'
      on_button_report_inline_subscriber.call(event)
    end
  end
end