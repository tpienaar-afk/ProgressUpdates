#ifndef __RISK_MANAGER_MQH__
#define __RISK_MANAGER_MQH__

double CalculateRiskLot(const string symbol, double riskPercent)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0 || riskPercent <= 0) return 0;

   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   return NormalizeDouble(minLot, 2);
}

#endif
