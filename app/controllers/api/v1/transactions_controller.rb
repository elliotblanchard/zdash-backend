class Api::V1::TransactionsController < ApplicationController

  def index
    # Replace this Date with a Time object for yesterday:
    # 1.day.ago
    # epoch_range = datetime_to_epoch_range(Date.yesterday)
    # epoch_range = datetime_to_epoch_range(1.day.ago)

    # For now simply returning all transactions from previous day (GMT)
    # Needs to be hourly totals for each transaction type

    # This gets the totals for each category for a given time range:
    # Transaction.group(:category).where(timestamp: 1606953601..1607039999).count
    # Returns
    # => {"sapling_shielded"=>106, "transparent"=>3072, nil=>14, "sapling_deshielding"=>253, 
    # "transparent_coinbase"=>1137, "sprout_deshielding"=>4, "sapling_shielding"=>214}
    
    # @transactions = Transaction.where(timestamp: epoch_range[:start]..epoch_range[:end])
    
    @transactions = get_transactions('day', 1.day.ago)
    render json: @transactions
  end

  private

  def get_transactions(time_unit, time)
    utc_offset = '+00:00'
    response = {}
    header = {}
    body = {}
    transactions = []

    # header[:time_unit] = time_unit
    # response[:header] = header

    # Needs to be a check in here for the 'weekly', 'monthly', 'quarterly' that it dosen't 
    # try to go past the current day - 1

    if time_unit == 'day'
      for i in 0..23
        hour = Time.new(time.year, time.month, time.day, i, 0, 0, utc_offset)
        epoch_range = time_to_epoch_range(time_unit, hour)
        time_interval = {}
        time_interval[:unit] = time_unit
        time_interval[:number] = i
        time_interval[:time] = hour.to_i
        time_interval[:total] = Transaction.where(timestamp: epoch_range[:start]..epoch_range[:end]).count
        # Next line is only for QA remove for performance
        time_interval[:example_hash] = Transaction.where(timestamp: epoch_range[:start]..epoch_range[:end]).last.zhash
        time_interval[:transactions] = Transaction.group(:category).where(timestamp: epoch_range[:start]..epoch_range[:end]).count
        transactions.push(time_interval)
      end
    end

    #body[:transactions] = transactions
    #response[:body] = body
    #response

    transactions
  end

  def time_to_epoch_range(time_unit, time)
    # Converts time object to a range of epoch times

    # Sequence to get beginning and end of a date:
    # date = Date.today
    # date.to_time.in_time_zone('London').beginning_of_day
    # date.to_time.in_time_zone('London').end_of_day
    # date.to_time.in_time_zone('London').end_of_day.to_i (convert to Unix Epoch time)
    # tz = timezone("Europe/Athens") # Eastern European Time, UTC+2
    # Time.new(2002, 10, 31, 2, 2, 2, tz) #=> 2002-10-31 02:02:02 +0200
    # time = Time.now
    # time.end_of_hour() / end_of_week() / end_of_month() / end_of_quarter() / end_of_year()
    # time.beginning_of_hour() / etc...
    # time.

    # Make sure to specify time zone (GMT)

    # Example values:
    # Dec 3 range: 1606953601 - 1607039999

    epoch_range = {}

    if time_unit == 'day'
      epoch_range[:start] = time.beginning_of_hour.to_i
      epoch_range[:end] = time.end_of_hour.to_i
    end

    epoch_range
  end
end
