# Zdash: Live analytics for Zcash
Dashboard for private transactions in the Zcash cryptocurrency

![Zdash](http://invisiblelightnetwork.com/wp-content/uploads/2021/03/zdash_comped.png)

## Features :sparkles:
* Only source online for data on all categories of Zcash transactions
* Live Zcash network data
* Browse recently active Zcash accounts
* Fast analysis for millions of transactions
* Responsive data visualization

## Built With :eyes:
* React front end
  * Redux to manage state
  * Thunk middleware for async requests via RESTful API calls
  * SPA with React Router for client-side routing
  * [Nivo](https://nivo.rocks) data viz for interactive SVG charts
  * [React Bootstrap](https://react-bootstrap.github.io) framework and CSS for styling
  * [React Grid Layout](https://www.npmjs.com/package/react-grid-layout) for chart and data organization
* Rails backend
  * Scheduled Rake tasks to import latest transaction data
  * [RPCJson](https://rubygems.org/gems/rpcjson) for fast RPC calls to blockchain data
  * [ActiveRecord Import](https://rubygems.org/gems/activerecord-import) for optimized transaction import
  * 8 million+ record PostgreSQL database


## Get Started
Visit https://www.zdash.info/

## Or install:

### Fork and clone Rails API backend:
* git clone to your local directory
* cd zdash-backend
* run bundle install
* run rake db:create
* run rake db:migrate
* run rails s

### Fork and clone frontend:
* git clone to your local directory
* cd zdash-frontend
* run npm install
* run npm start

## Contributors Guide 👋
Bug reports and pull requests are welcome on GitHub at https://github.com/elliotblanchard/zdash-backend. This project is intended to be a safe, welcoming space for collaboration.

## License
The app is available as open source under the terms of the MIT License.