#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

//--------------------------------------------------
// Proper risk-based lot calculation (SL aware)
//--------------------------------------------------
double CalculateRiskLot(
   const string symbol,
   double riskPercent,
   double slPrice
)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0 || riskPercent <= 0)
      return 0.0;

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

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

   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   lot = MathMax(minLot, MathMin(maxLot, lot));
   lot = MathFloor(lot / step) * step;

   return NormalizeDouble(lot, 2);
}

#endif
