class Api::V1::PoolsController < ApplicationController

  def show
    @pools = get_pools(params[:id], get_start_time(params[:id]))
    render json: @pools
  end

  private

  def get_pools(time_unit, time)
    pools = []
    interval_number = get_interval_number(time_unit, time)

    (0..interval_number).each do |i| 
      interval = get_interval(time_unit, time, i)
      epoch_range = time_to_epoch_range(time_unit, interval)
      time_interval = {}
      time_interval = init_time_interval_hash(time_interval, time_unit, interval, i)

      cache_exists = false
      pool_hash_exists = false

      if time_unit != 'day'
        # Check if search has been cached for slower queries
        cache_response = Cache.where("timestamp_start = '#{epoch_range[:start]}' and timestamp_end = '#{epoch_range[:end]}'")
        if cache_response.length.positive?
          cache_exists = true
          if cache_response[0].pool_hash.length.positive?
            time_interval[:total] = cache_response[0].total
            pool_hash = cache_response[0].pool_hash
            pool_hash_exists = true
          end
        end
      end

      if cache_exists == false || pool_hash_exists == false
        time_interval[:total] = Pool.where(timestamp: epoch_range[:start]..epoch_range[:end]).count
        pool_hash = Pool.group(:category).where(timestamp: epoch_range[:start]..epoch_range[:end]).count

        # If not a day, save for next time
        if time_unit != 'day'
          if cache_exists == false
            pool_new = Pool.create(
              timestamp_start: epoch_range[:start],
              timestamp_end: epoch_range[:end],
              total: time_interval[:total],
              pool_hash: category_hash
            )
          else
            cache_response[0].update(category_hash: category_hash)
          end
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
end
