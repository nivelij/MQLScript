//+------------------------------------------------------------------+
//|                                                   RSIScanner.mq4 |
//|                                                   Hans Kristanto |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hans Kristanto"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

#include <CommonLib.mqh>

const int                     RSI_DIGIT = 2;
const input int               RSI_PERIOD=14;
const input ENUM_TIMEFRAMES   TIME_FRAME=PERIOD_D1;
const input instrumentClass   INSTRUMENT_CLASS=All;
const input int               OVERBOUGHT_VALUE = 70;
const input int               OVERSOLD_VALUE = 30;
const input bool              ONLY_EXTREME_POINT=false;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void WriteEntry(string symbolName, int handle)
{
   double rsi = NormalizeDouble(iRSI(symbolName, TIME_FRAME, RSI_PERIOD, PRICE_CLOSE, 0), RSI_DIGIT);
            
   if ((ONLY_EXTREME_POINT && (rsi >= OVERBOUGHT_VALUE || rsi <= OVERSOLD_VALUE)) || !ONLY_EXTREME_POINT)
   {
      FileWrite(handle, StringConcatenate(symbolName, ",", DoubleToStr(rsi)));
      FileFlush(handle);
   }
}


void OnStart()
  {
//---
    string fileName = StringConcatenate("RSIScanner\\RSIScanner_TF(",
                                       TIME_FRAME,
                                       ")_RSI(",
                                       RSI_PERIOD,
                                       ")_",
                                       EnumToString(INSTRUMENT_CLASS),
                                       "_",
                                       TimeToStr(TimeCurrent(),TIME_DATE),
                                       ".csv");

    int handle = FileOpen(fileName, FILE_CSV|FILE_READ|FILE_WRITE);
    FileWrite(handle, StringConcatenate("Symbol", ",", StringConcatenate("RSI(", RSI_PERIOD, ")")));

    if (INSTRUMENT_CLASS == All)
    {
        int symbolsTotal = SymbolsTotal(false);

        for (int i=0;i < symbolsTotal;i++)
        {
            string symbolName = SymbolName(i, false);
            WriteEntry(symbolName, handle);
        }
    }
    else
    {
      string instrument[];
      
      switch(INSTRUMENT_CLASS)
      {
         case Major:
            ArrayCopy(instrument, MAJOR, 0, 0, WHOLE_ARRAY);
            break;
         case Minor:
            ArrayCopy(instrument, MINOR, 0, 0, WHOLE_ARRAY);
            break;
         case Exotic:
            ArrayCopy(instrument, EXOTIC, 0, 0, WHOLE_ARRAY);
            break;
         case Metals:
            ArrayCopy(instrument, METALS, 0, 0, WHOLE_ARRAY);
            break;
         case Indices:
            ArrayCopy(instrument, INDICES, 0, 0, WHOLE_ARRAY);
            break;
         case Commodities:
            ArrayCopy(instrument, COMMODITIES, 0, 0, WHOLE_ARRAY);
            break;
      }

      for (int i=0;i < ArraySize(instrument);i++)
      {
         WriteEntry(instrument[i], handle);
      }
    }
    
    FileClose(handle);
  }
//+------------------------------------------------------------------+
