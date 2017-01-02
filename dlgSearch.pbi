DeclareModule Search
  
  Global OkPressed.i
  
  Global SelectedCriteria.s
    
  Declare.s Open()
  
EndDeclareModule

Module Search

Enumeration dlgSearch 300
  #WinSearch
  #btnOk
  #btnCancel
  #txtTitle
  #strTitle
  #cmbType
  #cmbCategory
  #txtType
  #txtCategory
EndEnumeration

  Procedure ShowWindowText()
  
    SetWindowTitle(#WinSearch,"Enter Search Criteria")

    SetGadgetText(#txtTitle,"Title")
    SetGadgetText(#txtType,"Type") 
    SetGadgetText(#txtCategory,"Category") 
    GadgetToolTip(#cmbCategory,"Select Catagory")
    SetGadgetText(#btnOk,"Ok")
    SetGadgetText(#btnCancel,"Cancel")
  
  EndProcedure

  Procedure.s BuildQueryString()
    
    Define Built.i = #False
    Define QueryString.s
    
    QueryString = " WHERE "
    
    ;Title
    If Len(Trim(GetGadgetText(#strTitle))) > 0
      QueryString = QueryString + " CDBTitle LIKE '%" + GetGadgetText(#strTitle) + "%'"
      Built = #True
    EndIf
    
    ;Type
    If GetGadgetItemData(#cmbType,GetGadgetState(#cmbType)) > -1
      If Built = #True
         
        QueryString = QueryString + " AND Type_ID = " + Str(GetGadgetItemData(#cmbType,GetGadgetState(#cmbType)))
 
      Else
         
        QueryString = QueryString + " Type_ID = " + Str(GetGadgetItemData(#cmbType,GetGadgetState(#cmbType)))
        Built = #True
         
      EndIf
    EndIf
    
    ;Category
    If GetGadgetItemData(#cmbCategory,GetGadgetState(#cmbCategory)) > -1
      If Built = #True
         
        QueryString = QueryString + " AND Category_ID = " + Str(GetGadgetItemData(#cmbCategory,GetGadgetState(#cmbCategory)))
 
      Else
         
        QueryString = QueryString + " Category_ID = " + Str(GetGadgetItemData(#cmbCategory,GetGadgetState(#cmbCategory)))
        Built = #True
         
      EndIf
    EndIf
     
    If Built = #True
      QueryString = QueryString
    Else
      QueryString = ""
    EndIf
    
    ProcedureReturn QueryString      
      
  EndProcedure

  Procedure LoadTypes()
  
    Define Criteria.s
    Define iLoop.i = 0
 
    Criteria = "Select * FROM CodeType ORDER BY CDBTitle ASC;"
 
    If DatabaseQuery(App::CodeDB, Criteria)
    
      While NextDatabaseRow(App::CodeDB) ; Loop for each records
      
        AddGadgetItem(#cmbType,iLoop,GetDatabaseString(App::CodeDB, 1))
        SetGadgetItemData(#cmbType, iLoop,GetDatabaseLong(App::CodeDB, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(App::CodeDB)
    
    EndIf
  
  EndProcedure 

  Procedure LoadCategories()
  
    Define Criteria.s
    Define iLoop.i = 0
 
    Criteria = "Select * FROM Category ORDER BY CDBTitle ASC;"
 
    If DatabaseQuery(App::CodeDB, Criteria)
    
      While NextDatabaseRow(App::CodeDB) ; Loop for each records
      
        AddGadgetItem(#cmbCategory,iLoop,GetDatabaseString(App::CodeDB, 1))
        SetGadgetItemData(#cmbCategory, iLoop,GetDatabaseLong(App::CodeDB, 0))
        iLoop = iLoop + 1
        
      Wend
  
      FinishDatabaseQuery(App::CodeDB)
    
    EndIf
  
  EndProcedure 

  Procedure.s Open()
  
    Define RetString.s
   
    OpenWindow(#WinSearch, 0, 0, 460, 110, "", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)

    TextGadget(#txtTitle, 10, 10, 70, 20, "")
    StringGadget(#strTitle, 90, 10, 300, 20, "")
    TextGadget(#txtType, 10, 45, 60, 20, "") 
    ComboBoxGadget(#cmbType, 80, 40, 140, 20)
    TextGadget(#txtCategory, 230, 45, 60, 20, "") 
    ComboBoxGadget(#cmbCategory, 300, 40, 140, 20)
    GadgetToolTip(#cmbCategory, "")
    ButtonGadget(#btnOk, 300, 70, 70, 30, "")
    ButtonGadget(#btnCancel, 380, 70, 70, 30, "")
    StickyWindow(#WinSearch,#True)
    
    ShowWindowText()
    
    LoadTypes()
    LoadCategories()  
  
    Repeat
    
      Event = WaitWindowEvent()
      Select Event
        Case #PB_Event_CloseWindow
          CloseWindow(#WinSearch)
          Break

        Case #PB_Event_Gadget
          Select EventGadget()
          
            Case   #btnOk
              RetString = BuildQueryString()
              CloseWindow(#WinSearch)
              Break
            Case   #btnCancel
              CloseWindow(#WinSearch)       
              Break
          
          EndSelect ;EventGadget()
          
      EndSelect ;Event
    ForEver

    ProcedureReturn RetString

  EndProcedure

EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 83
; FirstLine = 8
; Folding = D+
; EnableXP