struct Cell
//each cell represents a container of equity. when we make orders, we dont give amount of microlots, we give a number indicating how many cells we are going to use in trade.
//the reasons behind this action are these: we now can easily have an understanding of our account situation. also we can use cells in concepts of machine learning later.
{
        double amount;//the amount of equity each cell has. the formula for obtaining this is: baseAmountOfCells +  (percentageOfProfitOfPosition * baseAmountOfCells)
        int associatedPositionTicket;
        bool isGrowing;//default value is true.
        bool isExpandable;
};

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
                
                int numberOfGrowingCells;//represents the number of cells that we are getting profit from
                int numberOfInActiveCells;//represents the number of possible cells to invest. this amount gets updated when a new order is made.
                
                //FUNCTIONS---------------
                Base();
                ~Base();
                
                void Initialize();//in case u needed anything to run only on initialization of program.
                
                void UpdateAccountInfo();
                
                bool NewCandleCame();
                
                void SetNumberOfPriceCandles(int n);
                
                //Cell AccessCell(int x){return this.allCells[x]; }
                
                void UpdateCellsStatus();//Updates number Of GrowingCells And Active Cells Properties. this function can be called after candles(this is better) or on ticks.
                void SetBaseCellAmount(double BA){allCellBaseAmount = BA;}
                
                void CreateNewCells();
                
        private:
                datetime timeStampCurrentCandle;
                datetime timeStampLastChecked;
                
                double allCellBaseAmount;
                Cell allCells[];//represents an arraylist of all current active cells.
                //there is no such thing as inactive cell, there is no need to. but we need to know how many candles we can invest.
                
                
                void GetPrices();
                void ResetCounter();
                
                void ReCalculateCells();

};
  
Base::Base()
{
        numberOfPriceCandles = 30;
}
Base::~Base()
{
}

Base::Initialize(void)
{
        ResetCounter();
        allCellBaseAmount = 100*_Point;
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

void Base::ReCalculateCells(void)
{
        ArrayFree(allCells);
        
        for (int i = PositionsTotal()-1; i>=0; i--)
        {
                string symbol = PositionGetSymbol(i);//gets the positions symbol and selects it as current!
                
                Cell newCell;
                newCell.amount = allCellBaseAmount + allCellBaseAmount * POSITION_PROFIT;
                newCell.associatedPositionTicket = POSITION_TICKET;
                
                newCell.isGrowing = true;//we set the default value as true.
                
                if(newCell.amount >= allCellBaseAmount*2)
                        newCell.isExpandable = true;
                else
                        newCell.isExpandable = false;
                
                ArrayResize(allCells, ArraySize(allCells) + 1);
                allCells[ArraySize(allCells)] = newCell;
        }
}

void Base::UpdateCellsStatus(void)
{
        numberOfGrowingCells = 0;
        numberOfInActiveCells = 0;
        
        bool getNewAmountFlag = false;
        double newAmount;
        bool stillGrowing;
        bool stillExpandable;
        
        for(int i=0;i<ArraySize(allCells);i++)
        {
                if(getNewAmountFlag == false)
                {
                        PositionSelectByTicket(allCells[i].associatedPositionTicket);
                        newAmount = allCellBaseAmount + allCellBaseAmount * POSITION_PROFIT;
                        getNewAmountFlag = true;               
                }
                else if( (ArraySize(allCells) + 1 > i) && (allCells[i].associatedPositionTicket != allCells[i+1].associatedPositionTicket) )
                        getNewAmountFlag = false;
                       
                
                if(newAmount >= allCells[i].amount)
                        stillGrowing = true;
                else
                        stillGrowing = false;
                        
                if(newAmount >= allCellBaseAmount * 2)
                        stillExpandable = true;
                else
                        stillExpandable = false;
                
                numberOfGrowingCells++;
                
                allCells[i].isGrowing = stillGrowing;
                allCells[i].amount = newAmount;
                allCells[i].isExpandable = stillExpandable;        
        }

}

/*
TODO:
i need to create a system that creates Cells based on New Orders. and Each order Should have an individual Set Of cells;
i should modify UpdateCellStatus to Update All cell Sets;
i should ReWrite the trading System and this time i should use Cells instead of microLots;
*/