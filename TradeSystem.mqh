#include <C:\Users\Prophet\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Classes\BasicFrameWork\Base.mqh>

#include <Trade\Trade.mqh>
#include <Indicators\Oscilators.mqh>

CTrade trade;
CiMACD cimacd;
extern Base base;

class TradeSystem
{  
public:
        string tradeSignal;
        string lastTradeSignal;
        double microLots;
        double buyTradeStopLoss;
        double sellTradeStopLoss;
        string lastOrderType;
        double reliability;
        
        TradeSystem();
        
        void StartTradeBasedOnCandleType();
        
        void CloseAllOrders();
        
        void UpdateAllStopLoss(MqlRates& priceData[]);
        
        void TradeIfSignalStands();
        
        void DetermineCandleType();
        
        string GetTradeSignal(){ return tradeSignal; }
        
        void Initialize();
        
private:
        string candlesTypes[5];
        string candleType;
        
        bool SignalIsValid();
        
        bool S1Trigger;
        bool S2Trigger;
        bool S3Trigger;
        bool S4Trigger;
        bool stopLossUpdateTrigger;
  };

TradeSystem::TradeSystem()
  {
  }

TradeSystem::StartTradeBasedOnCandleType(void)
{
        
        buyTradeStopLoss=NormalizeDouble(base.ask-100*_Point,_Digits);//why the hell did i declare this?
        
        lastTradeSignal = tradeSignal;
        //reliablity = 0.2;
        //microLots = base.accountBallance*reliability/base.ask/1000;
        //microLots = MathFloor(tradeSystem.microLots*100)/100;
        microLots = 0.05;
        
        if(tradeSignal == "sell")
        {
                S1Trigger = false;
                S2Trigger = false;
                S3Trigger = false;
                S4Trigger = false;
                stopLossUpdateTrigger = false;
                CloseAllOrders();
        }
        
        if(tradeSignal == "buyS1"
        && S1Trigger == false
        )
        {
                S1Trigger = true;
                lastOrderType="buy";
                trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
        }
        if(tradeSignal == "buyS2"
        && S2Trigger == false
        )
        {
                S2Trigger = true;
                lastOrderType="buy";       
                trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
        }
        if(tradeSignal == "buyS3"
        && S3Trigger == false
        )
        {
                S3Trigger = true;
                lastOrderType="buy";
                trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
        }
        if(tradeSignal == "buy"
        && S4Trigger == false
        )
        {
                S4Trigger = true;
                lastOrderType="buy";
                trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
        }
        if(PositionsTotal()==0)
        {
                for(int i=0;i<ArraySize(candlesTypes);i++)
                        candlesTypes[i]=NULL;
        }
        
        lastTradeSignal = GetTradeSignal();
        UpdateAllStopLoss(base.priceData);
}

        TradeSystem::CloseAllOrders(void)
        {
                int i = PositionsTotal()-1;
                while (i >= 0)
                        if(trade.PositionClose(PositionGetSymbol(i)))i--;
        }

TradeSystem::UpdateAllStopLoss(MqlRates &priceData[])
{
        for (int i = PositionsTotal()-1; i>=0; i--)
        {
                buyTradeStopLoss = NormalizeDouble(base.ask-150*_Point,_Digits);
                sellTradeStopLoss = NormalizeDouble(base.bid+150*_Point,_Digits);
        
                string symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
                
                ulong positionTicket = PositionGetInteger(POSITION_TICKET);
                
                double currentStopLoss = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
                
                OrderSelect(positionTicket);
        
                if(lastOrderType == "buy")
                {
                        if(currentStopLoss == 0 || currentStopLoss<buyTradeStopLoss)
                        {
                                trade.PositionModify(positionTicket,buyTradeStopLoss,trade.RequestTP());
                        }
                }
        
                if(lastOrderType == "sell")
                {
                        if(currentStopLoss == 0 || currentStopLoss>sellTradeStopLoss)
                        {
                                trade.PositionModify(positionTicket,sellTradeStopLoss,trade.RequestTP());
                        }
                }
        }
}

TradeSystem::TradeIfSignalStands(void)
{
               
        
        if(SignalIsValid())
        {
                if(lastOrderType == "buy")
                       trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
                
                if(lastOrderType == "sell")
                       trade.Sell(microLots,NULL,base.bid,(base.bid+200*_Point),(NULL),"BuyOrder");
        }
        else if(!SignalIsValid())
                CloseAllOrders();
}

        TradeSystem::DetermineCandleType(void)        
                {
                        if(base.priceData[1].close > base.priceData[1].open)
                                candleType = "Full";
                        else
                                candleType = "Empty";
                        
                        for (int i = ArraySize(candlesTypes)-2; i >= 0; i--)
                        {
                                candlesTypes[i+1] = candlesTypes[i];
                        }
                        
                        candlesTypes[0] = candleType;
                }

        bool TradeSystem::SignalIsValid(void)
        {
                int fCount = 0;
                int eCount = 0;
                
                for(int i=ArraySize(candlesTypes)-3; i>=0;i--)
                {
                        if(candlesTypes[i]=="Full")
                                fCount++;
                        else if(candlesTypes[i]=="Empty")
                                eCount++;
                }
                
                if(eCount==2&&lastOrderType=="buy")
                        return false;
                else if(fCount==2&&lastOrderType=="sell")
                        return false;
                else
                        return true;
}

TradeSystem::Initialize(void)
{
        for(int i=0;i<ArraySize(candlesTypes);i++)
                candlesTypes[i]=NULL;
                
        reliability=0;
}
