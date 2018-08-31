import logplus
import plac
import configparser
import json
from celery import Celery
from alpha_vantage.timeseries import TimeSeries
# from alpha_vantage.techindicators import TechIndicators
# from alpha_vantage.sectorperformance import SectorPerformances
# from alpha_vantage.cryptocurrencies import CryptoCurrencies

# amqp://user:bitnami@192.168.1.100:5672//
app = Celery('alphavantage', broker='amqp://user@localhost//')


@app.task
def add(x, y):
    return x + y


# @app.task
def main(symbol: "Equity ticker symbol"):

    config = configparser.ConfigParser()
    config.read("../config.ini")
    key = config.get("ingest.alphavantage", "key")

    ts = TimeSeries(key=key)
    # Get json object with the intraday data and another with  the call's metadata
    data, meta_data = ts.get_daily_adjusted(symbol)

    # print(json.dumps(data))


if __name__ == '__main__':
    plac.call(main)
