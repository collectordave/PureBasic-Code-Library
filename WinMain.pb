EnableExplicit

;Using Statements
UsePNGImageDecoder()
UseSQLiteDatabase()

;-Include Files
IncludeFile "App.pbi"
IncludeFile "DCTool.pbi"
IncludeFile "dlgSearch.pbi"
IncludeFile "dlgAddEditApplication.pbi"
IncludeFile "dlgAddEditCustomGadget.pbi"
IncludeFile "dlgAddEditExample.pbi"
IncludeFile "dlgAddEditModule.pbi"
IncludeFile "dlgAddEditProcedure.pbi"
IncludeFile "dlgPreferences.pbi"

;Get Applcation variables
App::ReadPreferences("CodeDB")

If Not App::FileExists(GetCurrentDirectory() + "CodeDB.INI")
  App::Title  = "Code Organiser"
  App::Writepreferences("CodeDB") 
EndIf
APP::ReadPreferences("CodeDB")

;Select Language For This Programme If Not set
;If App::Language = ""
;  Locale::AppLanguage = "English" ;Default
;  Locale::Initialise()
;  Locale::SelectLanguage()
;  App::Language = Locale::AppLanguage
;  App::Writepreferences("CodeDB")  
;Else
;  Locale::AppLanguage = App::Language
;EndIf

;Ready For Multiligual
;Locale::Initialise()




;-Enumerations
Enumeration FormWindow
  #WinMain
EndEnumeration

Enumeration FormGadget
  #IconBar
  #txtTitle
  #strTitle
  #txtType
  #strType
  #txtDescription
  #edtComments
  #btnFirst
  #imgFirst
  #btnPrevious
  #imgPrevious
  #txtStatus
  #btnNext
  #imgNext
  #btnLast
  #imgLast
  #imgAdd
  #imgSearch
  #imgUpdate
  #imgDelete
  #imgExit
  #imgHelp
EndEnumeration

Enumeration FormMenu
  #MnuAddApplication
  #MnuAddCustomGadget
  #MnuAddExample
  #MnuAddModule
  #MnuAddProcedure
  #MnuSearch
  #MnuUpDate
  #MnuDelete
  #MnuPreferences
  #MnuExit
EndEnumeration

Global IconBar.i,TotalRows.i,CurrentRow.i,CodeTypeID.i,CodeID.i
Global QueryString.s

Define Event.i

;-
;- Fetch Images
;-
CatchImage(#imgFirst,?FirstProc)
CatchImage(#imgPrevious,?PreviousProc)
CatchImage(#imgNext,?NextProc)
CatchImage(#imgLast,?LastProc)
;CatchImage(#imgNew,?ToolBarNew)
CatchImage(#imgSearch,?ToolBarGet)
CatchImage(#imgUpdate,?ToolBarEdit)
CatchImage(#imgDelete,?ToolBarDelete)
CatchImage(#imgExit,?ToolBarExit)
CatchImage(#imgHelp,?ToolBarHelp)

;Open The Code Database
App::CodeDB = App::Open_Database(GetCurrentDirectory() + "Code\CodeLib.db")

Procedure ShowWindowText()
  
  SetWindowTitle(#WinMain,"Code Manager")
  SetIconBarGadgetItemText(IconBar, "Search", 0,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar, "UpDate", 1,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar, "Delete", 2,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar, "Exit", 3,#IconBarText_ToolTip)
  SetIconBarGadgetItemText(IconBar, "Help", 4,#IconBarText_ToolTip)
  SetGadgetText(#txtTitle,"Title")
  SetGadgetText(#txtType,"Type")
  SetGadgetText(#txtDescription,"Description")
  
EndProcedure

Procedure BuildMenu()
  
  CreateMenu(0, WindowID(#WinMain))
  MenuTitle("Code")
    OpenSubMenu("Add")
      MenuItem(#MnuAddApplication, "Application")
      MenuItem(#MnuAddCustomGadget, "Custom Gadget")
      MenuItem(#MnuAddExample, "Example")
      MenuItem(#MnuAddModule, "Module")  
      MenuItem(#MnuAddProcedure, "Procedure")
    CloseSubMenu()
    MenuItem(#MnuSearch, "Search")
    MenuItem(#MnuUpDate, "UpDate")
    MenuItem(#MnuDelete, "Delete")
    MenuBar()
    MenuItem(#MnuPreferences,"Preferences")
    MenuBar() 
    MenuItem(#MnuExit, "Exit")
  
EndProcedure

Procedure GetTotalRecords()
  
  Define SearchString.s
  
  ;Find out how many records will be returned
  TotalRows = 0
  SearchString = "SELECT * FROM Code " + QueryString
  
  If DatabaseQuery(App::CodeDB, SearchString)
    
    While NextDatabaseRow(App::CodeDB)

      TotalRows = TotalRows + 1
      
    Wend
    
    FinishDatabaseQuery(App::CodeDB)  
    
  EndIf

    FinishDatabaseQuery(App::CodeDB)

  
EndProcedure

Procedure CheckRecords()
 
  ;Sort out the navigation buttons
  If TotalRows < 2
    
    ;Only one record so it is the first and the last
    DisableGadget(#btnLast, #True)     ;No move last as allready there
    DisableGadget(#btnNext, #True)     ;No next record as this is the last record
    DisableGadget(#btnFirst, #True)    ;No first record as this is the first record
    DisableGadget(#btnPrevious, #True) ;No previous record as this is the first record
    
  ElseIf CurrentRow = 1
    ;On the first row with more than one selected
    DisableGadget(#btnLast, 0)     ;Can move to last record
    DisableGadget(#btnNext, 0)     ;Can move to next record
    DisableGadget(#btnFirst, #True)    ;No first record as this is the first record
    DisableGadget(#btnPrevious, #True) ;No previous record as this is the first record
    
  ElseIf  CurrentRow = TotalRows
    
    ;If on the last record
    DisableGadget(#btnLast, #True)     ;No move last as allready there
    DisableGadget(#btnNext, #True)     ;No next record as this is the last record
    DisableGadget(#btnFirst, 0)    ;Can still move to first record
    DisableGadget(#btnPrevious, 0) ;Can still move to previous record
    
  Else
    
    ;Somewhere in the middle of the selected records
    DisableGadget(#btnLast, 0)     ;Can move to last record
    DisableGadget(#btnNext, 0)     ;Can move to next record
    DisableGadget(#btnFirst, 0)    ;Can move to first record
    DisableGadget(#btnPrevious, 0) ;Can move to previous record
    
  EndIf

  ;Show the user what is going on
  If TotalRows > 0
    DisableMenuItem(0, #MnuUpDate,#False)
    DisableMenuItem(0, #MnuDelete,#False)
    DisableIconBarGadgetItem(IconBar,1, #False)
    DisableIconBarGadgetItem(IconBar,2, #False)   
    SetGadgetText(#txtStatus,"Record" + Str(CurrentRow) + " Of " + Str(TotalRows) + " Selected")
  Else
    DisableMenuItem(0, #MnuUpDate,#True)
    DisableMenuItem(0, #MnuDelete,#True)
    DisableIconBarGadgetItem(IconBar,1, #True)
    DisableIconBarGadgetItem(IconBar,2, #True)    
    SetGadgetText(#txtStatus,"Record" + " 0 Of 0 " + " Selected") 
  EndIf

EndProcedure

Procedure DisplayRecord()
  
  Define SearchString.s
  SearchString = "SELECT * FROM Code " + QueryString + " LIMIT 1 OFFSET " + Str(CurrentRow -1)

  DatabaseQuery(App::CodeDB, SearchString)

  If FirstDatabaseRow(App::CodeDB)

    SetGadgetText(#strTitle, GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBTitle")))
    SetGadgetText(#edtComments, GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBComment")))    
    App::CodeID = GetDatabaseLong(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"Code_ID"))
    CodeTypeID = GetDatabaseLong(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"Type_ID"))
    FinishDatabaseQuery(App::CodeDB)
    
    
    SearchString = "SELECT CDBTitle FROM CodeType WHERE Type_ID = " + Str(CodeTypeID)
    DatabaseQuery(App::CodeDB, SearchString)

    If FirstDatabaseRow(App::CodeDB) 
      SetGadgetText(#strType, GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBTitle")))
      FinishDatabaseQuery(App::CodeDB) 
    EndIf
   
  EndIf 
  
EndProcedure


;-
;- Open Window
;-
OpenWindow(#WinMain, 5, 5, 860, 343, "", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)
BuildMenu()
IconBar = IconBarGadget(0, 0, WindowWidth(#WinMain),20,#IconBar_Default,#WinMain) 
AddIconBarGadgetItem(IconBar, "", #imgSearch)
AddIconBarGadgetItem(IconBar, "", #imgUpdate)
AddIconBarGadgetItem(IconBar, "", #imgDelete) 
IconBarGadgetDivider(IconBar)
AddIconBarGadgetItem(IconBar, "", #imgExit)
IconBarGadgetSpacer(IconBar)
AddIconBarGadgetItem(IconBar, "", #imgHelp)
ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
SetIconBarGadgetColor(IconBar, 1, RGB(176,224,230)) 
DisableMenuItem(0, #MnuUpDate,#True)
DisableMenuItem(0, #MnuDelete,#True)
DisableIconBarGadgetItem(IconBar,1, #True)
DisableIconBarGadgetItem(IconBar,2, #True)
TextGadget(#txtTitle, 10, 55, 60, 20, "",#PB_Text_Right)
StringGadget(#strTitle, 80, 50, 300, 20, "",#PB_String_ReadOnly)
SetGadgetColor(#strTitle, #PB_Gadget_BackColor, RGB(255,255,255))
TextGadget(#txtType, 400, 55, 60, 20, "",#PB_Text_Right)
StringGadget(#strType, 470, 50, 300, 20, "",#PB_String_ReadOnly)
SetGadgetColor(#strType, #PB_Gadget_BackColor, RGB(255,255,255))
TextGadget(#txtDescription, 10, 80, 60, 20, "")
EditorGadget(#edtComments, 10, 100, 840, 180,#PB_Editor_ReadOnly)
ButtonImageGadget(#btnFirst, 0, 290, 32, 32, ImageID(#imgFirst))
ButtonImageGadget(#btnPrevious, 32, 290, 32, 32, ImageID(#imgPrevious)) 
ButtonImageGadget(#btnNext, 796, 290, 32, 32, ImageID(#imgNext))
ButtonImageGadget(#btnLast, 828, 290, 32, 32, ImageID(#imgLast))
TextGadget(#txtStatus, 68, 290, 725, 30, "", #PB_Text_Center | #PB_Text_Border)
;SetGadgetFont(#txtStatus, FontID(txtStatusFont))  

;Show The Window Text In Selected Language
ShowWindowText()

;Move Window to top of screen in the middle
ResizeWindow(#WinMain,#PB_Ignore,5,#PB_Ignore,#PB_Ignore)

;Create Folders For Code
App::CheckCreatePath(GetCurrentDirectory() + "Code\Applications")
App::CheckCreatePath(GetCurrentDirectory() + "Code\Custom Gadgets")
App::CheckCreatePath(GetCurrentDirectory() + "Code\Examples")
App::CheckCreatePath(GetCurrentDirectory() + "Code\Modules")

;- Event Loop
CurrentRow = 0
CheckRecords()
Repeat
  
  Event = WaitWindowEvent()
  Select Event
        
    Case #PB_Event_CloseWindow

      End

    Case #PB_Event_Menu
      Select EventMenu()
          
        Case #MnuAddApplication

          AddEditApplication::Open(#False)
        
        Case #MnuAddCustomGadget
          
          AddEditCustomGadget::Open(#False)
          
        Case #MnuAddExample
          
          AddEditExample::Open(#False)
          
        Case #MnuAddModule
          
          AddEditModule::Open(#False)
          
        Case #MnuAddProcedure
          
          AddEditProcedure::Open(#False)
          
        Case #MnuSearch
          
          QueryString = Search::Open()
          CurrentRow = 1
          GetTotalRecords()
          CheckRecords()
          DisplayRecord()
          
        Case #MnuUpDate

          Select  CodeTypeID

            Case 1
              
              AddEditApplication::Open(#True)
              
            Case 2
              Debug "Module false"
              AddEditModule::Open(#True)
              
             Case 3
              
              AddEditCustomGadget::Open(#True)             
              
             Case 4
              
               AddEditExample::Open(#True)             
              
             Case 5
              
               AddEditProcedure::Open(#True)
                
          EndSelect
          
        Case #MnuDelete
          
        Case #MnuPreferences
          
          Preferences::open()
          
        Case #MnuExit

          End
       
      EndSelect;EventMenu()

    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case #btnFirst
          
          CurrentRow = 1
          CheckRecords()
          DisplayRecord()
          
        Case #btnNext
          
          If CurrentRow < TotalRows
            CurrentRow = CurrentRow + 1
            CheckRecords()
            DisplayRecord()
          EndIf
                        
        Case #btnPrevious
          
          If CurrentRow > 1
            CurrentRow = CurrentRow - 1
            CheckRecords()
            DisplayRecord()
          EndIf
          
        Case #btnLast  
          
          CurrentRow = TotalRows
          CheckRecords()
          DisplayRecord()
          
        Case IconBar
          
          Select EventData()              

            Case 0
              
              ;Search
              QueryString = Search::Open()
              CurrentRow = 1
              GetTotalRecords()
              CheckRecords()
              DisplayRecord()
              
            Case 1
              Select  CodeTypeID
          
                Case 1
              
                  AddEditApplication::Open(#True)
              
                Case 2
              Debug "Module true"
                  AddEditModule::Open(#True)
              
                Case 3
              
                  AddEditCustomGadget::Open(#True)             
              
                Case 4
              
                  AddEditExample::Open(#True)             
              
                Case 5
              
                  AddEditProcedure::Open(#True)
                
              EndSelect
              
            Case 2
              
              ;Delete
              
            Case 3
              
              ;Quit
              End
              
            Case 4
              ;Help
              
          EndSelect;EventData()
          
      EndSelect;EventGadget()
      
  EndSelect;Event
  
ForEver

;- Images Datasection
DataSection
  FirstProc: 
    IncludeBinary "Resultset_first.png"
  PreviousProc: 
    IncludeBinary "Resultset_previous.png"
  NextProc: 
    IncludeBinary "Resultset_next.png"
  LastProc: 
    IncludeBinary "Resultset_last.png"
  ToolBarNew:
    IncludeBinary "Add.png" 
  ToolBarGet:
    IncludeBinary "Search.png"
  ToolBarEdit:
    IncludeBinary "Edit.png" 
  ToolBarSave:
    IncludeBinary "Save.png"  
  ToolBarDelete:
    IncludeBinary "Delete.png"   
  ToolBarExit:
    IncludeBinary "Exit.png"  
  ToolBarOk:
    IncludeBinary "Ok.png" 
  ToolBarCancel:
    IncludeBinary "Cancel.png"  
  ToolBarHelp:
    IncludeBinary "Help.png"    
 EndDataSection
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 317
; FirstLine = 181
; Folding = g
; EnableXP