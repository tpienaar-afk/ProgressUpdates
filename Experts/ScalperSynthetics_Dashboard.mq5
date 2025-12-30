//+------------------------------------------------------------------+
//| Scalper_Synthetics_SpikeFade_FINAL_Vol10.mq5                      |
//| FINAL LOCKED VERSION – SYNTHETICS (VOL10 ONLY)                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include <Trade/Trade.mqh>
CTrade Trade;

//==================== ENUMS ====================
enum ENUM_EXECUTION_MODE { EXEC_ANALYSIS=0, EXEC_PAPER=1, EXEC_LIVE=2 };
enum ENUM_RISK_TIER      { TIER_MICRO=0, TIER_SMALL=1, TIER_MEDIUM=2, TIER_LARGE=3 };

//==================== INPUTS ===================
input ENUM_EXECUTION_MODE ExecutionMode = EXEC_PAPER;

// Spike (Vol10 tuned)
input int    SpikeLookbackBars = 12;
input double SpikeATR_Multiple = 2.0;
input int    SpikeCooldownBars = 10;

// ATR / SL
input int    ATR_Period     = 14;
input double ATR_Multiplier = 1.2;
input double MinSL_Multiplier_Synthetics = 1.2;
input double MinSL_Points_Fallback       = 120;

// Partial TP
input double TP1_R_Multiple   = 1.0;
input double TP2_R_Multiple   = 2.0;
input double TP1_ClosePercent = 0.50;

//==================== GLOBALS ==================
int atrHandle = INVALID_HANDLE;
int lastSpikeBarIndex = -100000;

string LastSkipReason = "";
double LastCalcLot    = 0.0;
int TradesToday = 0, SkipsToday = 0, SpikesToday = 0;
string LastSpikeTime = "-";

//==================== DASHBOARD =================
#define DASH_BG_NAME   "SpikeDash_BG"
#define DASH_TXT_PREF  "SpikeDash_TXT_"
#define DASH_X         10
#define DASH_Y         20
#define DASH_W         360
#define DASH_LINE_H    14

//==================== RISK ======================
ENUM_RISK_TIER GetRiskTier()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq <= 200.0)  return TIER_MICRO;
   if(eq <= 1000.0) return TIER_SMALL;
   if(eq <= 5000.0) return TIER_MEDIUM;
   return TIER_LARGE;
}

string RiskTierToString(ENUM_RISK_TIER t)
{
   if(t==TIER_MICRO)  return "MICRO";
   if(t==TIER_SMALL)  return "SMALL";
   if(t==TIER_MEDIUM) return "MEDIUM";
   return "LARGE";
}

double AllowedMoneyRisk()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   ENUM_RISK_TIER t = GetRiskTier();

   if(t==TIER_MICRO)  return MathMin(eq*0.0025,  2.0);
   if(t==TIER_SMALL)  return MathMin(eq*0.0025,  5.0);
   if(t==TIER_MEDIUM) return MathMin(eq*0.0030, 15.0);
   return                  MathMin(eq*0.0030, 30.0);
}

//==================== SYMBOL ====================
bool IsSupportedSymbol()
{
   string s = _Symbol;
   StringToUpper(s);
   if(StringFind(s,"VOLATILITY 10")>=0) return true;
   LastSkipReason = "Symbol not supported (Vol10 only)";
   SkipsToday++;
   return false;
}

//==================== INDICATORS ================
double GetATR()
{
   if(atrHandle==INVALID_HANDLE) return 0;
   double b[];
   if(CopyBuffer(atrHandle,0,0,1,b)<=0) return 0;
   return b[0];
}

//==================== SPIKE =====================
bool SpikeDetected()
{
   int bars = iBars(_Symbol,PERIOD_M1);
   if(bars-lastSpikeBarIndex < SpikeCooldownBars) return false;

   double atr = GetATR();
   if(atr<=0) return false;

   double hi=-DBL_MAX, lo=DBL_MAX;
   for(int i=1;i<=SpikeLookbackBars;i++)
   {
      hi = MathMax(hi,iHigh(_Symbol,PERIOD_M1,i));
      lo = MathMin(lo,iLow (_Symbol,PERIOD_M1,i));
   }

   if((hi-lo) < atr*SpikeATR_Multiple) return false;

   lastSpikeBarIndex = bars;
   SpikesToday++;
   LastSpikeTime = TimeToString(TimeCurrent(),TIME_SECONDS);
   return true;
}

//==================== LOT =======================
bool CalculateLotFromRisk(double slPts,double &lotOut)
{
   double tv = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tv<=0||ts<=0||slPts<=0) return false;

   double allowed = AllowedMoneyRisk();
   double lot = allowed / ((slPts*tv)/ts);

   double minLot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double step   = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   lot = MathFloor(lot/step)*step;
   LastCalcLot = lot;

   if(lot < minLot)
   {
      LastSkipReason = "Lot < broker minimum";
      SkipsToday++;
      return false;
   }

   lotOut = lot;
   LastSkipReason = "";
   return true;
}

//==================== EXECUTION =================
bool PlaceOrders(double lot,double slPts)
{
   ENUM_ORDER_TYPE type = ORDER_TYPE_SELL;

   double price = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double sl = price + slPts*_Point;
   double tp1 = price - slPts*TP1_R_Multiple*_Point;
   double tp2 = price - slPts*TP2_R_Multiple*_Point;

   double l1 = NormalizeDouble(lot*TP1_ClosePercent,2);
   double l2 = NormalizeDouble(lot-l1,2);
   if(l1<=0||l2<=0) return false;

   Trade.SetDeviationInPoints(10);
   Trade.Sell(l1,_Symbol,price,sl,tp1);
   Trade.Sell(l2,_Symbol,price,sl,tp2);
   return true;
}

//==================== DASHBOARD =================
void DrawDashboard()
{
   string lines[];
   ArrayResize(lines,10);

   lines[0]="SpikeFade FINAL (Vol10)";
   lines[1]="Mode: "+(ExecutionMode==EXEC_LIVE?"LIVE":ExecutionMode==EXEC_PAPER?"PAPER":"ANALYSIS");
   lines[2]="Equity: $"+DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2);
   lines[3]="Tier: "+RiskTierToString(GetRiskTier());
   lines[4]="Allowed Risk: $"+DoubleToString(AllowedMoneyRisk(),2);
   lines[5]="Symbol: "+_Symbol;
   lines[6]="Calc Lot: "+DoubleToString(LastCalcLot,4);
   lines[7]="Spikes: "+(string)SpikesToday;
   lines[8]="Trades: "+(string)TradesToday;
   lines[9]="Status: "+(LastSkipReason==""?"OK":LastSkipReason);

   int h=ArraySize(lines)*DASH_LINE_H+12;

   if(ObjectFind(0,DASH_BG_NAME)<0)
   {
      ObjectCreate(0,DASH_BG_NAME,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_XDISTANCE,DASH_X);
      ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_YDISTANCE,DASH_Y);
      ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_XSIZE,DASH_W);
   }

   ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,DASH_BG_NAME,OBJPROP_BGCOLOR,
      (LastSkipReason==""?clrDarkGreen:clrDarkRed));

   for(int i=0;i<ArraySize(lines);i++)
   {
      string n=DASH_TXT_PREF+(string)i;
      if(ObjectFind(0,n)<0)
      {
         ObjectCreate(0,n,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,n,OBJPROP_XDISTANCE,DASH_X+8);
         ObjectSetInteger(0,n,OBJPROP_YDISTANCE,DASH_Y+6+i*DASH_LINE_H);
         ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(0,n,OBJPROP_FONTSIZE,10);
         ObjectSetString (0,n,OBJPROP_FONT,"Consolas");
      }
      ObjectSetString(0,n,OBJPROP_TEXT,lines[i]);
   }
}

//==================== MT5 EVENTS ================
int OnInit()
{
   atrHandle = iATR(_Symbol,PERIOD_M1,ATR_Period);
   EventSetTimer(1);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();

   // Delete dashboard background
   ObjectDelete(0, DASH_BG_NAME);

   // Delete all dashboard text labels
   for(int i = 0; i < 20; i++)
   {
      ObjectDelete(0, DASH_TXT_PREF + (string)i);
   }

   // Release indicator
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
}


void OnTick()
{
   DrawDashboard();   // ← fallback redraw

   if(!IsSupportedSymbol()) return;
   if(!SpikeDetected())     return;
   if(ExecutionMode==EXEC_ANALYSIS) return;

   double atr = GetATR();
   if(atr <= 0) return;

   double slPts = (atr * ATR_Multiplier) / _Point;
   double lot;
   if(!CalculateLotFromRisk(slPts, lot)) return;

   TradesToday++;
   if(ExecutionMode == EXEC_PAPER) return;

   PlaceOrders(lot, slPts);
}

//+------------------------------------------------------------------+
