import logplus
import plac
from alpha_vantage.timeseries import TimeSeries
# from alpha_vantage.techindicators import TechIndicators
# from alpha_vantage.sectorperformance import SectorPerformances
# from alpha_vantage.cryptocurrencies import CryptoCurrencies


ts = TimeSeries(key='HRPMAL9U6F6FRB64')
# Get json object with the intraday data and another with  the call's metadata
data, meta_data = ts.get_daily_adjusted('MSFT')
