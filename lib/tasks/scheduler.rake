desc "This task is called by the Heroku scheduler add-on"
task :get_latest_transactions => :environment do
  require 'activerecord-import'
  require 'json'
  require 'open-uri'
  require 'pry'
  
  puts "Updating transactions..."

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
    end
    offset += offset_increment
    current_timestamp = transactions.last['timestamp']
    print("\nLatest_transactions.length: #{latest_transactions.length}\n")
    if latest_transactions.length > 500
      print("\n\n\nImporting #{latest_transactions.length} transactions.\n\n\n")
      Transaction.import latest_transactions
      latest_transactions = []
    end
  end
  
  Transaction.import latest_transactions # Import any remaining transactions to the db 
  print("Finished getting latest transactions. #{latest_transactions.length} processed.\n")

  # Now we need to remove duplicates - because activerecord-import ignores uniqueness validations, 
  # We have to check outselves - this is still much faster than the alternatives  

  all_transactions = Transaction.where("timestamp > '#{last_timestamp}'")
  unique_transactions = all_transactions.uniq { |transaction| transaction.zhash }
  group_by_zhash = all_transactions.group_by { |transaction| transaction.zhash }

  print("Removing duplicates...\n")
  print("Transactions since timestamp: #{last_timestamp}: #{all_transactions.count}\n")
  print("Unique transactions: #{unique_transactions.count}\n")
  print("Duplicates: #{all_transactions.count - unique_transactions.count}\n")
  print("Size of group_by_zhash: #{group_by_zhash.length}\n")

  group_by_zhash.each do |key, array|
    if array.length > 1
      array.pop() # Pop one off the array
     # Destroy the rest
      array.each { |transaction| transaction.destroy }
    end
  end  

  print("Current time is: #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}.\n\n")
end

task :remove_duplicates => :environment do
  last_timestamp = 1610574707 #You need to remove all duplicates after this timestamp
  all_transactions = Transaction.where("timestamp > '#{last_timestamp}'")
  unique_transactions = all_transactions.uniq { |transaction| transaction.zhash }
  group_by_zhash = all_transactions.group_by { |transaction| transaction.zhash }

  print("In remove duplicates.\n")
  print("Transactions since timestamp: #{last_timestamp}: #{all_transactions.count}\n")
  print("Unique transactions: #{unique_transactions.count}\n")
  print("Duplicates: #{all_transactions.count - unique_transactions.count}\n")
  print("Size of group_by_zhash: #{group_by_zhash.length}\n")

  group_by_zhash.each do |key, array|
    if array.length > 1
      array.pop() # Pop one off the array
     # Destroy the rest
      array.each { |transaction| transaction.destroy }
    end
  end
  
end