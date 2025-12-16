#ifndef __TM_BE_MQH__
#define __TM_BE_MQH__

#include <Trade/Trade.mqh>

void ApplyBreakEven(
   CTrade &tr,
   const string symbol,
   double triggerPips,
   double lockPips
)
{
   if(!PositionSelect(symbol)) return;
   // stub – safe
}

#endif
