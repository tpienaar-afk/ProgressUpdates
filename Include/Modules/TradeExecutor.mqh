#ifndef __TRADE_EXECUTOR_MQH__
#define __TRADE_EXECUTOR_MQH__

#include <Trade/Trade.mqh>

bool Trade_OpenBuy(const string symbol, double lot)
{
   CTrade trade;
   return trade.Buy(lot, symbol);
}

bool Trade_OpenSell(const string symbol, double lot)
{
   CTrade trade;
   return trade.Sell(lot, symbol);
}

#endif
