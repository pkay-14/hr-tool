FROM library/ruby:2.6

LABEL description="HRModule dev image"
LABEL version="0.0.1"

ENV APP_USER    hrmodule
ENV APP_GROUP   hrmodule
ENV RACK_ENV development
ENV SU_APP su - $APP_USER -c

RUN apt-get update && apt-get install -y rsync
RUN addgroup $APP_GROUP && \
  adduser --home /home/$APP_USER --ingroup $APP_GROUP --shell /bin/bash  $APP_USER
RUN uname -a

WORKDIR /home/$APP_USER/src

RUN chown $APP_USER.$APP_GROUP -R /home/$APP_USER

COPY startup.sh /home/$APP_USER/src
COPY .env /home/$APP_USER/src
RUN mkdir -p /home/$APP_USER/src/tmp/pids
RUN mkdir -p /home/$APP_USER/src/sidekiq/letter_opener
RUN chown $APP_USER.$APP_GROUP -R /home/$APP_USER/src
#RUN chmod +x /home/$APP_USER/src/startup.sh

RUN chown $APP_USER.$APP_GROUP -R /home/$APP_USER/src
RUN chmod +x /home/$APP_USER/src/startup.sh
RUN chmod +x /home/$APP_USER/src/.env

RUN gem install bundler
RUN gem install rack

ENV GEM_HOME /home/$APP_USER/bundle
ENV PATH $GEM_HOME/bin:$PATH

EXPOSE 8080

CMD [ "bash", "/home/hrmodule/src/startup.sh"]
