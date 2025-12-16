#ifndef __MARKET_CONDITIONS_MQH__
#define __MARKET_CONDITIONS_MQH__

bool IsSyntheticMarket(const string symbol)
{
   string s = symbol;
   StringToUpper(s);

   return (StringFind(s,"VOLATILITY")>=0 ||
           StringFind(s,"CRASH")>=0 ||
           StringFind(s,"BOOM")>=0 ||
           StringFind(s,"STEP")>=0);
}

bool MarketConditionsOK(
   const string symbol,
   double /*maxSpread*/,
   string &blockReason
)
{
   if(!IsSyntheticMarket(symbol))
   {
      MqlDateTime t;
      TimeToStruct(TimeTradeServer(), t);

      if(t.day_of_week == 0 || t.day_of_week == 6)
      {
         blockReason = "Weekend";
         return false;
      }

      if(t.hour < 7 || t.hour > 21)
      {
         blockReason = "Out of session";
         return false;
      }
   }

   blockReason = "";
   return true;
}

#endif
