#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5tutorial.com"
#property version   "1.00"




class Base
{
        public:
                double accountProfit;
                double accountBallance;
                double accountEquity;
                double bid;
                double ask;
                double minTrade;
                MqlRates priceData[];
                
                int candleCounter;
                
                Base();
                ~Base();
                
                void UpdateAccountInfo();

                void initialize();//in case u needed anything to run only on initialization of program.
                
                bool NewCandleCame();
                
        private:
                datetime timeStampCurrentCandle;
                datetime timeStampLastChecked;
                
                void GetPrices();
                void ResetCounter();

  };
  
Base::Base()
  {
  }
Base::~Base()
  {
  }

Base::UpdateAccountInfo(void)
{
        accountProfit = AccountInfoDouble(ACCOUNT_PROFIT);
        accountBallance = AccountInfoDouble(ACCOUNT_BALANCE);
        accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
        
        minTrade = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
        GetPrices();
}


Base::GetPrices(void)
{
        ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
        bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
        ArraySetAsSeries(priceData,true);
}


Base::ResetCounter(void)
{
        timeStampLastChecked = 0;
        candleCounter = 0;
}


Base::initialize(void)
{
        ResetCounter();
}


bool Base::NewCandleCame(void)
{
        timeStampCurrentCandle = priceData[0].time;
        if(timeStampCurrentCandle!=timeStampLastChecked)
        {
                timeStampLastChecked = timeStampCurrentCandle;
                candleCounter++;
        }
        return (timeStampCurrentCandle!=timeStampLastChecked);
}