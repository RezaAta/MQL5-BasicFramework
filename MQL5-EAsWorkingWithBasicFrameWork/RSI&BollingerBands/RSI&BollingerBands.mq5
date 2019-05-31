#include "C:\Users\rezaa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\MyProjects\MQL5-BasicFramework-master\Base.mqh"
#include "C:\Users\rezaa\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\MyProjects\MQL5-BasicFramework-master\TradeSystem.mqh"
#include "BollingerBands.mqh"
#include "RSI.mqh"

Base base = new Base();
TradeSystem tradeSystem = new TradeSystem();
BollingerBands bollingerBands = new BollingerBands();
RSI RSIIndicator = new RSI();

int OnInit()
{
        base.Initialize();
        tradeSystem.Initialize();
        tradeSystem.SetStrategyTriggers(1,1);
        tradeSystem.SetOptimizationSettings(true,true,true);
        bollingerBands.InitializeBands();
        RSIIndicator.Initialize();
        return(INIT_SUCCEEDED);
}

void OnTick()
{
        base.UpdateAccountInfo();
        bollingerBands.UpdateBands();
        RSIIndicator.UpdateInfo();
        
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
                base.UpdateCellsStatus();
                DetermineSignal();//this can be called outside of if statement
                tradeSystem.DetermineCandleType();
                
                tradeSystem.OptimizeTrades();
                
                //if(PositionsTotal()>0)
                //        tradeSystem.TradeIfSignalStands();
        }
        
}

void DetermineSignal()
{
        double microLotsforStrategy1 = 1;
        
        if((base.priceData[1].close < bollingerBands.LowerBandArray[1])&&(base.priceData[0].close>bollingerBands.LowerBandArray[0])&&(RSIIndicator.RSIArray[0]<30))//buy strategy
        {
                TradeSignal S1BSignal = tradeSystem.CreateTradeSignal(0,buy,microLotsforStrategy1,base.ask-200*_Point,base.ask+500*_Point);
                tradeSystem.ReceiveTradeSignal(S1BSignal);
        }
                
        if((base.priceData[1].close > bollingerBands.UpperBandArray[1])&&(base.priceData[0].close<bollingerBands.UpperBandArray[0])&&(RSIIndicator.RSIArray[0]>70))//sell strategy
        {
                TradeSignal S1SSignal = tradeSystem.CreateTradeSignal(0,sell,microLotsforStrategy1,base.bid+200*_Point,base.bid-500*_Point);
                tradeSystem.ReceiveTradeSignal(S1SSignal);
        }

//        double microLotsforStrategy2 = 1;
//        
//        bool RSICrossedFromBelow = (RSIIndicator.RSIArray[0]>30 && RSIIndicator.RSIArray[1]<30);
//        bool RSICrossedFromTop = (RSIIndicator.RSIArray[0]<70 && RSIIndicator.RSIArray[1]>70);
//        
//        if(RSICrossedFromBelow)
//        {
//                TradeSignal S2BSignal = tradeSystem.CreateTradeSignal(0,buy,microLotsforStrategy2,base.ask-200*_Point);
//                tradeSystem.ReceiveTradeSignal(S2BSignal);
//        }
//        if(RSICrossedFromTop)
//        {
//                TradeSignal S2SSignal = tradeSystem.CreateTradeSignal(0,sell,microLotsforStrategy2,base.bid+200*_Point);
//                tradeSystem.ReceiveTradeSignal(S2SSignal);
//        }
        
}

void OnTrade()
{
   
}