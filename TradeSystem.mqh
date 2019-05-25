#include "Base.mqh"

#include <Trade\Trade.mqh>
#include <Indicators\Oscilators.mqh>

CTrade trade;
CiMACD cimacd;
extern Base base;

struct TradeSignal
{
        int strategyNumber;//naturally each trade signal is given by a strategy, this parameter defines the number of that strategy. the first index should be 0;
        enum tradeTypes {sell,buy};
        int tradeType;
        double microlots;
        double stopLoss;
        double takeProfit;
};

class TradeSystem
{
public:
        string tradeSignal;
        string lastTradeSignal;
        TradeSignal tradeSignals[];//all signals that are given to trade system
        double test[];
        
        double microLots;
        double buyTradeStopLoss;
        double sellTradeStopLoss;
        int lastOrderType;
        double reliability;
        
        
        TradeSystem();
        
        void Initialize();
        
        void SetStrategyTriggers(int buyStrategies,int sellStrategies);
        
        void StartTradeBasedOnCandleType();
        
        void CloseAllOrders();
        
        void UpdateAllStopLoss(MqlRates& priceData[]);
        
        void TradeIfSignalStands();
        
        void DetermineCandleType();
        
        TradeSignal CreateTradeSignal(int strategyNumber, int tradeType,double microLots,double stopLoss,double takeProfit);// creates trade signals
        string GetTradeSignal(){ return tradeSignal; }
        void ReceiveTradeSignal(TradeSignal & tradeSignal);//give a trade signal to trade system using this array
        
        
        
private:
        string candlesTypes[5];
        string candleType;
        
        bool SignalIsValid();
        
        //These Triggers are used when we have different buy or sell strategies that must be used only once. sometimes some strategies give buy or sell signals more than
        //we need. if i want to be more accurate, some strategies keep giving signals in a certain period, while all you need is just one buy signal. so if we use these
        //boolean triggers, then we can manage our repeatative signals properly. for each strategy that u have, there should be a trigger.
        int numberOfBuyStrategies;//this parameters can be set by user.
        int numberOfSellStrategies;//this parameters can be set by user.
        bool buyStrategiesTriggers[];//an array for buy triggers
        bool sellStrategiesTriggers[];//an array for sell triggers
        
        bool BS1Trigger;
        bool SS1Trigger;
        bool stopLossUpdateTrigger;
        
        void InitializeStrategyTriggers();
        void TradeBySignal(TradeSignal &tradeSignal);//starts trading by signals that are given by strategies. returns a 
        void UpdateTriggers();
        void HedgeAllPositions();
        
  };

TradeSystem::TradeSystem()
  {
  }

TradeSystem::Initialize(void)
{
        for(int i=0;i<ArraySize(candlesTypes);i++)
                candlesTypes[i]=NULL;
                
        reliability=0;
        
        InitializeStrategyTriggers();
        //ArrayResize(tradeSignals,1);
        //tradeSignals[0] = CreateTradeSignal(0,buy,0,0,0);
        
        
        numberOfBuyStrategies = 1;
        numberOfSellStrategies = 1;
        
        ArrayResize(buyStrategiesTriggers,numberOfBuyStrategies);
        buyStrategiesTriggers[0] = false;
        ArrayResize(sellStrategiesTriggers,numberOfSellStrategies);
        sellStrategiesTriggers[0] = false;
}

TradeSystem::SetStrategyTriggers(int numberOfBuyStrategies,int numberOfSellStrategies)
{
        this.numberOfBuyStrategies = numberOfBuyStrategies;
        ArrayResize(buyStrategiesTriggers,this.numberOfBuyStrategies);
        ArrayFill(buyStrategiesTriggers,0,ArraySize(buyStrategiesTriggers),false);
        
        this.numberOfSellStrategies = numberOfSellStrategies;
        ArrayResize(sellStrategiesTriggers,this.numberOfSellStrategies);
        ArrayFill(sellStrategiesTriggers,0,ArraySize(sellStrategiesTriggers),false);
}

TradeSignal TradeSystem::CreateTradeSignal(int strategyNumber, int tradeType,double microLots,double stopLoss = NULL,double takeProfit = NULL)
{
        TradeSignal TS;
        TS.strategyNumber = strategyNumber;
        TS.tradeType = tradeType; 
        TS.microlots = microLots;
        TS.stopLoss = stopLoss;
        TS.takeProfit = takeProfit;
        
        return TS;
}

TradeSystem::InitializeStrategyTriggers(void)
{
        ArrayInitialize(this.buyStrategiesTriggers,false);
        ArrayInitialize(this.sellStrategiesTriggers,false);
}

TradeSystem::StartTradeBasedOnCandleType(void)
{
        
        buyTradeStopLoss=NormalizeDouble(base.ask-100*_Point,_Digits);//why the hell did i declare this?
        
        lastTradeSignal = tradeSignal;
        //reliablity = 0.2;
        //microLots = base.accountBallance*reliability/base.ask/1000;
        //microLots = MathFloor(tradeSystem.microLots*100)/100;
        //microLots = 0.05;
        
        //tradeAllSignals
        for(int i=0;i<ArraySize(tradeSignals);i++)
                TradeBySignal(tradeSignals[i]);        

        if(PositionsTotal()==0)
        {
                for(int i=0;i<ArraySize(candlesTypes);i++)
                        candlesTypes[i]=NULL;
        }
        
        lastTradeSignal = GetTradeSignal();
        UpdateAllStopLoss(base.priceData);
        ArrayFree(tradeSignals);
        UpdateTriggers();
}

        TradeSystem::TradeBySignal(TradeSignal &tradeSignal )
        {
                bool BuyStrategyIsNotInUseAlready = (tradeSignal.tradeType == buy && buyStrategiesTriggers[tradeSignal.strategyNumber] == false);//this determines signal Type and ensures it isnt in use right now
                if(BuyStrategyIsNotInUseAlready)
                {
                        buyStrategiesTriggers[tradeSignal.strategyNumber] = true;
                        lastOrderType= buy;
                        trade.Buy(tradeSignal.microlots,NULL,base.ask,(tradeSignal.stopLoss),(tradeSignal.takeProfit),"BuyOrder,Strategy " + IntegerToString(tradeSignal.strategyNumber));
                }
                
                bool SellStrategyIsNotInUseAlready = (tradeSignal.tradeType == sell && sellStrategiesTriggers[tradeSignal.strategyNumber] == false);
                if(SellStrategyIsNotInUseAlready)
                {
                        sellStrategiesTriggers[tradeSignal.strategyNumber] = true;
                        lastOrderType= sell;
                        trade.Sell(tradeSignal.microlots,NULL,base.bid,(tradeSignal.stopLoss),(tradeSignal.takeProfit),"SellOrder,Strategy " + IntegerToString(tradeSignal.strategyNumber));
                }
        }
        
        TradeSystem::UpdateTriggers(void)
        {
                
                for(int j=0;j<ArraySize(buyStrategiesTriggers);j++)
                {
                        bool triggerFound = false;
                        for (int i = PositionsTotal()-1; i>=0; i--)
                        {
                                string symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
                        
                                ulong positionTicket = PositionGetInteger(POSITION_TICKET);
                                
                                OrderSelect(positionTicket);
                                
                                if("BuyOrder,Strategy " + j == ORDER_COMMENT)
                                {
                                        triggerFound = true;
                                        break;
                                }
                                
                        }
                        if(!triggerFound)
                                buyStrategiesTriggers[j] = false;
                }
                
                for(int j=0;j<ArraySize(sellStrategiesTriggers);j++)
                {
                        bool triggerFound = false;
                        for (int i = PositionsTotal()-1; i>=0; i--)
                        {
                                string symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
                        
                                ulong positionTicket = PositionGetInteger(POSITION_TICKET);
                                
                                OrderSelect(positionTicket);
                                
                                if("SellOrder,Strategy " + j == ORDER_COMMENT)
                                {
                                        triggerFound = true;
                                        break;
                                }
                                
                        }
                        if(!triggerFound)
                                sellStrategiesTriggers[j] = false;
                }
                
        }

        TradeSystem::CloseAllOrders(void)
        {
                int i = PositionsTotal()-1;
                while (i >= 0)
                        if(trade.PositionClose(PositionGetSymbol(i)))i--;
                
                ArrayFill(buyStrategiesTriggers,0,ArraySize(buyStrategiesTriggers),false);
                ArrayFill(sellStrategiesTriggers,0,ArraySize(sellStrategiesTriggers),false);
        }

TradeSystem::UpdateAllStopLoss(MqlRates &priceData[])//a system that creates a trailing stoploss
{
        for (int i = PositionsTotal()-1; i>=0; i--)
        {
                buyTradeStopLoss = NormalizeDouble(base.ask-150*_Point,_Digits);
                sellTradeStopLoss = NormalizeDouble(base.bid+150*_Point,_Digits);
        
                string symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
                
                ulong positionTicket = PositionGetInteger(POSITION_TICKET);
                
                double currentStopLoss = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
                
                //Comment("TYPE:"+POSITION_COMMENT);
                OrderSelect(positionTicket);
                
                //PositionGetInteger(POSITION_TYPE);
                
                //Comment("\nTYPE:"+ORDER_TYPE);
                if(POSITION_TYPE == 0)// enters if order is a buy order
                {
                        if(currentStopLoss == 0 || currentStopLoss<buyTradeStopLoss)
                        {
                                trade.PositionModify(positionTicket,buyTradeStopLoss,trade.RequestTP());
                        }
                }
        
                if(POSITION_TYPE == 1)//enters if order is a sell order
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
                if(lastOrderType == buy)
                       trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
                
                if(lastOrderType == sell)
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
                
                if(eCount==2&&lastOrderType == buy)
                        return false;
                else if(fCount==2&&lastOrderType== sell)
                        return false;
                else
                        return true;
}

TradeSystem::HedgeAllPositions(void)
{
        
}
TradeSystem::ReceiveTradeSignal(TradeSignal &tradeSignal)
{
        ArrayResize(tradeSignals,ArraySize(tradeSignals)+1);
        tradeSignals[ArraySize(tradeSignals)-1] = tradeSignal;
        //tradeSignals[tradeSignal.strategyNumber] = tradeSignal;
}