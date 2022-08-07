
  r=reaper
  
  ---------------------------------------MAIN----------------------------------------------
  local function main()
    
    local MIDI=reaper.MIDIEditor_GetActive()
    local take=reaper.MIDIEditor_GetTake(MIDI)
    local n=reaper.CountSelectedMediaItems(0)
    local P=reaper.GetCursorPosition()
    local play=reaper.GetPlayState()
    local max=0
    local min=reaper.GetProjectLength(0)
    local item,S,L,E
    item={}
    S={}
    L={}
    E={}
    for abi=1,n do
        item[abi]=reaper.GetSelectedMediaItem(0,abi-1)
        S[abi]=reaper.GetMediaItemInfo_Value(item[abi],"D_POSITION")
        L[abi]=reaper.GetMediaItemInfo_Value(item[abi],"D_LENGTH")
        E[abi]=S[abi]+L[abi]
        if max < E[abi] then max=E[abi] end
        if min > S[abi] then min=S[abi] end
    end
    
    if play==1 then
       p=reaper.GetPlayPosition()
       if p>max then return end
       reaper.SetEditCurPos(p,false,false)
       for abi=1,n do
           if p>E[abi] then
              reaper.SetMediaItemSelected(item[abi],false)
           end
       end
    elseif play == 5 then 
       return
    else
       if P<min or P>max then return end 
       for abi=1,n do
           if P<S[abi] or P>E[abi] then
              reaper.SetMediaItemSelected(item[abi],false)
           end
       end
    end
    
    if MIDI then
       reaper.Main_OnCommand(40289,0)
       local item=reaper.GetMediaItemTake_Item(take)
       reaper.SetMediaItemSelected(item,true)
       if play==1 then
          reaper.Main_OnCommand(40759,0)
       else
          reaper.Main_OnCommand(40757,0)
       end
    else
       reaper.Main_OnCommand(40759,0)
    end
   
    reaper.SetEditCurPos(P,false,false)
    
  end
  
  main()
