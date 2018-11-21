#include <C:\Users\Prophet\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Classes\Base.mqh>
#include <C:\Users\Prophet\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Classes\CamarillaLines.mqh>

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
        double buyTradeStopLoss;
        double sellTradeStopLoss;
        
        TradeSystem();
        ~TradeSystem();
        
        void StartTrade();
        
        void UpdateAllStopLoss(MqlRates& priceData[]);
        
        string GetTradeSignal() { return tradeSignal; }      
        
private:
        string symbol;
        ulong positionTicket;
        double currentStopLoss;
        double microLots;
        string lastOrderType;
        
        void SelectAndGetOrderInfo(int i);
        void CloseAllOrders();
  };

TradeSystem::TradeSystem()
  {
  }

TradeSystem::~TradeSystem()
  {
  }

TradeSystem::StartTrade(void)
{
        if(tradeSignal == "sell")
        {
                trade.Sell(microLots,NULL,base.bid,(base.bid+200*_Point),(NULL),"SellOrder");
        }
                 
        if(tradeSignal == "buy")
        {
                trade.Buy(microLots,NULL,base.ask,(base.ask-200*_Point),(NULL),"BuyOrder");
        }
        if(tradeSignal == "closeAll")
        {
                CloseAllOrders();
        }
}

TradeSystem::UpdateAllStopLoss(MqlRates &priceData[])
{
        for (int i = PositionsTotal()-1; i>=0; i--)
        {
                buyTradeStopLoss = NormalizeDouble(base.ask-150*_Point,_Digits);
                sellTradeStopLoss = NormalizeDouble(base.bid+150*_Point,_Digits);
                SelectAndGetOrderInfo(i);
                
                if(lastOrderType == "buy")
                        if(currentStopLoss == 0 || currentStopLoss<buyTradeStopLoss)
                                trade.PositionModify (positionTicket,buyTradeStopLoss,trade.RequestTP());
                                
                if(lastOrderType == "sell")
                        if(currentStopLoss == 0 || currentStopLoss>sellTradeStopLoss)
                                trade.PositionModify(positionTicket,sellTradeStopLoss,trade.RequestTP());
        }
}

TradeSystem::SelectAndGetOrderInfo(int i)
{
        symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
        positionTicket = PositionGetInteger(POSITION_TICKET);
        currentStopLoss = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
        OrderSelect(positionTicket);
}

TradeSystem::CloseAllOrders(void)
{
        int i = PositionsTotal()-1;
        while (i >= 0)
                if(trade.PositionClose(PositionGetSymbol(i)))i--;
}