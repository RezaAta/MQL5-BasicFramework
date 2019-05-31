
class BollingerBands
  {
private:

public:
        double MiddleBandArray[];
        double UpperBandArray[];
        double LowerBandArray[];
        int BollingerBandsDefinition;
        int RSIDefinition;
        
        BollingerBands();
        ~BollingerBands();
        void InitializeBands();
        void UpdateBands();
    
  };

BollingerBands::BollingerBands()
  {
  }

BollingerBands::~BollingerBands()
  {
  }
  
BollingerBands::InitializeBands(void)
{

        ArraySetAsSeries(MiddleBandArray,true);
        ArraySetAsSeries(UpperBandArray,true);
        ArraySetAsSeries(LowerBandArray,true);
        
        UpdateBands();
        
}

BollingerBands::UpdateBands(void)
{
        BollingerBandsDefinition = iBands(_Symbol,_Period,20,0,2,PRICE_CLOSE);
        CopyBuffer(BollingerBandsDefinition,0,0,3,MiddleBandArray);
        CopyBuffer(BollingerBandsDefinition,1,0,3,UpperBandArray);
        CopyBuffer(BollingerBandsDefinition,2,0,3,LowerBandArray);
        
}
        