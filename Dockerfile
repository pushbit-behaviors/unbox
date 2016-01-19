FROM ruby:2.2.3

RUN apt-get update
RUN apt-get install -y libicu-dev
RUN apt-get install -y cmake

RUN gem install github-linguist
RUN gem install faraday
RUN gem install octokit

ADD ./execute.sh ./execute.sh
ADD ./execute.rb ./execute.rb

CMD ./execute.sh
