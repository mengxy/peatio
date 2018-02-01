require 'binance'
require 'eventmachine'
require 'rubygems'
require 'json'

require 'peatio_client'

bsymbol = ARGV[0]
puts "Miss binance's symbol ..." unless bsymbol
symbols = {"ethbtc" => "ethbtc", "ethusdt" => "ethusd", "btcusdt" => "btcusd"}
psymbol = symbols["#{bsymbol}"]

foo_client = PeatioAPI::Client.new access_key: 'K0uzOeAdWH4bSrJVUUznxc0sNxizZ8hhPxxHpKHW',
                               secret_key: 'tVz1MLIdR5QzJs9EzytbgonP1PQjqxVxxV86HC09',
                               endpoint: 'http://allin.co.in:3000', timeout: 60
bar_client = PeatioAPI::Client.new access_key: 'fel24JUOsQtEP3rxnqrmjabnwxtb8m8Bxx6Jth4N',
                               secret_key: '8V04pNJtgoorCsUP1wIZRxteHqn0JwtNQRnhMgCX',
                               endpoint: 'http://allin.co.in:3000', timeout: 60

client = Binance::Client::WebSocket.new
EM.run do
  # Create event handlers
  open    = proc { puts 'connected' }
  error   = proc { |e| puts e }
  close   = proc { puts 'closed' }
  message = proc { |e|
                    json = JSON.parse(e.data, symbolize_names: true)
                    json[:bids].each do |bid|
                      p "#{psymbol} bid: #{bid[0]} #{bid[1]}"
                      bar_client.post '/api/v2/orders', market: psymbol, side: 'buy', volume: bid[1], price: bid[0]
          sleep 3
                    end
                    json[:asks].each do |ask|
                      p "#{psymbol} ask: #{ask[0]} #{ask[1]}"
                      foo_client.post '/api/v2/orders', market: psymbol, side: 'sell', volume: ask[1], price: ask[0]
          sleep 3
                    end
                 }

  # Bundle our event handlers into Hash
  methods = { open: open, message: message, error: error, close: close }

  # Pass a symbol and event handler Hash to connect and process events
  #client.agg_trade symbol: 'XRPETH', methods: methods

  # kline takes an additional named parameter
  #client.kline symbol: 'XRPETH', interval: '1m', methods: methods

  # As well as partial_book_depth
  client.partial_book_depth symbol: bsymbol, level: '5', methods: methods

  # Create a custom stream
  #client.single stream: { type: 'aggTrade', symbol: 'XRPETH'}, methods: methods

  # Create multiple streams in one call
  #client.multi streams: [{ type: 'aggTrade', symbol: 'XRPETH' },
  #                       { type: 'ticker', symbol: 'XRPETH' },
  #                       { type: 'kline', symbol: 'XRPETH', interval: '1m'},
  #                       { type: 'depth', symbol: 'XRPETH', level: '5'}],
  #             methods: methods
end
