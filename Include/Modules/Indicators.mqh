#ifndef __INDICATORS_MQH__
#define __INDICATORS_MQH__

double EMA(const string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
{
   int h = iMA(symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
   if(h == INVALID_HANDLE) return 0.0;

   double buf[];
   if(CopyBuffer(h, 0, shift, 1, buf) <= 0) return 0.0;
   return buf[0];
}

double RSI(const string symbol, ENUM_TIMEFRAMES tf, int period, int shift)
{
   int h = iRSI(symbol, tf, period, PRICE_CLOSE);
   if(h == INVALID_HANDLE) return 0.0;

   double buf[];
   if(CopyBuffer(h, 0, shift, 1, buf) <= 0) return 0.0;
   return buf[0];
}

#endif
