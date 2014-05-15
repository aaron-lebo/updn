###updn

This project started after a comment by someone on [Hacker News](http://news.ycombinator.com) suggesting implementing a Hacker News/Reddit/Digg style site where story submission and voting required Dogecoin. This is my attempt at something similar.

####tldr

Reddit-style site where users must have Bitcoin to submit stories.

* new stories cost the equivalent of $0.03
* upvotes/downvotes cost the equivalent of $0.01
* comments are free
* also, a tipping system is built in where users can send whatever amount they want to each other

The recipient of an upvote receives the equivalent amount of Bitcoin. Ideally, this means that:

1. Story submissions and votes have some cost, and people will be more thoughtful about using either one.
2. Good content is rewarded. If someone submits a link to their blog post and they receive 700 upvotes, they get the equivalent of about $7.
3. People can easily be introduced to cryptocurrencies. Instead of buying Bitcoin online/offline or begging somewhere, they can make a comment and receive a small amount if others find it worthwhile.
4. The site itself can easily be monetized. No ads.

The key is that the cost exists, but it is still small. You could submit 5 stories and give out 15 votes to people and it would only cost about $0.30; not an large amount of money, but enough to weed out junk content.

####rationale

Social news sites are nothing new. Slashdot was probably the father but since then there have been numerous sites including Digg, del.icio.us, Reddit, and Hacker News. The basic idea is simple: users get to to submit and vote on what content they think belongs on the front page. It is democracy in action with all its benefits and flaws. It works pretty well, but there are obvious issues. 

1) Aside from exposure, good content is not actually rewarded monetarily. In fact, the additional traffic might be more expensive than the exposure is worth.
2) Since submissions and votes do not actually cost anything aside from time, it is easy to flood the system with noise. Additionally, users are careless and thoughtlessly upvote mediocre content or downvote controversial but worthwhile content.
3) Forum-style sites are notoriously difficult to monetize. 

Can these problems be fixed? If submissions and votes actually have a monetary cost, maybe.

####implementation

How do we easily incorporate money? We could require a credit card but that has a high psychological barrier of entry for a lot of people. Why not use Bitcoin or another cryptocurrency instead? It is ideal for this kind of system; somewhat anonymous and designed for transactions over the internet. Some individuals have already called Dogecoin "the tipping currency of the internet". It and other cryptocurrencies are easy ways to reward people small amounts of money for good content. [/r/dogecoin](http://www.reddit.com/r/dogecoin) in particular is known for users tipping each other for funny and useful comments. But that uses a third-party bot and submissions and story submissions are not affected by this. Let's build similar functionality right into the software instead.

When a user signs up for the site, a Bitcoin address is generated for them. This is their deposit address. In order to fully use the site (submit stories or vote on content), they need to transfer some Bitcoin to it.

Once they do that, they can submit new stories and vote. They can also tip stories, comments, and users directly, if they feel that something or someone deserves a different amount than voting provides. Once they accumulate a decent amount, they can create a withdrawal and have the Bitcoin transfered to an outside address.

###Lobsters Rails Project

This is the source code to the site operating at
[https://lobste.rs](https://lobste.rs).  It is a Rails 4 codebase and uses a
SQL (MariaDB in production) backend for the database and Sphinx for the search
engine.

While you are free to fork this code and modify it (according to the [license](https://github.com/jcs/lobsters/blob/master/LICENSE))
to run your own link aggregation website, this source code repository and bug
tracker are only for the site operating at [lobste.rs](https://lobste.rs/).
Please do not use the bug tracker for support related to operating your own
site unless you are contributing code that will also benefit [lobste.rs](https://lobste.rs/).

####Contributing bugfixes and new features

Please see the [CONTRIBUTING](https://github.com/jcs/lobsters/blob/master/CONTRIBUTING.md)
file.

####Initial setup

* Install Ruby. Supported Ruby versions include 1.9.3, 2.0.0 and 2.1.0.

* Checkout the lobsters git tree from Github

         $ git clone git://github.com/jcs/lobsters.git
         $ cd lobsters
         lobsters$ 

* Run Bundler to install/bundle gems needed by the project:

         lobsters$ bundle

* Create a MySQL (other DBs supported by ActiveRecord may work, only MySQL and
MariaDB have been tested) database, username, and password and put them in a
`config/database.yml` file:

          development:
            adapter: mysql2
            encoding: utf8mb4
            reconnect: false
            database: lobsters_dev
            socket: /tmp/mysql.sock
            username: *username*
            password: *password*
            
          test:
            adapter: sqlite3
            database: db/test.sqlite3
            pool: 5
            timeout: 5000

* Load the schema into the new database:

          lobsters$ rake db:schema:load

* Create a `config/initializers/secret_token.rb` file, using a randomly
generated key from the output of `rake secret`:

          Lobsters::Application.config.secret_token = 'your random secret here'

* (Optional, only needed for the search engine) Install Sphinx.  Build Sphinx
config and start server:

          lobsters$ rake ts:rebuild

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

          lobsters$ rails console
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

          lobsters$ rails server
