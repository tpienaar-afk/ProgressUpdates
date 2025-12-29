#property strict
#property version   "1.59"
#property description "Scalper Modular EA – EURGBP hardened"

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
// RISK / TRADE
//==================================================
#include <Modules/SLTPManager.mqh>
#include <Modules/RiskManager.mqh>
#include <Modules/TradeExecutor.mqh>
#include <Modules/EmergencySL.mqh>

//==================================================
// PAPER TRADING
//==================================================
#include <Modules/PaperTrade.mqh>

//==================================================
// INPUTS
//==================================================
input double RiskPercent   = 0.3;
input int    FastMAPeriod  = 10;
input int    SlowMAPeriod  = 30;
input int    RSIPeriod     = 14;

input int    SL_ATR_Period     = 14;
input double SL_ATR_Multiplier = 2.5;
input double RR_Multiplier     = 1.2;

//==================================================
// PAIR PROFILE
//==================================================
struct PairProfile
{
   double riskPercent;
   double slATRMultiplier;
   double rrMultiplier;
};

PairProfile profile;

//==================================================
// PER-SYMBOL COOLDOWN STATE
//==================================================
struct CooldownState
{
   string   symbol;
   datetime lastTime;
   double   lastProfit;
};

CooldownState g_cooldowns[];

//--------------------------------------------------
int GetCooldownIndex(const string symbol)
{
   for(int i=0; i<ArraySize(g_cooldowns); i++)
      if(g_cooldowns[i].symbol == symbol)
         return i;

   int n = ArraySize(g_cooldowns);
   ArrayResize(g_cooldowns, n+1);
   g_cooldowns[n].symbol     = symbol;
   g_cooldowns[n].lastTime   = 0;
   g_cooldowns[n].lastProfit = 0.0;
   return n;
}

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
// COOLDOWN AFTER LOSS (PER SYMBOL)
//==================================================
bool CooldownOK()
{
   int idx = GetCooldownIndex(_Symbol);

   if(g_cooldowns[idx].lastTime == 0)
      return true;

   int waitSeconds = (g_cooldowns[idx].lastProfit < 0 ? 600 : 120);

   if(TimeCurrent() - g_cooldowns[idx].lastTime < waitSeconds)
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
   // Emergency SL
   EmergencySL_CheckAndClose(_Symbol);

   //==================================================
   // PAIR PROFILE DEFAULT
   //==================================================
   profile.riskPercent     = RiskPercent;
   profile.slATRMultiplier = SL_ATR_Multiplier;
   profile.rrMultiplier    = RR_Multiplier;

   //==================================================
   // EURGBP HARD PROFILE
   //==================================================
   if(_Symbol == "EURGBP")
   {
      profile.riskPercent     = 0.2;
      profile.slATRMultiplier = 1.6;
      profile.rrMultiplier    = 0.7;

      // Only ONE trade allowed
      if(PositionSelect(_Symbol))
      {
         Dashboard_UpdateStatus("EURGBP: ONE TRADE ONLY");
         return;
      }
   }

   //==================================================
   // UI
   //==================================================
   Dashboard_UpdateSpread(GetDisplaySpread(_Symbol));
   Dashboard_UpdatePaperPL(PaperTrade_GetProfit());
   PaperTrade_OnTick();

   //==================================================
   // GUARDS
   //==================================================
   if(!ExecutionTimingOK(_Symbol))
      return;

   string blockReason = "";
   if(!MarketConditionsOK(_Symbol, 0, blockReason))
   {
      Dashboard_UpdateStatus(blockReason);
      return;
   }

   if(!CooldownOK())
      return;

   //==================================================
   // SIGNAL
   //==================================================
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

   //==================================================
   // EURGBP MOMENTUM FILTER (KEY FIX)
   //==================================================
   if(_Symbol == "EURGBP")
   {
      double fastEMA = EMA(_Symbol, PERIOD_M1, FastMAPeriod, 0);
      double slowEMA = EMA(_Symbol, PERIOD_M1, SlowMAPeriod, 0);

      int atrHandle = iATR(_Symbol, PERIOD_M1, 14);
      if(atrHandle == INVALID_HANDLE)
         return;

      double atrBuf[];
      if(CopyBuffer(atrHandle, 0, 0, 1, atrBuf) <= 0)
      {
         IndicatorRelease(atrHandle);
         return;
      }

      double atr = atrBuf[0];
      IndicatorRelease(atrHandle);

      if(MathAbs(fastEMA - slowEMA) < atr * 0.8)
      {
         Dashboard_UpdateStatus("EURGBP: NO MOMENTUM");
         return;
      }
   }

   Dashboard_UpdateSignal(signal > 0 ? "BUY" : "SELL");

   //==================================================
   // SL / TP
   //==================================================
   double sl = 0.0, tp = 0.0;

   if(!CalculateSLTP(
         _Symbol,
         signal > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
         SL_ATR_Period,
         profile.slATRMultiplier,
         profile.rrMultiplier,
         sl,
         tp))
   {
      Dashboard_UpdateStatus("SLTP ERROR");
      return;
   }

   //==================================================
   // LOT SIZE
   //==================================================
   double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
   double price     = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   double rawLot = CalculateRiskLot(
      balance,
      profile.riskPercent,
      price,
      sl,
      tickValue,
      tickSize
   );

   if(rawLot <= 0)
   {
      Dashboard_UpdateStatus("RISK CALC FAIL");
      return;
   }

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   double lot = MathFloor(rawLot / step) * step;
   lot = MathMax(minLot, MathMin(maxLot, lot));

   if(lot < minLot)
   {
      Dashboard_UpdateStatus("LOT < MIN");
      return;
   }

   Dashboard_UpdateLot(lot);

   //==================================================
   // PAPER MODE
   //==================================================
   if(ExecutionMode == MODE_PAPER && !pt_active)
   {
      int dir = (signal > 0 ? +1 : -1);
      PaperTrade_Open(dir, lot, sl, tp);
      Dashboard_UpdateStatus("PAPER OPEN");
      return;
   }

   //==================================================
   // LIVE MODE
   //==================================================
   if(ExecutionMode == MODE_LIVE && !PositionSelect(_Symbol))
   {
      bool ok;

      if(signal > 0)
         ok = Trade_OpenBuy(_Symbol, lot, SL_ATR_Period,
                            profile.slATRMultiplier,
                            profile.rrMultiplier);
      else
         ok = Trade_OpenSell(_Symbol, lot, SL_ATR_Period,
                             profile.slATRMultiplier,
                             profile.rrMultiplier);

      Dashboard_UpdateStatus(ok ? "LIVE OPEN" : "ORDER FAILED");
   }
}

//==================================================
// TRADE RESULT TRACKING
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

   string sym = trans.symbol;
   int idx = GetCooldownIndex(sym);

   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);

   g_cooldowns[idx].lastTime   = TimeCurrent();
   g_cooldowns[idx].lastProfit = profit;

   Print("Trade closed | ", sym, " | Profit: ", profit);
}
