# -*- coding: utf-8 -*-
require "./lib/slack_notifier.rb"
require "./config/slack.rb"

notifier = SlackNotifier.new(My::Config::Slack.token,
                             channel: My::Config::Slack.channel)

require "./lib/abemaria.rb"
require "./config/abema.rb"

abema = Abemaria.new(My::Config::Abema.bearer, 
                     channels: My::Config::Abema.channels,
                     keywords: My::Config::Abema.keywords,
                     ignores: My::Config::Abema.ignores)

newcomers = abema.newcomers
nctext = "*新着*\n" + Abemaria.show(newcomers)
notifier.reserve Time.now+1, nctext

newcomers.each do |c|
  c.each do |s|
    notifier.reserve Time.at(s.startAt - 5*60), "もうすぐはじまる\n#{Abemaria.show([[s]])}"
  end
end

favorites = abema.favorites
favtext = "*お気に入り*\n" + Abemaria.show(favorites)
notifier.reserve Time.now+1, favtext

favorites.each do |c|
  c.each do |s|
    be_notify = s.keywords.any? do |hit|
      My::Config::Abema.keywords.any? do |k|
        k[:keyword] == hit and k[:notification]
      end
    end
    if be_notify
      notifier.reserve Time.at(s.startAt - 5*60), "もうすぐはじまる\n#{Abemaria.show([[s]])}"
    end
  end
end

notifier.wait
