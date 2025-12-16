#ifndef __SIGNAL_SCALPER_MQH__
#define __SIGNAL_SCALPER_MQH__

int GetScalperSignal(
   const string symbol,
   ENUM_TIMEFRAMES tf,
   int fastMA,
   int slowMA,
   int rsiPeriod
)
{
   double f0 = EMA(symbol, tf, fastMA, 0);
   double f1 = EMA(symbol, tf, fastMA, 1);
   double s0 = EMA(symbol, tf, slowMA, 0);
   double s1 = EMA(symbol, tf, slowMA, 1);
   double r  = RSI(symbol, tf, rsiPeriod, 0);

   if(f1 <= s1 && f0 > s0 && r > 50) return +1;
   if(f1 >= s1 && f0 < s0 && r < 50) return -1;

   return 0;
}

#endif
