#ifndef __SIGNAL_GENERATOR_MQH__
#define __SIGNAL_GENERATOR_MQH__

//#include "Indicators.mqh"

//--------------------------------------------------
// Signal structure
//--------------------------------------------------
struct SignalInfo
{
   int    direction;   // -1 = SELL, 0 = NONE, +1 = BUY
   double strength;    // 0..100
};

//--------------------------------------------------
// Scalper MA crossover signal
//--------------------------------------------------
SignalInfo GetScalperSignal(const string symbol,
                            ENUM_TIMEFRAMES tf,
                            int fastMAPeriod,
                            int slowMAPeriod)
{
   SignalInfo sig;
   sig.direction = 0;
   sig.strength  = 0.0;

   double fastPrev = EMA(symbol, tf, fastMAPeriod, 1);
   double fastCurr = EMA(symbol, tf, fastMAPeriod, 0);

   double slowPrev = EMA(symbol, tf, slowMAPeriod, 1);
   double slowCurr = EMA(symbol, tf, slowMAPeriod, 0);

   if(fastPrev <= slowPrev && fastCurr > slowCurr)
   {
      sig.direction = 1;
      sig.strength  = MathMin(100.0, MathAbs(fastCurr - slowCurr) * 10000.0);
   }
   else if(fastPrev >= slowPrev && fastCurr < slowCurr)
   {
      sig.direction = -1;
      sig.strength  = MathMin(100.0, MathAbs(fastCurr - slowCurr) * 10000.0);
   }

   return sig;
}

#endif // __SIGNAL_GENERATOR_MQH__
