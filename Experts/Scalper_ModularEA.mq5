#property strict
#property version   "1.10"
#property description "Modular Scalper EA – stable locked baseline"

//--------------------------------------------------
// Module includes (LOCKED PATHS)
//--------------------------------------------------
#include <Modules/ExecutionMode.mqh>
#include <Modules/Dashboard.mqh>
#include <Modules/MarketConditions.mqh>
#include <Modules/Indicators.mqh>
#include <Modules/Signal_Scalper.mqh>
#include <Modules/PipCalculator.mqh>
#include <Modules/RiskManager.mqh>
#include <Modules/TradeExecutor.mqh>
#include <Modules/PaperTrade.mqh>


//--------------------------------------------------
// Inputs
//--------------------------------------------------
input double MaxSpread     = 50.0;
input double RiskPercent   = 1.0;
input int    FastMAPeriod  = 10;
input int    SlowMAPeriod  = 30;
input int    RSIPeriod     = 14;

//--------------------------------------------------
// Globals
//--------------------------------------------------
string g_blockReason = "";

//--------------------------------------------------
// Expert initialization
//--------------------------------------------------
int OnInit()
{
   Print("Scalper_ModularEA loaded");

   Dashboard_Create();

   Dashboard_UpdateStatus("INITIALISING");
   Dashboard_UpdateSymbol(_Symbol);
   Dashboard_UpdateTF(TFToString(_Period));
   Dashboard_UpdateRisk(RiskPercent);
   Dashboard_UpdateMode(ExecutionModeToText());

   // HARD SAFETY NOTICE
   if(ExecutionMode != MODE_LIVE)
      Print("⚠ EA running in SAFE MODE (NO REAL TRADES)");

   if(ExecutionMode == MODE_LIVE)
      Alert("⚠ LIVE TRADING ENABLED ⚠");

   return INIT_SUCCEEDED;
}

//--------------------------------------------------
// Expert deinitialization
//--------------------------------------------------
void OnDeinit(const int reason)
{
   Dashboard_Destroy();
   Print("Scalper_ModularEA unloaded");
}

//--------------------------------------------------
// Expert tick
//--------------------------------------------------
void OnTick()


{
   
//Call update on every tick
   
   PaperTrade_OnTick();
   Dashboard_UpdatePaperPL(PaperTrade_GetProfit());
   
   
   
   // --------------------------------------------------
   // ALWAYS UPDATE DASHBOARD (NO EARLY RETURNS ABOVE)
   // --------------------------------------------------
   double spread = GetDisplaySpread(_Symbol);
   Dashboard_UpdateSpread(spread);
   Dashboard_UpdatePaperPL(PaperTrade_GetProfit());

   // --------------------------------------------------
   // ANALYSIS MODE (DISPLAY ONLY – ABSOLUTE HARD STOP)
   // --------------------------------------------------
   if(ExecutionMode == MODE_ANALYSIS)
   {
      Dashboard_UpdateStatus("ANALYSIS");
      Dashboard_UpdateSignal("-");
      return;
   }

   // --------------------------------------------------
   // MARKET CONDITIONS
   // --------------------------------------------------
   if(!MarketConditionsOK(_Symbol, MaxSpread, g_blockReason))
   {
      Dashboard_UpdateStatus(g_blockReason);
      Dashboard_UpdateSignal("-");
      return;
   }

   Dashboard_UpdateStatus("OK");

   // --------------------------------------------------
   // SIGNAL
   // --------------------------------------------------
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

   string signalText = (signal > 0 ? "BUY" : "SELL");
   Dashboard_UpdateSignal(signalText);

   // --------------------------------------------------
   // LOT CALCULATION
   // --------------------------------------------------
   double lot = CalculateRiskLot(_Symbol, RiskPercent);
   if(lot <= 0)
   {
      Dashboard_UpdateStatus("RISK ERROR");
      return;
   }

   Dashboard_UpdateLot(lot);

   // --------------------------------------------------
   // PAPER TRADING MODE
   // --------------------------------------------------
  if(ExecutionMode == MODE_PAPER)
{
   // Manage existing paper trade
   PaperTrade_Manage(signal > 0 ? +1 : -1);

   // Open new paper trade if none exists
   if(!pt_active)
   {
      PaperTrade_Open(signal > 0 ? +1 : -1, lot);
      Dashboard_UpdateStatus("PAPER TRADE OPEN");
   }
   else
   {
      Dashboard_UpdateStatus("PAPER TRADE ACTIVE");
   }

   return;
}


   // --------------------------------------------------
   // LIVE TRADING MODE (ONLY PLACE REAL ORDERS CAN HAPPEN)
   // --------------------------------------------------
   if(ExecutionMode == MODE_LIVE)
   {
      bool ok = false;

      if(signal > 0)
         ok = Trade_OpenBuy(_Symbol, lot);
      else
         ok = Trade_OpenSell(_Symbol, lot);

      Dashboard_UpdateStatus(ok ? "TRADE OPENED" : "ORDER FAILED");
   }
}
