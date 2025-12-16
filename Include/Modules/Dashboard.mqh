#ifndef __DASHBOARD_MQH__
#define __DASHBOARD_MQH__

//--------------------------------------------------
// Layout
//--------------------------------------------------
#define DASH_X_LEFT   20
#define DASH_X_RIGHT  240
#define DASH_Y_START  60
#define DASH_LINE_H   18

//--------------------------------------------------
// Internal helper
//--------------------------------------------------
void DashLabel(const string name,int x,int y,const string text)
{
   if(ObjectFind(0,name)>=0)
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
   // Background
   ObjectCreate(0,"DASH_BG",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_XSIZE,430);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_YSIZE,120);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"DASH_BG",OBJPROP_BACK,true);

   // Left column
   DashLabel("D_STATUS", DASH_X_LEFT,  DASH_Y_START + 0*DASH_LINE_H,"Status:");
   DashLabel("D_SYMBOL", DASH_X_LEFT,  DASH_Y_START + 1*DASH_LINE_H,"Symbol:");
   DashLabel("D_TF",     DASH_X_LEFT,  DASH_Y_START + 2*DASH_LINE_H,"TF:");

   // Right column
   DashLabel("D_SPREAD", DASH_X_RIGHT, DASH_Y_START + 0*DASH_LINE_H,"Spread:");
   DashLabel("D_RISK",   DASH_X_RIGHT, DASH_Y_START + 1*DASH_LINE_H,"Risk:");
   DashLabel("D_LOT",    DASH_X_RIGHT, DASH_Y_START + 2*DASH_LINE_H,"Lot:");
   DashLabel("D_SIGNAL", DASH_X_RIGHT, DASH_Y_START + 3*DASH_LINE_H,"Signal:");
}

//--------------------------------------------------
// Updates
//--------------------------------------------------
void Dashboard_UpdateStatus(const string s)
{
   ObjectSetString(0,"D_STATUS",OBJPROP_TEXT,"Status: "+s);
}

void Dashboard_UpdateSymbol(const string s)
{
   ObjectSetString(0,"D_SYMBOL",OBJPROP_TEXT,"Symbol: "+s);
}

void Dashboard_UpdateTF(const string s)
{
   ObjectSetString(0,"D_TF",OBJPROP_TEXT,"TF: "+s);
}

void Dashboard_UpdateSpread(double v)
{
   ObjectSetString(0,"D_SPREAD",OBJPROP_TEXT,
                   "Spread: "+DoubleToString(v,1));
}

void Dashboard_UpdateRisk(double v)
{
   ObjectSetString(0,"D_RISK",OBJPROP_TEXT,
                   "Risk: "+DoubleToString(v,1)+"%");
}

void Dashboard_UpdateLot(double v)
{
   ObjectSetString(0,"D_LOT",OBJPROP_TEXT,
                   "Lot: "+DoubleToString(v,2));
}

void Dashboard_UpdateSignal(const string s)
{
   ObjectSetString(0,"D_SIGNAL",OBJPROP_TEXT,"Signal: "+s);
}

//--------------------------------------------------
// Cleanup
//--------------------------------------------------
void Dashboard_Destroy()
{
   string objs[]={
      "DASH_BG","D_STATUS","D_SYMBOL","D_TF",
      "D_SPREAD","D_RISK","D_LOT","D_SIGNAL"
   };

   for(int i=0;i<ArraySize(objs);i++)
      ObjectDelete(0,objs[i]);
}

#endif
