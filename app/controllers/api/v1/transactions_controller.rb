class Api::V1::TransactionsController < ApplicationController

  def show
    case params[:id]
    when 'day' then @transactions = get_transactions('day', 1.day.ago)
    when 'week' then @transactions = get_transactions('week', 1.week.ago - 1.day)
    when 'month' then @transactions = get_transactions('month', 1.month.ago - 1.day)
    when 'year' then @transactions = get_transactions('year', 1.year.ago - 1.day)
    end
    render json: @transactions
  end

  private

  def get_transactions(time_unit, time)
    utc_offset = '+00:00'
    response = {}
    header = {}
    body = {}
    transactions = []

    # Epoch range for one day: 1608422461..1608508799
    # Transaction.group(:category).where(timestamp: 1608422461..1608508799).count

    case time_unit
    when 'day' then interval_number = 23
    when 'week' then interval_number = 6
    when 'month' then interval_number = ((((1.day.ago - (time)) / 60) / 60) / 24).round
    when 'year' then interval_number = 11
    end

    (0..interval_number).each do |i|
      case time_unit
      when 'day' then interval = Time.new(time.year, time.month, time.day, i, 0, 0, utc_offset)
      when 'week' then interval = time + (i * (60 * 60 * 24)) # One day
      when 'month' then interval = time + (i * (60 * 60 * 24)) # One day
      when 'year' then interval = Time.new(time.year, time.month + i, time.day, 0, 0, 0, utc_offset)
      end
      puts("Interval is: #{interval}")
      epoch_range = time_to_epoch_range(time_unit, interval)
      time_interval = {}
      time_interval[:unit] = time_unit
      case time_unit
      when 'day' then time_interval[:interval] = 'hour'
      when 'week' then time_interval[:interval] = 'day'
      when 'month' then time_interval[:interval] = 'day'
      when 'year' then time_interval[:interval] = 'year'
      end
      time_interval[:number] = i
      time_interval[:time] = interval.to_i
      case time_unit
      when 'day' then time_interval[:display_time] = interval.strftime('%l%p')
      when 'week' then time_interval[:display_time] = interval.strftime('%a %-m/%d')
      when 'month' then time_interval[:display_time] = interval.strftime('%a %-m/%d')
      when 'year' then time_interval[:display_time] = interval.strftime('%b %y')
      end

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

  def time_to_epoch_range(time_unit, time)
    # Converts time object to a range of epoch times
    # Time zone is (GMT)
    # Example values:
    # Dec 3 range: 1606953601 - 1607039999

    epoch_range = {}

    if time_unit == 'day'
      epoch_range[:start] = time.beginning_of_hour.to_i
      epoch_range[:end] = time.end_of_hour.to_i
    elsif time_unit == 'week'
      epoch_range[:start] = time.beginning_of_day.to_i
      epoch_range[:end] = time.end_of_day.to_i
    elsif time_unit == 'month'
      epoch_range[:start] = time.beginning_of_day.to_i
      epoch_range[:end] = time.end_of_day.to_i
    elsif time_unit == 'year'
      epoch_range[:start] = time.beginning_of_month.to_i
      epoch_range[:end] = time.end_of_month.to_i
    end

    epoch_range
  end
end
