# otwarte zabytki

### application init
 - brew search elasticsearch postgresql
 - cp config/database.yml.example config/database.yml
 - create database and database users for dev and testing
 - bundle install
 - bundle exec rake db:migrate
 - gunzip -c db/dump/%m_%d_%Y.sql.gz | script/rails db
 - script/rails s

### db dump command
```bash:
  pg_dump -h localhost -cxOWU user_name db_name | gzip > db/dump/$(date +"%m_%d_%Y").sql.gz
```

### elastic search
 - install according to this: https://github.com/karmi/tire#installation
 - install Morfologik (Polish) Analysis for ElasticSearch from: https://github.com/chytreg/elasticsearch-analysis-morfologik
 - index the data:

 ```bash:
  bundle exec rake relic:reindex
 ```

### testing

 We're using spork for faster tests.

 - ```bundle exec guard```
 - hit enter to rerun all tests

 For running single specs just type:

```bash
bundle exec rspec spec/controllers/relics_controller_spec.rb
```

## relics export

First you need to create initial dump of relics:

```bash
bundle exec rake relic:export_init[public/system/relics_history.csv]
```

Then, you can incrementially export users' suggestions by executing following command periodically:

```bash
bundle exec rake relic:export[public/system/relics_history.csv]
```

Cron jobs auto-setup is also available, just run ```bundle exec whenever --update-crontab```
