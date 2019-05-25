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
                unsigned int numberOfPriceCandles;
                
                int candleCounter;
                
                //FUNCTIONS---------------
                Base();
                ~Base();
                
                void Initialize();//in case u needed anything to run only on initialization of program.
                
                void UpdateAccountInfo();
                
                bool NewCandleCame();
                
                void SetNumberOfPriceCandles(int n);
                
        private:
                datetime timeStampCurrentCandle;
                datetime timeStampLastChecked;
                
                void GetPrices();
                void ResetCounter();

  };
  
Base::Base()
{
        numberOfPriceCandles = 30;
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
                CopyRates(Symbol(),Period(),0,numberOfPriceCandles,priceData);
        }


Base::ResetCounter(void)
{
        timeStampLastChecked = 0;
        candleCounter = 0;
}

Base::Initialize(void)
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
                return(true);
        }
        return (false);
}

void Base::SetNumberOfPriceCandles(int n)
{
        this.numberOfPriceCandles = n; 
}