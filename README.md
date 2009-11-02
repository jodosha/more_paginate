more_paginate
=============

Provide a **Twitter like** pagination for Rails.


Example
-------

For a full working example, please visit [more\_paginate\_example](http://github.com/jodosha/more_paginate_example) repository.

    # app/models/tweet.rb
    class Tweet < ActiveRecord::Base
      belongs_to :person

      def self.paginate_by_creation_date(params)
        paginate :all,
          :sort_key   => params[:sort_key] || "created_at",
          :sort_value => params[:sort_value],
          :sort_id    => params[:sort_id],
          :sort_order => "desc",
          :include    => :person
      end
    end

    # app/controllers/tweets_controller.rb
    class TweetsController < ApplicationController
      def index
        @tweets = Tweet.paginate_by_creation_date params.dup

        respond_to do |format|
          format.html
          format.js { render :partial => "tweet_list" }
        end
      end
    end

    # app/views/tweets/index.html.erb
    <h1>Tweets</h1>
    <div id="tweets">
      <%= render "tweet_list" %>
    </div>

    # app/views/tweets/_tweet_list.html.erb
    <ol class="tweetList">
    <% @tweets.each do |tweet| -%>
      <li class="tweet">
        <%= avatar tweet.person %>
        <%= link_to h(tweet.person.nickname), person_path(tweet.person), :class => "bold" %>
        <%= truncate h(tweet.text), :length => 140 %><br />
        <span class="time"><%= link_to tweet.created_at.to_s(:db), tweet_path(tweet) %></span>
      </li>
    <% end -%>
    <ol>
    <%= more_paginate @tweets %>

    # public/javascripts/application.js
    $(document).ready(function() {
      $("#more_link").morePaginate({ container: "#tweets" });
    });

Acknowledgements
----------------

* [@lifo](http://twitter.com/lifo) for his great speech about [Lessons learnt](http://m.onkey.org/lessons_learnt_2009.pdf) and pagination.
* [@deadroxy](http://twitter.com/deadroxy) for her help.
* The **Yahoo!** team for their awesome [Efficient Pagination Using MySQL](http://www.scribd.com/doc/14683263/Efficient-Pagination-Using-MySQL) presentation.

Copyright
---------

Copyright (c) 2009 [Luca Guidi](http://lucaguidi.com), released under the MIT license.
