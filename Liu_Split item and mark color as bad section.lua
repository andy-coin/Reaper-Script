  
  r=reaper
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackzzz = {}
  trackzz={}

  local function SaveSelectedTracks (table)--trackzzz
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks (table)--trackzzz
    reaper.Main_OnCommand(40297,0)
    for _, track in ipairs(table) do
      reaper.SetTrackSelected(track, true)
    end
  end
  
  --------------
  local function colorize(A)
  
    reaper.SetEditCurPos(A,false,false)
    cmd=reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
    reaper.Main_OnCommand(cmd,0)--select items under edit cursor in selected track
    reaper.Main_OnCommand(40758,0)
    tmp=reaper.GetSelectedMediaItem(0,0)
    reaper.SetMediaItemInfo_Value(tmp,"I_CUSTOMCOLOR",26317201)
  
  end
  
  --------------
  local function FindEdge()
      
      min=reaper.GetProjectLength(0)
      max=0
      
      for abi=1,reaper.CountSelectedMediaItems(0) do
          local item=reaper.GetSelectedMediaItem(0,abi-1)
          local p=reaper.GetMediaItemInfo_Value(item,"D_POSITION")
          local l=reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
          local e=p+l
          if min>p then min=p end
          if max<e then max=e end
      end
      
      return min,max
  end
  
  --------------
  local function main()
    
    if reaper.CountSelectedMediaItems(0)==0 then return end
    
    local m,M=FindEdge()
    
    reaper.Undo_BeginBlock(0)
    SaveSelectedTracks(trackzzz)
    local P = reaper.GetPlayState()
    if P==1 then
       A = reaper.GetPlayPosition()
    else
       A = reaper.GetCursorPosition()
    end
    local Pos=reaper.GetCursorPosition()
    local tr={}
    local midi_item={}
    if A<m or A>M then return end
    
    --if P==1 then
    
      cmd=reaper.NamedCommandLookup("_SWS_SELTRKWITEM")
      reaper.Main_OnCommand(cmd,0)--select only tracks with selected items 
      SaveSelectedTracks(trackzz)
      
      for abi=1,reaper.CountSelectedMediaItems(0) do
          it=reaper.GetSelectedMediaItem(0,abi-1)
          midi= reaper.TakeIsMIDI(reaper.GetActiveTake(it)) 
          if midi then 
             midi_item[#midi_item+1]=it 
          end
      end
      
      n=reaper.CountSelectedTracks(0)
      for abi=1,n do
        tr[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      for abi=1,n do
        reaper.SetOnlyTrackSelected(tr[abi])
        --Section A
        reaper.SetEditCurPos(A,false,false)
        cmd=reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
        reaper.Main_OnCommand(cmd,0)--select items under edit cursor in selected track
        item_A=reaper.GetSelectedMediaItem(0,0)
        if not item_A then goto NEXT end
        --Section B
        reaper.SetEditCurPos(A-3,false,false)
        cmd=reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
        reaper.Main_OnCommand(cmd,0)--select items under edit cursor in selected track
        item_B=reaper.GetSelectedMediaItem(0,0)
        
        midi= reaper.TakeIsMIDI(reaper.GetActiveTake(item_A)) 
        
        if midi then goto NEXT end
        
        if item_B == nil then--start from begining
          colorize(A)
        else
          color_B=reaper.GetMediaItemInfo_Value(item_B,"I_CUSTOMCOLOR")
      
          if item_A==item_B then --same item,cut A and A-5
            reaper.Main_OnCommand(40759,0)
            colorize(A)
          else  -- only cut A
            colorize(A)
          end
        end
        local count_items = reaper.CountTrackMediaItems(tr[abi])
        -- SELECTED ITEMS LOOP
        if count_items > 0 then
          for i = 0, count_items-1 do
            item = reaper.GetTrackMediaItem(tr[abi], i)
            take = reaper.GetActiveTake(item)
            if take ~= nil then
              color = reaper.GetDisplayedMediaItemColor2(item, take)
            else -- elseif it's an empty/Text item
              color = reaper.GetDisplayedMediaItemColor(item)
            end
            if 26317201 == color then
              reaper.SetMediaItemSelected(item, 1)
            else
              reaper.SetMediaItemSelected(item, 0)
            end
          end
        end
        reaper.Main_OnCommand(40548,0)
        ::NEXT::
      end 
    --else 
    --  reaper.Main_OnCommand(40759,0)
    --end
    
    RestoreSelectedTracks(trackzz)
    reaper.SetEditCurPos(A+1,false,false)
    cmd=reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
    reaper.Main_OnCommand(cmd,0)--select items under edit cursor in selected track
    for abi=1,#midi_item do
        reaper.SetMediaItemSelected(midi_item[abi],true)
    end
    reaper.SetEditCurPos(Pos,false,false)
    RestoreSelectedTracks(trackzzz)
    reaper.Undo_EndBlock("Good color cut",-1)
    
  end
  
  main()
  
