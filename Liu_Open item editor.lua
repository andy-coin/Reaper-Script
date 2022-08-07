  r=reaper 
  
  --------------
  local function GetWindow(name)
      local title = reaper.JS_Localize(name, "common")
      local arr = reaper.new_array({}, 1024)
      reaper.JS_Window_ArrayFind(title, true, arr)
      local adr = arr.table()
      for j = 1, #adr do
        local hwnd = reaper.JS_Window_HandleFromAddress(adr[j])
        -- verify window by checking if it also has a specific child.
        --if reaper.JS_Window_FindChildByID(hwnd, 1045) then -- 1045:ID of volume control in media explorer.
          return hwnd
        --end 
      end
  end
  
  --------------
  local function GetProjectsCount()
      --local projects = {}
      local pro = 0
      repeat
          local proj = reaper.EnumProjects(p)
          if reaper.ValidatePtr(proj, 'ReaProject*') then
              --projects[#projects + 1] = proj
          end
          pro = pro + 1
      until not proj
      return pro-1
  end
  
  --------------
  local function GetTotalTCPH()
      
      local height=0
      for abigel=1,reaper.CountTracks(0) do
          local tr=reaper.GetTrack(0,abigel-1)
          height=height+reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
      end
      --reaper.ShowConsoleMsg(height)
      if height>1160 then
         return true
      else
         return false
      end
  end
  -----------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  local trackzzz={}
  local function SaveSelectedTracks (table)--trackzzz
    tcph=0
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
    if #table>0 then
       tcph=reaper.GetMediaTrackInfo_Value(table[#table],"I_TCPH")
    end
    return tcph
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    if #table==0 then return end
    reaper.Main_OnCommand(40297,0)
    reaper.SetOnlyTrackSelected(table[#table])
    for _, track in ipairs(table) do
       reaper.SetTrackSelected(track, true)
    end
    
  end
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  local itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0,reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0,i)
    end
  end
  ----------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
  
  ----------------------------------------------------------------------------------
  local function serialize(tbl)
    local str = ''
   
    for _, value in ipairs(tbl) do
      str = str .. type(value) .. '\31' .. tostring(value) .. '\30'
    end
   
    return str
  end
  
  ----------------------------------------------------------------------------------
  local function unserialize(str)
    local type_map = {
      string  = tostring,
      number  = tonumber,
      boolean = function(v) return v == 'true' and true or false end,
    }
  
    local tbl = {}
  
    for type, value in str:gmatch('(.-)\31(.-)\30') do
      if not type_map[type] then
        error(string.format("unsupported value type: %s", type))
      end
  
      table.insert(tbl, type_map[type](value))
    end
  
    return tbl
  end
  
  -----------------------------------SAVE SCREEN POSITION-------------------------------------------------
  local function SaveScreenPosition()
  
    CurStart,CurEnd = reaper.BR_GetArrangeView(0)
    ext_name = "Screen Position Start"
    reaper.SetExtState(ext_name,"Screen Position Start",CurStart, true)
    ext_name = "Screen Position End"
    reaper.SetExtState(ext_name,"Screen Position End",CurEnd, true)
  end
  
  -----------------------------------LOAD SCREEN POSITION-------------------------------------------------
  local function LoadScreenPosition()
  
    ext_name = "Screen Position Start"
    OldStart = reaper.GetExtState(ext_name,"Screen Position Start",false)
    ext_name = "Screen Position End"
    OldEnd = reaper.GetExtState(ext_name,"Screen Position End",false)
    reaper.BR_SetArrangeView(0,OldStart,OldEnd)
  end
  
  -------------------------------------SAVE VERTICAL ZOOM-------------------------------------
  local function SaveVerticalZoom()
  
    if 0 == reaper.CountTracks(0) then return end
    
    local TR = {}
    local TR_code={}
    local TR_TCPH = {}
    
    for abi = 0,reaper.CountTracks(0)-1 do
      TR[abi+1] = reaper.GetTrack(0,abi)
      _,TR_code[abi+1] = reaper.GetSetMediaTrackInfo_String(TR[abi+1],"GUID","",false)
      TR_TCPH[abi+1] = reaper.GetMediaTrackInfo_Value(TR[abi+1],"I_TCPH")
    end
    
    local TR_code = serialize(TR_code)
    local TR_TCPH = serialize(TR_TCPH)
  
    ext_name="Guid"
    reaper.SetExtState(ext_name,"Guid",TR_code, true)
    
    ext_name = "Vertical level"
    reaper.SetExtState(ext_name,"Vertical level",TR_TCPH, true)
  
  end
  
  -------------------------------------SAVE VERTICAL ZOOM-------------------------------------
  local function LoadVerticalZoom()
    
    ext_name = "Guid"
    TR_code = reaper.GetExtState(ext_name,"Guid",false)
    
    ext_name = "Vertical level"
    TR_TCPH = reaper.GetExtState(ext_name,"Vertical level",false)
    
    local code=unserialize(TR_code)
    local TCPH=unserialize(TR_TCPH)

    for abi=1,#code do
      local tr=reaper.BR_GetMediaTrackByGUID(0,code[abi])
      if not tr then return end
      local tcph=reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
      if tcph ~= TCPH[abi] then
        reaper.SetOnlyTrackSelected(tr)
        local times = (tcph-TCPH[abi])/2
        for abii=1,times do
          reaper.Main_OnCommand(41328,0)--decrease track height a bit
        end
      end
    end 
    
  end
  
  --------------------------------------ADJUST GRID-------------------------------------
  local function AdjustGrid()
      stages = {6,16,17.5,23.3,53,120,360,1000,3000} -- no grid
      
      grid_t = {}
      for i = 1,-7, -1 do grid_t[#grid_t+1] = 2^i end
      zoom_lev = reaper.GetHZoomLevel()   
      
      if zoom_lev>17 then
           
         for i = 1, #stages-1 do
             if zoom_lev > stages[i] and zoom_lev <= stages[i+1] then
                reaper.SetProjectGrid( 0, grid_t[i] )
                break
             end
         end
         
      else
         
         for i = 1, #stages-1 do
             if zoom_lev > stages[i] and zoom_lev <= stages[i+1] then
                reaper.SetProjectGrid( 0, grid_t[i] )
                break
             end
         end
         
      end
  end
  
  --------------------------------------CHECK-------------------------------------
  local function SelectItemsInRange(track, areaStart, areaEnd)
      local itemCount = reaper.CountTrackMediaItems(track)
      for k = 0, itemCount - 1 do 
          local item = reaper.GetTrackMediaItem(track, k)
          local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
          local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
          local itemEndPos = pos+length
  
          --check if item is in area bounds
          if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
              (pos >= areaStart and pos < areaEnd) or
              (pos <= areaStart and itemEndPos >= areaEnd) then
              reaper.SetMediaItemSelected(item,true)
          end
      end
  end
  
  -------------------------------------------SetRazor--------------------------------------------
  local function SetRazor(number,zone)
    if zone then
      for abi=1,#number do
        reaper.GetSetMediaTrackInfo_String(number[abi],'P_RAZOREDITS',zone[abi],true)
      end
    end
  end
  
  --------------------------------------CHECK-------------------------------------
  local function Check()
    
    tmp_guid="tmp_guid"
    last_guid=reaper.GetExtState(tmp_guid,"tmp_guid",false)
    
    last_guid=unserialize(last_guid)
  
    current={}
    current_guid={}
    local midi=true
    
    local n=reaper.CountSelectedMediaItems(0)
    
    if n==0 then midi=false end
    
    for abi=1,n do
        current[abi]=reaper.GetSelectedMediaItem(0,abi-1)
        current_guid[abi]=reaper.BR_GetMediaItemGUID(current[abi])
    end
    
    for abi=1,n do
        local item=reaper.GetSelectedMediaItem(0,abi-1)
        local take=reaper.GetActiveTake(item)
        local source=reaper.GetMediaItemTake_Source(take)
        local TYPE=reaper.GetMediaSourceType(source,'')
        if TYPE~="MIDI" then
          midi=false
          break
        end
    end
    
    local bool=true
    
    if #last_guid ~= #current_guid then 
      find={}
      for abi=1,#current_guid do
        find[abi]=false
        for abii=1,#last_guid do
          if current_guid[abi]==last_guid[abii] then
            find[abi]=true
            break
          end
        end
        if not find[abi] then
           bool=false
           break
        end
      end
    else
      for abi=1,#last_guid do
        if last_guid[abi]~=current_guid[abi] then
          bool=false
          break
        end
      end
    end
    
    current_guid=serialize(current_guid)
    
    reaper.SetExtState(tmp_guid,"tmp_guid",current_guid,false)
    
    
    return bool,midi
    
  end
    
  -----------------------------------RESET-----------------------------------------------
  local function Reset()
    
      repeat
          local tr=reaper.GetTrack(0,reaper.CountTracks(0)-1)
          local color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
          local height=reaper.GetMediaTrackInfo_Value(tr,"I_TCPH")
          if color==21388388 or height==686 then
            reaper.DeleteTrack(tr)
          end 
      until color~=21388388 
      
      local midi_editor = reaper.MIDIEditor_GetActive()
      
      if midi_editor then
         reaper.Main_OnCommand(40716,0)--window set for arrange
      end
      
      reaper.SetThemeColor("col_gridlines",4276545,0)
      reaper.SetThemeColor("col_gridlines2",7566195,0)
      reaper.SetThemeColor("col_gridlines3",6250335,0)
      
      LoadScreenPosition()
      LoadVerticalZoom() 
      RestoreSelectedTracks(trackzzz)
      --reaper.Main_OnCommand(40913,0)
      extname="MIDI_OPEN"
      reaper.SetExtState(extname,"MIDI_OPEN",0,false)
      extname="editor_toggle"
      reaper.SetExtState(extname,"editor_toggle",0,false)
    
  end
  
  -----------------------------------RAZOR AREA CHECK-----------------------------------------------
  local function RazorAreaCheck()
      local trackCount = reaper.CountTracks(0)
      local bool=false
      local tr={}
      local AREA={}
      local min=reaper.GetProjectLength(0)
      local max=0
      for i = 0, trackCount - 1 do
          local track = reaper.GetTrack(0, i)
          local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
          if area ~= '' then
             --PARSE STRING
             bool=true
             tr[#tr+1]=track
             AREA[#AREA+1]=area
             local str = {}
             for j in string.gmatch(area,"%S+") do
                 table.insert(str,j)
             end
             --FILL AREA DATA
             local j = 1
             while j <= #str do
                 --area data
                 local areaStart = tonumber(str[j])
                 local areaEnd = tonumber(str[j+1])
                 if min>areaStart then 
                   min = areaStart 
                 end
                 if max<areaEnd then 
                   max=areaEnd 
                 end
                 SelectItemsInRange(track,areaStart,areaEnd)
                 j = j + 3
             end
          end
      end 
      
      m=min-(max-min)*0.047/5*2
      M=max+(max-min)*0.047/5*3
      
      if bool == false then
         return false
      else
         return tr,m,M,AREA
      end
    
  end
  
  ----------------------------------VERTICAL ZOOM TO MIDI NOTE--------------------------------
  local function ZoomInMidiNote(E)

    local low=127
    local high=0
    local n = {}
    local midi_item={}
    local In=reaper.CountSelectedMediaItems(0)
    
    for abi=1,In do
      midi_item[abi]=reaper.GetSelectedMediaItem(0,abi-1)
    end
    
    if #midi_item==1 then
      t = reaper.MIDIEditor_GetTake(E)
      _,ALL,_,_ = reaper.MIDI_CountEvts(t)
      
      for abii=1,ALL do 
        local _,selected,_,_,_,_,pitch,_ = reaper.MIDI_GetNote(t,abii-1)
        if high<pitch then high=pitch end
        if low>pitch then low=pitch end
        if selected then 
          n[#n+1] = pitch 
        end
      end
      goto Sort
    else
      for abi=1,In do
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
      goto Zoom
    end
    
    
    table.sort(n)
    
    if #n>=2 and n[#n]-n[1]+10 >ZoomChart[1] then
      reaper.MIDIEditor_OnCommand(E,40725)--zoom to selected note
      reaper.MIDIEditor_OnCommand(E,40214)--unselect all note
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
    cmd=reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITCUR")
    reaper.Main_OnCommand(cmd,0)
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
    reaper.MIDIEditor_OnCommand(E,1011)
    cmd=reaper.NamedCommandLookup("_WOL_SETHZOOMC_MOUSECUR")
    reaper.Main_OnCommand(cmd,0)
    reaper.MIDIEditor_SetSetting_int(E,'active_note_row',ori_curs)
    reaper.MIDIEditor_OnCommand(E,40214)--unselect all note
  end
  
  -----------------------------------------EDITOR-----------------------------------------
  local function Editor(m,M,Razor)
    
    local nn=reaper.CountSelectedMediaItems(0)
    
    midi=true
    
    if nn==1 then
      item = reaper.GetSelectedMediaItem(0,0)
      acttake = reaper.GetActiveTake(item)
      if not reaper.TakeIsMIDI(acttake) then
         midi=false
         _,chunk=reaper.GetItemStateChunk(item,"",false)
         name=chunk:match("FILE".."[^\n]+")
         ext=name:match("m4a")
      end
      source=reaper.GetMediaItemTake_Source(acttake)
      video=reaper.GetMediaSourceType( source, '' )
      if video=="VIDEO" and not ext then
         reaper.Main_OnCommand(50125,0)
         reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",28685749)
         return 
      end
    else
      for abi=1,nn do
        item=reaper.GetSelectedMediaItem(0,abi-1)
        acttake=reaper.GetActiveTake(item)
        if not reaper.TakeIsMIDI(acttake) then
          midi=false
          break
        end
      end
    end
    
    if not Razor then
      if nn==1 then
        S=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
        E=S+reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
        m=S-(E-S)*0.047/5*2
        M=E+(E-S)*0.047/5*3
      else
        min=reaper.GetProjectLength(0)
        Max=0
        for abi=1,nn do
          item=reaper.GetSelectedMediaItem(0,abi-1)
          S=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
          E=S+reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
          if min>S then min=S end
          if Max<E then Max=E end
        end
        m=min-(Max-min)*0.047/5*2
        M=Max+(Max-min)*0.047/5*3
      end
    end
    
    
    SaveVerticalZoom()
    SaveScreenPosition()
    
    local MIDI = reaper.MIDIEditor_GetActive()
    local P=reaper.GetCursorPosition()
    
    if midi then --midi item
        reaper.Main_OnCommand(40702,0)--insert new track
        cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
        reaper.Main_OnCommand(cmd,0)--minimize selected track
        local tr=reaper.GetTrack(0,reaper.CountTracks(0)-1)
        reaper.SetOnlyTrackSelected(tr)
        cmd=reaper.NamedCommandLookup("_SWSTL_HIDEMCP")
        reaper.Main_OnCommand(cmd,0)
        for abi=1,83 do
          reaper.Main_OnCommand(41325,0)
        end
        reaper.Main_OnCommand(41327,0)
        reaper.Main_OnCommand(41327,0)
        reaper.Main_OnCommand(41327,0)
        reaper.SetTrackSelected(tr,false)
        reaper.SetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR",21388388)
                
        
      if not MIDI then
        
        starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
        reaper.Main_OnCommand(40153,0)--open MIDI editor
        MIDI = reaper.MIDIEditor_GetActive()
        if not Razor then
          reaper.GetSet_LoopTimeRange2(0,true,false,P-10,P+10,false)
        else
          reaper.GetSet_LoopTimeRange2(0,true,false,m,M,false)
        end
        reaper.MIDIEditor_OnCommand(MIDI,40746)--select note in time selection
        ZoomInMidiNote(MIDI)
        reaper.GetSet_LoopTimeRange2(0, true, false,starttime, endtime, false)
        
        reaper.SetExtState(extname,"editor_toggle",1,false)
      end
      
      extname="MIDI_OPEN"
      reaper.SetExtState(extname,"MIDI_OPEN",1,false)
      reaper.BR_SetArrangeView(0,as,ae)
      
    else --audio item
      
      reaper.SetThemeColor("col_gridlines2",13158600,0)
      reaper.SetThemeColor("col_gridlines3",10855845,0)
      reaper.SetThemeColor("col_gridlines",10855845,0)
      
      if midi_editor then 
        pn=GetProjectsCount()
        if pn >1 then
           reaper.Main_OnCommand(40457,0)--window set for arrange
        else
           reaper.Main_OnCommand(40454,0)--window set for arrange
        end
      end 
      
      local _, division = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
      
      
      ss,ee=reaper.BR_GetArrangeView(0)
      if division <=0.125 and  ee-ss<20 then
         m,M=reaper.BR_GetArrangeView(0)
      elseif M-m >20 then
         if P>m and P<M then
            M=P+10
            m=P-10
         else
            M=m+20
         end
      end
      
      local tr=reaper.GetMediaItemTrack(item)
      reaper.SetTrackSelected(tr,true)
      
      cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
      reaper.Main_OnCommand(cmd,0)--minimize selected track
      
      for abi=1,303 do
        reaper.Main_OnCommand(41327,0)--increase track height
      end 
      extname="editor_toggle"
      reaper.SetExtState(extname,"editor_toggle",1,false)
      
      return m,M
      
    end
    
  end
  
  -----------------------------------------Multi-----------------------------------------
  local function Multi(m,M,Razor,medy)
  
    SaveScreenPosition() 
    SaveVerticalZoom()
    
    local itemz={}
    if not m then
      min=reaper.GetProjectLength(0)
      Max=0
      for abi=1,reaper.CountSelectedMediaItems(0) do
        itemz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
        S=reaper.GetMediaItemInfo_Value(itemz[abi],"D_POSITION")
        E=S+reaper.GetMediaItemInfo_Value(itemz[abi],"D_LENGTH")
        if min>S then min=S end
        if Max<E then Max=E end
      end
      m=min-(Max-min)*0.047/5*2
      M=Max+(Max-min)*0.047/5*3
    end
    
    if medy then
      
      reaper.Main_OnCommand(40702,0)--insert new track
      cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
      reaper.Main_OnCommand(cmd,0)--minimize selected track
      local tr=reaper.GetTrack(0,reaper.CountTracks(0)-1)
      reaper.SetOnlyTrackSelected(tr)
      cmd=reaper.NamedCommandLookup("_SWSTL_HIDEMCP")
      reaper.Main_OnCommand(cmd,0)
      for abi=1,83 do
        reaper.Main_OnCommand(41325,0)
      end
      reaper.Main_OnCommand(41327,0)
      reaper.Main_OnCommand(41327,0)
      reaper.Main_OnCommand(41327,0)
      reaper.SetTrackSelected(tr,false)
      reaper.SetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR",21388388)
           
      starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
      reaper.Main_OnCommand(40153,0)--open MIDI editor
      MIDI = reaper.MIDIEditor_GetActive()
      local P=reaper.GetCursorPosition()
      if not Razor then
        reaper.GetSet_LoopTimeRange2(0,true,false,P-15,P+15,false)
      else
        reaper.GetSet_LoopTimeRange2(0,true,false,m,M,false)
      end
      reaper.MIDIEditor_OnCommand(MIDI,40746)--select note in time selection
      ZoomInMidiNote(MIDI)
      reaper.GetSet_LoopTimeRange2(0, true, false,starttime, endtime, false)
      
      extname="MIDI_OPEN"
      reaper.SetExtState(extname,"MIDI_OPEN",1,false)
      reaper.BR_SetArrangeView(0,as,ae)
    else
      
      cmd=reaper.NamedCommandLookup("_SWS_VZOOMIITEMS")
      reaper.Main_OnCommand(cmd,0)--Vertical zoom to selected item
      
      local P=reaper.GetCursorPosition()
      local _, division = reaper.GetSetProjectGrid( 0, 0, 0, 0, 0 )
      
      if division <=0.125 then
         m,M=reaper.BR_GetArrangeView(0)
      elseif M-m >30 then
         if P>m and P<M then
            M=P+15
            m=P-15
         else
            M=m+30
         end
      end
      
      reaper.BR_SetArrangeView(0,m,M)
      
    end
    
    extname="editor_toggle"
    reaper.SetExtState(extname,"editor_toggle",1,false)
  
  end
  
  -----------------------------------------MAIN-----------------------------------------
  local function main()
    
    reaper.Undo_BeginBlock()
    as,ae=reaper.BR_GetArrangeView(0)
    extname="editor_toggle"
    local toggle=reaper.GetExtState(extname,"editor_toggle",false)
    
    local ttccpphh=SaveSelectedTracks (trackzzz)
    SaveSelectedItems (itemzzz)
    
    PLAY=reaper.GetPlayState()
    if PLAY==5 then
       if toggle=="0" or reaper.MIDIEditor_GetActive() then
          arm={}
          SaveVerticalZoom()
          SaveScreenPosition()
          if reaper.MIDIEditor_GetActive() then
             Reset()
          end
          for abi=1,reaper.CountTracks(0) do
              local tr=reaper.GetTrack(0,abi-1)
              if reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")==1 then 
                 arm[#arm+1]=tr
              end
          end
          if #arm==1 then
             reaper.SetOnlyTrackSelected(arm[1])
             cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
             reaper.Main_OnCommand(cmd,0)--minimize selected track
             for abi=1,303 do
               reaper.Main_OnCommand(41327,0)--increase track height
             end 
             reaper.Main_OnCommand(40913,0)
             for abi=1,ttccpphh/(ttccpphh/34) do
                 reaper.CSurf_OnScroll( 0, -1 )
             end
          else
             reaper.Main_OnCommand(40297,0)
             for abi=1,#arm do
                 reaper.SetTrackSelected(arm[abi],true)
             end
             cmd=reaper.NamedCommandLookup("_SWS_VZOOMFIT")
             reaper.Main_OnCommand(cmd,0)
          end
          reaper.Main_OnCommand(40150,0)--go to cursor
          extname="editor_toggle"
          reaper.SetExtState(extname,"editor_toggle",1,false)
       elseif toggle=="1" then
          Reset()
          reaper.Main_OnCommand(40913,0)
          over=GetTotalTCPH() 
          if over then
             reaper.CSurf_OnScroll(0,1)
          else
             for abi=1,70 do
                 reaper.CSurf_OnScroll(0,-1)
             end
          end
       end
       RestoreSelectedItems(itemzzz)
       RestoreSelectedTracks(trackzzz)
       reaper.Undo_EndBlock("Show/hide Editor",-1) 
       return
    else
    
       local razor,m,M,AREA=RazorAreaCheck()
       local check,midi=Check()
       local n=reaper.CountSelectedMediaItems(0)
       
       --reaper.ShowConsoleMsg(toggle.."|"..tostring(midi).."|"..tostring(check).."|"..n)
      
       if toggle=='0' and n==0 then
          if GetWindow("Video Window") then
             reaper.Main_OnCommand(50125,0)--show hide video window
          end
          reaper.BR_SetArrangeView(0,as,ae)
          return
       elseif toggle=='1' and midi then
          EDITOR=reaper.MIDIEditor_GetActive()
          if not EDITOR and toggle=='1' then
             Reset()
          else
             Reset()
             goto END 
          end
       elseif toggle=='1' and not check and not midi then
          Reset()
       elseif toggle=='1' and check then
          bug=true
          Reset()
          goto END
       end
       
       for abi=1,reaper.CountSelectedTracks(0) do
           local tr=reaper.GetSelectedTrack(0,0)
           reaper.SetTrackSelected(tr,false)
       end
       
       if razor then 
         local it=reaper.GetSelectedMediaItem(0,0)
         local tr=reaper.GetMediaItemTrack(it)
         reaper.SetOnlyTrackSelected(tr)
         if #razor == 1 then
            left,right=Editor(m,M,razor)
         else
            Multi(m,M,razor,midi)
            AdjustGrid()
            if not midi then
               RestoreSelectedTracks(trackzzz)
               RestoreSelectedItems(itemzzz)
               --SetRazor(razor,AREA)
               return
            else
               RestoreSelectedTracks(trackzzz)
               --SetRazor(razor,AREA)
               return
            end
         end
       else
          for abi=1,reaper.CountSelectedMediaItems(0) do
              local it=reaper.GetSelectedMediaItem(0,abi-1)
              local tr=reaper.GetMediaItemTrack(it)
              reaper.SetTrackSelected(tr,true)
          end
          
          local tr_n=reaper.CountSelectedTracks(0)
          
          if tr_n == 1 then
             left,right=Editor(m,M,razor)
          else
             Multi(m,M,razor,midi)
             if not midi then
                AdjustGrid()
                RestoreSelectedTracks(trackzzz)
                RestoreSelectedItems(itemzzz)
                --SetRazor(razor,AREA)
                return
             end
          end 
       end
       ::END::
       RestoreSelectedItems(itemzzz)
       RestoreSelectedTracks(trackzzz)
       over=GetTotalTCPH()
       cmd=reaper.NamedCommandLookup("_S&M_SCROLL_ITEM")
       reaper.Main_OnCommand(cmd,0)
       
       if toggle=="1" then
          if over then
             reaper.CSurf_OnScroll(0,1)
          else
             for abi=1,70 do
                 reaper.CSurf_OnScroll(0,-1)
             end
          end
       end
       if left and right then
          reaper.BR_SetArrangeView(0,left,right)
          for abi=1,ttccpphh/(ttccpphh/34) do
              reaper.CSurf_OnScroll( 0, -1 )
          end
          AdjustGrid()
       else
          if midi then
             if ttccpphh>=24 and ttccpphh<=34 then
                times=0
             elseif ttccpphh>34 and ttccpphh<=44 then
                times=10
             elseif ttccpphh>44 and ttccpphh<=64 then
                times=20
             elseif ttccpphh>64 and ttccpphh<=124 then
                times=30
             else
                times=30+15*math.floor((ttccpphh-84)/20)
             end
             for abi=1,times do
                 --reaper.CSurf_OnScroll(0,1)
             end
          end
       end
       if bug then
          LoadScreenPosition()
       end
       --SetRazor(razor,AREA)
       reaper.Undo_EndBlock("Show/hide Editor",-1) 
    end
    
  end 
  
  
  ------------excute--------------
  
  reaper.defer(main)
