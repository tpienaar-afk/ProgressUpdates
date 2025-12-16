#ifndef __TM_TRAIL_MQH__
#define __TM_TRAIL_MQH__

#include <Trade/Trade.mqh>

void ApplyTrailingStop(
   CTrade &tr,
   const string symbol,
   double trailPips
)
{
   if(!PositionSelect(symbol)) return;
}

#endif
