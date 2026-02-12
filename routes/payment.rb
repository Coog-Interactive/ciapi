require 'stripe'
require 'sinatra'
require 'json'
require 'httparty'
require 'dotenv/load'

settings.environment = ENV['APP_ENV']
DISCORD_WEBHOOK = ENV['DISCORD_WEBHOOK']
ENDPOINT_SECRET = ENV['STRIPE_ENDPOINT_SECRET']
Stripe.api_key = ENV['STRIPE_API_KEY']

if settings.environment == :development
  get '/payment' do
    "<h1>Test!</h1><form action='/payment' method='POST'><button type='submit'>Checkout</button></form>"
  end
end

post '/payment' do
  session = Stripe::Checkout::Session.create({
    line_items: [{
      price_data: {
        currency: 'usd',
        product_data: {
          name: 'Membership'
        },
        unit_amount: 1000,
      },
      quantity: 1
    }],
    mode: 'payment',
    cancel_url: 'https://cooginteractive.com/club',
    success_url: 'https://cooginteractive.com/club/pay-success',
    custom_fields: [
      {
        key: 'uh-id',
        label: {
          custom: 'UH ID#',
          type: 'custom',
        },
        type: 'numeric',
        numeric: {
          minimum_length: 7,
          maximum_length: 7,
        }
      },
      {
        key: 'discord-username',
        label: {
          custom: 'Discord Username',
          type: 'custom',
        },
        type: 'text',
      }
    ],
    custom_text: {
      submit: {
        message: "We also accept Cash. Inquire on Discord."
      }
    },
    branding_settings: {
      display_name: 'Coog Interactive',
      button_color: '#C8102E'
    }
  })

  redirect session.url, 303
end

get '/payment/success' do
  erb :success
end

post '/payment/webhook' do
  payload = request.body.read
  event = nil

  begin
    event = Stripe::Event.construct_from(JSON.parse payload, symbolize_names: true)
  rescue JSON::ParserError => e
    puts "JSON Parser Error: #{e.message}"
    status 400
    return
  end

  if ENDPOINT_SECRET
    signature = request.env['HTTP_STRIPE_SIGNATURE']
    begin
      event = Stripe::Webhook.construct_event(payload, signature, ENDPOINT_SECRET)
    rescue Stripe::SignatureVerificationError => e
      puts "Webhook Signature Verification Failed: #{e.message}"
      status 400
    end
  end

  case event.type
  when 'checkout.session.completed'
    checkout_session = event.data.object
    puts "#{checkout_session.custom_fields[1].text.value} Purchased a membership!"
    HTTParty.post(DISCORD_WEBHOOK, {
      body: {
        content: "## #{checkout_session.custom_fields[1].text.value} purchased a membership! \n- UH ID#: #{checkout_session.custom_fields[0].numeric.value} \n- Email: #{checkout_session.customer_details.email}"
      }
    })
    puts checkout_session
  end
  status 200
end