desc "This task is called by the Heroku scheduler add-on"

task :get_latest_transactions_lightwalletd_proxy => :environment do
  require 'activerecord-import'
  require 'json'
  require 'open-uri'
  require 'pry'
  require 'uri'
  require 'net/http'

  uri_base = 'http://localhost:8000/'

  # GetLightdInfo
  # buffer = HTTParty.post(uri_base,
  # {
  #   body: { method: 'GetLightdInfo', params: {} }.to_json,
  #   headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  # })

  # GetBlock
  # buffer = HTTParty.post(uri_base,
  # {
  #   body: { method: 'GetBlock', params: { height: '10000' } }.to_json,
  #   headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  # })

  # GetTransaction
  # buffer = HTTParty.post(uri_base,
  # {
  #   body: { method: 'GetTransaction', params: { hash: 'fdde78d0f0e92a0296a5d9f570131da5917bc4bf5c56b92e912a86fb72228f59' } }.to_json,
  #   headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  # })

  print "Response: #{buffer}"

end

task :get_latest_transactions_zcash_api => :environment do
  require 'activerecord-import'
  require 'json'
  require 'httparty'
  require 'pry'

  uri_base = 'http://192.168.1.5:3000/'
 
  buffer = URI.parse("#{uri_base}getinfo").open.read
  network_info = JSON.parse(buffer)

  start_block = Pool.maximum('blockHeight') + 1 
  final_block = network_info['result']['blocks'] - 25

  latest_transactions = []
  latest_pools = []
  
  # Main loop: get each block in Zcash blockchain
  (start_block..final_block).each do |i|
    buffer = URI.parse("#{uri_base}getBlock?height=#{i}").open.read
    current_block = JSON.parse(buffer)
    num_transactions = current_block['result']['tx'].length - 1
    # Inner loop: get each transaction in this block
    (0..num_transactions).each do |j|
      tx_hash = current_block['result']['tx'][j]
      buffer = URI.parse("#{uri_base}getrawtransaction?txid=#{tx_hash}").open.read
      current_transaction = JSON.parse(buffer)
      t = Transaction.new(
        zhash: current_transaction['result']['txid'],
        mainChain: nil,
        fee: nil,
        ttype: nil,
        shielded: nil,
        index: nil,
        blockHash: current_block['result']['hash'],
        blockHeight: i,
        version: current_transaction['result']['version'],
        lockTime: current_transaction['result']['locktime'],
        timestamp: current_transaction['result']['time'],
        time: nil,
        vin: current_transaction['result']['vin'],
        vout: current_transaction['result']['vout'],
        vjoinsplit: current_transaction['result']['vjoinsplit'],
        vShieldedOutput: current_transaction['result']['vShieldedOutput'],
        vShieldedSpend: current_transaction['result']['vShieldedSpend'],
        valueBalance: current_transaction['result']['valueBalance'],
        value: nil,
        outputValue: nil,
        shieldedValue: nil,
        overwintered: current_transaction['result']['overwintered']
      )

      t.category = Transaction.classify(t)
      latest_transactions << t

      if (latest_transactions.length % 1000).zero?
        print "At block: #{i} Importing transactions at #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}.\n"
        Transaction.import latest_transactions
        print "Finished importing transactions. At block #{i} of #{final_block} (#{((i.to_f / final_block) * 100).round(2)}%) at #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}. Imported #{latest_transactions.length} transactions.\n"
        latest_transactions = []
      end
    end
    if latest_transactions.last
      timestamp = latest_transactions.last.timestamp
    else
      timestamp = Transaction.last.timestamp
    end

    p = Pool.new(
      blockHeight: i,
      timestamp: timestamp,
      sprout: 0,
      sproutHidden: 0.0,
      sproutRevealed: 0.0,
      sproutPool: current_block['result']['valuePools'][0]['chainValue'],
      sapling: 0,
      saplingHidden: 0.0,
      saplingRevealed: 0.0,
      saplingPool: current_block['result']['valuePools'][1]['chainValue']
    )
    latest_pools << p

    if (latest_pools.length % 1000).zero?
      print "At block: #{i} Importing pools. sprout pool: #{current_block['result']['valuePools'][0]['chainValue']} sapling pool: #{current_block['result']['valuePools'][1]['chainValue']}.\n"
      Pool.import latest_pools
      latest_pools = []
    end
  end
  # Save final group of transacations / pools in the array
  print "Importing blocks at #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}.\n"
  Transaction.import latest_transactions
  Pool.import latest_pools
  latest_transactions = []
  latest_pools = []
end

task :get_latest_transactions_zchain => :environment do
  # Depricated - do not use. Does not handle 
  require 'activerecord-import'
  require 'json'
  require 'open-uri'
  require 'pry'
  
  puts "Updating transactions..."

  offset = 0
  offset_increment = 15
  overlap = 300 # 5 minutes
  last_timestamp = Transaction.maximum('timestamp') #1614529233
  current_timestamp = Float::INFINITY
  max_block_size = 20
  retry_pause = 30
  max_retries = 20
  latest_transactions = []
  uri_base = 'https://api.zcha.in/v2/mainnet/transactions'
  multiple_transactions = '?sort=timestamp&direction=descending&limit='

  # Shielded pool counters
  #sapling = 0
  sapling_hidden = 0
  sapling_revealed = 0
  sapling_pool = 0
  #sprout = 0
  sprout_hidden = 0
  sprout_revealed = 0
  sprout_pool = 0
  latest_pools = []

  print("Getting new transactions. Last timestamp is: #{last_timestamp}\n")

  while (last_timestamp - overlap) < current_timestamp
    request_uri = "#{uri_base}#{multiple_transactions}#{max_block_size}&offset=#{offset}"

    begin
      retries ||= 0
      buffer = URI.parse(request_uri).open.read
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

      if ((t.category == 'sapling_shielding') || (t.category == 'sapling_deshielding') || (t.category == 'sapling_shielded'))
        # Need to re-query as a single transaction
        # API reports Value Balance wrong in multiple transaction queries
        requery_uri = "#{uri_base}/#{t.zhash}"
        requery_buffer = URI.parse(requery_uri).open.read
        requery_transaction = JSON.parse(requery_buffer)
        t.valueBalance = requery_transaction['valueBalance']
      end

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
  # We have to check outselves - this is still much faster than the alternative

  all_transactions = Transaction.where("timestamp > '#{last_timestamp}'")

  unique_transactions = all_transactions.uniq(&:zhash)
  group_by_zhash = all_transactions.group_by(&:zhash)

  print("Removing duplicates...\n")
  print("Transactions since timestamp: #{last_timestamp}: #{all_transactions.count}\n")
  print("Unique transactions: #{unique_transactions.count}\n")
  print("Duplicates: #{all_transactions.count - unique_transactions.count}\n")
  print("Size of group_by_zhash: #{group_by_zhash.length}\n")

  group_by_zhash.each do |key, array|
    if array.length > 1
      array.pop() # Pop one off the array
      # Destroy the rest
      array.each(&:destroy)
    end
  end

  # Once duplicates have been removed, we can do pool calculations
  print("Doing pool calculations.\n\n")

  # Load last sapling and sprout values so calculations continue correctly
  # THIS NEEDS UPDATING
  max_timestamp = Pool.maximum('timestamp')
  p = Pool.where("timestamp = #{max_timestamp}").first
  # sapling = p.sapling
  # sapling_hidden = p.saplingHidden
  # sapling_revealed = p.saplingRevealed
  sapling_pool = p.saplingPool
  # sprout = p.sprout
  # sprout_hidden = p.sproutHidden
  # sprout_revealed = p.sproutRevealed
  sprout_pool = p.sproutPool

  print("Initial sapling_pool: #{sapling_pool}, sprout_pool: #{sprout_pool}")

  new_transactions = Transaction.where("timestamp > '#{last_timestamp}'").order(:timestamp)
  current_block = new_transactions.first.blockHeight

  new_transactions.each do |transaction|
    if transaction.vjoinsplit.length > 2
      fields = transaction.vjoinsplit.split(' ')
      #if fields[2].split('=>')[1] == nil
      #  binding.pry
      #end
      vpub_old = 0
      vpub_new = 0
      fields.each do |field| 
        if field.include? 'vpub_oldZat'
          vpub_old += field.split('=>')[1].gsub('"', '').gsub(',', '').to_f
        elsif field.include? 'vpub_newZat'
          vpub_new += field.split('=>')[1].gsub('"', '').gsub(',', '').to_f
        end
      end
      #sprout += 1
    end

    case transaction.category
    when 'sprout_shielding' || 'sprout_deshielding' || 'sprout_shielded'
      # Update sprout_hidden, sprout_revealed, sprout count
      sprout_hidden += vpub_old
      sprout_revealed += vpub_new
      print("zhash: #{transaction.zhash} category: #{transaction.category} sprout_hidden: #{sprout_hidden} sprout_revealed: #{sprout_revealed}\n")
    when 'sapling_shielding' || 'sapling_deshielding' || 'sapling_shielded'
      # Update sapling_hidden, sapling_revealed, sapling count
      # sapling += 1
      if transaction.valueBalance.negative?
        sapling_hidden += transaction.valueBalance.to_f.abs
      else
        sapling_revealed += transaction.valueBalance.to_f
      end
      print("zhash: #{transaction.zhash} category: #{transaction.category} value balance: #{transaction.valueBalance} sapling_hidden: #{sapling_hidden} sapling_revealed: #{sapling_revealed}\n")
    end

    # If we've started a new block, create a Pool.new and add to latest_pools
    if current_block != transaction.blockHeight
      sprout_pool += ((sprout_hidden - sprout_revealed) / 100000000)
      sapling_pool += (sapling_hidden - sapling_revealed)
      # print("Creating new pool. Sprout_pool: #{sprout_pool} sapling_pool: #{sapling_pool}\n")
      p = Pool.new(
        blockHeight: current_block,
        timestamp: transaction.timestamp,
        sprout: 0,
        sproutHidden: 0.0,
        sproutRevealed: 0.0,
        sproutPool: sprout_pool,
        sapling: 0,
        saplingHidden: 0.0,
        saplingRevealed: 0.0,
        saplingPool: sapling_pool
      )
      latest_pools << p
      #print("Latest_pools: #{latest_pools.length}\n")
      current_block = transaction.blockHeight
    end
  end
  # Integrate final pool
  sprout_pool += ((sprout_hidden - sprout_revealed) / 100000000)
  sapling_pool += sapling_hidden - sapling_revealed
  p = Pool.new(
    blockHeight: current_block,
    timestamp: new_transactions.last.timestamp,
    sprout: 0,
    sproutHidden: 0.0,
    sproutRevealed: 0.0,
    sproutPool: sprout_pool,
    sapling: 0,
    saplingHidden: 0.0,
    saplingRevealed: 0.0,
    saplingPool: sapling_pool
  )
  latest_pools << p

  print("Importing pools.\n")
  Pool.import latest_pools
  print("Final sapling_pool: #{latest_pools.last.saplingPool}, sprout_pool: #{latest_pools.last.sproutPool}")
  latest_pools = []

  print("Current time is: #{DateTime.now.strftime('%I:%M%p %a %m/%d/%y')}.\n\n")
end

task :remove_duplicates => :environment do
  last_timestamp = 1610574707
  all_transactions = Transaction.where("timestamp > '#{last_timestamp}'")
  unique_transactions = all_transactions.uniq(&:zhash)
  group_by_zhash = all_transactions.group_by(&:zhash)

  print("In remove duplicates.\n")
  print("Transactions since timestamp: #{last_timestamp}: #{all_transactions.count}\n")
  print("Unique transactions: #{unique_transactions.count}\n")
  print("Duplicates: #{all_transactions.count - unique_transactions.count}\n")
  print("Size of group_by_zhash: #{group_by_zhash.length}\n")

  group_by_zhash.each do |key, array|
    if array.length > 1
      array.pop() # Pop one off the array
     # Destroy the rest
      array.each(&:destroy)
    end
  end
  
end