#property strict
#property version   "1.50"
#property description "Scalper Modular EA – synthetic safe baseline"

//==================================================
// EXECUTION MODE
//==================================================
#include <Modules/ExecutionMode.mqh>

//==================================================
// CORE / UI
//==================================================
#include <Modules/Dashboard.mqh>
#include <Modules/MarketConditions.mqh>
#include <Modules/PipCalculator.mqh>
#include <Modules/ExecutionGuard.mqh>

//==================================================
// SIGNALS
//==================================================
#include <Modules/Indicators.mqh>
#include <Modules/Signal_Scalper.mqh>

//==================================================
// RISK / TRADE (Trade object lives here)
//==================================================
#include <Modules/SLTPManager.mqh>
#include <Modules/RiskManager.mqh>
#include <Modules/TradeExecutor.mqh>

//==================================================
// PAPER TRADING
//==================================================
#include <Modules/PaperTrade.mqh>

//==================================================
// INPUTS
//==================================================
input double RiskPercent   = 0.3;   // SAFE for synthetics
input int    FastMAPeriod  = 10;
input int    SlowMAPeriod  = 30;
input int    RSIPeriod     = 14;

input int    SL_ATR_Period     = 14;
input double SL_ATR_Multiplier = 2.5;
input double RR_Multiplier     = 1.2;

//==================================================
// GLOBALS
//==================================================
string   g_blockReason     = "";
datetime g_lastTradeTime   = 0;
double   g_lastTradeProfit = 0.0;

//==================================================
// INIT
//==================================================
int OnInit()
{
   Dashboard_Create();

   Dashboard_UpdateSymbol(_Symbol);
   Dashboard_UpdateTF(TFToString(_Period));
   Dashboard_UpdateRisk(RiskPercent);
   Dashboard_UpdateMode(ExecutionModeToText());
   Dashboard_UpdateStatus("READY");

   Print("EA LOADED: ", _Symbol);
   return INIT_SUCCEEDED;
}

//==================================================
// DEINIT
//==================================================
void OnDeinit(const int reason)
{
   Dashboard_Destroy();
   Print("EA STOPPED");
}

//==================================================
// COOLDOWN AFTER LOSS
//==================================================
bool CooldownOK()
{
   if(g_lastTradeTime == 0)
      return true;

   int waitSeconds = (g_lastTradeProfit < 0 ? 600 : 120);

   if(TimeCurrent() - g_lastTradeTime < waitSeconds)
   {
      Dashboard_UpdateStatus("COOLDOWN");
      return false;
   }
   return true;
}

//==================================================
// TICK
//==================================================
void OnTick()
{
   // --- UI
   Dashboard_UpdateSpread(GetDisplaySpread(_Symbol));
   Dashboard_UpdatePaperPL(PaperTrade_GetProfit());
   PaperTrade_OnTick();

   // --- Guards
   if(!ExecutionTimingOK(_Symbol))
      return;

   if(!MarketConditionsOK(_Symbol, 0, g_blockReason))
   {
      Dashboard_UpdateStatus(g_blockReason);
      return;
   }

   if(!CooldownOK())
      return;

   // --- Signal
   int signal = GetScalperSignal(
      _Symbol,
      PERIOD_M1,
      FastMAPeriod,
      SlowMAPeriod,
      RSIPeriod
   );

   if(signal == 0)
   {
      Dashboard_UpdateSignal("NO SIGNAL");
      return;
   }

   Dashboard_UpdateSignal(signal > 0 ? "BUY" : "SELL");

   // --- SL / TP
   double sl = 0.0, tp = 0.0;

   if(!CalculateSLTP(
         _Symbol,
         signal > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
         SL_ATR_Period,
         SL_ATR_Multiplier,
         RR_Multiplier,
         sl,
         tp))
   {
      Dashboard_UpdateStatus("SLTP ERROR");
      return;
   }

   // --- Lot size (account safe)
   double lot = CalculateRiskLot(_Symbol, RiskPercent, sl);
   if(lot <= 0)
   {
      Dashboard_UpdateStatus("RISK BLOCKED");
      return;
   }

   Dashboard_UpdateLot(lot);

   // --- PAPER MODE
   if(ExecutionMode == MODE_PAPER && !pt_active)
   {
      int dir = (signal > 0 ? +1 : -1);
      PaperTrade_Open(dir, lot, sl, tp);
      Dashboard_UpdateStatus("PAPER OPEN");
      return;
   }

   // --- LIVE MODE
   if(ExecutionMode == MODE_LIVE && !PositionSelect(_Symbol))
   {
      bool ok;

      if(signal > 0)
         ok = Trade_OpenBuy(_Symbol, lot, SL_ATR_Period, SL_ATR_Multiplier, RR_Multiplier);
      else
         ok = Trade_OpenSell(_Symbol, lot, SL_ATR_Period, SL_ATR_Multiplier, RR_Multiplier);

      Dashboard_UpdateStatus(ok ? "LIVE OPEN" : "ORDER FAILED");
   }
}

//==================================================
// TRADE RESULT TRACKING (CORRECT MQL5 WAY)
//==================================================
void OnTradeTransaction(
   const MqlTradeTransaction &trans,
   const MqlTradeRequest &req,
   const MqlTradeResult &res
)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
      return;

   if(trans.deal_type != DEAL_TYPE_BUY &&
      trans.deal_type != DEAL_TYPE_SELL)
      return;

   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);

   g_lastTradeTime   = TimeCurrent();
   g_lastTradeProfit = profit;

   Print("Trade closed | Profit: ", profit);
}
