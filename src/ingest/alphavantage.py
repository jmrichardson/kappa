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
app = Celery('alphavantage', broker='amqp://user:bitnami@localhost//')


@app.task
def getDailyAdjusted(symbol: "Equity ticker symbol"):
    """ Download Alpha Vantage daily adjusted price history for equity

    Keyword Arguments:
        symbol:  Symbol of equity
    """

    # Get AV API user key
    config = configparser.ConfigParser()
    config.read("../config.ini")
    key = config.get("ingest.alphavantage", "key")
    return key
    # ts = TimeSeries(key=key)

    # Get json string of daily adjusted values
    # data, meta_data = ts.get_daily_adjusted(symbol)

    # print(json.dumps(data))


if __name__ == '__main__':
    plac.call(getDailyAdjusted)
