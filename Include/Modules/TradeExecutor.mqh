#ifndef __TRADE_EXECUTOR_MQH__
#define __TRADE_EXECUTOR_MQH__

#include <Trade/Trade.mqh>
#include <Modules/SLTPManager.mqh>
#include <Modules/MarketConditions.mqh>   // REQUIRED for IsSyntheticMarket

//--------------------------------------------------
// Trade object (owned here ONLY)
//--------------------------------------------------
CTrade Trade;

//--------------------------------------------------
// Open BUY with SL/TP
//--------------------------------------------------
bool Trade_OpenBuy(
   const string symbol,
   double lot,
   int atrPeriod,
   double atrMultiplier,
   double rrMultiplier
)
{
   double sl = 0.0, tp = 0.0;

   if(!CalculateSLTP(
         symbol,
         ORDER_TYPE_BUY,
         atrPeriod,
         atrMultiplier,
         rrMultiplier,
         sl,
         tp))
   {
      return false;
   }

   return Trade.Buy(lot, symbol, 0.0, sl, tp);
}

//--------------------------------------------------
// Open SELL with SL/TP
//--------------------------------------------------
bool Trade_OpenSell(
   const string symbol,
   double lot,
   int atrPeriod,
   double atrMultiplier,
   double rrMultiplier
)
{
   double sl = 0.0, tp = 0.0;

   if(!CalculateSLTP(
         symbol,
         ORDER_TYPE_SELL,
         atrPeriod,
         atrMultiplier,
         rrMultiplier,
         sl,
         tp))
   {
      return false;
   }

   return Trade.Sell(lot, symbol, 0.0, sl, tp);
}

//--------------------------------------------------
// Max slippage (points) by market type
//--------------------------------------------------
double GetMaxSlippagePoints(const string symbol)
{
   // Synthetic instruments tolerate wider slippage
   if(IsSyntheticMarket(symbol))
      return 100.0;

   // Forex / CFD default
   return 30.0;
}

#endif // __TRADE_EXECUTOR_MQH__
