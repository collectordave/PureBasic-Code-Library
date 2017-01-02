
DeclareModule AddEditModule
  
  Global OkPressed.i
  
  Global SelectedCriteria.s
    
  Declare Open(View.i)
  
EndDeclareModule

Module AddEditModule
  
  ;-Include Files
  IncludeFile "DCTool.pbi"
  
Enumeration AddEditModule 500
    #WinAddApp
    #txtTitle
    #strTitle
    #txtCategory
    #cmbCategory
    #txtComments
    #edtComments
    #btnFolder
    #imgOk
    #imgUpdate
    #imgToFolder
    #imgCancel
    #imgHelp
  EndEnumeration

  Global ApplicationTitle.s,PathToApplication.s,Comments.s,StoreFolder.s,PathToCopy.s
  Global Category_ID.i

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
  
  Procedure SaveModule(View.i)
     
    Define Criteria.s,Category.s
    
    Category = Str(GetGadgetItemData(#cmbCategory,GetGadgetState(#cmbCategory)))
    StoreFolder = GetCurrentDirectory() + "Code\Modules\" + ReplaceString(GetGadgetText(#strTitle)," ","-")
    
    If View = #True
      
      Criteria = "UPDATE Code SET"
      Criteria = Criteria + " Category_ID = " + Category + ","     
      Criteria = Criteria + " CDBTitle = '" + GetGadgetText(#strTitle) + "',"    
      Criteria = Criteria + " CDBComment = '" + GetGadgetText(#edtComments) + "',"     
      Criteria = Criteria + " WHERE Code_ID = " + App::CodeID
      
    Else
      
      Criteria = "INSERT INTO Code (Type_ID,Category_ID,CDBOrigFolder,CDBStoreFolder,CDBTitle,CDBComment,CDBProcedure) VALUES ("
      Criteria = Criteria + " 2," + Category + ",'" + PathToApplication + "','" + StoreFolder + "','"
      Criteria = Criteria + ReplaceString(GetGadgetText(#strTitle),"'","''") + "','"
      Criteria = Criteria + ReplaceString(GetGadgetText(#edtComments),"'","''") + "','"
      Criteria = Criteria + "');"

      ;Save To Database
      DatabaseUpdate(App::CodeDB, Criteria)

      ;Create Folder
      App::CheckCreatePath(StoreFolder)
    
      ;Copy Files    
      CopyDirectory(PathToApplication, StoreFolder, "*.*",#PB_FileSystem_Recursive)
      
    EndIf
  
  EndProcedure
  
  Procedure DisplayRecord()
    
    Define iLoop.i
    Define SearchString.s
    SearchString = "SELECT * FROM Code WHERE Code_ID = " + App::CodeID
    DatabaseQuery(App::CodeDB, SearchString)

    If FirstDatabaseRow(App::CodeDB)

      SetGadgetText(#strTitle, GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBTitle")))
      SetGadgetText(#edtComments, GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBComment")))    
      StoreFolder = GetDatabaseString(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"CDBStoreFolder"))
      For iLoop = 0 To CountGadgetItems(#cmbCategory) - 1
        If GetGadgetItemData(#cmbCategory,iLoop) = GetDatabaseLong(App::CodeDB,DatabaseColumnIndex(App::CodeDB,"Category_ID"))
          SetGadgetState(#cmbCategory,iLoop)
          Break
        EndIf
    
      Next iLoop

      FinishDatabaseQuery(App::CodeDB)
    
    EndIf 
  
  EndProcedure
   
  Procedure Open(View.i)
   
    CatchImage(#imgOk,?ToolBarOk)
    CatchImage(#imgCancel,?ToolBarCancel)
    CatchImage(#imgUpdate,?ToolBarUpDate)
    CatchImage(#imgToFolder,?ToolBarCopyTo)   
    CatchImage(#imgHelp,?ToolBarHelp)
    
    OpenWindow(#WinAddApp, 0, 0, 690, 180, "Module", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)
    IconBar = IconBarGadget(0, 0, WindowWidth(#WinAddApp),20,#IconBar_Default,#WinAddApp) 
    AddIconBarGadgetItem(IconBar, "Ok", #imgOk)
     If View = #True
      IconBarGadgetDivider(IconBar)
      AddIconBarGadgetItem(IconBar, "UpDate", #imgUpdate)
      AddIconBarGadgetItem(IconBar, "Copy To", #imgToFolder)      
      IconBarGadgetDivider(IconBar)
    EndIf   
    AddIconBarGadgetItem(IconBar, "Cancel", #imgCancel)
    IconBarGadgetSpacer(IconBar)
    AddIconBarGadgetItem(IconBar, "Help", #imgHelp)
    ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
    SetIconBarGadgetColor(IconBar, 1, RGB(176,224,230))
    TextGadget(#txtTitle, 20, 60, 70, 20, "Title", #PB_Text_Right)
    StringGadget(#strTitle, 110, 55, 200, 20, "")
    TextGadget(#txtCategory, 330, 60, 90, 20, "Category", #PB_Text_Right)
    ComboBoxGadget(#cmbCategory, 430, 55, 150, 20)
    TextGadget(#txtComments, 10, 80, 90, 20, "Comments")
    EditorGadget(#edtComments, 10, 100, 670, 70)
    If View = #False
      ButtonGadget(#btnFolder, 600, 55, 80, 20, "Folder")
    EndIf
    ResizeWindow(#WinAddApp,#PB_Ignore,5,#PB_Ignore,#PB_Ignore)
    StickyWindow(#WinAddApp,#True)
    
    LoadCategories()
        
    If View = #True
      DisplayRecord()
    EndIf   
    
    Repeat
    
      Event = WaitWindowEvent()
    
      Select event
        Case #PB_Event_CloseWindow
      
          CloseWindow(#WinAddApp)
          Break
      
        Case #PB_Event_Gadget
      
          Select EventGadget()
          
            Case IconBar

              Select EventData()

                Case 0
 
                  ;Check Title
                  ApplicationTitle = GetGadgetText(#strTitle)
                  If Len(Trim(ApplicationTitle)) > 0
                    ;Check Category
                    If GetGadgetItemData(#cmbCategory,GetGadgetState(#cmbCategory)) > -1
                      If View = #False ;New Application
                        ;Check Application Path
                        If Len(Trim(PathToApplication)) > 0
                          SaveModule(View)
                          CloseWindow(#WinAddApp) 
                          Break
                        Else
                          MessageRequester("More Data Required","Please Select The Applications Folder",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
                        EndIf
                      Else
                        SaveModule(View)
                        CloseWindow(#WinAddApp) 
                        Break
                      EndIf
                    Else
                      MessageRequester("More Data Required","Please Select A Category",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
                    EndIf
                  Else
                    MessageRequester("More Data Required","Please Enter Application Title",#PB_MessageRequester_Ok|#PB_MessageRequester_Info)
                  EndIf              
               
                Case 1
                  
                  If View = #True
                    ;Update Files
                    Debug "Update Files"
                  Else
                    
                    ;Cancel
                    CloseWindow(#WinAddApp) 
                    Break
                    
                  EndIf
                
                Case 2
                  
                  If View = #True
                    
                    ;Copy Files To
                    PathToCopy = PathRequester("Copy To", App::BaseFolder)
                    CopyDirectory(StoreFolder, PathToCopy, "*.*",#PB_FileSystem_Recursive)
                    
                  Else
                    
                    ;Help
                    Debug "Help"
                    
                  EndIf            

                Case 3

                    ;Cancel
                    CloseWindow(#WinAddApp) 
                    Break       
                    
                  Case 4
                  
                    ;Help
                    Debug "Help"

              EndSelect
          
            Case #btnFolder

              PathToApplication = PathRequester("Application Path", App::BaseFolder)
       
          
          EndSelect
      
      EndSelect
  
    ForEver

  EndProcedure

;- Images Datasection
DataSection
  ToolBarOk:
    IncludeBinary "Ok.png"
  ToolBarUpDate:
    IncludeBinary "Get.png"
  ToolBarCopyTo:
    IncludeBinary "Save.png"
  ToolBarCancel:
    IncludeBinary "Cancel.png" 
  ToolBarHelp:
    IncludeBinary "Help.png"  
EndDataSection
  
  EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 66
; FirstLine = 37
; Folding = r-
; EnableXP