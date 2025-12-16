#ifndef __GLOBALS_MQH__
#define __GLOBALS_MQH__

//--------------------------------------------------
// MAGIC & INSTANCE SAFETY
//--------------------------------------------------
long   gMagicNumber      = 0;
bool   gInitialized      = false;

//--------------------------------------------------
// ACCOUNT STATE
//--------------------------------------------------
double gStartBalance     = 0.0;
bool   gTradingAllowed   = true;

//--------------------------------------------------
// MARKET STATE
//--------------------------------------------------
double gLastSpreadPips   = 0.0;
double gLastATR_Pips     = 0.0;

//--------------------------------------------------
// SIGNAL STATE
//--------------------------------------------------
int    gLastSignalDir    = 0;    // -1 sell, 0 none, +1 buy
double gLastSignalPower  = 0.0;

//--------------------------------------------------
// BLOCKING / DIAGNOSTICS
//--------------------------------------------------
string gBlockReason      = "";
bool   gConditionsOK     = true;

//--------------------------------------------------
// TIME & RECOVERY
//--------------------------------------------------
datetime gLastTradeTime  = 0;

#endif // __GLOBALS_MQH__
