#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

//--------------------------------------------------
// PURE risk-based lot calculation (math only)
//--------------------------------------------------
double CalculateRiskLot(
   double balance,
   double riskPercent,
   double price,
   double slPrice,
   double tickValue,
   double tickSize
)
{
   if(balance <= 0 || riskPercent <= 0)
      return 0.0;

   if(tickValue <= 0 || tickSize <= 0)
      return 0.0;

   double slDistance = MathAbs(price - slPrice);
   if(slDistance <= 0)
      return 0.0;

   double riskMoney = balance * (riskPercent / 100.0);

   double costPerLot = (slDistance / tickSize) * tickValue;
   if(costPerLot <= 0)
      return 0.0;

   double lot = riskMoney / costPerLot;

   return lot;   // NO clamping, NO broker rules
}

#endif
