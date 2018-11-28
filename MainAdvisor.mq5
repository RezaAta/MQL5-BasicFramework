#include <C:\Users\Prophet\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Classes\BasicFramework\Base.mqh>
#include <C:\Users\Prophet\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Classes\BasicFramework\TradeSystem.mqh>

Base base = new Base();
TradeSystem tradeSystem = new TradeSystem();

void OnInit()
{
        //camarillaLines.initializeCamarilla();
        base.Initialize();
        tradeSystem.Initialize();
}

void OnTick()
  {
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
}