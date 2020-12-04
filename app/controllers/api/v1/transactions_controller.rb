class Api::V1::TransactionsController < ApplicationController

  def index
    # Replace this Date with a Time object for yesterday:
    # 1.day.ago
    epoch_range = datetime_to_epoch_range(Date.yesterday)

    # For now simply returning all transactions from previous day (GMT)
    # Needs to be hourly totals for each transaction type

    # This gets the totals for each category for a given time range:
    # Transaction.group(:category).where(timestamp: 1606953601..1607039999).count
    # Returns
    # => {"sapling_shielded"=>106, "transparent"=>3072, nil=>14, "sapling_deshielding"=>253, 
    # "transparent_coinbase"=>1137, "sprout_deshielding"=>4, "sapling_shielding"=>214}
    
    @transactions = Transaction.where(timestamp: epoch_range[:start]..epoch_range[:end])
    
    render json: @transactions
  end

  private

  def datetime_to_epoch_range(start_time, end_time = nil)
    # Converts datetime(s) to a range of epoch times
    # Will return epoch time from beginning to end of specified day

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
    epoch_range[:start] = start_time.to_time.in_time_zone('London').beginning_of_day.to_i

    if end_time
      epoch_range[:end] = end_time.to_time.in_time_zone('London').end_of_day.to_i
    else
      epoch_range[:end] = start_time.to_time.in_time_zone('London').end_of_day.to_i
    end

    epoch_range
  end
end
