#ifndef __PIP_CALCULATOR_MQH__
#define __PIP_CALCULATOR_MQH__

//--------------------------------------------------
// Detect synthetic symbols
//--------------------------------------------------
bool IsSynthetic(const string symbol)
{
   string s = symbol;
   StringToUpper(s);

   return (StringFind(s,"VOLATILITY") >= 0 ||
           StringFind(s,"CRASH")      >= 0 ||
           StringFind(s,"BOOM")       >= 0 ||
           StringFind(s,"STEP")       >= 0);
}

//--------------------------------------------------
// Display-friendly spread calculation
// Forex  -> pips
// Synthetic -> points
//--------------------------------------------------
double GetDisplaySpread(const string symbol)
{
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

   if(ask <= 0 || bid <= 0)
   {
      MqlTick tick;
      if(!SymbolInfoTick(symbol, tick))
         return 0.0;

      ask = tick.ask;
      bid = tick.bid;

      if(ask <= 0 || bid <= 0)
         return 0.0;
   }

   double raw = ask - bid;
   if(raw <= 0)
      return 0.0;

   // -------------------------------------------------
   // SYNTHETICS → points
   // -------------------------------------------------
   if(IsSynthetic(symbol))
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(point <= 0)
         return 0.0;

      return raw / point;
   }

   // -------------------------------------------------
   // FOREX → pips
   // -------------------------------------------------
   double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   if(point <= 0)
      return 0.0;

   double pip = (digits == 3 || digits == 5) ? point * 10.0 : point;

   return raw / pip;
}

#endif
