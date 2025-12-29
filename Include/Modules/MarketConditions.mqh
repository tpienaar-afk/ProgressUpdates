#ifndef __MARKET_CONDITIONS_MQH__
#define __MARKET_CONDITIONS_MQH__

//--------------------------------------------------
// Detect synthetic instruments
//--------------------------------------------------
bool IsSyntheticMarket(const string symbol)
{
   string s = symbol;
   StringToUpper(s);

   return (
      StringFind(s, "VOLATILITY") >= 0 ||
      StringFind(s, "CRASH")      >= 0 ||
      StringFind(s, "BOOM")       >= 0 ||
      StringFind(s, "STEP")       >= 0
   );
}

//--------------------------------------------------
// Market condition guard (session / weekend)
//--------------------------------------------------
bool MarketConditionsOK(
   const string symbol,
   double /*maxSpread*/,   // reserved for future use
   string &blockReason
)
{
   // Forex / CFDs only
   if(!IsSyntheticMarket(symbol))
   {
      MqlDateTime t;
      TimeToStruct(TimeTradeServer(), t);

      // Weekend block
      if(t.day_of_week == 0 || t.day_of_week == 6)
      {
         blockReason = "Weekend";
         return false;
      }

      // Session block
      if(t.hour < 7 || t.hour > 21)
      {
         blockReason = "Out of session";
         return false;
      }
   }

   blockReason = "";
   return true;
}

#endif // __MARKET_CONDITIONS_MQH__
