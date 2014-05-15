###updn

This project started after someone on [Hacker News](http://news.ycombinator.com) suggested implementing a Hacker News/Reddit/Digg style site where story submission and voting required Dogecoin. This is my attempt at something similar.

####tldr

Reddit-alike where submissions and voting use Bitcoin

Basically, the [Lobsters](https://lobste.rs/) codebase + Bitcoin. 

* new stories cost the equivalent of $0.03
* upvotes/downvotes cost the equivalent of $0.01
* comments are free
* a tipping system is built in where users can send whatever amount they want to each other

The recipient of an upvote receives the equivalent amount of Bitcoin. Ideally, this means that:

1. Story submissions and votes have some cost, and people will be more thoughtful about using either one.
2. Good content is rewarded. If someone submits a link to their blog post and they receive 700 upvotes, they get the equivalent of about $7.
3. People can easily be introduced to cryptocurrencies. Instead of buying Bitcoin online/offline or begging somewhere, they can make a comment and receive a small amount if others find it worthwhile.
4. The site itself can easily be monetized. No ads.

The key is that the cost exists, but it is still small. You could submit 5 stories and give out 15 votes to people and it would only cost about $0.30; not a large amount of money, but enough to weed out junk content.

Of course, that is the ideal scenario. It could just attact people trying to game the site to make money. Someone other than me can find out.

Note: these amounts are not hardwired, just an idea. Lower or higher costs might be better in practice.

####Rationale

Social news sites are nothing new. Slashdot was probably the father but since then there have been numerous sites including Digg, del.icio.us, Reddit, and Hacker News. The basic idea is simple: users get to to submit and vote on what content they think belongs on the front page. It is democracy in action with all its benefits and flaws. It works pretty well, but there are obvious issues. 

1. Aside from exposure, good content is not actually rewarded monetarily. In fact, the additional traffic might be more expensive than the exposure is worth.
2. Since submissions and votes do not actually cost anything aside from time, it is easy to flood the system with noise. Additionally, users are careless and thoughtlessly upvote mediocre content or downvote controversial but worthwhile content.
3. Forum-style sites are notoriously difficult to monetize. 

Can these problems be fixed? If submissions and votes actually have a monetary cost, maybe.

####Implementation

How do we easily incorporate money? We could require a credit card but that has a high psychological barrier of entry for a lot of people. Why not use Bitcoin or another cryptocurrency instead? It is ideal for this kind of system; somewhat anonymous and designed for transactions over the internet. Some individuals have already called Dogecoin "the tipping currency of the internet". It and other cryptocurrencies are easy ways to reward people small amounts of money for good content. [/r/dogecoin](http://www.reddit.com/r/dogecoin) in particular is known for users tipping each other for funny and useful comments. However, that uses a third-party bot and submissions and votes are unaffected. Let's build similar functionality right into the software instead.

When a user signs up for the site, a Bitcoin address is generated for them. This is their deposit address. In order to fully use the site (submit stories or vote on content), they need to transfer some Bitcoin to it.

Once they do that, they can submit new stories and vote. They can also tip stories, comments, and users directly, if they feel that something or someone deserves a different amount than voting provides. Once they accumulate a decent amount, they can create a withdrawal and have the Bitcoin transfered to an outside address.

####Technical details

The project is based on Joshua Stein's [lobste.rs](https://lobste.rs), an open source Rails codebase that is probably one of the best Reddit-alikes out there. It includes just about everything you would expect from such a site as well as some features such as tags. The majority of this project is due to his work.

updn is essentially the Lobsters code connected to a [Bitcoin daemon running as a JSON RPC server](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC)). The daemon handles generating new addresses and transfers in and out of the site. 

Each user has *deposit*, *withdrawal*, and *balance* fields. *deposit* and *withdrawal* simply keep track of the corresponding Bitcoin addresses. *balance* keeps track of the user's Bitcoin amount.

Transfers are represented in two forms, as an *Action* or *Transaction*. Every action internal to the site which represents some transfer of Bitcoin, like submissions, votes, and tips, creates an *Action*. Each deposit and withdrawal to and from the site (an external transfer) is represented as a *Transaction*, which ties pretty closely to actual an Bitcoin transaction.

Note: tips, unlike stories or votes do not have a unique model. Instead, each tip is represented as an *Action* with the *is_anonymous* field set to *true* or *false*. Actions that are not tips simply have *is_anonymous* as *null*. This probably is not the best way to do this, but what the hell. 

Most of the magic happens in */config/initializers/bitcoin.rb*. When the server starts, a job is initialized and run every minute. This job has a few important tasks:

* check the Bitcoin daemon for any new transactions since the last time; create a corresponding *Transaction* in the database for each
* check the Bitcoin daemon for any existing transactions that do not have the requisite amount of confirmations (currently at least 3); for those that have reached the threshold since last time, update the user's balance accordingly
* check for pending withdrawals, bundle them up into a single Bitcoin transaction and send it
* check the Bitcoin daemon for the latest block and [Coinbase](http://www.coinbase.com) for the most recent BTC/USD value; this information is saved as a *Check*; the former is used to retain the correct place in the blockchain and the latter to do the correct calculations for $0.01 of Bitcoin, etc 

####Dogecoin? Blackcoin? Altcoin #4598034820958? 

It should be trivial to use a cryptocurrency other than Bitcoin (the initial idea was to use Dogecoin). Simply modify the code in *bitcoin.rb* to connect to a different daemon and adjust your costs accordingly. For example, the right calculcation for Dogecoin would look something like:

1. Get BTC/USD value from Coinbase (already happens)
2. Get DOGE/BTC value from [Mintpal](http://www.mintpal.com) or [Cryptsy](http://www.cryptsy.com)
3. DOGE/USD = (BTC/USD) * (DOGE/BTC)

####Why aren't you running the site yourself?

With a few days of testing I could probably host the site myself. However, I do not trust my code enough to do this and I have no desire to spend the time required to run a community based site. Finally, I do not want to be responsible for losing someone else's money due to my own incompetence or a hacker's touch.

Consider the above a warning. If this warning does not phase you, I would love to see someone run with the codebase or the idea.

####Installation

This has been tested using Ruby 2.1 on an arch install using sqlite3. It should work fine in other scenarios, but I can't make any promises.

* Download Bitcoin or bitcoind, enable the server option, supply rpcuser and rpcpassword in [*bitcoin.conf*](https://en.bitcoin.it/wiki/Running_Bitcoin), and adjust *bitcoin.rb* to match. The entire Bitcoin blockchain can take hours to download. The site should still function as long as the daemon is accessible, you simply will not see the most recent transactions until that part of the blockchain has been downloaded.

* Install Ruby. Supported Ruby versions include 1.9.3, 2.0.0 and 2.1.0.

* Checkout the updn git tree from Github

         $ git clone git://github.com/fisher-lebo/updn.git
         $ cd updn
         updn$ 

* Run Bundler to install/bundle gems needed by the project:

         updn$ bundle

* Create a MySQL (other DBs supported by ActiveRecord may work, only MySQL and
MariaDB have been tested) database, username, and password and put them in a
`config/database.yml` file:

          development:
            adapter: mysql2
            encoding: utf8mb4
            reconnect: false
            database: updn_dev
            socket: /tmp/mysql.sock
            username: *username*
            password: *password*
            
          test:
            adapter: sqlite3
            database: db/test.sqlite3
            pool: 5
            timeout: 5000

* Load the schema into the new database:

          updn$ rake db:schema:load

* Create a `config/initializers/secret_token.rb` file, using a randomly
generated key from the output of `rake secret`:

          Lobsters::Application.config.secret_token = 'your random secret here'

* (Optional, only needed for the search engine) Install Sphinx.  Build Sphinx
config and start server:

          updn$ rake ts:rebuild

* Define your site's name and default domain, which are used in various places,
in a `config/initializers/production.rb` or similar file:

          class << Rails.application
            def domain
              "example.com"
            end
          
            def name
              "Example News"
            end
          end
          
          Rails.application.routes.default_url_options[:host] = Rails.application.domain

* Create an initial administrator user and at least one tag:

          updn$ rails console
          Loading development environment (Rails 3.2.6)
          irb(main):001:0> u = User.new(:username => "test", :email => "test@example.com", :password => "test", :password_confirmation => "test")
          irb(main):002:0> u.is_admin = true
          irb(main):003:0> u.is_moderator = true
          irb(main):004:0> u.save

          irb(main):005:0> t = Tag.new
          irb(main):006:0> t.tag = "test"
          irb(main):007:0> t.save

* Run the Rails server in development mode.  You should be able to login to
`http://localhost:3000` with your new `test` user:

          updn$ rails server
