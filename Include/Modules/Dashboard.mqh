#ifndef __DASHBOARD_MQH__
#define __DASHBOARD_MQH__

//--------------------------------------------------
// Timeframe helper
//--------------------------------------------------
string TFToString(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return "?";
   }
}

//--------------------------------------------------
// Layout (LOCKED)
//--------------------------------------------------
#define DASH_X_LEFT    20
#define DASH_X_RIGHT   300

#define DASH_Y_START   96
#define DASH_LINE_H    18

//--------------------------------------------------
// Object names
//--------------------------------------------------
#define D_STATUS       "D_STATUS"
#define D_SYMBOL       "D_SYMBOL"
#define D_TF           "D_TF"
#define D_MODE         "D_MODE"
#define D_SPREAD       "D_SPREAD"
#define D_RISK         "D_RISK"
#define D_LOT          "D_LOT"
#define D_SIGNAL       "D_SIGNAL"
#define D_PAPER        "D_PAPER"

//--------------------------------------------------
// COLOR HELPERS
//--------------------------------------------------
color StatusColor(const string s)
{
   if(s == "WEEKEND" || s == "OUT OF SESSION")
      return clrOrange;

   if(s == "FAST MOVE" || s == "ERROR")
      return clrRed;

   if(s == "SIGNAL READY")
      return clrDodgerBlue;

   if(s == "TRADE EXECUTED" || s == "TRADE ACTIVE")
      return clrGreen;

   return clrSilver;
}

color SignalColor(const string s)
{
   if(StringFind(s, "STRONG") >= 0)
      return clrGreen;

   if(StringFind(s, "READY") >= 0)
      return clrDodgerBlue;

   if(StringFind(s, "WEAK") >= 0)
      return clrOrange;

   return clrSilver;
}

//--------------------------------------------------
// Label helper
//--------------------------------------------------
void DashLabel(const string name,int x,int y,const string text)
{
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetString (0,name,OBJPROP_FONT,"Consolas");
   ObjectSetString (0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrSilver);
}

//--------------------------------------------------
// Create dashboard
//--------------------------------------------------
void Dashboard_Create()
{
   DashLabel(D_STATUS, DASH_X_LEFT,  DASH_Y_START + 0*DASH_LINE_H, "Status:");
   DashLabel(D_SYMBOL, DASH_X_LEFT,  DASH_Y_START + 1*DASH_LINE_H, "Symbol:");
   DashLabel(D_TF,     DASH_X_LEFT,  DASH_Y_START + 2*DASH_LINE_H, "TF:");
   DashLabel(D_MODE,   DASH_X_LEFT,  DASH_Y_START + 3*DASH_LINE_H, "Mode:");

   DashLabel(D_SPREAD, DASH_X_RIGHT, DASH_Y_START + 0*DASH_LINE_H, "Spread:");
   DashLabel(D_RISK,   DASH_X_RIGHT, DASH_Y_START + 1*DASH_LINE_H, "Risk:");
   DashLabel(D_LOT,    DASH_X_RIGHT, DASH_Y_START + 2*DASH_LINE_H, "Lot:");
   DashLabel(D_SIGNAL, DASH_X_RIGHT, DASH_Y_START + 3*DASH_LINE_H, "Signal:");

   DashLabel(D_PAPER,  DASH_X_RIGHT, DASH_Y_START + 4*DASH_LINE_H, "Paper P/L:");
}

//--------------------------------------------------
// Updates
//--------------------------------------------------
void Dashboard_UpdateStatus(const string s)
{
   ObjectSetInteger(0,D_STATUS,OBJPROP_COLOR,StatusColor(s));
   ObjectSetString(0,D_STATUS,OBJPROP_TEXT,"Status: "+s);
}

void Dashboard_UpdateSignal(const string s)
{
   ObjectSetInteger(0,D_SIGNAL,OBJPROP_COLOR,SignalColor(s));
   ObjectSetString(0,D_SIGNAL,OBJPROP_TEXT,"Signal: "+s);
}

void Dashboard_UpdateSymbol(const string s)
{
   ObjectSetString(0,D_SYMBOL,OBJPROP_TEXT,"Symbol: "+s);
}

void Dashboard_UpdateTF(const string s)
{
   ObjectSetString(0,D_TF,OBJPROP_TEXT,"TF: "+s);
}

void Dashboard_UpdateMode(const string s)
{
   ObjectSetString(0,D_MODE,OBJPROP_TEXT,"Mode: "+s);
}

void Dashboard_UpdateSpread(double v)
{
   ObjectSetString(0,D_SPREAD,OBJPROP_TEXT,"Spread: "+DoubleToString(v,1));
}

void Dashboard_UpdateRisk(double v)
{
   ObjectSetString(0,D_RISK,OBJPROP_TEXT,"Risk: "+DoubleToString(v,1)+"%");
}

void Dashboard_UpdateLot(double v)
{
   ObjectSetString(0,D_LOT,OBJPROP_TEXT,"Lot: "+DoubleToString(v,2));
}

void Dashboard_UpdatePaperPL(double v)
{
   ObjectSetString(0,D_PAPER,OBJPROP_TEXT,"Paper P/L: "+DoubleToString(v,2));
}

//--------------------------------------------------
// Cleanup
//--------------------------------------------------
void Dashboard_Destroy()
{
   ObjectDelete(0,D_STATUS);
   ObjectDelete(0,D_SYMBOL);
   ObjectDelete(0,D_TF);
   ObjectDelete(0,D_MODE);
   ObjectDelete(0,D_SPREAD);
   ObjectDelete(0,D_RISK);
   ObjectDelete(0,D_LOT);
   ObjectDelete(0,D_SIGNAL);
   ObjectDelete(0,D_PAPER);
}

#endif
