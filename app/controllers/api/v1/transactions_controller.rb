class Api::V1::TransactionsController < ApplicationController

  def show

=begin
    zcash_first_transaction = Time.new(2016, 10, 28) # Friday, October 28, 2016

    case params[:id]
    when 'day' then @transactions = get_transactions('day', 1.day.ago)
    when 'week' then @transactions = get_transactions('week', 1.week.ago - 1.day)
    when 'month' then @transactions = get_transactions('month', 1.month.ago - 1.day)
    when 'year' then @transactions = get_transactions('year', 1.year.ago - 1.day)
    when 'all' then @transactions = get_transactions('all', zcash_first_transaction)
    end
=end
    @transactions = get_transactions(params[:id], get_start_time(params[:id]))
    render json: @transactions
  end

  private

  def get_transactions(time_unit, time)
    #utc_offset = '+00:00'
    #response = {}
    #header = {}
    #body = {}

    # Epoch range for one day: 1608422461..1608508799
    # Transaction.group(:category).where(timestamp: 1608422461..1608508799).count

=begin
    case time_unit
    when 'day' then interval_number = 23
    when 'week' then interval_number = 6
    when 'month' then interval_number = ((((1.day.ago - (time)) / 60) / 60) / 24).round
    when 'year' then interval_number = 11
    when 'all' then interval_number = ((Time.new.year * 12 + Time.new.month) - (time.year * 12 + time.month)) - 1
    end
=end

    transactions = []
    interval_number = get_interval_number(time_unit, time)

    (0..interval_number).each do |i|
=begin
      case time_unit
      when 'day' then interval = Time.new(time.year, time.month, time.day, i, 0, 0, utc_offset)
      when 'week' then interval = time + (i * (60 * 60 * 24)) # One day
      when 'month' then interval = time + (i * (60 * 60 * 24)) # One day
      when 'year' then interval = time + i.months
      when 'all' then interval = time + i.months
      end
=end

=begin
      case time_unit
      when 'day' then time_interval[:interval] = 'hour'
      when 'week' then time_interval[:interval] = 'day'
      when 'month' then time_interval[:interval] = 'day'
      when 'year' then time_interval[:interval] = 'month'
      when 'all' then time_interval[:interval] = 'month'
      end
=end

=begin
      case time_unit
      when 'day' then time_interval[:display_time] = interval.strftime('%l%p')
      when 'week' then time_interval[:display_time] = interval.strftime('%a %-m/%d')
      when 'month' then time_interval[:display_time] = interval.strftime('%a %-m/%d')
      when 'year' then time_interval[:display_time] = interval.strftime('%b %y')
      when 'all' then time_interval[:display_time] = interval.strftime('%b %y')
      end
=end

=begin
      time_interval[:unit] = time_unit
      time_interval[:interval] = get_interval_name(time_unit)
      time_interval[:number] = i
      time_interval[:time] = interval.to_i
      time_interval[:display_time] = get_display_time(time_unit, interval)
=end

      interval = get_interval(time_unit, time, i)
      epoch_range = time_to_epoch_range(time_unit, interval)
      time_interval = {}
      time_interval = init_time_interval_hash(time_interval, time_unit, interval, i)
      
      cache_used = false

      if time_unit != 'day'
        # Check if search has been cached for slower queries
        cache_response = Cache.where("timestamp_start = '#{epoch_range[:start]}' and timestamp_end = '#{epoch_range[:end]}'")
        if cache_response.length > 0
          time_interval[:total] = cache_response[0].total
          category_hash = cache_response[0].category_hash
          cache_used = true
        end
      end

      if cache_used == false
        time_interval[:total] = Transaction.where(timestamp: epoch_range[:start]..epoch_range[:end]).count
        category_hash = Transaction.group(:category).where(timestamp: epoch_range[:start]..epoch_range[:end]).count
      
        # If not a day, save for next time
        if time_unit != 'day'
          cache_new = Cache.create(
            timestamp_start: epoch_range[:start],
            timestamp_end: epoch_range[:end],
            total: time_interval[:total],
            category_hash: category_hash
          )
        end
      end
      
      category_array = []
      category_hash.each do |item|
        item[0] = item[0].gsub('_', ' ').titleize
        category_array.push(item)
      end
      sorted_category_array = category_array.sort_by { |category| category[0] }
      time_interval[:categories] = sorted_category_array
      transactions.push(time_interval)
    end

    transactions
  end

=begin
  def time_to_epoch_range(time_unit, time)
    # Converts time object to a range of epoch times
    # Time zone is (GMT)
    # Example values:
    # Dec 3 range: 1606953601 - 1607039999

    epoch_range = {}

    if time_unit == 'day'
      epoch_range[:start] = time.beginning_of_hour.to_i
      epoch_range[:end] = time.end_of_hour.to_i
    elsif (time_unit == 'week') || (time_unit == 'month')
      epoch_range[:start] = time.beginning_of_day.to_i
      epoch_range[:end] = time.end_of_day.to_i
    elsif (time_unit == 'year') || (time_unit == 'all')
      epoch_range[:start] = time.beginning_of_month.to_i
      epoch_range[:end] = time.end_of_month.to_i
    end

    epoch_range
  end
=end  
end
