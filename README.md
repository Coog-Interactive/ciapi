# Ciapi
The backend for [cooginteractive.com](https://cooginteractive.com)!

## Development
Install all dependencies:
```
bundle install
```
Run the application:
```
ruby app.rb
```

## Testing The Payment System
You will need a Discord account and the Stripe CLI to test the payment system.
### 1. Have Stripe CLI listen for and forward webhook requests
```
./stripe listen --forward-to localhost:4567/payment/webhook
```
### 2. Populate the `.env` file with the following environement variables:
1. `DISCORD_WEBHOOK` You can create one for your testing.
2. `STRIPE_API_KEY` You can use Stripe's public sample key available in their docs.
3. `STRIPE_ENDPOINT_SECRET` You will get this from the `stripe` CLI when you have it start listening.

### 3. Start the Ruby App
```
ruby app.rb
```
Afterwards, go to http://localhost:4567/payment to see it live and test it.
