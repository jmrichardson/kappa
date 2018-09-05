import logplus
import plac
import configparser
import json
from kafka import KafkaProducer
from celery import Celery
from alpha_vantage.timeseries import TimeSeries
# from alpha_vantage.techindicators import TechIndicators
# from alpha_vantage.sectorperformance import SectorPerformances
# from alpha_vantage.cryptocurrencies import CryptoCurrencies

# amqp://user:bitnami@192.168.1.100:5672//
app = Celery('alphavantage', broker='amqp://guest:guest@localhost//')


@app.task
def getDailyAdjusted(symbol: "Equity ticker symbol"):
    """ Download Alpha Vantage daily adjusted price history for equity

    Keyword Arguments:
        symbol:  Symbol of equity
    """

    # Setup logging (Log file path and context arguments)
    log = logplus.setup('../../logs/alphavantage.log', '../config/logging.yaml', symbol=symbol)

    # Total execution time
    log.info('Start ingest module Alphavantage: ' + symbol )

    # Get AV API user key
    config = configparser.ConfigParser()
    config.read("config.ini")
    key = config.get("ingest.alphavantage", "key")

    # Get json string of daily adjusted values
    # ts = TimeSeries(key=key, output_format='pandas')
    ts = TimeSeries(key=key)
    data, meta_data = ts.get_daily_adjusted(symbol)

    producer = KafkaProducer(value_serializer=lambda v: json.dumps(v).encode('utf-8'), bootstrap_servers='192.168.1.100:9092')

    # producer = KafkaProducer(bootstrap_servers='192.168.1.100:9092')
    producer.send('daily_alphavantage', data)


    # latest = data.tail(1)
    # test = latest.to_json(orient="records")

    # new = data.head(1)

    # print(json.dumps(data))


if __name__ == '__main__':
    plac.call(getDailyAdjusted)
