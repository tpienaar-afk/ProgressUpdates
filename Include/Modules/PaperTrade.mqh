#ifndef __PAPER_TRADE_MQH__
#define __PAPER_TRADE_MQH__

//--------------------------------------------------
// Virtual position state
//--------------------------------------------------
bool   pt_active    = false;
int    pt_direction = 0;     // +1 BUY, -1 SELL
double pt_entry     = 0.0;
double pt_lot       = 0.0;
double pt_sl        = 0.0;
double pt_tp        = 0.0;

//--------------------------------------------------
void PaperTrade_Open(
   int direction,
   double lot,
   double sl_price,
   double tp_price
)
{
   pt_active    = true;
   pt_direction = direction;
   pt_lot       = lot;
   pt_sl        = sl_price;
   pt_tp        = tp_price;

   pt_entry = (direction > 0)
      ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
      : SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

//--------------------------------------------------
void PaperTrade_Close()
{
   pt_active    = false;
   pt_direction = 0;
   pt_entry     = 0.0;
   pt_lot       = 0.0;
   pt_sl        = 0.0;
   pt_tp        = 0.0;
}

//--------------------------------------------------
double PaperTrade_GetProfit()
{
   if(!pt_active)
      return 0.0;

   double price = (pt_direction > 0)
      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   double points = (price - pt_entry) * pt_direction;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickSize <= 0)
      return 0.0;

   return (points / tickSize) * tickValue * pt_lot;
}

//--------------------------------------------------
// Paper trade tick management
//--------------------------------------------------
void PaperTrade_OnTick()
{
   if(!pt_active)
      return;

   double price = (pt_direction > 0)
      ? SymbolInfoDouble(_Symbol, SYMBOL_BID)
      : SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // --- Stop Loss
   if(pt_sl > 0)
   {
      if(pt_direction > 0 && price <= pt_sl)
         PaperTrade_Close();

      if(pt_direction < 0 && price >= pt_sl)
         PaperTrade_Close();
   }

   // --- Take Profit
   if(pt_tp > 0)
   {
      if(pt_direction > 0 && price >= pt_tp)
         PaperTrade_Close();

      if(pt_direction < 0 && price <= pt_tp)
         PaperTrade_Close();
   }
}

#endif
