#ifndef __EQUITY_GUARD_MQH__
#define __EQUITY_GUARD_MQH__

//--------------------------------------------------
// Drawdown calculation
//--------------------------------------------------
double CurrentDrawdownPct()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   if(balance <= 0.0)
      return 0.0;

   double dd = 100.0 * (balance - equity) / balance;
   if(dd < 0.0) dd = 0.0;

   return dd;
}

//--------------------------------------------------
// Margin level check
//--------------------------------------------------
bool IsMarginSafe(string &blockReason)
{
   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);

   // Some brokers return 0 if no margin is used
   if(marginLevel == 0.0)
      return true;

   if(marginLevel < 100.0)
   {
      blockReason = "Margin level too low";
      return false;
   }

   return true;
}

//--------------------------------------------------
// Equity guard master gate
//--------------------------------------------------
bool EquityIsSafe(bool useEquityGuard,
                  double softDrawdownPct,
                  double hardDrawdownPct,
                  string &blockReason)
{
   if(!useEquityGuard)
      return true;

   double dd = CurrentDrawdownPct();

   if(dd >= hardDrawdownPct)
   {
      blockReason = "Hard drawdown reached";
      return false;
   }

   if(dd >= softDrawdownPct)
   {
      blockReason = "Soft drawdown reached";
      return false;
   }

   if(!IsMarginSafe(blockReason))
      return false;

   return true;
}

#endif // __EQUITY_GUARD_MQH__
