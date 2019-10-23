struct GUIElement
{
        string name;
        string label;
        uint objType;
        color BGColor;
        uint scaleLevel;
        uint x;
        uint y;
};

enum OBJTYPE
{

};

enum SCALELEVEL
{
        VERY_SMALL,SMALL,NORMAL,LARGE,VERY_LARGE
};

class GUIHandler
{
        public:
                uint normalButtonWidth;
                uint normalButtonHeight;
                uint smallButtonWidth;
                uint smallButtonHeight;
                uint verySmallButtonWidth;
                uint verySmallButtonHeight;
                uint largeButtonWidth;
                uint largeButtonHeight;
                uint veryLargeButtonWidth;
                uint veryLargeButtonHeight;
                
                
                ulong horizontalSpaceBetweenElements;
                ulong verticalSpaceBetweenElements;
                ulong horizontalMargine;
                ulong verticalMargine;
                
                uint normalFont;
                uint smallFont;
                uint verySmallFont;
                uint largeFont;
                uint veryLargeFont;
                
                float sizeMultiplier;//golden number is the default value which is equal to 1.6
                
                ulong chartHeight;
                ulong chartWidth;
                
                
                
                //FUNCTIONS---------------
                void DrawGUI(void);
                void AddObject(string, string, uint,color, uint, uint, uint);
                void CheckAllElements(void);
                
                
                //setters
                void SetNumberOfGUIElements(uint);
                void SetNormalButtonWidth(uint);
//                void SetNormalButtonHeight(uint); no need
                void UpdateChartDimensions();
                
                GUIHandler(int);

        private:
                uint numberOfElements;
                

                
                
                GUIElement GUIElements[];
                
                void InitializeWidthAndHeight();
                void SortGUIElementsMatris(void);
                void DrawElement(GUIElement &);

};

GUIHandler::GUIHandler(int numberOfElements = 0)
{
        sizeMultiplier = 1.6;
        SetNumberOfGUIElements(numberOfElements);
        
        UpdateChartDimensions();
        
        horizontalSpaceBetweenElements = chartWidth/32;
        verticalSpaceBetweenElements = chartHeight/32;
        horizontalMargine = chartWidth/16;
        verticalMargine = chartHeight/16;
        
        InitializeWidthAndHeight();
        
}

        void GUIHandler::SetNumberOfGUIElements(uint numberOfElements)
        {
                this.numberOfElements = numberOfElements;
                ArrayResize(GUIElements,numberOfElements);
                
        //        for(int i=0;i<numberOfElements;i++)
        //        {
        //                string subArrayName = "SA" + IntegerToString(numberOfElements);
        //                GUIElement subArrayName [numberOfElements];
        //                ArrayInsert()
        //                
        //                ArrayResize(GUIElements)
        //        }
        }

        void GUIHandler::UpdateChartDimensions(void)
        {
                this.chartHeight = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
                this.chartWidth = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
        }

void GUIHandler::DrawGUI(void)
{
        UpdateChartDimensions();
        SortGUIElementsMatris();
        InitializeWidthAndHeight();
        
        for(int i=0;i<ArraySize(GUIElements);i++)
                DrawElement(GUIElements[i]);
}
        void GUIHandler::DrawElement(GUIElement & E)
        {
        
                if(E.objType == OBJ_BUTTON)
                        ObjectCreate(_Symbol,E.name,OBJ_BUTTON,0,0,0);
                
                else if(E.objType == OBJ_LABEL)
                {
                        ObjectCreate(_Symbol,E.name,OBJ_LABEL,0,0,0);
                        ObjectSetInteger(_Symbol,E.name,OBJPROP_COLOR,E.BGColor);
                }        
                else if(E.objType == OBJ_EDIT)
                {
                        ObjectCreate(_Symbol,E.name,OBJ_EDIT,0,0,0);
                }
                if(E.objType != OBJ_EDIT)
                        ObjectSetString(_Symbol,E.name,OBJPROP_TEXT,E.label);
                        
                ObjectSetInteger(_Symbol,E.name,OBJPROP_XDISTANCE,E.x);
                ObjectSetInteger(_Symbol,E.name,OBJPROP_YDISTANCE,E.y);
                ObjectSetInteger(_Symbol,E.name,OBJPROP_BGCOLOR,E.BGColor);
                ObjectSetInteger(_Symbol,E.name,OBJPROP_BORDER_COLOR,clrWhite);
                
                
                
                if(E.scaleLevel == VERY_SMALL)
                        {
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_XSIZE,verySmallButtonWidth);//TO DO---- DEFINE MORE WIDTH AND HEIGHTS!
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_YSIZE,verySmallButtonHeight);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_FONTSIZE,verySmallFont);
                        }
                        else if(E.scaleLevel == SMALL)
                        {
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_XSIZE,smallButtonWidth);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_YSIZE,smallButtonHeight);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_FONTSIZE,smallFont);
                        }
                        else if(E.scaleLevel == NORMAL)
                        {
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_XSIZE,normalButtonWidth);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_YSIZE,normalButtonHeight);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_FONTSIZE,normalFont);
                        }
                        else if(E.scaleLevel == LARGE)
                        {
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_XSIZE,largeButtonWidth);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_YSIZE,largeButtonHeight);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_FONTSIZE,largeFont);
                        }
                        else if(E.scaleLevel == VERY_LARGE)
                        {
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_XSIZE,veryLargeButtonWidth);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_YSIZE,veryLargeButtonHeight);
                                ObjectSetInteger(_Symbol,E.name,OBJPROP_FONTSIZE,veryLargeFont);
                        }
//                if(condition)
//                {
//                
//                }
        }

void GUIHandler::CheckAllElements(void)// i think this is not necessary...
{
        //for(int i=0;i<ArraySize(GUIElements);i++)
        //{
        //       if(GUIElements[i].name == "Buy"
        //       &&ObjectGetInteger(_Symbol,GUIElements[i].name,OBJPROP_STATE) == 1)
        //       {
        //                double manualLotSize = 
        //       }
        //}

}

void GUIHandler::AddObject(string name,string label,uint objType,color BGColor,uint scaleLevel, uint x, uint y)
{
        GUIElement E;
        E.name = name;
        E.label = label;
        E.objType = objType;
        E.BGColor = BGColor;
        E.scaleLevel = scaleLevel;
        E.x = x;
        E.y = y;
        
        ArrayResize(GUIElements,ArraySize(GUIElements)+1);
        GUIElements[ArraySize(GUIElements)-1] = E;
        
        SortGUIElementsMatris();
        //WAAARNIING: i dont know if the E is passed by reference or cloned into the array... if it gets passed by ref then there would be issues.
}



void GUIHandler::InitializeWidthAndHeight(void)
{
//simple calculations for scaling sizes based on normal size and sizeMultiplier.

        normalButtonWidth = chartWidth/10;//this initial size can be modified thorough its set function.
        normalButtonHeight = normalButtonWidth/sizeMultiplier;
        
        smallButtonWidth = normalButtonHeight;
        smallButtonHeight = smallButtonWidth/sizeMultiplier;
        verySmallButtonWidth = smallButtonHeight;
        verySmallButtonHeight = verySmallButtonWidth/sizeMultiplier;
        
        largeButtonWidth = largeButtonHeight*sizeMultiplier;
        largeButtonHeight = normalButtonWidth;
        veryLargeButtonWidth = veryLargeButtonHeight* sizeMultiplier;
        veryLargeButtonHeight = largeButtonWidth;
        
        normalFont = 24;
        smallFont = normalFont/sizeMultiplier;
        verySmallFont = smallFont / sizeMultiplier;
        largeFont = normalFont * sizeMultiplier;
        veryLargeFont = normalFont * sizeMultiplier;

}

void GUIHandler::SortGUIElementsMatris(void)
{
        
}

