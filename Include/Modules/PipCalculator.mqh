#ifndef __PIP_CALCULATOR_MQH__
#define __PIP_CALCULATOR_MQH__

double GetDisplaySpread(const string symbol)
{
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   if(ask <= 0 || bid <= 0) return 0.0;

   double raw = ask - bid;

   string s = symbol;
   StringToUpper(s);

   // Synthetic → divide by 10 for display (Deriv convention)
   if(StringFind(s,"VOLATILITY")>=0 ||
      StringFind(s,"CRASH")>=0 ||
      StringFind(s,"BOOM")>=0)
   {
      return raw / 10.0;
   }

   // Forex → pips
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double pip   = (digits==3 || digits==5) ? point*10.0 : point;

   return raw / pip;
}

#endif
