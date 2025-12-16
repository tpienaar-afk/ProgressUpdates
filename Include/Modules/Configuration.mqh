#ifndef __CONFIGURATION_MQH__
#define __CONFIGURATION_MQH__

//--------------------------------------------------
// GENERAL
//--------------------------------------------------
input bool   EnableTrading        = true;
input bool   EnableDebugMode      = false;

//--------------------------------------------------
// TRADE MODE
//--------------------------------------------------
enum ENUM_TradeMode
{
   TRADE_OFF = 0,
   TRADE_SIGNAL = 1,
   TRADE_SIMULATION = 2,
   TRADE_LIVE = 3
};

input ENUM_TradeMode TradeMode = TRADE_LIVE;

//--------------------------------------------------
// RISK & LOTS
//--------------------------------------------------
input bool   UseFixedLot       = false;
input double FixedLotSize      = 0.01;

input bool   UseRiskPercent    = true;
input double RiskPerTradePct   = 1.0;

input double MinLotPerTrade    = 0.01;
input double MaxLotPerTrade    = 5.0;

//--------------------------------------------------
// SPREAD & VOLATILITY
//--------------------------------------------------
input double MaxSpreadPips     = 3.0;
input int    ATRPeriod         = 14;

//--------------------------------------------------
// EQUITY PROTECTION
//--------------------------------------------------
input bool   UseEquityGuard    = true;
input double SoftDrawdownPct   = 20.0;
input double HardDrawdownPct   = 35.0;

//--------------------------------------------------
// TIME / SESSION
//--------------------------------------------------
input bool   BlockWeekendForex = true;

//--------------------------------------------------
// DASHBOARD
//--------------------------------------------------
input bool   ShowDashboard     = true;

#endif // __CONFIGURATION_MQH__
