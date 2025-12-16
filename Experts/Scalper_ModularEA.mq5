#property strict
#property version   "1.10"
#property description "Modular Scalper EA – stable locked baseline"

//--------------------------------------------------
// Module includes (LOCKED PATHS)
//--------------------------------------------------
#include <Modules/Dashboard.mqh>
#include <Modules/MarketConditions.mqh>
#include <Modules/Indicators.mqh>
#include <Modules/Signal_Scalper.mqh>
#include <Modules/PipCalculator.mqh>
#include <Modules/RiskManager.mqh>
#include <Modules/TradeExecutor.mqh>

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
int OnInit()
{
   Print("Scalper_ModularEA loaded");

   Dashboard_Create();
   Dashboard_UpdateStatus("INITIALISING");
   Dashboard_UpdateSymbol(_Symbol);
   Dashboard_UpdateRisk(RiskPercent);

   return INIT_SUCCEEDED;
}

//--------------------------------------------------
void OnDeinit(const int reason)
{
   Dashboard_Destroy();
   Print("Scalper_ModularEA unloaded");
}

//--------------------------------------------------
void OnTick()
{
   // --- Spread
   double spread = GetDisplaySpread(_Symbol);
   Dashboard_UpdateSpread(spread);

   // --- Market conditions
   if(!MarketConditionsOK(_Symbol, MaxSpread, g_blockReason))
   {
      Dashboard_UpdateStatus(g_blockReason);
      Dashboard_UpdateSignal("-");
      return;
   }

   Dashboard_UpdateStatus("OK");

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

   string signalText = (signal > 0 ? "BUY" : "SELL");
   Dashboard_UpdateSignal(signalText);

   // --- Risk & lot sizing
   double lot = CalculateRiskLot(_Symbol, RiskPercent);
   if(lot <= 0)
   {
      Dashboard_UpdateStatus("RISK ERROR");
      return;
   }

   Dashboard_UpdateLot(lot);

   // --- Trade execution
   bool ok;
   if(signal > 0)
      ok = Trade_OpenBuy(_Symbol, lot);
   else
      ok = Trade_OpenSell(_Symbol, lot);

   Dashboard_UpdateStatus(ok ? "TRADE OPENED" : "ORDER FAILED");
}
