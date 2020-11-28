# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# BUILD Notes:

* Overall time-series day / month / year
* Overall network info: GET https://api.zcha.in/v2/mainnet//v2/mainnet/network
* Potential routes:
    * ALL Zcash transactions:
        * Total transactions
          * Migration
          * Sapling Deshielding
          * Sapling Shielded
          * Sapling Shielding
          * Shielded Coinbase
          * Sprout Deshielding
          * Sprout Shielded
          * Sprout Shielding
          * Transparent
          * Transparent coinbase transaction
        * Block height
        * By type
        * Transaction type as a % of total transacations
    * Only shielded transactions:
        * With any shielded component (shielded, deshielding, shielding)
        * Only fully shielded transactions
          * Sapling Shielded
          * Sprout Shielded
        * Cumulative fully shielded tx
        * Shielded pool size (what is this pulled from)
    * Look at a single transaction
    * Sprout vs Sapling activity (?)
    * Mining stats (?)
    * Price (?)
    * Maps (?)
    * Info on a single account (maybe some charts like - transactions (limit 1000) over time, pie chart showing sent vs recieved, etc):
      * https://api.zcha.in/v2/mainnet//v2/mainnet/accounts/{address}
      * https://api.zcha.in/v2/mainnet/accounts/t3Vz22vK5z2LcKEdg16Yv4FFneEL1zg9ojd/recv?limit=5&offset=0
      * https://api.zcha.in/v2/mainnet//v2/mainnet/accounts/{address}/sent


* Some inspiration from an ETH dash: https://medium.com/coinmonks/how-to-build-ethereum-dashboard-and-to-monitor-your-ethereum-network-status-9f1941beac08
