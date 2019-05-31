class RSI
{
private:

public:
        int RSIDefinition;
        double RSIArray[];
        double currentRSIValue;
        
        RSI();
        ~RSI();
        void Initialize();
        void UpdateInfo();
        
};

RSI::RSI()
{
}

RSI::~RSI()
{
}

RSI::Initialize()
{
        ArraySetAsSeries(RSIArray,true);
}

RSI::UpdateInfo(void)
{
        RSIDefinition = iRSI(_Symbol,_Period,14,PRICE_CLOSE);
        CopyBuffer(RSIDefinition,0,0,3,RSIArray);
        currentRSIValue =NormalizeDouble(RSIArray[0],2);
}