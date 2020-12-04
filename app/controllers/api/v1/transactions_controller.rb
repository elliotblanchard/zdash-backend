class Api::V1::TransactionsController < ApplicationController

  def index
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
