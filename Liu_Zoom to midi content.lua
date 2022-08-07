  
  r=reaper
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  local function SaveSelectedItems (table)--itemzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
  end
  
  ----------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
  
  ----------------------------------VERTICAL ZOOM TO MIDI NOTE--------------------------------
  local function main()
    
    
    local extname="editor_toggle"
    if reaper.GetExtState(extname,"editor_toggle",false) == '0' then return end
    local extname="Zoom toggle"
    local T_T=reaper.GetExtState(extname,"Zoom toggle",false)
    
    starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
    
    local low=127
    local high=0
    local Begin=reaper.GetProjectLength(0)
    local End=0
    local n = {}
    local midi_item={}
    local In=reaper.CountSelectedMediaItems(0)
    local P=reaper.GetCursorPosition()
    if In==0 then 
       E = reaper.MIDIEditor_GetActive()
       t = reaper.MIDIEditor_GetTake(E)
       if t then 
          midi_item[1]=reaper.GetMediaItemTake_Item(t)
          looong=reaper.GetMediaItemInfo_Value(midi_item[1],"D_LENGTH")
          iP=reaper.GetMediaItemInfo_Value(midi_item[1],"D_POSITION")
          iE=iP+looong
       else
          return
       end
    else
      looong=0
      iP=reaper.GetProjectLength(0)
      iE=0
      for abi=1,In do
        item = reaper.GetSelectedMediaItem(0,abi-1)
        acttake = reaper.GetActiveTake(item)
        if reaper.TakeIsMIDI(acttake) then
          midi_item[#midi_item+1]=item
          local length=reaper.GetMediaItemInfo_Value(midi_item[#midi_item],"D_LENGTH")
          if looong<length then
             looong=length
             ip=reaper.GetMediaItemInfo_Value(midi_item[#midi_item],"D_POSITION")
             ie=ip+length
             if iP>ip then iP=ip end
             if iE<ie then iE=ie end
          end
        end
      end
    end
    
    if P+5 < iP or P-5 > iE then P = nil end
    
    if #midi_item==1 then
       E = reaper.MIDIEditor_GetActive()
       t = reaper.MIDIEditor_GetTake(E)
       _,ALL,_,_ = reaper.MIDI_CountEvts(t)
    
      for abii =1,ALL do 
        local _,selected,_,_,_,_,pitch,_ = reaper.MIDI_GetNote(t,abii-1)
        if high<pitch then high=pitch end
        if low>pitch then low=pitch end
        if selected then 
          n[#n+1] = pitch 
        end
      end
      goto Sort
    else
      for abi=1,#midi_item do
        E = reaper.MIDIEditor_GetActive()
        t = reaper.GetActiveTake(midi_item[abi])
        _,ALL,_,_ = reaper.MIDI_CountEvts(t)
        
        if ALL == 0 then goto NEXT end
        
        for abii =1,ALL do 
          local _,selected,_,_,_,_,pitch,_ = reaper.MIDI_GetNote(t,abii-1)
          if high<pitch then high=pitch end
          if low>pitch then low=pitch end
          if selected then 
            n[#n+1] = pitch 
          end
        end
        ::NEXT::
      end
    end
    
    t = reaper.MIDIEditor_GetTake(E)
    
    ::Sort::
    local ori_curs = reaper.MIDIEditor_GetSetting_int(E, 'active_note_row')
    local ZoomChart={112,94,80,70,63,56,51,47,43,40,37,35,33,31,29,28,26,25,24,23,22,21,20,19,18,0}
    
    reaper.MIDI_InsertNote(t,false,true,0,3840,1,0,127,false)
    reaper.MIDI_InsertNote(t,false,true,0,3840,1,127,127,false)
    reaper.MIDIEditor_OnCommand(E,40466)--zoom to content
    local abi=0
    local FOUND=false
    local found=false
    repeat
      local _,_,mute,_,_,_,pitch,velocity = reaper.MIDI_GetNote(t, abi )
      if pitch==127 and mute and velocity==127 then
        A_9=abi
        FOUND=true
      end
      if pitch==0 and mute and velocity==127 then
        C_0=abi
        found=true
      end
    abi=abi+1
    until (FOUND and found) or abi==500000
    if abi==500000 then
       reaper.ShowConsoleMsg("BUG T_T")
    end
    reaper.MIDI_DeleteNote(t,A_9)
    reaper.MIDI_DeleteNote(t,C_0)
    
    if #n ==0 then --whole midi note
      center=math.floor((low+high)/2)
      range=high-low+10
      reaper.GetSet_LoopTimeRange2(0,true,false,iP,iE, false)
      for abi=1,#midi_item do
        --local take = reaper.GetActiveTake(midi_item[abi])
      end
      reaper.SetExtState(extname,"Zoom toggle",0,false)
      if looong >40 and T_T=='0' then
         if P then
            reaper.GetSet_LoopTimeRange2(0,true,false,P-20,P+20, false)
         else
            reaper.GetSet_LoopTimeRange2(0,true,false,(iE+iP)/2-20,(iE+iP)/2+20, false)
         end
         reaper.SetExtState(extname,"Zoom toggle",1,false)
      end
      reaper.MIDIEditor_OnCommand(E,40746)--select note in time selection
      goto Zoom
    end
    
    table.sort(n)
    
    if #n>=2 and n[#n]-n[1]+10 >ZoomChart[1] then
      return 
    end
    
    if #n==1 then
      center=n[1]
      range=11
    else
      center=math.floor((n[#n]+n[1])/2)
      range=n[#n]-n[1]+10
    end
    
    ::Zoom::
    reaper.MIDIEditor_SetSetting_int(E,'active_note_row',center)
    
    for abi=2,#ZoomChart do
      if range >ZoomChart[abi] then
        for abii=1,abi-1 do
          reaper.MIDIEditor_OnCommand(E,40111)
        end
        break
      end
    end
    
    reaper.MIDIEditor_OnCommand(E,40725)--zoom to selected note
    cmd=reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITCUR")
    reaper.Main_OnCommand(cmd,0)
    reaper.MIDIEditor_OnCommand(E,1011)--zoom out
    cmd=reaper.NamedCommandLookup("_WOL_SETHZOOMC_MOUSECUR")
    reaper.Main_OnCommand(cmd,0)
    reaper.MIDIEditor_SetSetting_int(E,'active_note_row',ori_curs)
    reaper.MIDIEditor_OnCommand(E,40214)--unselect all note
    reaper.GetSet_LoopTimeRange2(0, true, false,starttime, endtime, false)
    reaper.SetExtState(extname,"editor_toggle",1,false)
  end
  
  reaper.defer(main) 
  
    
