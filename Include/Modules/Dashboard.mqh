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
#define DASH_X_RIGHT   240

#define DASH_Y_START   96
#define DASH_LINE_H    18

#define DASH_BG_X      10
#define DASH_BG_Y      70
#define DASH_BG_W      460
#define DASH_BG_H      200

//--------------------------------------------------
// Object names
//--------------------------------------------------
#define DASH_BG        "DASH_BG"

#define D_STATUS       "D_STATUS"
#define D_SYMBOL       "D_SYMBOL"
#define D_TF           "D_TF"
#define D_MODE         "D_MODE"

#define D_SPREAD       "D_SPREAD"
#define D_RISK         "D_RISK"
#define D_LOT          "D_LOT"
#define D_SIGNAL       "D_SIGNAL"

#define DASH_SL        "DASH_SL"
#define DASH_TP        "DASH_TP"
#define DASH_BE        "DASH_BE"
#define DASH_TRAIL     "DASH_TRAIL"

#define D_PAPER        "D_PAPER"

//--------------------------------------------------
// Internal helper
//--------------------------------------------------
void DashLabel(const string name,int x,int y,const string text)
{
   if(ObjectFind(0,name) >= 0)
      ObjectDelete(0,name);

   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
   ObjectSetString (0,name,OBJPROP_FONT,"Consolas");
   ObjectSetString (0,name,OBJPROP_TEXT,text);
}

//--------------------------------------------------
// Create dashboard
//--------------------------------------------------
void Dashboard_Create()
{
   ObjectCreate(0,DASH_BG,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,DASH_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,DASH_BG,OBJPROP_XDISTANCE,DASH_BG_X);
   ObjectSetInteger(0,DASH_BG,OBJPROP_YDISTANCE,DASH_BG_Y);
   ObjectSetInteger(0,DASH_BG,OBJPROP_XSIZE,DASH_BG_W);
   ObjectSetInteger(0,DASH_BG,OBJPROP_YSIZE,DASH_BG_H);
   ObjectSetInteger(0,DASH_BG,OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,DASH_BG,OBJPROP_BACK,true);

   // Left
   DashLabel(D_STATUS, DASH_X_LEFT,  DASH_Y_START + 0*DASH_LINE_H, "Status:");
   DashLabel(D_SYMBOL, DASH_X_LEFT,  DASH_Y_START + 1*DASH_LINE_H, "Symbol:");
   DashLabel(D_TF,     DASH_X_LEFT,  DASH_Y_START + 2*DASH_LINE_H, "TF:");
   DashLabel(D_MODE,   DASH_X_LEFT,  DASH_Y_START + 3*DASH_LINE_H, "Mode:");

   // Right
   DashLabel(D_SPREAD, DASH_X_RIGHT, DASH_Y_START + 0*DASH_LINE_H, "Spread:");
   DashLabel(D_RISK,   DASH_X_RIGHT, DASH_Y_START + 1*DASH_LINE_H, "Risk:");
   DashLabel(D_LOT,    DASH_X_RIGHT, DASH_Y_START + 2*DASH_LINE_H, "Lot:");
   DashLabel(D_SIGNAL, DASH_X_RIGHT, DASH_Y_START + 3*DASH_LINE_H, "Signal:");

   // Management
   DashLabel(DASH_SL,    DASH_X_LEFT, DASH_Y_START + 5*DASH_LINE_H, "SL: -");
   DashLabel(DASH_TP,    DASH_X_LEFT, DASH_Y_START + 6*DASH_LINE_H, "TP: -");
   DashLabel(DASH_BE,    DASH_X_LEFT, DASH_Y_START + 7*DASH_LINE_H, "BE: -");
   DashLabel(DASH_TRAIL, DASH_X_LEFT, DASH_Y_START + 8*DASH_LINE_H, "Trail: -");

   DashLabel(D_PAPER, DASH_X_RIGHT, DASH_Y_START + 4*DASH_LINE_H, "Paper P/L:");
}

//--------------------------------------------------
// Updates
//--------------------------------------------------
void Dashboard_UpdateStatus(const string s)
{
   ObjectSetString(0,D_STATUS,OBJPROP_TEXT,"Status: "+s);
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

void Dashboard_UpdateSignal(const string s)
{
   ObjectSetString(0,D_SIGNAL,OBJPROP_TEXT,"Signal: "+s);
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
   string objs[]={
      DASH_BG,
      D_STATUS,D_SYMBOL,D_TF,D_MODE,
      D_SPREAD,D_RISK,D_LOT,D_SIGNAL,
      DASH_SL,DASH_TP,DASH_BE,DASH_TRAIL,
      D_PAPER
   };

   for(int i=0;i<ArraySize(objs);i++)
      ObjectDelete(0,objs[i]);
}

#endif
