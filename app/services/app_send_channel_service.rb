class AppSendChannelService
  def initialize channel_name, user_ids = Account.ids
    @channel_name = channel_name
    @user_ids = user_ids
  end

  def send_late_checkin date
    app_with_channel = SlackAppWithChannel.find_by(app_id: ENV['SLACK_APP_ID'], channel_name: @channel_name)
    if !app_with_channel.nil? && !@user_ids.empty?
      # find time_infos by users_id
      users_right_checkin = []
      users_late_checkin = []
      @user_ids.each do |user_id|
        user = Account.find_by(id: user_id)
        late_checkin_minutes = user.late_checkin_minutes(date) if !user.nil?
        if !late_checkin_minutes.nil? && !user.nil?
          users_late_checkin << {id: user.id, name: user.name, late_checkin_minutes: late_checkin_minutes, check_in: user.first_checkin_time(date).strftime('%H:%M')} if late_checkin_minutes > 0
          users_right_checkin << {id: user.id, name: user.name, check_in: user.first_checkin_time(date).strftime('%H:%M')} if late_checkin_minutes == 0
        end
      end
      # message content
      # header message
      blocks = [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "@channel *NGÀY: #{date} - #{Time.now.strftime('%H:%M')}*"
          }
        }
      ]
      # body message
      users_right_checkin_text = ""
      users_right_checkin.each do |user_right_checkin|
        users_right_checkin_text += "\n#{user_right_checkin[:name]}: #{user_right_checkin[:check_in]}"
      end
      blocks += [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "CHẤM CÔNG (SÁNG) ĐÚNG GIỜ :white_check_mark:: #{users_right_checkin_text}"
          }
        }
      ]
      users_late_checkin_text = ""
      users_late_checkin.each do |user_late_checkin|
        users_late_checkin_text += "\n#{user_late_checkin[:name]}: #{user_late_checkin[:check_in]} (#{user_late_checkin[:late_checkin_minutes]} phút)"
      end
      blocks += [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "CHẤM CÔNG (SÁNG) MUỘN :X:: #{users_late_checkin_text}"
          }
        }
      ]

      message = {
        text: 'THÔNG BÁO THỜI GIAN CHẤM CÔNG',
        blocks: blocks.to_json
      }.to_json

      # send
      response = Faraday.post(app_with_channel.incoming_webhook, message)
      response.env.status == 200 ? true : false
    else
      false
    end
  end

  def send_early_checkout date
    app_with_channel = SlackAppWithChannel.find_by(app_id: ENV['SLACK_APP_ID'], channel_name: @channel_name)
    if !app_with_channel.nil? && !@user_ids.empty?
      # users_right_checkout, users_right_checkout  by users_id
      users_right_checkout = []
      users_early_checkout = []
      @user_ids.each do |user_id|
        user = Account.find_by(id: user_id)
        early_checkout_minutes = user.early_checkout_minutes(date) if !user.nil?
        if !early_checkout_minutes.nil? && !user.nil?
          users_early_checkout << {id: user.id, name: user.name, early_checkout_minutes: early_checkout_minutes, check_out: user.last_checkout_time(date).strftime('%H:%M')} if early_checkout_minutes > 0
          users_right_checkout << {id: user.id, name: user.name, check_out: user.last_checkout_time(date).strftime('%H:%M')} if early_checkout_minutes == 0
        end
      end
      
      # message content
      # header message
      blocks = [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "@channel *NGÀY: #{date} - #{Time.now.strftime('%H:%M')}*"
          }
        }
      ]
      # body message
      users_right_checkout_text = ""
      users_right_checkout.each do |user_right_checkout|
        users_right_checkout_text += "\n#{user_right_checkout[:name]}: #{user_right_checkout[:check_out]}"
      end
      blocks += [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "CHẤM CÔNG (CHIỀU) ĐÚNG GIỜ :white_check_mark:: #{users_right_checkout_text}"
          }
        }
      ]
      users_early_checkout_text = ""
      users_early_checkout.each do |user_early_checkout|
        users_early_checkout_text += "\n#{user_early_checkout[:name]}: #{user_early_checkout[:check_out]} (#{user_early_checkout[:early_checkout_minutes]} phút)"
      end
      blocks += [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "CHẤM CÔNG (CHIỀU) SỚM :X:: #{users_early_checkout_text}"
          }
        }
      ]
      
      message = {
        text: 'THÔNG BÁO THỜI GIAN CHẤM CÔNG',
        blocks: blocks.to_json
      }.to_json

      # send
      response = Faraday.post(app_with_channel.incoming_webhook, message)
      response.env.status == 200 ? true : false
    else
      false
    end
  end
end
