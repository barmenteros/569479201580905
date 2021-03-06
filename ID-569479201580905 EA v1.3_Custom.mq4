//+------------------------------------------------------------------+
//|                                            ID-569479201580905 EA |
//|                                Copyright © 2016, barmenteros.com |
//|                                     support.team@barmenteros.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, barmenteros.com"
#property link      "http://barmenteros.com"
#property version   "1.30"
#property strict
#define EA_NAME     "ID-569479201580905 EA"
#define EA_VERSION  "v1.3"
#define EXPIRY_DATE  "2022.01.01 00:00"
#define WEBSITE_ADDRESS  "vicky.com"
#define SKYPE_ID  "vicky skype"

/*
+--------------------------------------------------------------------+

 R E M A R K S:

 - New in v1.3 (2017.03.20):
   » Lot size inputs are multiplied by 10. 

 - New in v1.2 (2016.12.09):
   » Changed from AccountBalance to AccountEquity. 
   » Added info to screen.

 - New in v1.1 (2016.12.05):
   » Enable inputs for every lot size. 
   » Add the option to enable/disable the auto lot size feature that 
     increases the lot size according to the account balance.

 - v1.0 (2016.11.18):
   » This EA does not use indicators. 
   » It only opens market orders (doesn't place pending positions).
   » Chart: ordinary (no renko nor other kind of offline charts).
   » Timeframe(s): ANY.
   » Multi-timeframe: No.

+--------------------------------------------------------------------+
*/


#define MAXOPENORDERS    101
#define INVALID_TICKET    -1
#define SLEEP_MEAN    2
#define SLEEP_MAX    8
#define ENTIRE_SYMBOL    0
#define ONLY_QUOTE_CURRENCY    1
#define ONLY_BASE_CURRENCY    2
#define OP_BUYSELL    6
#define ALL_ORDERS    -1
#define ONLY_MARKET    -2
#define ONLY_PENDING    -3
#define ONLY_BUY_ANY    -4
#define ONLY_SELL_ANY    -5
#define MODE_BALANCE    0
#define MODE_FREE_MARGIN    1
#define MODE_EQUITY    2
#define MODE_MANUAL    -1
#define MODE_NORMAL    0
#define MODE_SHORTHAND    1
#define INCLUDE_COMMENT    0
#define EXCLUDE_COMMENT    1
#define LAST_ORDER_BY_TICKET    0
#define LAST_ORDER_BY_TIME    1
#define ANY_CLOSE    -2
#define FAILED    -1
#define NOT_CLOSED    0
#define JUST_CLOSED    1
#define CLOSED_AT_TP    2
#define CLOSED_AT_SL    3
#define TOP_LEFT_CORNER    0
#define TOP_RIGHT_CORNER    1
#define BOTTOM_LEFT_CORNER    2
#define BOTTOM_RIGHT_CORNER    3
#define CURRENT_BAR_NO_NEW    0
#define CURRENT_BAR_NEW    1
#define SHIFT_CURRENT_BAR    0
#define SHIFT_PREVIOUS_BAR    1
#define MAX_AMOUNT_ARRAY_VALUES    22


#import "stdlib.ex4"
   string ErrorDescription(int error_code);
#import


extern string s1_="GENERAL SETTINGS";//________________________________
extern double Max_DD_InPercent = -1.0;
extern int MinimumElapsedMinutes = 240; //Minimum Elapsed Minutes

       long Password=0;
extern double BufferToOpenOrders = 10.0;
extern int Slippage = 5;
extern bool EnableAutoLotSize = true; //Enable Auto Lot Size
extern double Lots1 = 0.1; //Lots 1 
extern double Lots2 = 0.1; //Lots 2 
extern double Lots3 = 0.1; //Lots 3 
extern double Lots4 = 0.2; //Lots 4 
extern double Lots5 = 0.3; //Lots 5 
extern double Lots6 = 0.4; //Lots 6 
extern double Lots7 = 0.6; //Lots 7 
extern double Lots8 = 0.9; //Lots 8 
extern double Lots9 = 1.3; //Lots 9 
extern double Lots10 = 1.8; //Lots 10 
extern double Lots11 = 2.7; //Lots 11 
extern double Lots12 = 3.8; //Lots 12 
extern double Lots13 = 5.5; //Lots 13 
extern double Lots14 = 7.9; //Lots 14 
extern double Lots15 = 11.4; //Lots 15 
extern double Lots16 = 16.5; //Lots 16 
extern double Lots17 = 23.7; //Lots 17 
extern double Lots18 = 34.2; //Lots 18 
extern double Lots19 = 49.2; //Lots 19 
extern double Lots20 = 70.9; //Lots 20 
extern double Lots21 = 102.1; //Lots 21 
extern double Lots22 = 147.0; //Lots 22 
extern string _s1="";//¦
extern string _ss1="";//¦

extern string sN_="ADDITIONAL OPTIONS";//________________________________
extern bool DisplayLiveOrders = true; //Display Live Orders
//extern string _sN="";//¦
//extern string _ssN="";//¦


//+------------------------------------------------------------------+
// Global variables

bool bG_ValidParameters;
bool bG_IsTesting = false;

/*
  Must be 'true' if the function needs to get 'Digits' from a symbol
  different from the current chart on testing mode.
*/
bool bG_DismissTestingMode = false;

datetime dtG_CurrentTime;
int iG_Period;
int iG_Digits;
double dG_Point;
double dG_PointDigits;
double dG_MinLot;
string sG_HeadTxt;
string sG_BodyTxt;
string sG_Symbol;
string sG_TimeBegin;
string sG_RegisterFileName; // file name of the register
string sG_StoreDataFileName; // file name of the store data
string sG_RegisterTextHeader;

double ad_lots[MAX_AMOUNT_ARRAY_VALUES];// = { 
//   0.01, 0.01, 0.01, 
//   0.02, 0.03, 0.04,
//   0.06, 0.09, 0.13,
//   0.18, 0.27, 0.38,
//   0.55, 0.79, 1.14,
//   1.65, 2.37, 3.42,
//   4.92, 7.09, 10.21,
//   14.70 
//};

double ad_takeprofit[MAX_AMOUNT_ARRAY_VALUES] = { 
   10.0, 15.0, 20.0, 
   20.0, 25.0, 30.0,
   30.0, 30.0, 30.0,
   30.0, 30.0, 30.0,
   30.0, 35.0, 35.0,
   35.0, 35.0, 35.0,
   35.0, 35.0, 35.0,
   35.0 
};

       string SymbolSuffix = ""; //Symbol Suffix (eg: XXXXXXpro » pro)
       int MagicNumber = 312856813; //Magic Number ID
       string CommentForOrders = ""; //Comment For Orders
       bool Enable_CFD = false; //Enable CFD
       
       // if 'true', order opens when the signal bar has closed
       bool EntryAtClosedBar = true; //Enable Entry At Closed Bar
       
       // if 'true', only 1 order can be open at the same bar
       bool OneTradePerBar = false; //Enable One Trade Per Bar

       double StopLossInPips = 20.0; //StopLoss (In Pips)
       bool HiddenStopLoss = false; //Enable Hidden StopLoss
       double TakeProfitInPips = 40.0; //TakeProfit (In Pips)
       bool HiddenTakeProfit = false; //Enable Hidden TakeProfit

       string sM_="ALERTS SETTINGS";//________________________________
       bool DisableAllAlerts = false; //Disable All Alerts
       bool DialogBoxAlert = false; //Enable Pop-up Alert
       bool EmailAlert = false; //Enable Email Alert
       bool SMSAlert = false; //Enable Mobile Notifications
       bool SoundAlert = false; //Enable Sound Alert
       string SoundAlertFile = "alert.wav"; //Sound Alert File
       string _sM="";//¦
       string _ssM="";//¦

       bool DisplayInfo = false; //Display Info
       bool EnableRegister = false; //Enable Register
       bool EnableStoreData = false; //Enable Store Data

/*
  'SaveTemplate' stores a template with EA settings. The template is 
  saved by default in '[terminal_directory]\templates\'.
  This template should be requested along with other files to speed 
  up the debugging process.
*/
       bool SaveTemplate = false; //Enable Chart Save Template
       bool ScreenChartCapture = false; //Enable Screen Chart Capture
//+------------------------------------------------------------------+
//| IsSymbolList
//+------------------------------------------------------------------+
bool IsSymbolList (string symbol, int retries=3)
{
   int    i_last_error;
   int    _DIGITS;
   double d_BID;
//---- clean last error
   i_last_error = GetLastError ();
   i_last_error = 0;
//+------------------------------------------------------------------+
//---- verify data
   _DIGITS = (int)MarketInfo (symbol, MODE_DIGITS);
   d_BID = MarketInfo (symbol, MODE_BID);
   d_BID = NormalizeDouble (d_BID, _DIGITS);
   while (d_BID <= NormalizeDouble (0.0, _DIGITS) // no data available
          && retries > 0)                    // not been all retries
     {
       Sleep (500);                          // waiting half a second
       RefreshRates ();
       d_BID = MarketInfo (symbol, MODE_BID);
       d_BID = NormalizeDouble (d_BID, _DIGITS);
       retries--;                                  // next retry
     }
//---- verify last error
   i_last_error = GetLastError ();
   if (i_last_error == 4106)                       // unknown symbol
     {
       Print (__FUNCTION__," » ",symbol,
              ": unknown or missing symbol");
       Print (__FUNCTION__," » please, verify that ",symbol,
              " symbol is listed in the \"Market Watch\" window");
       Print (__FUNCTION__,
              " » for more information, press F1 and look for \"Market Watch\"" );
       return (false);
     }
//----
   return (true);
}
//+------------------------------------------------------------------+
//| IsValidAsCurrency function
//+------------------------------------------------------------------+
bool IsValidAsCurrency( string symbol, int mode=ENTIRE_SYMBOL )
  {
   // mode: [ONLY_BASE_CURRENCY] - for trading commodities
   string s_major_currencies[64] ={ "USD", "USd", "UsD", "uSD", "Usd", "uSd", "usD", "usd",
                                    "EUR", "EUr", "EuR", "eUR", "Eur", "eUr", "euR", "eur",
                                    "JPY", "JPy", "JpY", "jPY", "Jpy", "jPy", "jpY", "jpy",
                                    "GBP", "GBp", "GbP", "gBP", "Gbp", "gBp", "gbP", "gbp",
                                    "CHF", "CHf", "ChF", "cHF", "Chf", "cHf", "chF", "chf",
                                    "CAD", "CAd", "CaD", "cAD", "Cad", "cAd", "caD", "cad",
                                    "AUD", "AUd", "AuD", "aUD", "Aud", "aUd", "auD", "aud",
                                    "NZD", "NZd", "NzD", "nZD", "Nzd", "nZd", "nzD", "nzd" };
   string s_suff_pref_confusing[14] ={ "DJ_", "Dj_", "dj_", "BUND",   // Suffixes and prefixes confusing
                                       "BUNd", "BUnD", "BuND", "bUND", "BUnd", 
                                       "BunD", "buND", "Bund", "bunD", "bund" };
   string s_currency;
   string s_quote_currency;
   string s_base_currency;
   int    i;
//---- exceptions
   for( i = 0; i < 14; i++ )
      {
       s_currency = s_suff_pref_confusing[i];   
       if( StringFind( symbol, s_currency ) >= 0 ) // There is any confusing suffixes/prefixes
           return( false );                        // .. so it's not a currency
      }
//----
   for( i = 0; i < 64; i++ )
      {
       s_currency = s_major_currencies[i];
      //---
       if( mode == ENTIRE_SYMBOL &&
           StringFind( symbol, s_currency ) >= 0 )
           return( true );
      //---
       s_quote_currency = StringSubstr( symbol, 3, 3 );  // also called the cross-currency ( ex. xxxUSD -> USD )
       if( mode == ONLY_QUOTE_CURRENCY &&
           StringFind( s_quote_currency, s_currency ) >= 0 )
           return( true );
      //---
       s_base_currency = StringSubstr( symbol, 0, 3 );   // ( ex. USDxxx -> USD )
       if( mode == ONLY_BASE_CURRENCY &&
           StringFind( s_base_currency, s_currency ) >= 0 )
           return( true );
      }
//---- 
   return( false );
  }
//+------------------------------------------------------------------+
//| Get_DIGITS
//| b_dismiss_testing_mode: must be 'true' if the function needs to
//|                         get 'Digits' from a symbol different from
//|                         the current chart on testing mode
//+------------------------------------------------------------------+
int Get_DIGITS( string symbol, bool b_is_testing, bool b_dismiss_testing_mode=false, int retries=10 )
  {
   int    _DIGITS;                              // Count of digits after decimal point in the symbol prices
//----
   _DIGITS = -1;
   RefreshRates();
  //---
   if( !b_dismiss_testing_mode &&
       b_is_testing )
      _DIGITS = _Digits;
  //--- 
//   if( _DIGITS == -1 &&
//       symbol == _Symbol )                      // it's the symbol name of the current chart
//      _DIGITS = _Digits;
  //---
   if( _DIGITS != -1 )
      return( _DIGITS );
//----
   _DIGITS = (int)MarketInfo( symbol, MODE_DIGITS );
   while( _DIGITS < 0 &&                        // no digits available
          retries > 0 )                         // not been all retries
      {
       Sleep( 500 );                            // waiting half a second
       RefreshRates();
       _DIGITS = (int)MarketInfo( symbol, MODE_DIGITS );
      //---
       retries--;                               // next retry
      }
  //--- 
   if( _DIGITS < 0 )                            // yet no digits available
      {
       if( !IsSymbolList( symbol, retries ) )  // symbol is not available
	       return( -1 );
      //---
       Print( __FUNCTION__," » digits after decimal point for ",symbol," is not available" );
	    return( -1 );
	   }
//---- 
   return( _DIGITS );
  }
//+------------------------------------------------------------------+
//| Get_POINT
//+------------------------------------------------------------------+
double Get_POINT( string symbol, int i_Digits, bool b_is_testing, bool b_dismiss_testing_mode=false,  int retries=10, int mode = 0 )
  {
  // mode = [0] - pip; [1] - pipette
   double _POINT;                                        // Point size in the quote currency
//----
   _POINT = 0;
   RefreshRates();
  //---
   if( !b_dismiss_testing_mode &&
       b_is_testing )
      _POINT = _Point;
  //--- 
//   if( _POINT == 0 &&
//       symbol == _Symbol )                      // it's the symbol name of the current chart
//      _POINT = _Point;
  //---
   if( _POINT == 0 )
      _POINT =MarketInfo( symbol, MODE_POINT );
   _POINT =NormalizeDouble( _POINT, i_Digits );
  //---
   while( _POINT <= NormalizeDouble( 0.0, i_Digits ) &&   // no point size available
          retries > 0 )                                  // not been all retries
      {
       Sleep( 500 );                                     // waiting half a second
      //---
       RefreshRates();
       _POINT =MarketInfo( symbol, MODE_POINT );
       _POINT =NormalizeDouble( _POINT, i_Digits );
      //---
       retries--;                                        // next retry
      }
  //---
   if( _POINT <= NormalizeDouble( 0.0, i_Digits ) )       // yet no stop level available
      {
       if( !IsSymbolList( symbol, retries ) )           // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » point size for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   if( mode == 0 )
      {
       if( !IsValidAsCurrency( symbol ) )          // symbol does not contain any of the major currencies
          {
           _POINT *= ( ( i_Digits == 0 ) + 10.0 * ( i_Digits == 1 ) + 100.0 * ( i_Digits == 2 ) + 1000.0 * ( i_Digits == 3 ) + 10000.0 * ( i_Digits == 4 ) + 100000.0 * ( i_Digits == 5 ) + 1000000.0 * ( i_Digits == 6 ) );
           return( _POINT );
          } // symbol does not contain any of the major currencies END
      //--- 
       if( i_Digits == 1 || i_Digits == 3 || i_Digits == 5 ) _POINT *=10.0;
      }
//---- 
   return( _POINT );
  }
//+------------------------------------------------------------------+
//| Get_ASK
//+------------------------------------------------------------------+
double Get_ASK( string symbol, int i_Digits, bool b_is_testing, bool b_dismiss_testing_mode=false, int retries=10 )
  {
   int      i_text_position;
   double   d_ASK;                                     // Last incoming ask price
//----
   i_text_position =-1;
   i_text_position =StringFind( Symbol(), symbol );
//----
   RefreshRates();
   if( i_text_position >= 0 )                         // current financial instrument
      { d_ASK =Ask; }
   else // if( i_text_position < 0 )                  // no current financial instrument
      { d_ASK =MarketInfo( symbol, MODE_ASK ); }
   d_ASK =NormalizeDouble( d_ASK, i_Digits );
  //---
   if( !b_dismiss_testing_mode &&
       b_is_testing &&
       NormalizeDouble( d_ASK, i_Digits ) > NormalizeDouble( 0.0, i_Digits ) )
      return( d_ASK );
//----
   while( d_ASK <= NormalizeDouble( 0.0, i_Digits ) &&  // no ask price available
          retries > 0 )                               // not been all retries
      {
       Sleep( 500 );                                  // waiting half a second
      //---
       RefreshRates();
       if( i_text_position >= 0 )
          { d_ASK =Ask; }
       else // if( i_text_position < 0 )
          { d_ASK =MarketInfo( symbol, MODE_ASK ); }
       d_ASK =NormalizeDouble( d_ASK, i_Digits );
      //---
       retries--;                                     // next retry
      }
  //--- 
   if( d_ASK <= NormalizeDouble( 0.0, i_Digits ) )      // yet no ask price available
      {
       if( !IsSymbolList( symbol, retries ) )        // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » ask price for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   d_ASK = NormalizeDouble( d_ASK, i_Digits );
   return( d_ASK );
  }
//+------------------------------------------------------------------+
//| Get_BID
//+------------------------------------------------------------------+
double Get_BID( string symbol, int i_Digits, bool b_is_testing, bool b_dismiss_testing_mode=false, int retries=10 )
  {
   int    i_text_position;
   double d_BID;                                       // Last incoming bid price
//----
   i_text_position =-1;
   i_text_position =StringFind( Symbol(), symbol );
//----
   RefreshRates();
   if( i_text_position >= 0 )                         // current financial instrument
      { d_BID =Bid; }
   else // if( i_text_position < 0 )                  // no current financial instrument
      { d_BID =MarketInfo( symbol, MODE_BID ); }
   d_BID =NormalizeDouble( d_BID, i_Digits );
  //---
   if( !b_dismiss_testing_mode &&
       b_is_testing &&
       NormalizeDouble( d_BID, i_Digits ) > NormalizeDouble( 0.0, i_Digits ) )
      return( d_BID );
//----
   while( d_BID <= NormalizeDouble( 0.0, i_Digits ) &&  // no bid price available
          retries > 0 )                               // not been all retries
      {
       Sleep( 500 );                                  // waiting half a second
      //---
       RefreshRates();
       if( i_text_position >= 0 )
          { d_BID =Bid; }
       else // if( i_text_position < 0 )
          { d_BID =MarketInfo( symbol, MODE_BID ); }
       d_BID =NormalizeDouble( d_BID, i_Digits );
      //---
       retries--;                                     // next retry
      }
  //--- 
   if( d_BID <= NormalizeDouble( 0.0, i_Digits ) )      // yet no bid price available
      {
       if( !IsSymbolList( symbol, retries ) )        // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » bid price for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   d_BID = NormalizeDouble( d_BID, i_Digits );
   return( d_BID );
  }
//+------------------------------------------------------------------+
//| Get_STOPLEVEL
//+------------------------------------------------------------------+
double Get_STOPLEVEL( string symbol, int i_Digits, int retries=10, int mode = 0 )
  {
  // mode = [0] - pip; [1] - pipette
   double _STOPLEVEL;                           // Stop level in points
//----
   _STOPLEVEL = MarketInfo( symbol, MODE_STOPLEVEL );
   while( _STOPLEVEL < 0 &&                     // no stop level available
          retries > 0 )                         // not been all retries
      {
       Sleep( 500 );                            // waiting half a second
       RefreshRates();
       _STOPLEVEL = MarketInfo( symbol, MODE_STOPLEVEL );
       retries--;                               // next retry
      }
  //---
   if( _STOPLEVEL < 0 )                         // yet no stop level available
      {
       if( !IsSymbolList( symbol, retries ) )  // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » stop level for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   if( mode == 0 )
      {
       if( !IsValidAsCurrency( symbol ) )                         // symbol does not contain any of the major currencies
          {
           _STOPLEVEL *= ( ( i_Digits == 0 ) + 0.1 * ( i_Digits == 1 ) + 0.01 * ( i_Digits == 2 ) + 0.001 * ( i_Digits == 3 ) + 0.0001 * ( i_Digits == 4 ) + 0.00001 * ( i_Digits == 5 ) + 0.000001 * ( i_Digits == 6 ) );
           return( _STOPLEVEL );
          } // symbol does not contain any of the major currencies END
      //--- 
       if( i_Digits == 1 || i_Digits == 3 || i_Digits == 5 ) _STOPLEVEL *=0.1;
      }
//---- 
   return( _STOPLEVEL );
  }
//+------------------------------------------------------------------+
//| Get_SPREAD
//+------------------------------------------------------------------+
double Get_SPREAD( string symbol, int i_Digits, double d_Point, int retries=3, int mode = 0 )
  {
  // mode = [0] - pip; [1] - pipette
   double _SPREAD;                              // Spread value in points
   double d_ASK;
   double d_BID;
//----
   _SPREAD = MarketInfo( symbol, MODE_SPREAD );
   while( _SPREAD < 0 &&                        // no spread available
          retries > 0 )                         // not been all retries
      {
       Sleep( 500 );                            // waiting half a second
       RefreshRates();
       _SPREAD = MarketInfo( symbol, MODE_SPREAD );
       retries--;                               // next retry
      }
  //---
   if( _SPREAD < 0 )                            // yet no spread available
      {
       if( !IsSymbolList( symbol, retries ) )  // symbol is not available
	       return( -1.0 );
      //--- get ask price
       d_ASK = Get_ASK( symbol, i_Digits, bG_IsTesting, bG_DismissTestingMode );
       if( d_ASK < 0 )                           // no ask price available
	        return( -1.0 );
      //--- get bid price
       d_BID = Get_BID( symbol, i_Digits, bG_IsTesting, bG_DismissTestingMode );
       if( d_BID < 0 )                           // no bid price available
	        return( -1.0 );
      //---
       _SPREAD = MathAbs( d_ASK - d_BID ) / d_Point;
       return( _SPREAD );
	   }
//---- 
   if( mode == 0 )
      {
       if( !IsValidAsCurrency( symbol ) )       // symbol does not contain any of the major currencies
          {
           _SPREAD *= ( ( i_Digits == 0 ) + 0.1 * ( i_Digits == 1 ) + 0.01 * ( i_Digits == 2 ) + 0.001 * ( i_Digits == 3 ) + 0.0001 * ( i_Digits == 4 ) + 0.00001 * ( i_Digits == 5 ) + 0.000001 * ( i_Digits == 6 ) );
           return( _SPREAD );
          } // symbol does not contain any of the major currencies END
      //--- 
       if( i_Digits == 1 || i_Digits == 3 || i_Digits == 5 ) _SPREAD *=0.1;
      }
//---- 
   return( _SPREAD );
  }
//+------------------------------------------------------------------+
//| Get_MARGINREQUIRED
//+------------------------------------------------------------------+
double Get_MARGINREQUIRED( string symbol, int retries=10 )
  {
   double d_MARGINREQUIRED;                      // free margin required to open 1 lot for buying
//----
   d_MARGINREQUIRED = MarketInfo( symbol, MODE_MARGINREQUIRED );
   d_MARGINREQUIRED = NormalizeDouble( d_MARGINREQUIRED, 2 );
   while( d_MARGINREQUIRED < NormalizeDouble( 0.0, 2 ) &&   // no free margin info available
          retries > 0 )                                     // not been all retries
      {
       Sleep( 500 );                                        // waiting half a second
       RefreshRates();
       d_MARGINREQUIRED = MarketInfo( symbol, MODE_MARGINREQUIRED );
       d_MARGINREQUIRED = NormalizeDouble( d_MARGINREQUIRED, 2 );
       retries--;                               // next retry
      }
  //---
   if( d_MARGINREQUIRED < 0 )                    // yet no free margin info available
      {
       if( !IsSymbolList( symbol, retries ) )  // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » free margin info for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   d_MARGINREQUIRED = NormalizeDouble( d_MARGINREQUIRED, 2 );
//---- 
   return( d_MARGINREQUIRED );
  }
//+------------------------------------------------------------------+
//| Get_MINLOT
//+------------------------------------------------------------------+
double Get_MINLOT( string symbol, int retries=10 )
  {
   double _MINLOT;                                 // minimum permitted amount of a lot
//----
   _MINLOT = MarketInfo( symbol, MODE_MINLOT );
   _MINLOT = NormalizeDouble( _MINLOT, 2 );
   while( _MINLOT <= NormalizeDouble( 0.0, 2 ) &&  // no minimum lot info available
          retries > 0 )                            // not been all retries
      {
       Sleep( 500 );                               // waiting half a second
       RefreshRates();
       _MINLOT = MarketInfo( symbol, MODE_MINLOT );
       _MINLOT = NormalizeDouble( _MINLOT, 2 );
       retries--;                                  // next retry
      }
  //---
   if( _MINLOT <= NormalizeDouble( 0.0, 2 ) )      // yet no minimum lot info available
      {
       if( !IsSymbolList( symbol, retries ) )     // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » minimum lot info for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   _MINLOT = NormalizeDouble( _MINLOT, 2 );
//---- 
   return( _MINLOT );
  }
//+------------------------------------------------------------------+
//| Get_MAXLOT
//+------------------------------------------------------------------+
double Get_MAXLOT( string symbol, int retries=10 )
  {
   double _MAXLOT;                                 // maximum permitted amount of a lot
//----
   _MAXLOT = MarketInfo( symbol, MODE_MAXLOT );
   _MAXLOT = NormalizeDouble( _MAXLOT, 2 );
   while( _MAXLOT <= NormalizeDouble( 0.0, 2 ) &&  // no maximum lot info available
          retries > 0 )                            // not been all retries
      {
       Sleep( 500 );                               // waiting half a second
       RefreshRates();
       _MAXLOT = MarketInfo( symbol, MODE_MAXLOT );
       _MAXLOT = NormalizeDouble( _MAXLOT, 2 );
       retries--;                                  // next retry
      }
  //---
   if( _MAXLOT <= NormalizeDouble( 0.0, 2 ) )      // yet no maximum lot info available
      {
       if( !IsSymbolList( symbol, retries ) )     // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » maximum lot info for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   _MAXLOT = NormalizeDouble( _MAXLOT, 2 );
//---- 
   return( _MAXLOT );
  }
//+------------------------------------------------------------------+
//| Get_LOTSTEP
//+------------------------------------------------------------------+
double Get_LOTSTEP( string symbol, int retries=10 )
  {
   double d_LOTSTEP;                                // step for changing lots
//----
   d_LOTSTEP = MarketInfo( symbol, MODE_LOTSTEP );
   d_LOTSTEP = NormalizeDouble( d_LOTSTEP, 2 );
   while( d_LOTSTEP <= NormalizeDouble( 0.0, 2 ) && // no step info available
          retries > 0 )                            // not been all retries
      {
       Sleep( 500 );                               // waiting half a second
       RefreshRates();
       d_LOTSTEP = MarketInfo( symbol, MODE_LOTSTEP );
       d_LOTSTEP = NormalizeDouble( d_LOTSTEP, 2 );
       retries--;                                  // next retry
      }
  //---
   if( d_LOTSTEP <= NormalizeDouble( 0.0, 2 ) )     // yet no step lot info available
      {
       if( !IsSymbolList( symbol, retries ) )     // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » step info for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   d_LOTSTEP = NormalizeDouble( d_LOTSTEP, 2 );
//---- 
   return( d_LOTSTEP );
  }
//+------------------------------------------------------------------+
//| Get_LOTSIZE
//+------------------------------------------------------------------+
double Get_LOTSIZE( string symbol, int retries=3 )
  {
   double d_LOTSIZE;                                // lot size in the base currency
//----
   d_LOTSIZE = MarketInfo( symbol, MODE_LOTSIZE );
   d_LOTSIZE = NormalizeDouble( d_LOTSIZE, 2 );
   while( d_LOTSIZE <= NormalizeDouble( 0.0, 2 ) && // no lot size info available
          retries > 0 )                            // not been all retries
      {
       Sleep( 500 );                               // waiting half a second
       RefreshRates();
       d_LOTSIZE = MarketInfo( symbol, MODE_LOTSIZE );
       d_LOTSIZE = NormalizeDouble( d_LOTSIZE, 2 );
       retries--;                                  // next retry
      }
  //---
   if( d_LOTSIZE <= NormalizeDouble( 0.0, 2 ) )     // yet no lot size info available
      {
       if( !IsSymbolList( symbol, retries ) )     // symbol is not available
	       return( -1.0 );
      //---
       Print( __FUNCTION__," » lot size info for ",symbol," is not available" );
	    return( -1.0 );
	   }
//---- 
   d_LOTSIZE = NormalizeDouble( d_LOTSIZE, 2 );
//---- 
   return( d_LOTSIZE );
  }
//+------------------------------------------------------------------+
//| TimeFrameToString
//+------------------------------------------------------------------+
string TimeFrameToString( int timeframe, int mode=MODE_SHORTHAND )
  {
   switch( timeframe )
      {
       case PERIOD_M1:  if( mode == 1 )   { return("M1");         break; }
                        else              { return("1 minute");   break; }
       case PERIOD_M5:  if( mode == 1 )   { return("M5");         break; }
                        else              { return("5 minutes");  break; }
       case PERIOD_M15: if( mode == 1 )   { return("M15");        break; }
                        else              { return("15 minutes"); break; }
       case PERIOD_M30: if( mode == 1 )   { return("M30");        break; }
                        else              { return("30 minutes"); break; }
       case PERIOD_H1:  if( mode == 1 )   { return("H1");         break; }
                        else              { return("1 hour");     break; }
       case PERIOD_H4:  if( mode == 1 )   { return("H4");         break; }
                        else              { return("4 hour");     break; }
       case PERIOD_D1:  if( mode == 1 )   { return("D1");         break; }
                        else              { return("Daily");      break; }
       case PERIOD_W1:  if( mode == 1 )   { return("W1");         break; }
                        else              { return("Weekly");     break; }
       case PERIOD_MN1: if( mode == 1 )   { return("MN1");        break; }
                        else              { return("Monthly");    break; }
       case 0:          if( mode == 1 )   { return("Current");    break; }
                        else              { return("Current TF"); break; }
       default: return( StringConcatenate( timeframe," timeframe is not available" ) );
      }
//----
   return("");
  }
//+------------------------------------------------------------------+
//| IsTradeContextFree
//+------------------------------------------------------------------+
bool IsTradeContextFree( int retries=10 )
  {
   while( !IsTradeAllowed() &&                  // trade is not allowed
          retries > 0 )                         // not been all retries
      {
      //--- verify if stopped
       if( IsStopped() )
          {
           Print( __FUNCTION__," » the program was commanded to stop its operation" );
           return( false );
          }
      //--- 
       RandomSleep( SLEEP_MEAN, SLEEP_MAX );
       retries--;                               // next retry
	   }
  //--- 
   if( !IsTradeAllowed() )                      // yet trade is not allowed
      {
       Print( __FUNCTION__," » trade context is busy at ",TimeToStr(TimeCurrent()) );
	    return( false );
	   }
//---- 
   return( true );
  }
//+------------------------------------------------------------------+
//| RandomSleep
//+------------------------------------------------------------------+
void RandomSleep( double seconds_mean, double seconds_max )
  {
   // double seconds_mean =1.0 - 4.0 ( recommended -> 2.0);	   // average sleeping interval (in seconds)
   // double seconds_max  =3.0 - 25.0 ( recommended -> 8.0);   // maximum sleeping interval (in seconds)
   double deciseconds;                                   // deciseconds (seconds expressed as tenths of seconds)
   int    maximum_deciseconds;
   double scaling_factor;
//----
	// if( IsTesting() ) return;
//----
	deciseconds =MathCeil( seconds_mean / 0.1 );
	deciseconds =NormalizeDouble( deciseconds, 1 );
	if( deciseconds <= NormalizeDouble( 0.0, 1 ) )
	   return;
//----
	maximum_deciseconds =(int)MathRound( seconds_max / 0.1 );
	scaling_factor      =1.0 - ( 1.0 / deciseconds );
  //---
   Sleep( 100 );                                         // 1 ds ( 0.1s )
  //---
	for( int i =0; i < maximum_deciseconds; i++ )
	   {
		 if( MathRand() > ( 32768.0 * scaling_factor ) ) break;
       Sleep( 100 );                                     // 1 ds ( 0.1s )
	   }
  }
//+------------------------------------------------------------------+
//| CheckVolume
//| Checks and corrects the value of the volume.
//| If mode_recalc is true, it returns the volume adjusted to the broker limitations and the account current
//| status or 0.0 if an error occurs (the volume can not be checked, the result is an incorrect volume).
//+------------------------------------------------------------------+
double CheckVolume( string symbol, double _lots, int type_operation=-1, bool mode_recalc=false )
  {
   int    i_lasterror;
   double _MINLOT;
   double _MAXLOT;
   double d_LOTSTEP;
   double _AccountFreeMarginCheck;
//---- get minimum lot
   _MINLOT =Get_MINLOT( symbol );
   if( _MINLOT < 0 )                                     // no minimum lot info available
	   return( 0.0 );
//---- get maximum lot
   _MAXLOT =Get_MAXLOT( symbol );
   if( _MAXLOT < 0 )                                     // no maximum lot info available
	   return( _MINLOT );
//---- get step
   d_LOTSTEP =Get_LOTSTEP( symbol );
   if( d_LOTSTEP < 0 )                                    // no step info available
	   return( _MINLOT );
//---- adjust lot size
   _lots =MathRound( _lots / d_LOTSTEP ) * d_LOTSTEP;
   _lots =NormalizeDouble( _lots, 2);
  //---
   if( _lots < _MINLOT )
      {
       _lots =_MINLOT;
       Print( __FUNCTION__," » position size was set to minimum ( ",DoubleToStr( _lots, 2 )," )" );
      }
  //--- 
   if( _lots > _MAXLOT )
      {
       _lots =_MAXLOT;
       Print( __FUNCTION__," » position size was set to maximum ( ",DoubleToStr( _lots, 2 )," )" );
      }
//----
   if( !mode_recalc )
      {
       _lots =NormalizeDouble( _lots, 2 );
       return( _lots );
      }
//---- verify free margin availability
   switch( type_operation )
      {
       case OP_BUY: case OP_BUYLIMIT: case OP_BUYSTOP:    type_operation =OP_BUY;  break;
       case OP_SELL: case OP_SELLLIMIT: case OP_SELLSTOP: type_operation =OP_SELL; break;
      }
  //---
   i_lasterror =0;
   _AccountFreeMarginCheck =AccountFreeMarginCheck( symbol, type_operation, _lots );
   _AccountFreeMarginCheck =NormalizeDouble( _AccountFreeMarginCheck, 2 );
   i_lasterror =GetLastError();
   while( _AccountFreeMarginCheck <= NormalizeDouble( 0.0, 2 ) || // error handling
          i_lasterror == 134 )
      {
      //--- exit WHILE if stopped
         if( IsStopped() )
            {
             Print( __FUNCTION__," » the program was commanded to stop its operation" );
             return( 0.0 );
            }
      //---
       if( _lots <= _MINLOT ) // lots are already in the minimum size
          {
           Print( __FUNCTION__," » free margin is insufficient for opening minimum lot size ( ",
                  DoubleToStr( _MINLOT, 2 )," )" );
           return( 0.0 );
          }
       
       if( _lots > _MINLOT )  // lots can be reduced further to the minimum size
          {
           Print( __FUNCTION__," » free margin is insufficient for opening ",
                  DoubleToStr( _lots, 2 )," lots" );
           _lots -=d_LOTSTEP;
           _lots =NormalizeDouble( _lots, 2 );
           Print( __FUNCTION__," » trying with smaller lot size ( ",DoubleToStr( _lots, 2 )," ) ..." );
          }
      //---
       i_lasterror =0;
       _AccountFreeMarginCheck =AccountFreeMarginCheck( symbol, type_operation, _lots );
       _AccountFreeMarginCheck =NormalizeDouble( _AccountFreeMarginCheck, 2 );
       i_lasterror =GetLastError();
      } // error handling END
//----
   _lots =NormalizeDouble( _lots, 2 );
   return( _lots );
  }
//+------------------------------------------------------------------+
//| Set_Slippage
//+------------------------------------------------------------------+
double Set_Slippage( string symbol, int i_Digits, int slippage_points )
  {
   if( !IsValidAsCurrency( symbol ) )  // symbol does not contain any of the major currencies
      {
       slippage_points *= ( ( i_Digits == 0 ) + 10 * ( i_Digits == 1 ) + 100 * ( i_Digits == 2 ) + 1000 * ( i_Digits == 3 ) + 10000 * ( i_Digits == 4 ) + 100000 * ( i_Digits == 5 ) + 1000000 * ( i_Digits == 6 ) );
       return( slippage_points );
      } // symbol does not contain any of the major currencies END
  //--- 
   if( i_Digits == 1 || i_Digits == 3 || i_Digits == 5 ) slippage_points *=10;
//---- 
   return( slippage_points );
  }
//+------------------------------------------------------------------+
//| CheckStopLossLevel
//+------------------------------------------------------------------+
double CheckStopLossLevel( string symbol, int _ordertype, double sl_level, int _digits, double punto, 
                           double minlevel )
  {
   double minimal_stoploss_level;
   double d_ASK;
   double d_BID;
//----
   sl_level =NormalizeDouble( sl_level, _digits );
   if( sl_level <= NormalizeDouble( 0.0, _digits ) )
      return( 0.0 );
//----
   switch( _ordertype )                                     // choosing operation type
      {
      //--- long positions 
       case OP_BUY: 
       
       /* 
         The use of 'MODE_STOPLEVEL' is not entirely clear 
         for TakeProfit & StopLoss levels of pending 
         positions so we are disabling pending orders in 
         this function preventively.  Check how this 
         issue is managed in 'CheckStopLossInPoints' and
         develop a strong solution.
       */
//       case OP_BUYLIMIT:
//       case OP_BUYSTOP: 

         //--- get bid price
          d_BID =Get_BID( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_BID < 0 )                                    // no bid price available
	           return( 0.0 );
         //---
          minimal_stoploss_level =d_BID - ( minlevel * punto );
          minimal_stoploss_level =NormalizeDouble( minimal_stoploss_level, _digits );
         //---
          if( sl_level > minimal_stoploss_level ) sl_level =minimal_stoploss_level;
         //---
          break;
      //--- short positions 
       case OP_SELL: 
       
       /* 
         The use of 'MODE_STOPLEVEL' is not entirely clear 
         for TakeProfit & StopLoss levels of pending 
         positions so we are disabling pending orders in 
         this function preventively.  Check how this 
         issue is managed in 'CheckStopLossInPoints' and
         develop a strong solution.
       */
//       case OP_SELLLIMIT: 
//       case OP_SELLSTOP: 

         //--- get ask price
          d_ASK =Get_ASK( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_ASK < 0 )                                    // no ask price available
	           return( 0.0 );
         //---
          minimal_stoploss_level =d_ASK + ( minlevel * punto );
          minimal_stoploss_level =NormalizeDouble( minimal_stoploss_level, _digits );
         //---
          if( sl_level < minimal_stoploss_level ) sl_level =minimal_stoploss_level;
         //---
          break;
      } // choosing operation type END
//----
   sl_level =NormalizeDouble( sl_level, _digits);
   return( sl_level );
  }
//+------------------------------------------------------------------+
//| CheckTakeProfitLevel
//+------------------------------------------------------------------+
double CheckTakeProfitLevel( string symbol, int _ordertype, double tp_level, int _digits, double punto, 
                             double minlevel )
  {
   double minimal_takeprofit_level;
   double d_ASK;
   double d_BID;
//----
   tp_level =NormalizeDouble( tp_level, _digits );
   if( tp_level <= NormalizeDouble( 0.0, _digits ) )
      return( 0.0 );
//----
   switch( _ordertype )                                     // choosing operation type
      {
      //--- long positions 
       case OP_BUY: 
       
       /* 
         The use of 'MODE_STOPLEVEL' is not entirely clear 
         for TakeProfit & StopLoss levels of pending 
         positions so we are disabling pending orders in 
         this function preventively.  Check how this 
         issue is managed in 'CheckTakeProfitInPoints' and
         develop a strong solution.
       */
//       case OP_BUYLIMIT:
//       case OP_BUYSTOP: 

         //--- get ask price
          d_ASK =Get_ASK( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_ASK < 0 )                                    // no ask price available
	           return( 0.0 );
         //---
          minimal_takeprofit_level =d_ASK + ( minlevel * punto );
          minimal_takeprofit_level =NormalizeDouble( minimal_takeprofit_level, _digits );
         //---
          if( tp_level < minimal_takeprofit_level ) tp_level =minimal_takeprofit_level;
         //---
          break;
      //--- short positions 
       case OP_SELL: 
       
       /* 
         The use of 'MODE_STOPLEVEL' is not entirely clear 
         for TakeProfit & StopLoss levels of pending 
         positions so we are disabling pending orders in 
         this function preventively.  Check how this 
         issue is managed in 'CheckTakeProfitInPoints' and
         develop a strong solution.
       */
//       case OP_SELLLIMIT: 
//       case OP_SELLSTOP: 

         //--- get bid price
          d_BID =Get_BID( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_BID < 0 )                                    // no bid price available
	           return( 0.0 );
         //---
          minimal_takeprofit_level =d_BID - ( minlevel * punto );
          minimal_takeprofit_level =NormalizeDouble( minimal_takeprofit_level, _digits );
         //---
          if( tp_level > minimal_takeprofit_level ) tp_level =minimal_takeprofit_level;
         //---
          break;
      } // choosing operation type END
//----
   tp_level =NormalizeDouble( tp_level, _digits);
   return( tp_level );
  }
//+------------------------------------------------------------------+
//| CheckStopLossInPoints
//+------------------------------------------------------------------+
double CheckStopLossInPoints( string symbol, int _ordertype, double _price, double sl_points, int _digits, 
                              double punto, double minlevel )
  {
   double stoploss_level=0;
   double minimal_stoploss_level;
   double d_ASK;
   double d_BID;
//----
   sl_points =NormalizeDouble( sl_points, 2 );
   if( sl_points <= NormalizeDouble( 0.0, 2 ) )
      return( 0.0 );
//----
   switch( _ordertype )                                     // choosing operation type
      {
      //--- long positions 
       case OP_BUY:
         //--- get bid price
          d_BID =Get_BID( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_BID < 0 )                                    // no bid price available
	           return( 0.0 );
         //---
          stoploss_level         =_price - ( sl_points * punto );
          stoploss_level         =NormalizeDouble( stoploss_level, _digits );
          minimal_stoploss_level =d_BID - ( minlevel * punto );
          minimal_stoploss_level =NormalizeDouble( minimal_stoploss_level, _digits );
         //---
          if( stoploss_level > minimal_stoploss_level ) stoploss_level =minimal_stoploss_level;
         //---
          break;
       case OP_BUYLIMIT:
       case OP_BUYSTOP: 
          if( minlevel > 0 &&
              sl_points < minlevel )
              sl_points = minlevel;
          stoploss_level =_price - ( sl_points * punto );
         //---
          break;
      //--- short positions 
       case OP_SELL:
         //--- get ask price
          d_ASK =Get_ASK( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_ASK < 0 )                                    // no ask price available
	           return( 0.0 );
         //---
          stoploss_level         =_price + ( sl_points * punto );
          stoploss_level         =NormalizeDouble( stoploss_level, _digits );
          minimal_stoploss_level =d_ASK + ( minlevel * punto );
          minimal_stoploss_level =NormalizeDouble( minimal_stoploss_level, _digits );
         //---
          if( stoploss_level < minimal_stoploss_level ) stoploss_level =minimal_stoploss_level;
         //---
          break;
       case OP_SELLLIMIT: 
       case OP_SELLSTOP: 
          if( minlevel > 0 &&
              sl_points < minlevel )
              sl_points = minlevel;
         //--- 
          stoploss_level =_price + ( sl_points * punto );
          break;
      }
//----
   stoploss_level =NormalizeDouble( stoploss_level, _digits );
   return( stoploss_level );
  }
//+------------------------------------------------------------------+
//| CheckTakeProfitInPoints
//+------------------------------------------------------------------+
double CheckTakeProfitInPoints( string symbol, int _ordertype, double _price, double tp_points, int _digits,
                                double punto, double minlevel )
  {
   double takeprofit_level=0;
   double minimal_takeprofit_level;
   double d_ASK;
   double d_BID;
//----
   tp_points =NormalizeDouble( tp_points, 2 );
   if( tp_points <= NormalizeDouble( 0.0, 2 ) )
      return( 0.0 );
//----
   switch( _ordertype )                                     // choosing operation type
      {
      //--- long positions 
       case OP_BUY: 
         //--- get ask price
          d_ASK =Get_ASK( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_ASK < 0 )                                    // no ask price available
	           return( 0.0 );
         //---
          takeprofit_level         =_price + ( tp_points * punto );
          takeprofit_level         =NormalizeDouble( takeprofit_level, _digits );
          minimal_takeprofit_level =d_ASK + ( minlevel * punto );
          minimal_takeprofit_level =NormalizeDouble( minimal_takeprofit_level, _digits );
         //---
          if( takeprofit_level < minimal_takeprofit_level ) takeprofit_level =minimal_takeprofit_level;
         //---
          break;
       case OP_BUYLIMIT:
       case OP_BUYSTOP: 
          if( minlevel > 0 &&
              tp_points < minlevel )
              tp_points = minlevel;
          takeprofit_level =_price + ( tp_points * punto );
          break;
      //--- short positions 
       case OP_SELL: 
         //--- get bid price
          d_BID =Get_BID( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
          if( d_BID < 0 )                                    // no bid price available
	           return( 0.0 );
         //---
          takeprofit_level         =_price - ( tp_points * punto );
          takeprofit_level         =NormalizeDouble( takeprofit_level, _digits );
          minimal_takeprofit_level =d_BID - ( minlevel * punto );
          minimal_takeprofit_level =NormalizeDouble( minimal_takeprofit_level, _digits );
         //---
          if( takeprofit_level > minimal_takeprofit_level ) takeprofit_level =minimal_takeprofit_level;
         //---
          break;
       case OP_SELLLIMIT: 
       case OP_SELLSTOP: 
          if( minlevel > 0 &&
              tp_points < minlevel )
              tp_points = minlevel;
          takeprofit_level =_price - ( tp_points * punto );
          break;
      }
//----
   takeprofit_level =NormalizeDouble( takeprofit_level, _digits );
   return( takeprofit_level );
  }
//+------------------------------------------------------------------+
//| CustomOrderModify
//| Modification of characteristics for the previously opened position
//| or pending orders. If the function succeeds, the returned value
//| will be true. If the function fails, the returned value will be
//| false.
//+------------------------------------------------------------------+
bool CustomOrderModify( int _Ticket, double _Price, double _StopLoss, double _TakeProfit, datetime _Expiration,
                        color _Arrow_Color=CLR_NONE, int _Retries=10 )
  {
   string   _OrderSymbol;
   bool     F_IsOrderModified =false;
   bool     F_modify_order    =false;
   int      i_lasterror;
   int      _DIGITS;                      // Count of digits after decimal point in the symbol prices
   int      i_OrderType;
   datetime _OrderExpiration;
   double   _OrderStopLoss;
   double   _OrderTakeProfit;
   double   _OrderOpenPrice;
   double   _POINT;
   double   SL_remainder, TP_remainder;
   double   SL_temp, TP_temp;
//----
   i_lasterror =0;
   if( OrderSelect( _Ticket, SELECT_BY_TICKET ) )  // properly selected order
      {
       if( OrderCloseTime() > 0 )
          {
//           Print( __FUNCTION__," » order #",_Ticket," could not be modified ( order was previously closed )" );
           return( false );
          }
       _OrderSymbol =OrderSymbol();
      //--- verify digits
       _DIGITS =Get_DIGITS( _OrderSymbol, bG_IsTesting, bG_DismissTestingMode );
       if( _DIGITS < 0 )                          // no digits available
	       return( false );
      //--- check trading context
       IsTradeContextFree();
      //--- normalize parameters
       _Price      =NormalizeDouble( _Price, _DIGITS );
       _StopLoss   =NormalizeDouble( _StopLoss, _DIGITS );
       _TakeProfit =NormalizeDouble( _TakeProfit, _DIGITS );
      //--- get order parameters
       i_OrderType       =OrderType();
       _OrderStopLoss   =OrderStopLoss();
       _OrderStopLoss   =NormalizeDouble( _OrderStopLoss, _DIGITS );
       _OrderTakeProfit =OrderTakeProfit();
       _OrderTakeProfit =NormalizeDouble( _OrderTakeProfit, _DIGITS );
       _OrderOpenPrice  =OrderOpenPrice();
       _OrderOpenPrice  =NormalizeDouble( _OrderOpenPrice, _DIGITS );
       _OrderExpiration =OrderExpiration();
      //--- compare parameters
       F_modify_order   =false;
//       if( _OrderStopLoss != _StopLoss )           F_modify_order =true; // v1.1 - disabled line
       
       
       // v1.1 - added segment
       if (_StopLoss > 0)
       {
          if (_OrderStopLoss == 0
             || (_OrderStopLoss > 0
                 && _OrderStopLoss != _StopLoss))
          {
             F_modify_order = true;
          }
       }
       
       
//       if( _OrderTakeProfit != _TakeProfit )       F_modify_order =true; // v1.1 - disabled line
       
       // v1.1 - added segment
       if (_TakeProfit > 0)
       {
          if (_OrderTakeProfit == 0
             || (_OrderTakeProfit > 0
                 && _OrderTakeProfit != _TakeProfit))
          {
             F_modify_order = true;
          }
       }
       
       
       if( i_OrderType > OP_SELL)                   // pending order
          {
           if( _OrderOpenPrice != _Price )         F_modify_order =true;
           if( _OrderExpiration != _Expiration )   F_modify_order =true;
          }
      //---
       if( !F_modify_order)
           return( false );
      } // properly selected order END
  //--- 
   else                                            // wrong selected order
      {
       i_lasterror =GetLastError();
       Print( __FUNCTION__," » order #",_Ticket," could not be selected for modifying ( ",
              ErrorDescription( i_lasterror )," )" );
       return( false );
      }
//---- modifying order
   if( F_modify_order )                            // modify order
      {
       SL_temp = _StopLoss;
       TP_temp = _TakeProfit;
       F_IsOrderModified =false;
       while( !F_IsOrderModified &&                // no valid modification
              _Retries > 0 )                       // not been all retries
          {
		     RefreshRates();
		     i_lasterror =0;
           F_IsOrderModified =OrderModify( _Ticket, _Price, SL_temp, TP_temp, _Expiration, _Arrow_Color );
           i_lasterror =GetLastError();
          //---
           if( !F_IsOrderModified )                // order has not been modified
              {
               if( i_lasterror == 1 )               // no error
                  {
                   return( false );
                  }
              } // market order has not been opened END
          //--- 
           if( i_lasterror == 130 )                 // invalid stops
              {
              //--- get point size
               _POINT = MarketInfo( _OrderSymbol, MODE_POINT );
              //---
               SL_temp = _StopLoss / _POINT;
               SL_remainder = MathMod( SL_temp, 5.0 );
               SL_temp -= SL_remainder;
               SL_temp *= _POINT;
               SL_temp =  NormalizeDouble( SL_temp, _DIGITS );
              //---
               TP_temp = _TakeProfit / _POINT;
               TP_remainder = MathMod( TP_temp, 5.0 );
               TP_temp -= TP_remainder;
               TP_temp *= _POINT;
               TP_temp =  NormalizeDouble( TP_temp, _DIGITS );
              //---
//               Print( __FUNCTION__," » order #",_Ticket,
//                       " SL_temp: ",DoubleToStr(SL_temp,_DIGITS),
//                       " || TP_temp: ",DoubleToStr(TP_temp,_DIGITS),
//                       " || SL_remainder: ",DoubleToStr(SL_remainder,_DIGITS),
//                       " || TP_remainder: ",DoubleToStr(TP_remainder,_DIGITS),
//                       " || _POINT: ",DoubleToStr(_POINT,_DIGITS) );
              //---
               _Retries--;
               continue;
              }
          //--- 
           if( i_lasterror == 147 )                 // expirations are denied by broker
              {
               _Expiration =0;
               _Retries--;
               continue;
              }
          //---
           _Retries--;
           RandomSleep( SLEEP_MEAN, SLEEP_MAX );
          } // no valid modification END
      //---
       if( !F_IsOrderModified )                    // order was not modified
          {
           Print( __FUNCTION__," » failed attempt to modify order #",_Ticket," ( ",
                  ErrorDescription( i_lasterror )," )" );
           return( false );
          }
      //---
       return( true );
      } // modify order END
//----
   return( false );
  }
//+------------------------------------------------------------------+
//| OrderSendModule
//+------------------------------------------------------------------+
int OrderSendModule( string symbol, int operation_type, double _volume, double _price, int _slippage,
                     double _stoploss, double _takeprofit, bool SL_LEVEL=true, bool TP_LEVEL=true, string _comment="",
                     int magic_number=-1, datetime _expiration=0, color _arrow_color=clrNONE, int retries=10,
                     bool b_hidden_sl=false, bool b_hidden_tp=false )
  {
   // string _comment ( only 31 characters )
   // bool SL_LEVEL =[ true ] - stoploss prices, [ false ] - stoploss points
   // bool TP_LEVEL =[ true ] - takeprofit prices, [ false ] - takeprofit points
   string   str_unused;
   bool     ModifyOrder;
   bool     _CustomOrderModify;
   int      _ticket=-1;
   int      i_lasterror=0;
   int      _retries;
   int      security_timer;
   int      _DIGITS;                                                // Digits after decimal point
   double   _STOPLEVEL;                                              // Stop level in points
   double   _POINT;                                                 // Point size in the quote currency
   double   d_ASK;                                                   // Last incoming ask price
   double   d_BID;                                                   // Last incoming bid price
   double   minimal_open_price=0;
//---- verify if stopped
   if( IsStopped() )
      {
       Print( __FUNCTION__," » the program was commanded to stop its operation" );
       return( INVALID_TICKET );
      }
//---- verify if disabled
   if( !IsExpertEnabled() )
      {
       Print( __FUNCTION__," » the program was disabled" );
       return( INVALID_TICKET );
      }
//---- verify trade context
   if( !IsTradeContextFree() )                                       // trade is not allowed
	    return( INVALID_TICKET );
//---- verify operation type
   if( operation_type < OP_BUY ||
       operation_type > OP_SELLSTOP )
      {
       Print( __FUNCTION__," » unknown type of operation (",operation_type,")" );
	    return( INVALID_TICKET );
      }
//---- verify digits
   _DIGITS =Get_DIGITS( symbol, bG_IsTesting, bG_DismissTestingMode );
   if( _DIGITS < 0 )                                                // no digits available
	    return( INVALID_TICKET );
//---- get stop level in points
   _STOPLEVEL =Get_STOPLEVEL( symbol, _DIGITS );
   if( _STOPLEVEL < 0 )                                              // no stop level available
	    return( INVALID_TICKET );
//---- get point size
   _POINT =Get_POINT( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
   if( _POINT < 0 )                                                 // no point size available
	    return( INVALID_TICKET );
//----
   ModifyOrder = false;
//---- set volume
   _volume =CheckVolume( symbol, _volume, operation_type );
   if( _volume <= NormalizeDouble( 0.0, 2 ) )
      return( INVALID_TICKET );
//---- set slippage
   _slippage = (int)Set_Slippage( symbol, _DIGITS, _slippage );
//---- normalize price
   _price =NormalizeDouble( _price, _DIGITS );
//---- handle PENDING orders
   if( operation_type > OP_SELL )                                    // pending position
      {
       _ticket  =INVALID_TICKET;
       _retries =retries;
       while( _ticket <= 0 &&                                        // no valid ticket
              _retries > 0 )                                         // not been all retries
          {
          //--- verify if stopped
           if( IsStopped() )
              {
               Print( __FUNCTION__," » the program was commanded to stop its operation" );
               return( INVALID_TICKET );
              }
          //--- verify if disabled
           if( !IsExpertEnabled() )
              {
               Print( __FUNCTION__," » the program was disabled" );
               return( INVALID_TICKET );
              }
          //--- get stop level in points
           _STOPLEVEL =Get_STOPLEVEL( symbol, _DIGITS );
           if( _STOPLEVEL < 0 )                                      // no stop level available
	            return( INVALID_TICKET );
          //--- look for the closest allowed price
           switch( operation_type )                                  // PENDING operation type switch #1
              {
               case OP_BUYLIMIT:                                     // placed below the market price
                 //--- get ask price
                  d_ASK =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_ASK < 0 )                                    // no ask price available
	                   return( INVALID_TICKET );
                 //--- ask price available
                  minimal_open_price =d_ASK - ( _STOPLEVEL * _POINT );
                  minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                 //---
                  if( _price <= NormalizeDouble( 0.0, _DIGITS ) ||  // no price
                      _price > minimal_open_price )                  // wrong price
                      _price =minimal_open_price;
                 //--- 
                  break;
              //--- 
               case OP_BUYSTOP:                                      // placed above the market price
                 //--- get ask price
                  d_ASK =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_ASK < 0 )                                    // no ask price available
	                   return( INVALID_TICKET );
                 //--- ask price available
                  minimal_open_price =d_ASK + ( _STOPLEVEL * _POINT );
                  minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                 //---
                  if( _price <= NormalizeDouble( 0.0, _DIGITS ) ||  // no price
                      _price < minimal_open_price )                  // wrong price
                      _price =minimal_open_price;
                 //--- 
                  break;
              //--- 
               case OP_SELLLIMIT:                                    // placed above the market price
                 //--- get bid price
                  d_BID =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_BID < 0 )                                    // no bid price available
	                   return( INVALID_TICKET );
                 //--- bid price available
                  minimal_open_price =d_BID + ( _STOPLEVEL * _POINT );
                  minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                 //---
                  if( _price <= NormalizeDouble( 0.0, _DIGITS ) ||  // no price
                      _price < minimal_open_price )                  // wrong price
                      _price =minimal_open_price;
                 //--- 
                  break;
              //--- 
               case OP_SELLSTOP:                                     // placed below the market price
                 //--- get bid price
                  d_BID =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_BID < 0 )                                    // no bid price available
	                   return( INVALID_TICKET );
                 //--- bid price available
                  minimal_open_price =d_BID - ( _STOPLEVEL * _POINT );
                  minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                 //---
                  if( _price <= NormalizeDouble( 0.0, _DIGITS ) ||  // no price
                      _price > minimal_open_price )                  // wrong price
                      _price =minimal_open_price;
                 //--- 
                  break;
              } // PENDING operation type switch #1 END
          //--- price previously set
		     i_lasterror =0;
		     _ticket =OrderSend( symbol, operation_type, _volume, _price, _slippage, 0.0, 0.0,
		                         _comment, magic_number, _expiration, _arrow_color );
           i_lasterror =GetLastError();
          //---
           if( _ticket <= 0 )                                        // pending order has not been opened
              {
               if( i_lasterror == 130 )                              // false open price of a pending order
                  {
                  //--- convert pending order to market order
                   switch( operation_type )
                      {
                       case OP_BUY: case OP_BUYLIMIT: case OP_BUYSTOP:    operation_type =OP_BUY;  break;
                       case OP_SELL: case OP_SELLLIMIT: case OP_SELLSTOP: operation_type =OP_SELL; break;
                      }
                  //---
                   Print( __FUNCTION__," » failed attempt to place a pending position ",
                          "( open price is too close to the market )" );
                   break;                                            // no valid ticket EXIT WHILE
                  } // false open price of a pending order END
              //--- 
               if( i_lasterror == 129 )                              // invalid price
                  {
                  //--- look for the next closest allowed price
                   switch( operation_type )                          // PENDING operation type switch #2
                      {
                       case OP_BUYLIMIT:                             // placed below the market price
                         //--- get bid price
                          d_BID =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                          if( d_BID < 0 )                            // no bid price available
	                           return( INVALID_TICKET );
                         //--- bid price available
                          minimal_open_price =d_BID - ( _STOPLEVEL * _POINT );
                          minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                         //---
                          if( _price > minimal_open_price )          // wrong price
                              _price =minimal_open_price;
                         //--- 
                          break;
                      //--- 
                       case OP_SELLLIMIT:                            // placed above the market price
                         //--- get ask price
                          d_ASK =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                          if( d_ASK < 0 )                            // no ask price available
	                           return( INVALID_TICKET );
                         //--- bid price available
                          minimal_open_price =d_ASK + ( _STOPLEVEL * _POINT );
                          minimal_open_price =NormalizeDouble( minimal_open_price, _DIGITS );
                         //---
                          if( _price < minimal_open_price )          // wrong price
                              _price =minimal_open_price;
                         //--- 
                          break;
                      } // PENDING operation type switch #2 END
                  //---
                   _retries--;
                   if( retries - _retries < 3 ) continue;
                   break;
                  }
              //--- 
               if( i_lasterror == 147 )                              // expirations are denied by broker
                  {
                   _expiration =0;
                  //---
                   _retries--;
                   if( retries - _retries < 3 ) continue;
                   break;
                  }
              //---
               if( i_lasterror == 148 )                              // amount of total orders has reached the limit
                  {
                   Print( __FUNCTION__," » failed attempt to place a pending position ( ",
                          ErrorDescription( 148 )," )" );
                   return( INVALID_TICKET );
                  }
              //---
               if(!bG_IsTesting)
                  RandomSleep( SLEEP_MEAN, SLEEP_MAX );
              } // pending order has not been opened END
          //---
           _retries--;
          } // no valid ticket END
      //---
       if( _ticket <= 0 &&                                           // pending order has not been opened
           i_lasterror == 129 )                                      // invalid price
          {
          //--- convert pending order to market order
           switch( operation_type )
              {
               case OP_BUY: case OP_BUYLIMIT: case OP_BUYSTOP:    operation_type =OP_BUY;  break;
               case OP_SELL: case OP_SELLLIMIT: case OP_SELLSTOP: operation_type =OP_SELL; break;
              }
          //---
           Print( __FUNCTION__," » failed attempt to place a pending position ",
                  "( open price is not accepted by the broker )" );
          }
      //---
       if( _ticket <= 0 &&                                           // pending order was not placed
           operation_type > OP_SELL )                                // pending order
          {
           Print( __FUNCTION__," » failed attempt to place a pending position ( ",
                  ErrorDescription( i_lasterror )," )" );
           return( INVALID_TICKET );
          }
      //---
       if( _ticket <= 0 &&                                           // pending order was not placed
           operation_type < OP_BUYLIMIT )                            // market order
          {
           Print( __FUNCTION__," » trying to open a market order ... " );
          }
      } // pending position END
//---- handle MARKET orders
   if( operation_type < OP_BUYLIMIT )                                // market position
      {
       _ticket  =INVALID_TICKET;
       _retries =retries;
       while( _ticket <= 0 &&                                        // no valid ticket #2
              _retries > 0 )                                         // not been all retries
          {
          //--- verify if stopped
           if( IsStopped() )
              {
               Print( __FUNCTION__," » the program was commanded to stop its operation" );
               return( INVALID_TICKET );
              }
          //--- verify if disabled
           if( !IsExpertEnabled() )
              {
               Print( __FUNCTION__," » the program was disabled" );
               return( INVALID_TICKET );
              }
          //--- look for the latest price
           switch( operation_type )                                  // MARKET operation type switch
              {
               case OP_BUY:                                          // placed at market price
                 //--- get ask price
                  d_ASK =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_ASK < 0 )                                    // no ask price available
                    return( INVALID_TICKET );
                 //--- ask price available
                  minimal_open_price =d_ASK;
                 //--- 
                  break;
              //--- 
               case OP_SELL:                                         // placed at market price
                 //--- get bid price
                  d_BID =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_BID < 0 )                                    // no bid price available
                    return( INVALID_TICKET );
                 //--- bid price available
                  minimal_open_price =d_BID;
                 //--- 
                  break;
              } // MARKET operation type switch END
          //---
           _price =NormalizeDouble( minimal_open_price, _DIGITS );
          //---
		     i_lasterror =0;
		     _ticket =OrderSend( symbol, operation_type, _volume, _price, _slippage, 0.0, 0.0,
		                         _comment, magic_number, 0, _arrow_color );
           i_lasterror =GetLastError();
          //---
           if( _ticket <= 0 )                                        // market order has not been opened
              {
               if( i_lasterror == 148 )                              // amount of total orders has reached the limit
                  {
                   Print( __FUNCTION__," » failed attempt to open a market position ( ",
                          ErrorDescription( 148 )," )" );
                   return( INVALID_TICKET );
                  }
              //---
               if(!bG_IsTesting)
                  RandomSleep( SLEEP_MEAN, SLEEP_MAX );
              } // market order has not been opened END
          //---
           _retries--;
          } // no valid ticket #2 END
      //---
       if( _ticket <= 0 )                                            // market order was not opened
          {
           Print( __FUNCTION__," » failed attempt to open a market position ( ",
                  ErrorDescription( i_lasterror )," )" );
           return( INVALID_TICKET );
          }
      } // market position END
//---- modify order
   i_lasterror =0;
   if( OrderSelect( _ticket, SELECT_BY_TICKET ) )                    // properly selected order
      {
       _price =OrderOpenPrice();
       _price =NormalizeDouble( _price, _DIGITS );
      //---
       _retries =retries;
       _CustomOrderModify = false;
       while( !_CustomOrderModify &&                                 // no valid modification
              _retries > 0 )                                         // not been all retries
          {
          //--- verify if stopped
           if( IsStopped() )
              {
               Print( __FUNCTION__," » the program was commanded to stop its operation" );
               return( INVALID_TICKET );
              }
          //--- verify if disabled
           if( !IsExpertEnabled() )
              {
               Print( __FUNCTION__," » the program was disabled" );
               return( INVALID_TICKET );
              }
          //--- get stop level in points
           _STOPLEVEL =Get_STOPLEVEL( symbol, _DIGITS );
           if( _STOPLEVEL < 0 )                                      // no stop level available
	            return( INVALID_TICKET );
          //--- set stoploss and takeprofit
           if( SL_LEVEL ) // levels ( absolute price )
              {
               if( _stoploss > NormalizeDouble( 0.0, _DIGITS ) )
                  {
                   _stoploss   =CheckStopLossLevel( symbol, operation_type, _stoploss, 
                                                    _DIGITS, _POINT, _STOPLEVEL );
                   ModifyOrder = true;
                  }
              }
           if( TP_LEVEL ) // levels ( absolute price )
              {
               if( _takeprofit > NormalizeDouble( 0.0, _DIGITS ) )
                  {
                   _takeprofit =CheckTakeProfitLevel( symbol, operation_type, _takeprofit, 
                                                      _DIGITS, _POINT, _STOPLEVEL );
                   ModifyOrder = true;
                  }
              }
           if( !SL_LEVEL ) // points
              {
               if( _stoploss > 0 )
                  {
                   _stoploss   =CheckStopLossInPoints( symbol, operation_type, _price, _stoploss, 
                                                       _DIGITS, _POINT, _STOPLEVEL );
                   ModifyOrder = true;
                  }
              }
           if( !TP_LEVEL ) // points
              {
               if( _takeprofit > 0 )
                  {
                   _takeprofit =CheckTakeProfitInPoints( symbol, operation_type, _price, _takeprofit, 
                                                         _DIGITS, _POINT, _STOPLEVEL );
                   ModifyOrder = true;
                  }
              }
          //--- 
           security_timer =0;
           if( !ModifyOrder ) break;
           if( ModifyOrder )                                       // ModifyOrder enabled
              {
               if( b_hidden_sl && // hidden sl enabled
                   NormalizeDouble( _stoploss, _DIGITS ) > NormalizeDouble( 0.0, _DIGITS ) )
                  {
                   _stoploss = NormalizeDouble( _stoploss, _DIGITS );
                   CreateLine( StringConcatenate( "SL",_ticket ), OBJ_HLINE, TimeCurrent(), _stoploss, 0, 0.0, Red, STYLE_DASHDOT, 1 );
                   _stoploss = 0;
                  } // hidden sl enabled END
              //---
               if( b_hidden_tp && // hidden tp enabled
                   NormalizeDouble( _takeprofit, _DIGITS ) > NormalizeDouble( 0.0, _DIGITS ) )
                  {
                   _takeprofit = NormalizeDouble( _takeprofit, _DIGITS );
                   CreateLine( StringConcatenate( "TP",_ticket ), OBJ_HLINE, TimeCurrent(), _takeprofit, 0, 0.0, Red, STYLE_DASHDOT, 1 );
                   _takeprofit = 0;
                  } // hidden tp enabled END
              //---
               if( b_hidden_sl &&
                   b_hidden_tp )
                  {
                   _CustomOrderModify = true;
                  }
               else 
                   _CustomOrderModify = CustomOrderModify( _ticket, _price, _stoploss, _takeprofit, 
                                                           _expiration, _arrow_color, retries );
              } // ModifyOrder enabled END
          //--- 
           _retries--;
          } // no valid modification END
      } // properly selected order END
  //--- 
   else
      {
       i_lasterror =GetLastError();
       Print( __FUNCTION__," » order #",_ticket," could not be selected for modifying ( ",
              ErrorDescription( i_lasterror )," )" );
       return( INVALID_TICKET );
      }
//----
   return( _ticket );
  }
//+------------------------------------------------------------------+
//| TrackingOrdersTotal
//+------------------------------------------------------------------+
int TrackingOrdersTotal( string& _globaltext, string symbol="", int _magic_number=-1,
                         string custom_comment="" )
  {
   string   str_type;
   int      i_OrderType;
   int      i_OrdersTotal;
   int      counter;
//----
   counter = 0;
   i_OrdersTotal = GetOrdersTotal();
   for( int i =0; i < OrdersTotal(); i++ )
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment ) ) continue;
     //---
      counter++;
      i_OrderType = OrderType();
      if( i_OrderType == OP_BUY ) str_type = "buy";
      if( i_OrderType == OP_BUYLIMIT ) str_type = "buy limit";
      if( i_OrderType == OP_BUYSTOP ) str_type = "buy stop";
      if( i_OrderType == OP_SELL ) str_type = "sell";
      if( i_OrderType == OP_SELLLIMIT ) str_type = "sell limit";
      if( i_OrderType == OP_SELLSTOP ) str_type = "sell stop";
      _globaltext = _globaltext + StringConcatenate(
                                       "#",OrderTicket()," ",str_type,
                                       " ",DoubleToStr( OrderLots(), 2 )," ",OrderSymbol(),
                                       " at ",DoubleToStr( OrderOpenPrice(), Digits ),
                                       " sl: ",DoubleToStr( OrderStopLoss(), Digits ),
                                       " tp: ",DoubleToStr( OrderTakeProfit(), Digits ),
                                       " c: ",OrderComment(),"\n"
                                  );
     }
//----
   return( counter );
  }
//+--------------------------------------------------------------------------------------------------+
//| CreateLine
//+--------------------------------------------------------------------------------------------------+
bool CreateLine( string name, int obj_type, datetime time1, double price1, datetime time2, double price2,
                 color colour=Red, int style=STYLE_SOLID, int width=1, int window=0, bool back=false,
                 bool ray=false, int retries=3 )
  {
   bool   line_created;
   int    i_lasterror;
//----
   if( ObjectFind( name ) >= 0 ) return( false );
  //--- 
   i_lasterror   =GetLastError();
   i_lasterror   =0;
  //---
   line_created =false;
   while( !line_created &&                      // error creating object
          retries > 0 )                         // not been all retries
      {
       line_created =ObjectCreate( name, obj_type, window, 0, 0 );
       i_lasterror  =GetLastError();
       retries--;                               // next retry
      }
  //--- 
   if( !line_created )                          // still error creating object
      {
       Print( __FUNCTION__," » error creating line ( ",ErrorDescription( i_lasterror )," )" );
       return( false );
      }
//----
   bool   error   =false;
   string prop[9] ={ "colour", "style", "width", "back", "time1", "price1", "time2", "price2", "ray" };
   double i_last_error[9];
  //---
   ArrayInitialize( i_last_error, 0.0 );
  //---
   if( !ObjectSet( name, OBJPROP_COLOR, colour ) )    { i_last_error[0] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_STYLE, style ) )     { i_last_error[1] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_WIDTH, width ) )     { i_last_error[2] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_BACK, back ) )       { i_last_error[3] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_TIME1, time1 ) )     { i_last_error[4] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_PRICE1, price1 ) )   { i_last_error[5] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_TIME2, time2 ) )     { i_last_error[6] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_PRICE2, price2 ) )   { i_last_error[7] =GetLastError(); error=true; }
   if( !ObjectSet( name, OBJPROP_RAY, ray ) )         { i_last_error[8] =GetLastError(); error=true; }
  //---
   if( error )                                  // error occurred
      {
       for( int i =0; i <= 8; i++ )
          {
           if( i_last_error[i] == 0.0 ) continue;
           Print( __FUNCTION__," » error setting ",prop[i]," ( ",ErrorDescription( (int)i_last_error[i] )," )" );
          }
      } // error occurred END
//----
   WindowRedraw();
   return( true );
  }
//+------------------------------------------------------------------+
//| TrackingStealthLevels function
//+------------------------------------------------------------------+
void TrackingStealthLevels( int _digits, int _slippage,
                            string symbol="", int _magic_number=-1, string custom_comment="",
                            int order_type=ALL_ORDERS, int _retries=10 )
  {
   bool   Close_Order;
   int    _OrderTicket;
   int    i_OrderType;
   int    i_OrdersTotal;
   int    security_timer;
   double _OrderOpenPrice;
   double _SL_stealth=0;
   double _TP_stealth=0;
   double _Bid;
   double _Ask;
//----
   i_OrdersTotal = GetOrdersTotal();
   for( int i =0; i < i_OrdersTotal; i++ )                                 // loop for each open order
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment ) ) continue;
     //---
      i_OrderType =OrderType();


      if (order_type != ALL_ORDERS) //not ALL order
      {
         
         if (order_type == ONLY_MARKET //only 'market' allowed..
             && i_OrderType > OP_SELL) //..but it's not 'market'
         {
            continue;
         }
         
         if (order_type == ONLY_PENDING //only 'pending' allowed..
             && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
         {
            continue;
         }
         
         if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
             && (i_OrderType == OP_SELL //..but it's not a BUY
                 || i_OrderType == OP_SELLLIMIT
                 || i_OrderType == OP_SELLSTOP)
             )
         {
            continue;
         }
         
         if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
             && (i_OrderType == OP_BUY //..but it's not a SELL
                 || i_OrderType == OP_BUYLIMIT
                 || i_OrderType == OP_BUYSTOP)
             )
         {
            continue;
         }
         
         if (order_type == OP_BUY //only buy 'market' allowed..
             && i_OrderType != OP_BUY) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELL //only sell 'market' allowed..
             && i_OrderType != OP_SELL) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
             && i_OrderType != OP_BUYLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
             && i_OrderType != OP_BUYSTOP) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
             && i_OrderType != OP_SELLLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
             && i_OrderType != OP_SELLSTOP) //..but it's not
         {
            continue;
         }
      }
     
     //---
      Close_Order =false;
      _OrderTicket    =OrderTicket();
      _OrderOpenPrice =OrderOpenPrice();
      _OrderOpenPrice =NormalizeDouble( _OrderOpenPrice, _digits );
     //---
      if( HiddenStopLoss &&
          ObjectFind( StringConcatenate( "SL",_OrderTicket ) ) >= 0 )
         {
          _SL_stealth = ObjectGet( StringConcatenate( "SL",_OrderTicket ), OBJPROP_PRICE1 );
          _SL_stealth = NormalizeDouble( _SL_stealth, _digits );
         }
      if( HiddenTakeProfit &&
          ObjectFind( StringConcatenate( "TP",_OrderTicket ) ) >= 0 )
         {
          _TP_stealth = ObjectGet( StringConcatenate( "TP",_OrderTicket ), OBJPROP_PRICE1 );
          _TP_stealth = NormalizeDouble( _TP_stealth, _digits );
         }
     //---
      i_OrderType =OrderType();
      switch( i_OrderType )                            // type order switch
         {
          case OP_BUY:
             _Bid =Get_BID( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
             if( _Bid < 0 )                           // no bid price available
                 return;
             _Bid = NormalizeDouble( _Bid, _digits );
            //---
             if( _SL_stealth > NormalizeDouble( 0.0, _digits ) &&
                 _Bid <= _SL_stealth )
                {
                 Print( __FUNCTION__," » buy order #",_OrderTicket," stealth sl: ",DoubleToStr( _SL_stealth, _digits ),
                        " was hit" );
                 Close_Order = true;
                 break;
                }
            //---
             if( _TP_stealth > NormalizeDouble( 0.0, _digits ) &&
                 _Bid >= _TP_stealth )
                {
                 Print( __FUNCTION__," » buy order #",_OrderTicket," stealth tp: ",DoubleToStr( _TP_stealth, _digits ),
                        " was hit" );
                 Close_Order = true;
                 break;
                }
            //---
             break;
         //--- 
          case OP_SELL:
             _Ask =Get_ASK( symbol, _digits, bG_IsTesting, bG_DismissTestingMode );
             if( _Ask < 0 )                           // no ask price available
                 return;
             _Ask = NormalizeDouble( _Ask, _digits );
            //---
             if( _SL_stealth > NormalizeDouble( 0.0, _digits ) &&
                 _Ask >= _SL_stealth )
                {
                 Print( __FUNCTION__," » sell order #",_OrderTicket," stealth sl: ",DoubleToStr( _SL_stealth, _digits ),
                        " was hit" );
                 Close_Order = true;
                 break;
                }
            //---
             if( _TP_stealth > NormalizeDouble( 0.0, _digits ) &&
                 _Ask <= _TP_stealth )
                {
                 Print( __FUNCTION__," » sell order #",_OrderTicket," stealth tp: ",DoubleToStr( _TP_stealth, _digits ),
                        " was hit" );
                 Close_Order = true;
                 break;
                }
            //---
             break;
         } // type order switch END
     //---
      if( Close_Order )
         {
         //--- closing order
          security_timer = 0;
          while( ClosePosition( _OrderTicket, symbol, _slippage, _retries, Goldenrod ) == 0 )
             {
              security_timer++;
              if( security_timer > 10 ) { Print( __FUNCTION__," » security timer has been activated" ); break; }
              RandomSleep( SLEEP_MEAN, SLEEP_MAX );
              RefreshRates();
             }
         }
     } // loop for each open order END
  }
//+------------------------------------------------------------------+
//| CustomOrdersTotal()
//+------------------------------------------------------------------+
int CustomOrdersTotal( string symbol="", int _magic_number=-1, string custom_comment="",
                       int order_type=ALL_ORDERS, int pool_mode=MODE_TRADES )
  {
   int      i_counter;
   int      i_OrderType;
   int      i_OrdersTotal;
//----
   i_OrdersTotal = GetOrdersTotal( pool_mode );
//----
   i_counter     =0;
   for( int i =0; i < i_OrdersTotal; i++ )
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment, pool_mode ) ) continue;
     //---
      i_OrderType =OrderType();


      if (order_type != ALL_ORDERS) //not ALL order
      {
         
         if (order_type == ONLY_MARKET //only 'market' allowed..
             && i_OrderType > OP_SELL) //..but it's not 'market'
         {
            continue;
         }
         
         if (order_type == ONLY_PENDING //only 'pending' allowed..
             && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
         {
            continue;
         }
         
         if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
             && (i_OrderType == OP_SELL //..but it's not a BUY
                 || i_OrderType == OP_SELLLIMIT
                 || i_OrderType == OP_SELLSTOP)
             )
         {
            continue;
         }
         
         if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
             && (i_OrderType == OP_BUY //..but it's not a SELL
                 || i_OrderType == OP_BUYLIMIT
                 || i_OrderType == OP_BUYSTOP)
             )
         {
            continue;
         }
         
         if (order_type == OP_BUY //only buy 'market' allowed..
             && i_OrderType != OP_BUY) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELL //only sell 'market' allowed..
             && i_OrderType != OP_SELL) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
             && i_OrderType != OP_BUYLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
             && i_OrderType != OP_BUYSTOP) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
             && i_OrderType != OP_SELLLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
             && i_OrderType != OP_SELLSTOP) //..but it's not
         {
            continue;
         }
      }
     //---
      i_counter++;                                                          // order is counted
     }
//----
   return( i_counter );
  }
//+------------------------------------------------------------------+
//| ▼ CustomOrdersTotalDetailed function  (Last update: 2016.04.23)
//+------------------------------------------------------------------+
/*
  Core function mainly intended to count orders according to certain 
  criterias.
*/
int CustomOrdersTotalDetailed (
      int& i_buy_total, //[i/o] market buy orders
      int& i_sell_total, //[i/o] market sell orders
      int& i_buylimit_total, //[i/o] pending limit buy positions
      int& i_selllimit_total, //[i/o] pending limit sell positions
      int& i_buystop_total, //[i/o] pending stop buy positions
      int& i_sellstop_total, //[i/o] pending stop sell positions
      string symbol="", 
      int magic_number=-1, 
      string custom_comment="",
      int order_type=ALL_ORDERS, 
      int pool_mode=MODE_TRADES
   )
{
   int i_counter = 0,
       i_OrderType = 0,
       i_OrdersTotal = 0;


   i_buy_total = 0;
   i_sell_total = 0;
   i_buylimit_total = 0;
   i_selllimit_total = 0;
   i_buystop_total = 0;
   i_sellstop_total = 0;


   i_OrdersTotal = GetOrdersTotal (pool_mode);
   
   
   for (int i=0; i<i_OrdersTotal; i++)
   {
      
      if (!IsValidOrder (
            i, 
            symbol, 
            magic_number, 
            custom_comment, 
            pool_mode)
         )
      {
         continue;
      }

      
      i_OrderType = OrderType ();
      switch (i_OrderType)
      {
         case OP_BUY: i_buy_total++; break;
         case OP_SELL: i_sell_total++; break;
         case OP_BUYLIMIT: i_buylimit_total++; break;
         case OP_SELLLIMIT: i_selllimit_total++; break;
         case OP_BUYSTOP: i_buystop_total++; break;
         case OP_SELLSTOP: i_sellstop_total++; break;
         default: 
            Print( __FUNCTION__," » unknown order type" ); break;
      }


      if (order_type != ALL_ORDERS) //not ALL order
      {
         
         if (order_type == ONLY_MARKET //only 'market' allowed..
             && i_OrderType > OP_SELL) //..but it's not 'market'
         {
            continue;
         }
         
         if (order_type == ONLY_PENDING //only 'pending' allowed..
             && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
         {
            continue;
         }
         
         if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
             && (i_OrderType == OP_SELL //..but it's not a BUY
                 || i_OrderType == OP_SELLLIMIT
                 || i_OrderType == OP_SELLSTOP)
             )
         {
            continue;
         }
         
         if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
             && (i_OrderType == OP_BUY //..but it's not a SELL
                 || i_OrderType == OP_BUYLIMIT
                 || i_OrderType == OP_BUYSTOP)
             )
         {
            continue;
         }
         
         if (order_type == OP_BUY //only buy 'market' allowed..
             && i_OrderType != OP_BUY) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELL //only sell 'market' allowed..
             && i_OrderType != OP_SELL) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
             && i_OrderType != OP_BUYLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
             && i_OrderType != OP_BUYSTOP) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
             && i_OrderType != OP_SELLLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
             && i_OrderType != OP_SELLSTOP) //..but it's not
         {
            continue;
         }
      }
     

      i_counter++; // order counted
   }


   return (i_counter);
}
// ▲ [End] CustomOrdersTotalDetailed function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| GetProfitLevel()
//+------------------------------------------------------------------+
double GetProfitLevel( string symbol="", int _magic_number=EMPTY_VALUE, string custom_comment="",
                       int mode=ALL_ORDERS, int _mode=MODE_TRADES )
  {
   int      _counter;
   int      _OrderType;
   int      _OrdersTotal;
   double d_WeightedPricesSum, d_WeightsSum, d_ProfitLevel;
//----
   _OrdersTotal = GetOrdersTotal( _mode );
//----
   _counter     =0;
   d_WeightedPricesSum = 0;
   d_WeightsSum = 0;
   d_ProfitLevel = 0;
   for( int i =0; i < _OrdersTotal; i++ )
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment, _mode ) ) continue;
     //---
      _OrderType =OrderType();
      if( mode != ALL_ORDERS )                                             // all orders are not be considered
         {
          if( mode == ONLY_MARKET &&                                       // only market orders to be considered
              _OrderType > OP_SELL )                           continue;   // order is not market
         //--- 
          if( mode == ONLY_PENDING &&                                      // only pending orders to be considered
              _OrderType < OP_BUYLIMIT )                       continue;   // order is not pending
         //--- 
          if( mode == ONLY_BUY_ANY &&                                      // only buy (market and pending) orders..
              ( _OrderType == OP_SELL ||                                   // ..to be considered
                _OrderType == OP_SELLLIMIT ||
                _OrderType == OP_SELLSTOP ) )                  continue;   // order is not buy
         //--- 
          if( mode == ONLY_SELL_ANY &&                                     // only sell (market and pending) orders..
              ( _OrderType == OP_BUY ||                                    // ..to be considered
                _OrderType == OP_BUYLIMIT ||
                _OrderType == OP_BUYSTOP ) )                   continue;   // order is not sell
         //--- 
          if( mode == OP_BUY &&                                            // only buy market orders to be considered
              _OrderType != OP_BUY )                           continue;   // order is not buy
         //--- 
          if( mode == OP_SELL &&                                           // only sell market orders to be considered
              _OrderType != OP_SELL )                          continue;   // order is not sell
         //--- 
          if( mode == OP_BUYLIMIT &&                                       // only buy limit orders to be considered
              _OrderType != OP_BUYLIMIT )                      continue;   // order is not buy limit
         //--- 
          if( mode == OP_BUYSTOP &&                                        // only buy stop orders to be considered
              _OrderType != OP_BUYSTOP )                       continue;   // order is not buy stop
         //--- 
          if( mode == OP_SELLLIMIT &&                                      // only sell limit orders to be considered
              _OrderType != OP_SELLLIMIT )                     continue;   // order is not sell limit
         //--- 
          if( mode == OP_SELLSTOP &&                                       // only sell stop orders to be considered
              _OrderType != OP_SELLSTOP )                      continue;   // order is not sell stop
         } // all orders are not be considered END
     //---
      d_WeightedPricesSum += (OrderOpenPrice()*OrderLots());
      d_WeightsSum += OrderLots();
     }

   if(d_WeightsSum > 0)
     {
      d_ProfitLevel = d_WeightedPricesSum / d_WeightsSum;
     }
//----
   return( d_ProfitLevel );
  }
//+------------------------------------------------------------------+
//| GetLastOrder
//+------------------------------------------------------------------+
int GetLastOrder( string symbol="", int _magic_number=-1, string custom_comment="",
                  int order_type=ALL_ORDERS, int _pool=MODE_TRADES, int select_by=LAST_ORDER_BY_TICKET )
  {
   int      _ticket;
   int      _OrderTicket;
   int      i_OrdersTotal;
   int      i_OrderType;
   datetime last_time;
   datetime _OrderTime;
//----
   i_OrdersTotal = GetOrdersTotal( _pool );
   last_time =0;
   _ticket   =INVALID_TICKET;
   _OrderTicket = INVALID_TICKET;
   for( int i =i_OrdersTotal; i >= 0; i-- )
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment, _pool ) ) continue;
     //---
      i_OrderType =OrderType();


      if (order_type != ALL_ORDERS) //not ALL order
      {
         
         if (order_type == ONLY_MARKET //only 'market' allowed..
             && i_OrderType > OP_SELL) //..but it's not 'market'
         {
            continue;
         }
         
         if (order_type == ONLY_PENDING //only 'pending' allowed..
             && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
         {
            continue;
         }
         
         if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
             && (i_OrderType == OP_SELL //..but it's not a BUY
                 || i_OrderType == OP_SELLLIMIT
                 || i_OrderType == OP_SELLSTOP)
             )
         {
            continue;
         }
         
         if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
             && (i_OrderType == OP_BUY //..but it's not a SELL
                 || i_OrderType == OP_BUYLIMIT
                 || i_OrderType == OP_BUYSTOP)
             )
         {
            continue;
         }
         
         if (order_type == OP_BUY //only buy 'market' allowed..
             && i_OrderType != OP_BUY) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELL //only sell 'market' allowed..
             && i_OrderType != OP_SELL) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
             && i_OrderType != OP_BUYLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
             && i_OrderType != OP_BUYSTOP) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
             && i_OrderType != OP_SELLLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
             && i_OrderType != OP_SELLSTOP) //..but it's not
         {
            continue;
         }
      }
     //--- 
      if( _pool == MODE_TRADES )  _OrderTime =OrderOpenTime();
      else
      if( _pool == MODE_HISTORY ) _OrderTime =OrderCloseTime();
     //---
      if( select_by == LAST_ORDER_BY_TIME ){
      if( _OrderTime <= last_time )                            continue;
      else //if( _OrderTime > last_time )
         {
          _ticket   =OrderTicket();
          last_time =_OrderTime;
         }
      }
     //---
      if( select_by == LAST_ORDER_BY_TICKET ){
      if( OrderTicket() < _OrderTicket )                       continue;
      else //if( OrderTicket() > _OrderTicket )
         {
          _OrderTicket = OrderTicket();
          _ticket = _OrderTicket;
         }
      }
     }
//----
   return( _ticket );
  }
//+------------------------------------------------------------------+
//| The function receives chart background color.                    |
//+------------------------------------------------------------------+
color ChartBackColorGet(const long chart_ID=0)
  {
//--- prepare the variable to receive the color
   long result=clrNONE;
//--- reset the error value
   ResetLastError();
//--- receive chart background color
   if(!ChartGetInteger(chart_ID,CHART_COLOR_BACKGROUND,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((color)result);
  }
//+------------------------------------------------------------------+
//| ModifyAllTypePositions
//+------------------------------------------------------------------+
void ModifyAllTypePositions( double stoploss_order, double profit_order, string symbol="", 
                             int _magic_number=-1, string custom_comment="", 
                             int order_type=ALL_ORDERS, int attempts=10 )
  {
   string   s_function_name ="ModifyAllTypePositions";
   int      i_OrderType;
   int      i_OrdersTotal;
   double  d_OrderStopLoss = 0.0,
           d_OrderTakeProfit = 0.0;
//----
   i_OrdersTotal = GetOrdersTotal();
   for( int i =0; i < i_OrdersTotal; i++ )
     {
      if( !IsValidOrder( i, symbol, _magic_number, custom_comment ) ) continue;
     //---
      i_OrderType =OrderType();


      if (order_type != ALL_ORDERS) //not ALL order
      {
         
         if (order_type == ONLY_MARKET //only 'market' allowed..
             && i_OrderType > OP_SELL) //..but it's not 'market'
         {
            continue;
         }
         
         if (order_type == ONLY_PENDING //only 'pending' allowed..
             && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
         {
            continue;
         }
         
         if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
             && (i_OrderType == OP_SELL //..but it's not a BUY
                 || i_OrderType == OP_SELLLIMIT
                 || i_OrderType == OP_SELLSTOP)
             )
         {
            continue;
         }
         
         if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
             && (i_OrderType == OP_BUY //..but it's not a SELL
                 || i_OrderType == OP_BUYLIMIT
                 || i_OrderType == OP_BUYSTOP)
             )
         {
            continue;
         }
         
         if (order_type == OP_BUY //only buy 'market' allowed..
             && i_OrderType != OP_BUY) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELL //only sell 'market' allowed..
             && i_OrderType != OP_SELL) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
             && i_OrderType != OP_BUYLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
             && i_OrderType != OP_BUYSTOP) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
             && i_OrderType != OP_SELLLIMIT) //..but it's not
         {
            continue;
         }
         
         if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
             && i_OrderType != OP_SELLSTOP) //..but it's not
         {
            continue;
         }
      }
     //---
      d_OrderStopLoss = OrderStopLoss();
      d_OrderTakeProfit = OrderTakeProfit();
      
      if(stoploss_order != 0.0)
        {
         d_OrderStopLoss = stoploss_order;
        }
      
      if(profit_order != 0.0)
        {
         d_OrderTakeProfit = profit_order;
        }
      
      CustomOrderModify( OrderTicket(), OrderOpenPrice(), d_OrderStopLoss, d_OrderTakeProfit, 
                         OrderExpiration(), CLR_NONE, attempts );
     }
  }
//+------------------------------------------------------------------+
//| ClosePosition
//+------------------------------------------------------------------+
int ClosePosition(int c_ticket, string symbol, int c_slippage, int attempts, color c_color=CLR_NONE) // Goldenrod
  {
   double d_ask, d_bid;
//----
   if(!OrderSelect(c_ticket,SELECT_BY_TICKET)) return(-1);
   if(OrderType()>1)                           return(-1);
   if(IsStopped())                             return(-1);
   if(OrderCloseTime()!=0)                     return(1);
//---- get volume
   double _OrderLots;
   _OrderLots=OrderLots();
   _OrderLots=NormalizeDouble(_OrderLots,2);
//---- verify digits
   int _DIGITS;
   _DIGITS =Get_DIGITS( symbol, bG_IsTesting, bG_DismissTestingMode );
   if( _DIGITS < 0 )                                                // no digits available
       return(-1);
//----
   double price_cls   =0.0;
   int  attempt     =0;
   bool exit_loop   =false;
   bool order_closed=false;
   int  i_OrderType  =OrderType();
   int  lasterror   =GetLastError();
  //---
   lasterror=0;
   while(!exit_loop)
      {
      //--- verify trade context
       if( !IsTradeContextFree() )                                       // trade is not allowed
	        continue;
      //---
       RefreshRates();
       switch(i_OrderType)
          {
           case OP_BUY:
             //--- get bid price
              d_bid =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
              if( d_bid < 0 )                                    // no bid price available
    	           return( -1 );
              price_cls = d_bid;
             //--- 
              break;
          //--- 
           case OP_SELL:
             //--- get ask price
              d_ask =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
              if( d_ask < 0 )                                    // no ask price available
    	           return( -1 );
              price_cls = d_ask;
             //--- 
              break;
          }
      //---
       order_closed=OrderClose(c_ticket,_OrderLots,price_cls,c_slippage,c_color);
       lasterror   =GetLastError();
       if(order_closed) exit_loop=true;
      //--- 
       switch(lasterror)
          {
           case 135:                   continue;   // ERR_PRICE_CHANGED
           case 138:                   continue;   // ERR_REQUOTE
           case 0:   exit_loop=true;   break;      // ERR_NO_ERROR
          //---
           case 4:                                 // ERR_SERVER_BUSY
           case 6:                                 // ERR_NO_CONNECTION
           case 128:                               // ERR_TRADE_TIMEOUT
           case 129:                               // ERR_INVALID_PRICE
           case 136:                               // ERR_OFF_QUOTES
           case 137:                               // ERR_BROKER_BUSY
           case 146: attempt++;        break;      // ERR_TRADE_CONTEXT_BUSY
          //--- 
           default:
              exit_loop=true;
          }
      //--- 
       if(attempt>attempts) exit_loop=true;
      //--- 
       if(!exit_loop) 
          {
           Print( __FUNCTION__," » ",ErrorDescription(lasterror),
                  " - retrievable error (attempt ",attempt,"/",attempts,")" );
          //--- 
           RandomSleep( SLEEP_MEAN, SLEEP_MAX );
          //---
           RefreshRates();
           switch(i_OrderType)
              {
               case OP_BUY:
                 //--- get bid price
                  d_bid =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_bid < 0 )                                    // no bid price available
	                   return( -1 );
                  price_cls = d_bid;
                 //--- 
                  break;
              //--- 
               case OP_SELL:
                 //--- get ask price
                  d_ask =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
                  if( d_ask < 0 )                                    // no ask price available
	                   return( -1 );
                   price_cls = d_ask;
                 //--- 
                  break;
              }
          }
      //--- 
       if(exit_loop)
          {
           if(lasterror!=0 && // ERR_NO_ERROR
              lasterror!=1)   // ERR_NO_RESULT
              Print( __FUNCTION__," » oops ... a non-retrievable error (#",lasterror,") has ocurred" );
           if(attempt>attempts)
              Print( __FUNCTION__," » retry attempts maxed at ",attempts );
          }
      }
//----
   if(order_closed || lasterror==0) return(1);
//----
   Print( __FUNCTION__," » order #",c_ticket," closing operation has failed at attempt ",attempt,
          " of ",attempts," - error code #",lasterror );
   return(0);
  }
//+------------------------------------------------------------------+
//| CloseAllTypePositions
//+------------------------------------------------------------------+
void CloseAllTypePositions( string symbol, int _magic_number, int _slippage, string custom_comment,
                            int& error_handle, int attempts= 10, int order_type=ONLY_MARKET, color c_color=CLR_NONE )
  {    // Goldenrod
   bool order_closed;
   int i_reply;
   int lasterror=0;
   int attempt;
   int i_OrderType;
   int _OrderTicket;
   int _DIGITS;
   int i_OrdersTotal;
   double price_cls;
   double _OrderLots;
   double _ASK, _BID;
//----
   i_reply = 0;
   while( CustomOrdersTotal( symbol, _magic_number, custom_comment, order_type ) > 0 &&   // while there is any open order
          i_reply < 11 )
      {
      //--- verify if stopped
       if( IsStopped() )
          {
           Print( __FUNCTION__," » the program was commanded to stop its operation" );
           return;
          }
      //--- verify if disabled
       if( !IsExpertEnabled() )
          {
           Print( __FUNCTION__," » the program was disabled" );
           return;
          }
      //--- closing orders
       error_handle = 0;
       i_OrdersTotal = GetOrdersTotal();
       for( int i=i_OrdersTotal-1; i>=0; i-- )  // loop for each open order
          {
           if( !IsValidOrder( i, symbol, _magic_number, custom_comment ) ) continue;
           if( OrderCloseTime() > 0 )                                      continue;   // order was already closed
          //---
           i_OrderType =OrderType();


           if (order_type != ALL_ORDERS) //not ALL order
           {
               
              if (order_type == ONLY_MARKET //only 'market' allowed..
                  && i_OrderType > OP_SELL) //..but it's not 'market'
              {
                 continue;
              }
               
              if (order_type == ONLY_PENDING //only 'pending' allowed..
                  && i_OrderType < OP_BUYLIMIT) //..but it's not 'pending'
              {
                 continue;
              }
               
              if (order_type == ONLY_BUY_ANY //only 'any BUY' allowed..
                  && (i_OrderType == OP_SELL //..but it's not a BUY
                      || i_OrderType == OP_SELLLIMIT
                      || i_OrderType == OP_SELLSTOP)
                  )
              {
                 continue;
              }
               
              if (order_type == ONLY_SELL_ANY //only 'any SELL' allowed..
                  && (i_OrderType == OP_BUY //..but it's not a SELL
                      || i_OrderType == OP_BUYLIMIT
                      || i_OrderType == OP_BUYSTOP)
                  )
              {
                 continue;
              }
               
              if (order_type == OP_BUY //only buy 'market' allowed..
                  && i_OrderType != OP_BUY) //..but it's not
              {
                 continue;
              }
               
              if (order_type == OP_SELL //only sell 'market' allowed..
                  && i_OrderType != OP_SELL) //..but it's not
              {
                 continue;
              }
               
              if (order_type == OP_BUYLIMIT //only buy 'limit' allowed..
                  && i_OrderType != OP_BUYLIMIT) //..but it's not
              {
                 continue;
              }
               
              if (order_type == OP_BUYSTOP //only buy 'stop' allowed..
                  && i_OrderType != OP_BUYSTOP) //..but it's not
              {
                 continue;
              }
             
              if (order_type == OP_SELLLIMIT //only sell 'limit' allowed..
                  && i_OrderType != OP_SELLLIMIT) //..but it's not
              {
                 continue;
              }
               
              if (order_type == OP_SELLSTOP //only sell 'stop' allowed..
                  && i_OrderType != OP_SELLSTOP) //..but it's not
              {
                 continue;
              }
           }
          //---
           _OrderTicket =OrderTicket();
           _OrderLots =OrderLots();
           price_cls =0.0;
          //---- verify digits
           _DIGITS =Get_DIGITS( symbol, bG_IsTesting, bG_DismissTestingMode );
           if( _DIGITS < 0 )                                                // no digits available
               continue;
          //---
           attempt      =0;
           order_closed =false;
           while(!order_closed && attempt<=attempts-1)
              {
              //--- verify if stopped
               if( IsStopped() )
                  {
                   Print( __FUNCTION__," » the program was commanded to stop its operation" );
                   return;
                  }
              //--- verify if disabled
               if( !IsExpertEnabled() )
                  {
                   Print( __FUNCTION__," » the program was disabled" );
                   return;
                  }
              //--- verify trade context
               if( !IsTradeContextFree() )                                       // trade is not allowed
	                continue;
              //---- get ask price
               _ASK =Get_ASK( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
               if( _ASK < 0 )                                                    // no ask price available
      	          continue;
              //--- get bid price
               _BID =Get_BID( symbol, _DIGITS, bG_IsTesting, bG_DismissTestingMode );
               if( _BID < 0 )                                    // no bid price available
      	          continue;
              //---
               if(i_OrderType==OP_BUY) price_cls=NormalizeDouble(_BID,_DIGITS);
               if(i_OrderType==OP_SELL) price_cls=NormalizeDouble(_ASK,_DIGITS);
              //--- 
               order_closed=OrderClose(_OrderTicket,_OrderLots,price_cls,_slippage,c_color);
               lasterror=GetLastError();
               if(!order_closed &&
                  lasterror!=0)
                  {
                   Print("OrderClose (attempt ",attempt+1,") - Error code #",lasterror);
                   attempt++;
                   RandomSleep( SLEEP_MEAN, SLEEP_MAX );
                   error_handle = lasterror;
//                   if( error_handle == 132 )     // market is closed
//                       return;
                  }
              }
          } // loop for each open order END
       i_reply++;
      } // while there is any open order END
  }
//+------------------------------------------------------------------+
//| IsNewBar function
//+------------------------------------------------------------------+
bool IsNewBar( int mode=CURRENT_BAR_NO_NEW )
  {
  // int mode =[CURRENT_BAR_NO_NEW]-the function does not recognize the very first bar as new;
  //            [CURRENT_BAR_NEW]-the function does recognize the very first bar as new
   datetime dt_time;                              // current time
   static datetime sdt_LastTime = 0;
//----
   dt_time =Time[0];
   if( dt_time == 0 )                                 return( false );
//----
   if( mode == CURRENT_BAR_NO_NEW && sdt_LastTime == 0)  { sdt_LastTime =dt_time; return( false ); }
   if( sdt_LastTime != dt_time)            { sdt_LastTime =dt_time; return( true );}
//---- 
   return( false );
  }
//+------------------------------------------------------------------+
//| TimeStringToTime
//+------------------------------------------------------------------+
void TimeStringToTime( string s_time_str, int& i_first_hour, int& i_first_minutes )
  {
   // 's_time_str' at format '23:00'
   string s_cleanstring;
//---- check input parameters
   s_cleanstring = StringTrimLeft( StringTrimRight( s_time_str ) ); // "cleaning" string
   if( StringFind(s_cleanstring,":") < 0 )
     {
      i_first_hour = -1;
      i_first_minutes = -1;
      return;
     }
   i_first_hour = StrToInteger( StringSubstr( s_cleanstring, 0, StringFind( s_cleanstring, ":" ) ) );
   i_first_minutes = StrToInteger( StringSubstr( s_cleanstring, StringFind( s_cleanstring, ":" ) + 1 ) );
  }
//+------------------------------------------------------------------+
//| DeletingHiddenLevels
//+------------------------------------------------------------------+
void DeletingHiddenLevels()
  {
   string s_obj_name;
   int i_line_ticket;
   int i;
//----
   for( i = ObjectsTotal()-1; i >= 0; i-- )
      {
       s_obj_name = ObjectName(i);
       if( StringLen( s_obj_name ) <= 0 ) continue;
       if( ObjectType( s_obj_name ) != OBJ_HLINE ) continue;
       if( StringFind( s_obj_name, "TP" ) < 0 &&
           StringFind( s_obj_name, "SL" ) < 0 ) continue;
       i_line_ticket = StrToInteger( StringSubstr( s_obj_name, 2 ) );
       if( OrderSelect( i_line_ticket, SELECT_BY_TICKET ) &&
           OrderCloseTime() > 0 )
          {
           if( ObjectFind( StringConcatenate( "SL",i_line_ticket ) ) >= 0 )
               ObjectDelete( StringConcatenate( "SL",i_line_ticket ) );
           if( ObjectFind( StringConcatenate( "TP",i_line_ticket ) ) >= 0 )
               ObjectDelete( StringConcatenate( "TP",i_line_ticket ) );
          }
      }
  }
//+------------------------------------------------------------------+
//| DeletePendingOrder function
//+------------------------------------------------------------------+
bool DeletePendingOrder(int c_ticket, int attempts, color c_color=CLR_NONE)   // Goldenrod
  {
//----
   if(!OrderSelect(c_ticket,SELECT_BY_TICKET)) return(false);
   if(OrderType()<2)                           return(false);
   if(OrderCloseTime()!=0)                     return(true);
  //---
   int  attempt     =0;
   int  lasterror   =0;
   bool order_closed=false;
   while(!order_closed && attempt<=attempts-1)
      {
       order_closed=OrderDelete(c_ticket,c_color);
       lasterror=GetLastError();
       if(lasterror!=0)
          {
           Print("OrderDelete (attempt ",attempt+1,") - Error code #",lasterror);
           attempt++;
           RandomSleep( SLEEP_MEAN, SLEEP_MAX );
          }
      }
//----
   return(order_closed);
  }
//+------------------------------------------------------------------+
//| GetOrdersTotal
//| Returns the total amount of orders from the selected pool.
//+------------------------------------------------------------------+
int GetOrdersTotal (int i_pool=MODE_TRADES)
{

   if (i_pool == MODE_HISTORY)
   {
      return (OrdersHistoryTotal ());
   }

   return (OrdersTotal ());
}
//+------------------------------------------------------------------+
//| IsValidOrder
//| Checks if the order meets the search criteria.
//+------------------------------------------------------------------+
bool IsValidOrder( 
   int i_id=INVALID_TICKET, 
   string s_symbol="",
   int i_magic=-1,
   string s_comment="",
   int i_pool=MODE_TRADES,
   bool b_included_comment=true, // if 'true', the order comment must include the searched comment
   int i_selecting_flag=SELECT_BY_POS, 
   bool b_enabled_debugging=false
   )
  {
//----
   // selecting the order
   if( !OrderSelect( i_id, i_selecting_flag, i_pool ) )
     {
      if(b_enabled_debugging)
        {
         Print(__FUNCTION__," » OrderSelect failed returning the error: ",GetLastError());
        }
      return( false );
     }
   
   // verifying matching symbol if enabled
   if( StringLen( s_symbol ) > 0 &&
       StringFind( OrderSymbol(), s_symbol ) < 0 )
     {
      if(b_enabled_debugging)
        {
         Print(__FUNCTION__," » order symbol (",OrderSymbol(),") does not match the searched symbol (",s_symbol,")");
        }
      
      // unselecting the last selected order
      if( !OrderSelect( INVALID_TICKET, SELECT_BY_TICKET ) )
        {
//         Print(__FUNCTION__," » order successfully deselected");
        }
      return( false );
     }

   // verifying matching magic number if enabled
   if( i_magic != -1 &&                                  // search criteria by magic number enabled
       OrderMagicNumber() != i_magic )
     {
      if(b_enabled_debugging)
        {
         Print(__FUNCTION__," » order magic (",OrderMagicNumber(),") does not match the searched magic (",i_magic,")");
        }
      
      // unselecting the last selected order
      if( !OrderSelect( INVALID_TICKET, SELECT_BY_TICKET ) )
        {
//         Print(__FUNCTION__," » order successfully deselected");
        }
      return( false );
     }

   // verifying matching comment if enabled
   if( StringLen( s_comment ) > 0 )
     {
      // the order comment must include the searched comment
      if( b_included_comment &&
          StringFind( OrderComment(), s_comment ) < 0 )
        {
         if(b_enabled_debugging)
           {
            Print(__FUNCTION__," » order comment (",OrderComment(),") does not include the searched comment (",s_comment,")");
           }
         
         // unselecting the last selected order
         if( !OrderSelect( INVALID_TICKET, SELECT_BY_TICKET ) )
           {
//            Print(__FUNCTION__," » order successfully deselected");
           }
         return( false );
        }
      
      // the order comment must NOT include the searched comment
      if( !b_included_comment &&
          StringFind( OrderComment(), s_comment ) >= 0 )
        {
         if(b_enabled_debugging)
           {
            Print(__FUNCTION__," » order comment (",OrderComment(),") includes the searched comment (",s_comment,")");
           }
         
         // unselecting the last selected order
         if( !OrderSelect( INVALID_TICKET, SELECT_BY_TICKET ) )
           {
//            Print(__FUNCTION__," » order successfully deselected");
           }
         return( false );
        }
     }
//---- 
   return( true );
  }
/*-------------------------------------------------------------------*

   Function  IsBinFileCreated
 
   Purpose:   IsBinFileCreated checks if the specified file exists 
            and if not, it creates the file. It prints a message 
            indicating the result of its verification

   Parameters:
            s_file_name (IN) - The name of the file being checked.

   Returns:   Returns true, if the file exists or it was correctly 
            created.  Otherwise returns false.
   
*-------------------------------------------------------------------*/
bool IsBinFileCreated (string s_file_name)
{
   int i_FileHandle;  // stores file handle

   // If the file doesn't exist .. create it
   if (!FileIsExist (s_file_name))
   {
      i_FileHandle = FileOpen (s_file_name,
            FILE_READ  // opened for reading
            | FILE_WRITE  // opened for writing
            | FILE_BIN  // binary read-write mode
            | FILE_SHARE_READ  // shared reading
            | FILE_SHARE_WRITE );  // shared writing 
      
      // Print the result of the operation
      if (i_FileHandle)  // opening ok
      {
         FileClose (i_FileHandle);
         Print (__FUNCTION__," » File opening OK");
         return (true);
      }
      else  // opening failed
      {
         Print (__FUNCTION__,
               " » File opening failed (error #",
               GetLastError(),")");
         return (false);
      }
   }
   else  // file does exist
   {
      return (true);
   }

   return (false);
}   
/*-------------------------------------------------------------------*

   Function  IsTxtFileCreated
 
   Purpose:   IsTxtFileCreated checks if the specified file exists 
            and if not, it creates the file. It prints a message 
            indicating the result of its verification

   Parameters:
            s_file_name (IN) - The name of the file being checked.

   Returns:   Returns true, if the file exists or it was correctly 
            created.  Otherwise returns false.
   
*-------------------------------------------------------------------*/
bool IsTxtFileCreated (string s_file_name)
{
   int i_FileHandle;  // stores file handle

   // If the file doesn't exist .. create it
   if (!FileIsExist (s_file_name))
   {
      i_FileHandle = FileOpen (s_file_name,
            FILE_READ  // opened for reading
            | FILE_WRITE  // opened for writing
            | FILE_BIN  // binary read-write mode
            | FILE_SHARE_READ  // shared reading
            | FILE_SHARE_WRITE );  // shared writing 
      
      // Print the result of the operation
      if (i_FileHandle)  // opening ok
      {
         FileClose (i_FileHandle);
//         Print (__FUNCTION__," » File opening OK");
         return (true);
      }
      else  // opening failed
      {
         Print (__FUNCTION__,
               " » File opening failed (error #",
               GetLastError(),")");
         return (false);
      }
   }
   else  // file does exist
   {
      return (true);
   }

   return (false);
}   
/*-------------------------------------------------------------------*

   Function  CheckUsingProgramConditions
 
   Purpose:   Checks the conditions of using the application program.

   Parameters:
	         s_head_txt (IN/OUT) - Text informing the specific issue.
            b_enable_register (IN) - Enables register file.
	         s_register_file_name (IN) - Register name.
	         b_enable_store_data (IN) - Enables store data file.
            s_store_data_file_name (IN) - Store data name.

   Returns:   Returns TRUE, if the conditions of using the 
            application program are complied with.  Otherwise, it 
            returns FALSE.
   
*-------------------------------------------------------------------*/
bool CheckUsingProgramConditions (
         string& s_head_txt, 
         bool b_enable_register, 
         string s_register_file_name,
         bool b_enable_store_data, 
         string s_store_data_file_name
         )
{
   // Checking register file   
   if (b_enable_register)
   {
      /* 
         Check if the register file of the EA is ready for use.  If
         it doesn't exist or wasn't created correctly, the EA must 
         not continue because it neeeds it to register the important 
         events to speed up the debugging process.
      */
      if (!IsTxtFileCreated (s_register_file_name))
      {
         s_head_txt += StringConcatenate (
               "\nOops .. Expert Advisor is not able to find/create",
               " its register file.",
               "\nContact the developer of the EA to fix this issue.");
   	   return (false);
   	}
   }


   // Checking Store Data File   
   if (b_enable_store_data)
   {
      /* 
         Check if the store data file of the EA is ready for use.  
         If it doesn't exist or wasn't created correctly, the EA 
         must not continue because it neeeds it to store important 
         values for its proper functioning.
      */
      if (!IsBinFileCreated (s_store_data_file_name))
      {
         s_head_txt += StringConcatenate (
               "\nOops .. Expert Advisor is not able to find/create",
               " its store data file.",
               "\nContact the developer of the EA to fix this issue.");
   	   return (false);
   	}
   }

   return (true);
}
/*-------------------------------------------------------------------*
   Function  SetRegisterFileName
*-------------------------------------------------------------------*/
string SetRegisterFileName (
         bool b_enable_register, 
         datetime dt_current_time, 
         int i_magic_number, 
         string s_symbol, 
         bool b_is_testing
         )
{
   string s_register_file_name = "";
   
   if (b_enable_register)
   {
      /* 
         File name includes the following values:
            - Year, month & day of current time.
            - 'MagicNumber' to identify the EA that created the file
            - 'Symbol' to identify the chart where the EA is attached
            - 'Register' word to distinguish these files from others
      */
         
      s_register_file_name = StringConcatenate (
            TimeYear (dt_current_time),
            TimeMonth (dt_current_time),
            TimeDay (dt_current_time),
            "_",i_magic_number,
            "_",s_symbol,
            "_Register.txt"
            );
         
      if (b_is_testing)
      {
         s_register_file_name = StringConcatenate (
               TimeYear (dt_current_time),
               TimeMonth (dt_current_time),
               TimeDay (dt_current_time),
               "_",i_magic_number,
               "_",s_symbol,
               "_RegisterTest.txt"
               );
      }
   }
   
   return (s_register_file_name);
}
/*-------------------------------------------------------------------*
   Function  SetStoreDataFileName
*-------------------------------------------------------------------*/
string SetStoreDataFileName (
         bool b_enable_store_data, 
         int i_magic_number, 
         string s_symbol
         )
{
   string s_store_data_file_name = "";
   
   if (b_enable_store_data)
   {
   
      /* 
         File name includes the following values:
            - 'MagicNumber' to identify the EA that created the file
            - 'Symbol' to identify the chart where the EA is attached
      */
      s_store_data_file_name = StringConcatenate (
            i_magic_number,
            "_",s_symbol,
            ".bin"
            );
   }
   
   return (s_store_data_file_name);
}
/*-------------------------------------------------------------------*

   Function  WriteToRegister
 
   Purpose:   Writes a text into a file.

   Parameters:
            s_text_to_print (IN) - String-type value to be printed
                  into the file.
	         b_add_line_end_character (IN) - If 'true' (default) the 
	               text will be printed in a new line of the file. 
	               Otherwise the text will be overwritten.

   Returns:   'true' if the file was opened successfully. In case of
            failure returns 'false'.
   
*-------------------------------------------------------------------*/
bool WriteToRegister (
         string s_text_to_print, 
         bool b_add_line_end_character=true
         )
{
   int i_FileHandle;
   
   i_FileHandle = FileOpen (
         sG_RegisterFileName,
         FILE_READ  // opened for reading
         | FILE_WRITE  // opened for writing
         | FILE_BIN  // binary read-write mode
         | FILE_SHARE_READ  // shared reading
         | FILE_SHARE_WRITE  // shared writing 
         );

   if (i_FileHandle)  // opening ok
   {
   
      /*
        Move the position of the file pointer to the end of the file. 
        This prevents overwriting.
      */
      FileSeek (i_FileHandle, 0, SEEK_END);
      
      
      if (b_add_line_end_character)
      {
         // Write text into the file adding the line end character
         FileWriteString (
            i_FileHandle, 
            StringConcatenate (s_text_to_print,"\r\n")
            );
      }
      else
      {
         // Write text into the file without the line end character
         FileWriteString (
            i_FileHandle, 
            StringConcatenate (s_text_to_print,";")
            );
      }
      
      
      // Close the file previously opened
      FileClose (i_FileHandle);
//      Print (__FUNCTION__," » File opening OK");
      return (true);
   }
   
   
   // opening failed
   Print (__FUNCTION__,
      " » File opening failed (error #",GetLastError(),")");
   return (false);
}
//+------------------------------------------------------------------+
//| SetAlerts
//+------------------------------------------------------------------+
void SetAlerts( string s_order_type, bool b_DisableAllAlerts=false, bool b_DialogBoxAlert=false, bool b_EmailAlert=false,
                bool b_SMSAlert=false, bool b_SoundAlert=false, string s_SoundAlertFile="alert.wav" )
  {
   if( !b_DisableAllAlerts ) // if true, all alerts will be disabled
      {
       if( b_DialogBoxAlert ) // if true, a dialog box will be displayed
          {
           Alert( s_order_type," at ",sG_Symbol," ",TimeFrameToString( iG_Period ) );
          } // if true, a dialog box will be displayed END
      //--- 
       if( b_EmailAlert ) // if true, an email will be sent
          {
           SendMail( StringConcatenate( s_order_type," at ",sG_Symbol," ",TimeFrameToString( iG_Period ) ), 
                     StringConcatenate( TimeToStr(TimeCurrent())," - ",s_order_type," Signal at ",Symbol()," ",
                                        TimeFrameToString( iG_Period ) ) );
          } // if true, an email will be sent END
      //--- 
       if( b_SMSAlert ) // if true, a push notification will be sent
          {
           SendNotification( StringConcatenate( TimeToStr(TimeCurrent())," - ",s_order_type," at ",sG_Symbol," ",
                                                TimeFrameToString( iG_Period ) ) );
          } // if true, a push notification will be sent END
      //--- 
       if( !b_DialogBoxAlert ) // dialog box alert disabled
          {
           if( b_SoundAlert ) // if true, a sound will be played
               PlaySound( s_SoundAlertFile );
          } // dialog box alert disabled END
      } // if true, all alerts will be disabled END
  }
//+------------------------------------------------------------------+
//| ▼ LabelCreate function  (Last update: 2016.01.23)
//+------------------------------------------------------------------+
/*
  Based on default 'LabelCreate' function from MQL4 documentation.
*/
bool LabelCreate (
   const long chart_ID=0, // chart's ID 
   const string name="Label", // label name 
   const int sub_window=0, // subwindow index 
   const int x=0, // X coordinate 
   const int y=0, // Y coordinate 
   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // corner 
   const string text="Label", // text (up to 62 characters)
   const string font="Tahoma", // font 
   const int font_size=7, // font size 
   const color clr=clrLightGray, // color 
   const double angle=0.0, // text slope 
   const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor 
   const bool back=false, // in the background 
   const bool selection=false, // highlight to move 
   const bool hidden=true, // hidden in the object list 
   const long z_order=0 // priority for mouse click
   )
{
   // Reset the error value 
   ResetLastError();
   
   // Create a text label
   if (!ObjectCreate (chart_ID, name, OBJ_LABEL, sub_window, 0, 0))
   {
      Print (__FUNCTION__," » ", 
             "failed to create text label! error(",
             GetLastError (),")"
            );
      return (false);
   }

   // Set label coordinates 
   ObjectSetInteger (chart_ID, name, OBJPROP_XDISTANCE, x); 
   ObjectSetInteger (chart_ID, name, OBJPROP_YDISTANCE, y);

   // Set the chart's corner, relative to which point coordinates are 
   // defined 
   ObjectSetInteger (chart_ID, name, OBJPROP_CORNER, corner); 

   // Set the text 
   ObjectSetString (chart_ID, name, OBJPROP_TEXT, text); 

   // Set text font 
   ObjectSetString (chart_ID, name, OBJPROP_FONT, font); 
   
   // Set font size 
   ObjectSetInteger (chart_ID, name, OBJPROP_FONTSIZE, font_size); 

   // Set the slope angle of the text 
   ObjectSetDouble (chart_ID, name, OBJPROP_ANGLE, angle); 

   // Set anchor type 
   ObjectSetInteger (chart_ID, name, OBJPROP_ANCHOR, anchor); 

   // Set color 
   ObjectSetInteger (chart_ID, name, OBJPROP_COLOR, clr);
   
   // Display in the foreground (false) or background (true) 
   ObjectSetInteger (chart_ID, name, OBJPROP_BACK, back); 
   
   // Enable (true) or disable (false) the mode of moving the label 
   // by mouse 
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTABLE, selection); 
   ObjectSetInteger (chart_ID, name, OBJPROP_SELECTED, selection); 
   
   // Hide (true) or display (false) graphical object name in the 
   // object list 
   ObjectSetInteger (chart_ID, name, OBJPROP_HIDDEN, hidden); 
   
   // Set the priority for receiving the event of a mouse click in 
   // the chart 
   ObjectSetInteger (chart_ID, name, OBJPROP_ZORDER, z_order); 

   // Successful execution 
   return (true); 
}
// ▲ [End] LabelCreate function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ▼ DisplayLabel function  (Last update: 2016.01.23)
//+------------------------------------------------------------------+
bool DisplayLabel ( 
   string s_txt_out,
   int i_tab_hor_space, 
   int i_tab_ver_space,
   int i_magic,
   int i_column,
   int i_row,
   const string s_txt_font="Tahoma", // font 
   const int i_txt_font_size=7, // font size 
   const color cl_txt_clr=clrLightGray, // color 
   const double d_txt_angle=0.0, // text slope 
   const ENUM_ANCHOR_POINT i_txt_anchor=ANCHOR_LEFT_UPPER, // anchor 
   const bool b_txt_back=false, // in the background 
   const bool b_txt_selection=false, // highlight to move 
   const bool b_txt_hidden=true, // hidden in the object list 
   const long l_txt_z_order=0 // priority for mouse click
   )
{
   // Label name format: 
   // "[MagicNumber]_[Col. Number][Row Number]_label"
   string s_TextLabelName = StringConcatenate (
                               i_magic,"_",
                               i_column,i_row,"_",
                               "1A831"
                               );
         
   // Delete previous label if any
   if (ObjectFind (0, s_TextLabelName) >= 0)
   {
      ObjectDelete (0, s_TextLabelName);
   }
         
   // Create the label
   if (!LabelCreate (
          0,
          s_TextLabelName,
          0,
          i_tab_hor_space,
          i_tab_ver_space,
          CORNER_LEFT_UPPER,
          s_txt_out,
          s_txt_font,
          i_txt_font_size,
          cl_txt_clr,
          d_txt_angle,
          i_txt_anchor,
          b_txt_back,
          b_txt_selection,
          b_txt_hidden,
          l_txt_z_order
          )
      )
   {
      return (false);
   }
   
   return (true);
}
// ▲ [End] DisplayLabel function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ▼ AlignedInfoPanel function  (Last update: 2016.01.23)
//+------------------------------------------------------------------+
/*
  Function description (Optional)
*/
void AlignedInfoPanel (
   string s_txtIn, 
   int& ai_Tabs[], 
   const int i_magic_number=-1,
   const int i_line_spacing=12,
   const int i_initial_hor_space = 4, 
   const int i_initial_ver_space = 15,
   const string s_font="Tahoma", // font 
   const int i_font_size=7, // font size 
   const color cl_clr=clrLightGray, // color 
   const double d_angle=0.0, // text slope 
   const ENUM_ANCHOR_POINT i_anchor=ANCHOR_LEFT_UPPER, // anchor 
   const bool b_back=false, // in the background 
   const bool b_selection=false, // highlight to move 
   const bool b_hidden=true, // hidden in the object list 
   const long l_z_order=0 // priority for mouse click
   )
{
	string s_TextLine = "",
	       s_TextLabelName = "";
   int i_Row = 0,
       i_Column = 0,
       i_TabHorSpace = i_initial_hor_space, // horizontal space
       i_TabVerSpace = i_initial_ver_space, // vertical space
       i_TabIndex = 0;
   int i_SymbolsNumber = StringLen (s_txtIn);
   int i_ElementsNumber = ArraySize (ai_Tabs);
   
   
   // Delete previous display
   RemoveObjectByName ("1A831");
   
   
   // Loop for every text symbol
   for (int i=0; i<i_SymbolsNumber; i++)
   {
      int i_SymbolCode = StringGetCharacter (s_txtIn, i);
      
      
      // Symbol is not 'tab'..
      if (i_SymbolCode != '\t')
      {
         // ..form the text
         s_TextLine += CharToStr ((uchar)i_SymbolCode);
      }
   
      
      // Symbol is 'new line' or end of entered text is reached
      if (i_SymbolCode == '\n'
          || i == i_SymbolsNumber-1)
      {
         
         // Display the concatenated text
         if (s_TextLine != "\n"
             && s_TextLine != "")
         {
            if (!DisplayLabel (
                   s_TextLine, 
                   i_TabHorSpace, 
                   i_TabVerSpace,
                   i_magic_number,
                   i_Column,
                   i_Row
                   )
              )
            {
               return;
            }
         }
         
         // Reset & update values
         s_TextLine = "";
         i_Row++;
         i_Column = 0;
         i_TabHorSpace = i_initial_hor_space;
         i_TabVerSpace += i_line_spacing;
         i_TabIndex = 0;
         continue;
      }
      
      
      // Symbol is 'horizontal tab'
      if (i_SymbolCode == '\t')
      {
         
         // Display the concatenated text
         if (s_TextLine != "\t"
             && s_TextLine != "")
         {
            if (!DisplayLabel (
                   s_TextLine, 
                   i_TabHorSpace, 
                   i_TabVerSpace,
                   i_magic_number,
                   i_Column,
                   i_Row
                   )
              )
            {
               return;
            }
         }

         // Reset & update values
         s_TextLine = "";
         i_Column++;
         
         /*
           If there are more 'hor tab' within a line (row) than the 
           number of 'hor tab' defined by the user, then last 
           defined tab will be used by default
         */
         if (i_TabIndex > i_ElementsNumber-1)
         {
            i_TabHorSpace += ai_Tabs[i_ElementsNumber-1];
         }
         else
         {
            i_TabHorSpace += ai_Tabs[i_TabIndex];
         }
         
         i_TabIndex++;
      }
   }
}
// ▲ [End] AlignedInfoPanel function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ▼ RemoveObjectByName function  (Last update: 2016.01.23)
//+------------------------------------------------------------------+
void RemoveObjectByName (string s_name_to_search)
{
   string s_ObjectName = "";
   
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      s_ObjectName = ObjectName (i);
      
      if (StringLen (s_ObjectName) > 0
          && StringFind (s_ObjectName, s_name_to_search) >= 0)
      {
         ObjectDelete (0, s_ObjectName);
      }
   }
}
// ▲ [End] RemoveObjectByName function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ▼ PointDecimalDigits function  (Last update: 2016.05.10)
//+------------------------------------------------------------------+
int PointDecimalDigits ( double d_point=0.0001)
{
   int i_digits = 0;
   
   while (d_point < 1)
   {
      d_point *= 10.0;
      i_digits++;
   }

   return (i_digits);
}
// ▲ [End] PointDecimalDigits function
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| DisplayTrademark2
//+------------------------------------------------------------------+
void DisplayTrademark2( int _CORNER=BOTTOM_RIGHT_CORNER, int _WINDOW=0, 
                        int _XDISTANCE=5, int _YDISTANCE=5 )
  {
   string _label_1="lb_TradeMark_Cod_01";
   string _label_2="lb_TradeMark_Cod_02";
   string _label_3="lb_TradeMark_Cod_03";
//----
   CreateLabel( _label_1, _WINDOW, "WEBSITE: "+WEBSITE_ADDRESS, _CORNER, _XDISTANCE, _YDISTANCE, 10, "Verdana", clrRed );
   CreateLabel( _label_2, _WINDOW, "SKYPE ID: "+SKYPE_ID, _CORNER, _XDISTANCE, _YDISTANCE+15, 10, "Verdana", clrRed );
   CreateLabel( _label_3, _WINDOW, "powered by barmenteros.com", _CORNER, _XDISTANCE, _YDISTANCE+30, 10, "Verdana", clrRed );
  }
//+------------------------------------------------------------------+
//| RemoveTrademark
//+------------------------------------------------------------------+
void RemoveTrademark()
  {
   string _label_1="lb_TradeMark_Cod_01";
   string _label_2="lb_TradeMark_Cod_02";
   string _label_3="lb_TradeMark_Cod_03";
//----
   if(ObjectFind(_label_1)>=0) ObjectDelete(_label_1);
   if(ObjectFind(_label_2)>=0) ObjectDelete(_label_2);
   if(ObjectFind(_label_3)>=0) ObjectDelete(_label_3);
  }
//+------------------------------------------------------------------+
//| CreateLabel function
//+------------------------------------------------------------------+
bool CreateLabel( string obj_name, int obj_window, string obj_text, int corner, double xaxis, double yaxis,
                  int fontsize, string font, color textcolor, int retries=3 )
  {
   bool   label_created;
   int    _lasterror;
//----
   if( ObjectFind( obj_name ) >= 0 ) return( FALSE );
  //--- 
   _lasterror   =GetLastError();
   _lasterror   =0;
  //---
   label_created =FALSE;
   while( !label_created &&                     // error creating object
          retries > 0 )                         // not been all retries
      {
       label_created =ObjectCreate( obj_name, OBJ_LABEL, obj_window, 0, 0 );
       _lasterror    =GetLastError();
       retries--;                               // next retry
      }
  //--- 
   if( !label_created )                         // still error creating object
      {
       Print( StringConcatenate( __FUNCTION__," >> error creating label ( ",ErrorDescription( _lasterror )," )" ) );
       return( FALSE );
      }
//----
   bool   error   =FALSE;
   string prop[4] ={ "corner", "x-distance", "y-distance", "text format" };
   double last_error[4];
  //---
   ArrayInitialize( last_error, 0.0 );
  //---
   ObjectSet(obj_name,OBJPROP_CORNER,1);
   if( !ObjectSet( obj_name, OBJPROP_CORNER, corner ) )                    { last_error[0] =GetLastError(); error=true; }
   if( !ObjectSet( obj_name, OBJPROP_XDISTANCE, xaxis ) )                  { last_error[1] =GetLastError(); error=true; }
   if( !ObjectSet( obj_name, OBJPROP_YDISTANCE, yaxis ) )                  { last_error[2] =GetLastError(); error=true; }
   if( !ObjectSetText( obj_name, obj_text, fontsize, font, textcolor ) )   { last_error[3] =GetLastError(); error=true; }
  //---
   if( error )                                  // error occurred
      {
       for( int i =0; i <= 3; i++ )
          {
           if( last_error[i] == 0.0 ) continue;
           Print( StringConcatenate( __FUNCTION__," >> error setting ",prop[i]," ( ",ErrorDescription( (int)last_error[i] )," )" ) );
          }
      } // error occurred END
//----
   return( TRUE );
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   DisplayTrademark2( TOP_RIGHT_CORNER, 0, 5, 20 );
   dtG_CurrentTime = TimeCurrent ();
   bG_ValidParameters = true;
   sG_HeadTxt = StringConcatenate (
         "\n",EA_NAME," ",EA_VERSION,": No operational"
         );
   bG_IsTesting = false;
   bG_IsTesting = IsTesting ();
   sG_Symbol = Symbol ();
   iG_Period = Period ();
   

   // Remove any previous comment
   Comment("");
   
   
   ad_lots[0] = Lots1;
   ad_lots[1] = Lots2;
   ad_lots[2] = Lots3;
   ad_lots[3] = Lots4;
   ad_lots[4] = Lots5;
   ad_lots[5] = Lots6;
   ad_lots[6] = Lots7;
   ad_lots[7] = Lots8;
   ad_lots[8] = Lots9;
   ad_lots[9] = Lots10;
   ad_lots[10] = Lots11;
   ad_lots[11] = Lots12;
   ad_lots[12] = Lots13;
   ad_lots[13] = Lots14;
   ad_lots[14] = Lots15;
   ad_lots[15] = Lots16;
   ad_lots[16] = Lots17;
   ad_lots[17] = Lots18;
   ad_lots[18] = Lots19;
   ad_lots[19] = Lots20;
   ad_lots[20] = Lots21;
   ad_lots[21] = Lots22;


   //S e t t i n g   r e g i s t e r   f i l e   n a m e
   sG_RegisterFileName = SetRegisterFileName (
         EnableRegister, 
         dtG_CurrentTime, 
         MagicNumber, 
         sG_Symbol, 
         bG_IsTesting
         );


   //S e t t i n g   s t o r e   d a t a   f i l e   n a m e
   sG_StoreDataFileName = SetStoreDataFileName (
         EnableStoreData, 
         MagicNumber, 
         sG_Symbol
         );
/*
   int last3=AccountNumber()%1000;
   long last6=(long)AccountNumber()*(long)AccountNumber()%1000000;

   if(Password!=last6)
   {
      Alert("WRONG PASSWORD");
      sG_HeadTxt = sG_HeadTxt + 
              "\nWRONG PASSWORD";
      Comment (sG_HeadTxt);
      bG_ValidParameters = false;
   	return (INIT_FAILED);
   }

   
   if (EXPIRY_DATE != "0"
       && TimeCurrent () >= StringToTime (EXPIRY_DATE))
   {
      sG_HeadTxt = sG_HeadTxt + 
              "\nExpert Advisors has expired as of " + TimeToStr (StringToTime (EXPIRY_DATE), TIME_DATE) + ".";
      Comment (sG_HeadTxt);
      bG_ValidParameters = false;
   	return (INIT_FAILED);
   }
*/   
   
   // Checking the conditions of using the application program
   if (!CheckUsingProgramConditions (sG_HeadTxt, 
            EnableRegister, sG_RegisterFileName, 
            EnableStoreData, sG_StoreDataFileName))
   {
      Comment (sG_HeadTxt);
      bG_ValidParameters = false;
   	return (INIT_FAILED);
   }
      
   
   //Save template with EA settings
   if (SaveTemplate)
   {
      string s_template_name;
      
      s_template_name = 
         StringConcatenate (MagicNumber,"_",
           (int)TimeCurrent()
           );
      
      if (bG_IsTesting)
      {
         s_template_name = 
         StringConcatenate (MagicNumber,"_",
           (int)TimeCurrent(),"_tester"
           );
      }
      
      
      Print ("Chart template \'",
         s_template_name,
         "\' saved to \'",
         TerminalInfoString(TERMINAL_DATA_PATH),"\\templates\\\'"
         );
      
      ChartSaveTemplate (0, s_template_name);
   }
   
   
   //S e t t i n g   r e g i s t e r   h e a d e r   n a m e
   sG_RegisterTextHeader = StringConcatenate (
         TimeToStr (dtG_CurrentTime, TIME_SECONDS),"    ",
         EA_NAME," ",
         sG_Symbol,",",
         TimeFrameToString (iG_Period),": "
         );

   
//---- verify DLL function call
//   if( TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) == 0 )                   // DLL function call disabled
//      {
//       sG_HeadTxt = sG_HeadTxt + 
//               "\nOops .. DLL call is not allowed. Experts cannot run.\nPress \'Ctrl+O\', select \'Expert Advisors\' tab, check \'Allow DLL imports\', click \'OK\' and reattach the EA to the chart.";
//       Comment(sG_HeadTxt);
//       WriteToRegister (sG_RegisterTextHeader + sG_HeadTxt);
//       bG_ValidParameters = false;
//	    return( INIT_FAILED );
//	   }
//---- verify Expert Advisors are enabled for running
   if( !IsExpertEnabled() )                                                // Expert Advisors disabled for running
      {
       sG_HeadTxt = sG_HeadTxt + 
               "\nOops .. Expert Advisors are disabled for running.\nPress \'Ctrl+O\', select \'Expert Advisors\' tab, check \'Allow automated trading\', click \'OK\' and reattach the EA to the chart.";
       Comment(sG_HeadTxt);
       WriteToRegister (sG_RegisterTextHeader + sG_HeadTxt);
       bG_ValidParameters = false;
	    return( INIT_FAILED );
	   }


//---- verify digits
   iG_Digits = Get_DIGITS( sG_Symbol, bG_IsTesting, bG_DismissTestingMode );
   if( iG_Digits < 0 )                                                 // no digits available
      {
       sG_HeadTxt = sG_HeadTxt + 
               "\nPlease, contact the support team of your broker. \'Digits\' info not available.\nReattach the EA to the chart upon fixing the issue.";
       Comment(sG_HeadTxt);
       WriteToRegister (sG_RegisterTextHeader + sG_HeadTxt);
       bG_ValidParameters = false;
	    return( INIT_FAILED );
	   }
//---- get point size
   dG_Point = Get_POINT( sG_Symbol, iG_Digits, bG_IsTesting, bG_DismissTestingMode );
   if( dG_Point < 0 )                                                  // no point size available
      {
       sG_HeadTxt = sG_HeadTxt + 
               "\nPlease, contact the support team of your broker. \'Points\' info not available.\nReattach the EA to the chart upon fixing the issue.";
       Comment(sG_HeadTxt);
       WriteToRegister (sG_RegisterTextHeader + sG_HeadTxt);
       bG_ValidParameters = false;
	    return( INIT_FAILED );
	   }
//---- get point decimal digits
   dG_PointDigits = PointDecimalDigits (dG_Point);
//---- get minimum lot
   dG_MinLot =Get_MINLOT( sG_Symbol );
   if( dG_MinLot < 0 )                                                // no minimum lot info available
      {
       sG_HeadTxt = sG_HeadTxt + 
               "\nPlease, contact the support team of your broker. \'Minimum Lot\' info not available.\nReattach the EA to the chart upon fixing the issue.";
       Comment(sG_HeadTxt);
       WriteToRegister (sG_RegisterTextHeader + sG_HeadTxt);
       bG_ValidParameters = false;
	    return( INIT_FAILED );
	   }

//----
   if( bG_ValidParameters ) 
       sG_HeadTxt = StringConcatenate( "\n",EA_NAME," ",EA_VERSION,": Operational" );
//---
   WriteToRegister (sG_RegisterTextHeader + "initialized");
   OnTick();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(reason != REASON_INITFAILED)
     {
      Comment("");
     }
   
   if(reason == REASON_RECOMPILE)
     {
      Alert("Program has been recompiled while the EA is running \n Be aware this action restarts the EA");
      WriteToRegister (sG_RegisterTextHeader + "Program has been recompiled while the EA is running");
     }
  
   if(reason == REASON_CHARTCHANGE)
     {
      Alert("Chart timeframe has been changed \n Avoid this action on the chart where the EA is attached \n This could cause malfunctions or erratic behavior of the EA");
      WriteToRegister (sG_RegisterTextHeader + "Chart timeframe has been changed");
     }
  
   if(reason == REASON_PARAMETERS)
     {
      Alert("Input parameters have been changed \n Be aware this action restarts the EA");
      WriteToRegister (sG_RegisterTextHeader + "Input parameters have been changed");
     }
   
   RemoveObjectByName ((string)MagicNumber);
   RemoveTrademark ();
   WriteToRegister (sG_RegisterTextHeader + "removed");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick ()
{
   DisplayTrademark2( TOP_RIGHT_CORNER, 0, 5, 20 );
   int tab[] = {5, 80};


   //S e t t i n g   r e g i s t e r   f i l e   n a m e
   sG_RegisterFileName = SetRegisterFileName (
      EnableRegister, 
      dtG_CurrentTime, 
      MagicNumber, 
      sG_Symbol, 
      bG_IsTesting
   );
   
   
   //S e t t i n g   s t o r e   d a t a   f i l e   n a m e
   sG_StoreDataFileName = SetStoreDataFileName (
      EnableStoreData, 
      MagicNumber, 
      sG_Symbol
   );


   //S e t t i n g   r e g i s t e r   h e a d e r   n a m e
   sG_RegisterTextHeader = StringConcatenate (
      TimeToStr (dtG_CurrentTime, TIME_SECONDS),"    ",
      EA_NAME," ",
      sG_Symbol,",",
      TimeFrameToString (iG_Period),": "
   );

   
   //Checking the conditions of using the application program
   if (!CheckUsingProgramConditions (sG_HeadTxt, 
            EnableRegister, sG_RegisterFileName, 
            EnableStoreData, sG_StoreDataFileName))
   {
      bG_ValidParameters = false;
   }

   
   sG_BodyTxt = sG_HeadTxt;
   if (!bG_ValidParameters)
   {
      AlignedInfoPanel (
         sG_BodyTxt, 
         tab,
         MagicNumber
      );
      WriteToRegister (sG_RegisterTextHeader + sG_BodyTxt);
      return;
   }
   

   //Get initial time
   static datetime dt_TimeThreshold = 0;
   if (dt_TimeThreshold == 0)
   {
      dt_TimeThreshold = TimeCurrent ();
   }
       

   static datetime sdt_PreviousTime = 0;
   dtG_CurrentTime = TimeCurrent ();
   
   /*
     Avoiding a wrong time value. New time value must never be 
     smaller than a previous time value. Time always moves forward.
   */
   if (dtG_CurrentTime < sdt_PreviousTime)
   {
      dtG_CurrentTime = sdt_PreviousTime;
   }


   if (sdt_PreviousTime == 0)
   {
      sdt_PreviousTime = dtG_CurrentTime;
   }

       
   static double d_PreviousPrice = -1.0;
   double d_CurrentPrice;
   d_CurrentPrice = Close[0];
   if (d_PreviousPrice == -1.0)
   {
      d_PreviousPrice = d_CurrentPrice;
   }
       

   //Get spread
   double d_SPREAD;
   d_SPREAD = Get_SPREAD (sG_Symbol, iG_Digits, dG_Point);
   if (d_SPREAD < 0) // no spread available
   {
      return;
   }
   
   
   int i_error_handle = 0;
   double d_CurrentDD = 0.0;
   double d_MaxDD_InCurrency = 0.0;
   
   if(Max_DD_InPercent > 0)
     {
      d_MaxDD_InCurrency = AccountBalance() * Max_DD_InPercent / 100.0;
      d_CurrentDD = AccountEquity() - AccountBalance();
     }
//   if (d_CurrentDD != 0)
//   {
//      Print ("d_CurrentDD: ",DoubleToStr (d_CurrentDD, 2)," || d_MaxDD_InCurrency: ",DoubleToStr (d_MaxDD_InCurrency, 2));
//   }
   
   if (d_CurrentDD < 0
       && MathAbs(d_CurrentDD) >= d_MaxDD_InCurrency)
   {
      CloseAllTypePositions( sG_Symbol, MagicNumber, Slippage, "", i_error_handle, 10, ONLY_MARKET, clrGoldenrod );
      Print ("Closing ALL positions »",
             " d_CurrentDD: ",DoubleToStr (d_CurrentDD, 2)," (",Max_DD_InPercent,"%) above the threshold");
   }


   //Hidden sl & tp activation
   if (HiddenStopLoss
       || HiddenTakeProfit)
   {
      TrackingStealthLevels (
         iG_Digits, 
         Slippage, 
         sG_Symbol, 
         MagicNumber, 
         "", 
         ONLY_MARKET
      );
   
      DeletingHiddenLevels();
   }
       


//+------------------------------------------------------------------+
// ↓ OnTick:Section#1
   
   // Checking entry conditions
   bool b_IsNewBar;
   int i_Shift;
   int i_EntrySignal;
   int i_ExitSignal;

   b_IsNewBar = true;
   i_Shift = SHIFT_CURRENT_BAR; // or SHIFT_PREVIOUS_BAR
   i_EntrySignal = -1;
   i_ExitSignal = -1;


   // Trade only with new bars (only check conditions at new bars)
   if (EntryAtClosedBar)
   {
      b_IsNewBar = IsNewBar (CURRENT_BAR_NO_NEW);
   }

       
   if (b_IsNewBar) // Each new bar
   {
      i_EntrySignal = OP_BUYSELL;
   }

// ↑ [End] OnTick:Section#1
//+------------------------------------------------------------------+
   
   

   //Closing positions
//   int i_error_handle;
   
   if (i_ExitSignal != -1)
   {
      CloseAllTypePositions (
         sG_Symbol,
         MagicNumber,
         Slippage,
         "",
         i_error_handle,
         10,
         i_ExitSignal,
         Goldenrod
      );
   }


   /*
     Cancel the signal if the last closed order was opened at the
     same bar
   */
   int i_LastClosedPosition;
   if (OneTradePerBar // enable only 1 market order per bar
       && !EntryAtClosedBar)
   {
      
      i_LastClosedPosition = GetLastOrder (
         sG_Symbol, 
         MagicNumber, 
         "", 
         ONLY_MARKET, 
         MODE_HISTORY, 
         LAST_ORDER_BY_TIME
      );
      
      
      /*
        Last closed order is valid & was open at current bar
      */
      if (i_LastClosedPosition > 0
          && OrderSelect (i_LastClosedPosition, SELECT_BY_TICKET)
          && OrderOpenTime() >= Time[0])
      {
         //Cancel the signal because no trading allowed
         i_EntrySignal = -1;
      }
   }
   

   // Opening positions
   int i_ticket = -1,
       i_OrdersTotal = 0,
       i_BuyTotal = 0,
       i_SellTotal = 0,
       i_BuylimitTotal = 0,
       i_SelllimitTotal = 0,
       i_BuystopTotal = 0,
       i_SellstopTotal = 0,
       i_LastBuyPosition = -1, 
       i_LastSellPosition = -1;
   double d_volume = 0.0;
   string s_OrderText = "", 
          s_SL_txt = "", 
          s_TP_txt = "";
   
   
   // getting last open market buy & sell orders
   i_LastBuyPosition = GetLastOrder (
      sG_Symbol, 
      MagicNumber, 
      "", 
      OP_BUY
   );
   
   i_LastSellPosition = GetLastOrder (
      sG_Symbol, 
      MagicNumber, 
      "", 
      OP_SELL
   );
   
   d_volume = NormalizeDouble( ad_lots[0], 2 );
   if(EnableAutoLotSize 
      && AccountEquity() >= 10000.0)
   {
      d_volume = ad_lots[0] + ((0.01 * AccountEquity() / 10000.0) - 0.01);
      d_volume = NormalizeDouble( d_volume, 2 );
   }

   
   // no open market orders
   if (i_EntrySignal != -1
       && i_LastBuyPosition <= 0 &&
       i_LastSellPosition <= 0)
   {
      // opening market buy order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_BUY,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         ad_takeprofit[0], //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Blue,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
      && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         SetAlerts (
            "BUY", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
      }
      
      // opening market sell order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_SELL,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         ad_takeprofit[0], //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Red,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
      && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         SetAlerts (
            "SELL", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
      }
   }
   
   
   // no open market buy orders
   if (i_EntrySignal != -1
       && i_LastSellPosition > 0
       && i_LastBuyPosition <= 0)
   {
      // opening market buy order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_BUY,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         ad_takeprofit[0], //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Blue,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
      && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         SetAlerts (
            "BUY", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
      }
   }
   
   
   // no open market sell orders
   if (i_EntrySignal != -1
       && i_LastBuyPosition > 0
       && i_LastSellPosition <= 0)
   {
      // opening market sell order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_SELL,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         ad_takeprofit[0], //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Red,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
      && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         SetAlerts (
            "SELL", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
      }
   }
   
   
   
   // opening protective orders
   
   // get ask/bid prices
   double d_ASK, d_BID, d_TakeProfit;
   d_ASK = Get_ASK (sG_Symbol, iG_Digits, bG_IsTesting, bG_DismissTestingMode);
   d_BID = Get_BID (sG_Symbol, iG_Digits, bG_IsTesting, bG_DismissTestingMode);
   if ( d_ASK < 0 || d_BID < 0 ) return; // no ask/bid price available
	   
   // opening buy protective order
   if (i_LastBuyPosition > 0 // valid last buy order
       && OrderSelect (i_LastBuyPosition, SELECT_BY_TICKET)
       && (TimeCurrent() - OrderOpenTime()) >= (MinimumElapsedMinutes * 60)
       && (OrderOpenPrice () - d_ASK) >= (BufferToOpenOrders * dG_Point))
   {
      i_OrdersTotal = CustomOrdersTotalDetailed (
         i_BuyTotal, 
         i_SellTotal, 
         i_BuylimitTotal, 
         i_SelllimitTotal,
         i_BuystopTotal, 
         i_SellstopTotal, 
         sG_Symbol, 
         MagicNumber, 
         "",
         ALL_ORDERS,
         MODE_TRADES
      );
      
      if (i_BuyTotal < MAX_AMOUNT_ARRAY_VALUES)
      {
         d_volume = NormalizeDouble( ad_lots[i_BuyTotal], 2 );
         if(EnableAutoLotSize 
            && AccountEquity() >= 10000.0)
         {
            d_volume = ad_lots[i_BuyTotal] + ((0.01 * AccountEquity() / 10000.0) - 0.01);
            d_volume = NormalizeDouble( d_volume, 2 );
         }
         
         d_TakeProfit = ad_takeprofit[i_BuyTotal];
      }
      else //if(i_BuyTotal >= MAX_AMOUNT_ARRAY_VALUES)
      {
         d_volume = NormalizeDouble( ad_lots[MAX_AMOUNT_ARRAY_VALUES-1], 2 );
         if(EnableAutoLotSize 
            && AccountEquity() >= 10000.0)
         {
            d_volume = ad_lots[MAX_AMOUNT_ARRAY_VALUES-1] + ((0.01 * AccountEquity() / 10000.0) - 0.01);
            d_volume = NormalizeDouble( d_volume, 2 );
         }
         
         d_TakeProfit = ad_takeprofit[MAX_AMOUNT_ARRAY_VALUES-1];
      }
      
      // opening market buy order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_BUY,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         d_TakeProfit, //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Blue,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
          && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         d_TakeProfit = GetProfitLevel (sG_Symbol, MagicNumber, "", OP_BUY) + (BufferToOpenOrders * dG_Point);
         
         SetAlerts (
            "BUY", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
         
         ModifyAllTypePositions (
            0.0, 
            d_TakeProfit, 
            sG_Symbol, 
            MagicNumber, 
            "", 
            OP_BUY
         );
      }
   }
	   
   // opening sell protective order
   if (i_LastSellPosition > 0 // valid last sell order
       && OrderSelect (i_LastSellPosition, SELECT_BY_TICKET)
       && (TimeCurrent() - OrderOpenTime()) >= (MinimumElapsedMinutes * 60)
       && (d_BID - OrderOpenPrice ()) >= (BufferToOpenOrders * dG_Point))
   {
      i_OrdersTotal = CustomOrdersTotalDetailed (
         i_BuyTotal, 
         i_SellTotal, 
         i_BuylimitTotal, 
         i_SelllimitTotal,
         i_BuystopTotal, 
         i_SellstopTotal, 
         sG_Symbol, 
         MagicNumber, 
         "",
         ALL_ORDERS,
         MODE_TRADES
      );
      
      if (i_SellTotal < MAX_AMOUNT_ARRAY_VALUES)
      {
         d_volume = NormalizeDouble( ad_lots[i_SellTotal], 2 );
         if(EnableAutoLotSize 
            && AccountEquity() >= 10000.0)
         {
            d_volume = ad_lots[i_SellTotal] + ((0.01 * AccountEquity() / 10000.0) - 0.01);
            d_volume = NormalizeDouble( d_volume, 2 );
         }
         
         d_TakeProfit = ad_takeprofit[i_SellTotal];
      }
      else //if(i_SellTotal >= MAX_AMOUNT_ARRAY_VALUES)
      {
         d_volume = NormalizeDouble( ad_lots[MAX_AMOUNT_ARRAY_VALUES-1], 2 );
         if(EnableAutoLotSize 
            && AccountEquity() >= 10000.0)
         {
            d_volume = ad_lots[MAX_AMOUNT_ARRAY_VALUES-1] + ((0.01 * AccountEquity() / 10000.0) - 0.01);
            d_volume = NormalizeDouble( d_volume, 2 );
         }
         
         d_TakeProfit = ad_takeprofit[MAX_AMOUNT_ARRAY_VALUES-1];
      }
      
      // opening market sell order
      i_ticket = -1;
      i_ticket = OrderSendModule (
         sG_Symbol,
         OP_SELL,
         d_volume,
         0.0,
         Slippage,
         0.0, //StopLossInPips,
         d_TakeProfit, //TakeProfitInPips,
         false,
         false,
         CommentForOrders,
         MagicNumber,
         0,
         Red,
         10,
         HiddenStopLoss,
         HiddenTakeProfit
      );
                 
      if (i_ticket > 0
          && OrderSelect (i_ticket, SELECT_BY_TICKET))
      {
         d_TakeProfit = GetProfitLevel (sG_Symbol, MagicNumber, "", OP_SELL) - (BufferToOpenOrders * dG_Point);
         
         SetAlerts (
            "SELL", 
            DisableAllAlerts, 
            DialogBoxAlert, 
            EmailAlert,
            SMSAlert, 
            SoundAlert, 
            SoundAlertFile
         );
         
         ModifyAllTypePositions (
            0.0, 
            d_TakeProfit, 
            sG_Symbol, 
            MagicNumber, 
            "", 
            OP_SELL
         );
      }
   }
   
   
   //Updating previous price
   sdt_PreviousTime = dtG_CurrentTime;
   d_PreviousPrice = d_CurrentPrice;


   //Display market orders
   if (DisplayLiveOrders)
   {
      int i_TrackingOrdersTotal;
      
      sG_BodyTxt += "\n\nlive orders\n--------------------------\n";

      i_TrackingOrdersTotal = TrackingOrdersTotal (
         sG_BodyTxt, 
         sG_Symbol, 
         MagicNumber
      );
      
      if (i_TrackingOrdersTotal == 0)
      {
         sG_BodyTxt += "\tno open orders\n";
      }
      else
      {
         sG_BodyTxt += StringConcatenate (
            "orders total: ",
            i_TrackingOrdersTotal,
            "\n"
         );
      }
   }


   AlignedInfoPanel (sG_BodyTxt, tab, MagicNumber);
}
//+------------------------------------------------------------------+