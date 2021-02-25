class Api::V1::PoolsController < ApplicationController

  def show
    @pools = get_pools(params[:id], get_start_time(params[:id]))
    render json: @pools
  end

  private

  def with_timestamp_nearest_to(timestamp)
    order("abs(pools.timestamp - #{timestamp})")
  end

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
      pool_hash = {}

      if time_unit != 'day'
        # Check if search has been cached for slower queries
        cache_response = Cache.where("timestamp_start = '#{epoch_range[:start]}' and timestamp_end = '#{epoch_range[:end]}'")
        if cache_response.length.positive?
          cache_exists = true
          if cache_response[0].pool_hash
            time_interval[:total] = cache_response[0].total
            pool_hash = cache_response[0].pool_hash
            pool_hash_exists = true
          end
        end
      end

      if cache_exists == false || pool_hash_exists == false
        closest_block = Pool.order(Arel.sql("ABS(timestamp - #{epoch_range[:end]})")).first
        pool_hash["sprout_pool"] = closest_block.sproutPool
        pool_hash["sapling_pool"] = closest_block.saplingPool

        # If not a day, save for next time
        if time_unit != 'day'
          if cache_exists == false
            cache_new = Cache.create(
              timestamp_start: epoch_range[:start],
              timestamp_end: epoch_range[:end],
              pool_hash: pool_hash
            )            
          else
            cache_response[0].update(pool_hash: pool_hash)
          end
        end
      end

      pool_array = []
      pool_hash.each do |item|
        item[0] = item[0].gsub('_', ' ').titleize
        pool_array.push(item)
      end
      time_interval[:pools] = pool_array
      pools.push(time_interval)
    end

    pools
  end
end
