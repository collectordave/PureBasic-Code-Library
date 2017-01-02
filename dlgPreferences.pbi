DeclareModule Preferences
  
  Declare Open()
  
EndDeclareModule

Module Preferences

Enumeration 50 
  #winPreferences
  #txtLanguage
  #strLanguage
  #btnSelectLanguage
  #txtWorkFolder
  #strWorkFolder
  #btnSelectFolder
  #btnOk
  #btnCancel
EndEnumeration

Procedure ShowFormTexts()
  
 ; SetWindowTitle(#winPreferences,Locale::TranslatedString(52))

 ; SetGadgetText(#txtLanguage,Locale::TranslatedString(135))
 ; SetGadgetText(#btnSelectLanguage,"...")
 ; GadgetToolTip(#btnSelectLanguage, Locale::TranslatedString(114))
 ; SetGadgetText(#txtImageFolder, Locale::TranslatedString(115))
 ; SetGadgetText(#btnSelectFolder,"...")
 ; GadgetToolTip(#btnSelectFolder, Locale::TranslatedString(116))
 ; SetGadgetText(#txtSlideShow, Locale::TranslatedString(117))
 ; SetGadgetText(#txtOnAdd, Locale::TranslatedString(118)) 
 ; SetGadgetText(#OptCopy, Locale::TranslatedString(20))   
 ; SetGadgetText(#OptMove, Locale::TranslatedString(136))   
 ; SetGadgetText(#btnOk,Locale::TranslatedString(0))
 ; SetGadgetText(#btnCancel,Locale::TranslatedString(3))
  
EndProcedure

Procedure Open()

  Define Quit.i = #False
  Define SelectedPath.s
  
  OpenWindow(#winPreferences, 0, 0, 340, 160, "Preferences", #PB_Window_Tool | #PB_Window_WindowCentered)
  TextGadget(#txtLanguage, 5, 10, 60, 20, "Language", #PB_Text_Right)
  StringGadget(#strLanguage, 70, 10, 110, 20, "")
  ButtonGadget(#btnSelectLanguage, 180, 10, 20, 20, "...")
  GadgetToolTip(#btnSelectLanguage, "Select Language")
  TextGadget(#txtWorkFolder, 10, 40, 170, 20, "Working Folder")
  StringGadget(#strWorkFolder, 10, 60, 300, 20, "")
  ButtonGadget(#btnSelectFolder, 310, 60, 20, 20, "...")
  GadgetToolTip(#btnSelectFolder, "")

  
  ButtonGadget(#btnOk, 170, 120, 70, 25, "Ok")
  ButtonGadget(#btnCancel, 260, 120, 70, 25, "Cancel")
  StickyWindow(#winPreferences,#True)
  
  ShowFormTexts()
  
  SetGadgetText(#strLanguage,App::Language)

  SetGadgetText(#strWorkFolder,App::BaseFolder) 
  
  Repeat
  
    Event = WaitWindowEvent()
    
    Select event


    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case #btnOk
          
          App::Language = GetGadgetText(#strLanguage)
          App::BaseFolder = GetGadgetText(#strWorkFolder)
          App::Writepreferences("CodeDB")
          CloseWindow(#winPreferences)
          Quit = #True
          
        Case #btnCancel
          
          CloseWindow(#winPreferences)
          Quit = #True   
          
        Case #btnSelectFolder

          SelectedPath = PathRequester("Select Working Folder", App::#DefaultFolder)
          If SelectedPath
            SetGadgetText(#strWorkFolder,SelectedPath)
          EndIf
          
        Case #btnSelectLanguage
          
  ;        Locale::SelectLanguage()
  ;        App::Language = Locale::AppLanguage
  ;        SetGadgetText(#strLanguage,Locale::AppLanguage)
  ;        Locale::Initialise()
  ;        ShowFormTexts()
          
      EndSelect
      
  EndSelect
  
Until Quit = #True

EndProcedure

EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 45
; FirstLine = 33
; Folding = -
; EnableXP