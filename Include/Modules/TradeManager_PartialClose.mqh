#ifndef __TM_PARTIAL_MQH__
#define __TM_PARTIAL_MQH__

#include <Trade/Trade.mqh>

void ApplyPartialClose(
   CTrade &tr,
   const string symbol,
   double triggerPips,
   double percent
)
{
   if(!PositionSelect(symbol)) return;
}

#endif
