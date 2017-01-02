
DeclareModule AddEditApplication
  
  Global OkPressed.i
  
  Global SelectedCriteria.s
    
  Declare Open(AddEdit.i)
  
EndDeclareModule

Module AddEditApplication
  
  ;-Include Files
  IncludeFile "DCTool.pbi"
  
Enumeration AddEditApp 200
  #WinAddApp
  #txtTitle
  #strTitle
  #txtCategory
  #cmbCategory
  #txtComments
  #edtComments
  #btnFolder
EndEnumeration
  
 Procedure Open(AddEdit.i)
   
  CatchImage(0,?ToolBarOk)
  CatchImage(1,?ToolBarCancel)
  CatchImage(2,?ToolBarHelp)
 
   
  OpenWindow(#WinAddApp, 0, 0, 690, 180, "Application", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)
  IconBar = IconBarGadget(0, 0, WindowWidth(#WinAddApp),20,#IconBar_Default,#WinAddApp) 
  AddIconBarGadgetItem(IconBar, "Ok", 0)
  AddIconBarGadgetItem(IconBar, "Cancel", 1)
  IconBarGadgetSpacer(IconBar)
  AddIconBarGadgetItem(IconBar, "Help", 2)
  ResizeIconBarGadget(IconBar, #PB_Ignore, #IconBar_Auto)  
  SetIconBarGadgetColor(IconBar, 1, RGB(176,224,230))
  TextGadget(#txtTitle, 20, 60, 70, 20, "Title", #PB_Text_Right)
  StringGadget(#strTitle, 110, 55, 200, 20, "")
  TextGadget(#txtCategory, 330, 60, 90, 20, "Category", #PB_Text_Right)
  ComboBoxGadget(#cmbCategory, 430, 55, 150, 20)
  TextGadget(#txtComments, 10, 80, 90, 20, "Comments")
  EditorGadget(#edtComments, 10, 100, 670, 70)
  ButtonGadget(#btnFolder, 600, 55, 80, 20, "Folder")
  ResizeWindow(#WinAddApp,#PB_Ignore,5,#PB_Ignore,#PB_Ignore)
  StickyWindow(#WinAddApp,#True)
  
  Repeat
    
    Event = WaitWindowEvent()
    
    Select event
    Case #PB_Event_CloseWindow
      Debug "Close Add"

      CloseWindow(#WinAddApp)
      Break
      
    Case #PB_Event_Gadget
      
      Select EventGadget()
          
        Case IconBar

          Select EventData()

            Case 0
              
              ;Ok
               CloseWindow(#WinAddApp) 
               Break
               
            Case 1
              
              ;Cancel
               CloseWindow(#WinAddApp) 
               Break
               
            Case 2
              
              ;Help

          EndSelect
      EndSelect
  EndSelect
  
ForEver

EndProcedure

;- Images Datasection
DataSection
  ToolBarOk:
    IncludeBinary "Ok.png" 
  ToolBarCancel:
    IncludeBinary "Cancel.png" 
  ToolBarHelp:
    IncludeBinary "Help.png"  
EndDataSection
  
  EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 16
; FirstLine = 9
; Folding = -
; EnableXP