class ApplicationController < ActionController::API

  private

  def api_req(uri)
    uri_base = 'https://api.zcha.in/v2/mainnet/'
    response = HTTParty.get("#{uri_base}#{uri}")
    begin
      parsed = JSON.parse(response.body)
    rescue JSON::ParserError => e
      false
    end
  end

  def get_start_time(time_unit)
    zcash_first_transaction = Time.new(2016, 10, 28) # Friday, October 28, 2016

    case time_unit
    when 'day' then 1.day.ago
    when 'week' then 1.week.ago - 1.day
    when 'month' then 1.month.ago - 1.day
    when 'year' then 1.year.ago - 1.day
    when 'all' then zcash_first_transaction
    end
  end

  def get_interval_number(time_unit, time)
    case time_unit
    when 'day' then 23
    when 'week' then 6
    when 'month' then number_of_weeks(time)
    when 'year' then 11
    when 'all' then number_of_months(time)
    end
  end

  def number_of_weeks(time)
    ((((1.day.ago - time) / 60) / 60) / 24).round
  end

  def number_of_months(time)
    ((Time.new.year * 12 + Time.new.month) - (time.year * 12 + time.month)) - 1
  end

  def get_interval(time_unit, time, interval)
    utc_offset = '+00:00'

    case time_unit
    when 'day' then Time.new(time.year, time.month, time.day, interval, 0, 0, utc_offset)
    when 'week' then time + (interval * (60 * 60 * 24)) # One day
    when 'month' then time + (interval * (60 * 60 * 24)) # One day
    when 'year' then time + interval.months
    when 'all' then time + interval.months
    end
  end

  def get_interval_name(time_unit)
    case time_unit
    when 'day' then 'hour'
    when 'week' then 'day'
    when 'month' then 'day'
    when 'year' then 'month'
    when 'all' then 'month'
    end
  end

  def get_display_time(time_unit, interval)
    case time_unit
    when 'day' then interval.strftime('%l%p')
    when 'week' then interval.strftime('%a %-m/%d')
    when 'month' then interval.strftime('%a %-m/%d')
    when 'year' then interval.strftime('%b %y')
    when 'all' then interval.strftime('%b %y')
    end
  end

  def time_to_epoch_range(time_unit, time)
    # Converts time object to a range of epoch times
    # Time zone is (GMT)
    # Example values:
    # Dec 3 range: 1606953601 - 1607039999

    epoch_range = {}

    if time_unit == 'day'
      epoch_range[:start] = time_range(time, 'hour')[0]
      epoch_range[:end] = time_range(time, 'hour')[1]
    elsif (time_unit == 'week') || (time_unit == 'month')
      epoch_range[:start] = time_range(time, 'day')[0]
      epoch_range[:end] = time_range(time, 'day')[1]
    else
      epoch_range[:start] = time_range(time, 'month')[0]
      epoch_range[:end] = time_range(time, 'month')[1]
    end
    epoch_range
  end

  def time_range(time, time_unit)
    case time_unit
    when 'hour' then [time.beginning_of_hour.to_i, time.end_of_hour.to_i]
    when 'day' then [time.beginning_of_day.to_i, time.end_of_day.to_i]
    when 'month' then [time.beginning_of_month.to_i, time.end_of_month.to_i]
    end
  end

  def init_time_interval_hash(time_interval, time_unit, interval, i)
    time_interval[:unit] = time_unit
    time_interval[:interval] = get_interval_name(time_unit)
    time_interval[:number] = i
    time_interval[:time] = interval.to_i
    time_interval[:display_time] = get_display_time(time_unit, interval)
    time_interval
  end
end
