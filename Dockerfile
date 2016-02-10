FROM pushbit/ruby

RUN apt-get update
RUN apt-get install -y libicu-dev
RUN apt-get install -y cmake
RUN apt-get install ruby2.2-dev

RUN gem install github-linguist
RUN gem install faraday
RUN gem install octokit

ADD ./execute.rb ./execute.rb

CMD ['ruby', './execute.rb']