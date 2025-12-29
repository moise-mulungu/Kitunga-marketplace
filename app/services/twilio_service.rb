require 'twilio-ruby'

class TwilioService
  def self.send_otp(phone_number, otp)
    client = Twilio::REST::Client.new(ENV['KITUNGA_MARKET_TWILIO_ACCOUNT_SID'], ENV['KITUNGA_MARKET_TWILIO_AUTH_TOKEN'])

    client.messages.create(
      from: ENV['KITUNGA_MARKET_TWILIO_PHONE_NUMBER'],
      to: phone_number,
      body: "Your Kitunga verification code is: #{otp}"
    )
  end
end