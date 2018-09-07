import logplus
import plac
import configparser
import json
import uuid
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

    # Create a unique id for this execution instance
    uid = uuid.uuid4().hex.upper()[0:6]

    # Setup logging (Log file path and context arguments)
    lp = logplus.setup('../../../logs/alphavantage.log', '../../config/logging.yaml', symbol=symbol, uid=uid)

    # Total execution time
    lp.info('Start ingest module Alphavantage: ' + symbol )

    # Get AV API user key
    config = configparser.ConfigParser()
    config.read("config.ini")
    key = config.get("default", "key")

    # Get json string of daily adjusted values
    # ts = TimeSeries(key=key, output_format='pandas')
    ts = TimeSeries(key=key)
    data, meta_data = ts.get_daily_adjusted(symbol)

    # Create producer to kafka topic
    producer = KafkaProducer(value_serializer=lambda v: json.dumps(v).encode('utf-8'), bootstrap_servers='192.168.1.100:9092')

     # Append data to topic
    lp.info('Sending data to topic')
    topic = config.get("default", "topic")
    producer.send(topic, data)

    # Close producer
    lp.info('Closing producer')
    producer.flush()
    producer.close()


if __name__ == '__main__':
    plac.call(getDailyAdjusted)
