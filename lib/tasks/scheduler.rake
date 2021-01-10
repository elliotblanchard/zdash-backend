desc "This task is called by the Heroku scheduler add-on"
task :get_latest_transactions => :environment do
  require 'activerecord-import'
  require 'json'
  require 'open-uri'
  require 'pry'
  
  puts 'Updating transactions...'

  offset = 0
  offset_increment = 15
  overlap = 300 # 5 minutes
  last_timestamp = Transaction.maximum('timestamp')
  current_timestamp = Float::INFINITY
  max_block_size = 20
  retry_pause = 30
  max_retries = 20
  latest_transactions = []
  uri_base = 'https://api.zcha.in/v2/mainnet/transactions?sort=timestamp&direction=descending&limit='

  print("Getting new transactions. Last timestamp is: #{last_timestamp}\n")

  while (last_timestamp - overlap) < current_timestamp  
  
    request_uri = "#{uri_base}#{max_block_size}&offset=#{offset}"

    begin
      retries ||= 0
      buffer = open(request_uri).read
    rescue => e
      if retries < max_retries
        retries += 1
        sleep(retry_pause)
        print("Retrying API request.\n")
        retry
      else
        print("Max retries of #{max_retries} hit. Can't reach API. Shutting down.\n\n")
        exit(false)
      end
    end
  
    transactions = JSON.parse(buffer)
  
    transactions.each_with_index do |transaction, index|
      t = Transaction.new(
        zhash: transaction['hash'],
        mainChain: transaction['mainChain'],
        fee: transaction['fee'],
        ttype: transaction['type'],
        shielded: transaction['shielded'],
        index: transaction['index'],
        blockHash: transaction['blockHash'],
        blockHeight: transaction['blockHeight'],
        version: transaction['version'],
        lockTime: transaction['lockTime'],
        timestamp: transaction['timestamp'],
        time: transaction['time'],
        vin: transaction['vin'],
        vout: transaction['vout'],
        vjoinsplit: transaction['vjoinsplit'],
        vShieldedOutput: transaction['vShieldedOutput'],
        vShieldedSpend: transaction['vShieldedSpend'],
        valueBalance: transaction['valueBalance'],
        value: transaction['value'],
        outputValue: transaction['outputValue'],
        shieldedValue: transaction['shieldedValue'],
        overwintered: transaction['overwintered']
      )

      t.category = Transaction.classify(t)
      latest_transactions << t

      transaction_time = Time.at(transaction['timestamp']).to_datetime.strftime('%I:%M%p %a %m/%d/%y')

      print("\n#{offset + index + 1}. ")
      print("#{transaction['hash'][0..5]}... ")
      print('category ')
      print("#{t['category']}. ")
      print('at ')
      print("#{transaction_time} ")
      print("timestamp: #{transaction['timestamp']} ")
      print('/ ')
      print("#{transaction['timestamp'] - last_timestamp} ")

    offset += offset_increment
    current_timestamp = transactions.last['timestamp']
  end
  
  Transaction.import latest_transactions # Import all transactions to the db at same time to speed things up
  
  print("Finished getting latest transactions. #{latest_transactions.length} processed.\n")
  print("Current time is: #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}.\n\n")
  print("Latest timestamp is: #{Transaction.maximum('timestamp')}")
end