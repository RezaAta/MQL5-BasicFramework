#include "Base.mqh"
#include "TradeSystem.mqh"
#include "GUIHandler.mqh"

Base base;
TradeSystem tradeSystem;
GUIHandler GUIH;

void OnInit()
{
        base.Initialize();
        tradeSystem.Initialize();
        
        CreateGUI();
}

void OnTick()
  {
  
        GUIH.DrawGUI();//this function draws GUI if existing
        
        base.UpdateAccountInfo();
        
        //order tradeSignal
        tradeSystem.tradeSignal ="";
        
        RunMainStrategy();
        
        tradeSystem.StartTradeBasedOnCandleType();

  }
  
  /*
  |
  |
  |
  |
  |
  |
  |
  |
  |
  |
  Functions
  |
  |
  |
  |
  |
  |
  |
  |
  |
  */
  
//in this function u will write all the things about your trade strategy.
void RunMainStrategy()
{
        RunGUIFunctionality();//must be called outside of the below if statement
        
        if(base.NewCandleCame())
        {
                DetermineSignal();//this can be called outside of if statement
                tradeSystem.DetermineCandleType();
                
                if(PositionsTotal()>0)
                        tradeSystem.TradeIfSignalStands();
                
        }
        
}

        void DetermineSignal()
        {
        //you should write ur strategy of finding signal here. if u found a signal u should set reliablity in ur signals and also should set microlots in tradesystem.
        //this is a ONE TIME FUNCTION and its only called inside RunMainStrategy
        }

        void RunGUIFunctionality()
        {
        //here you write Functionality of your GUI
        //this is a ONE TIME FUNCTION and its only called inside RunMainStrategy
        }

void CreateGUI()// this function declares all GUI elements
{
//I Declare GUI Objects Here and THEN draw GUI
//this is a ONE TIME FUNCTION and its only called inside OnInit
        GUIH.DrawGUI();
}