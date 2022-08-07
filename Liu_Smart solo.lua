  
  r=reaper
  
  ---------------------SAVE INITIAL SELECTED TRACKS------------------------------------
  trackzzz={}
  local function SaveSelectedTracks (table)--trackabi
    
    for i = 0, reaper.CountSelectedTracks(0)-1 do
      table[i+1] = reaper.GetSelectedTrack(0, i)
    end
  end
  
  ---------------------RESTORE INITIAL SELECTED TRACKS------------------------------------
  local function RestoreSelectedTracks(table)--trackabi
    reaper.Main_OnCommand(40297,0)
    if #table~=0 then   
       reaper.SetOnlyTrackSelected(table[#table])
    end
    for i=1,#table do
        reaper.SetTrackSelected(table[i],true)
    end
    for _, track in ipairs(table) do
      --reaper.SetTrackSelected(track,true)
    end
  end
  
  --------------
  local function FindBoss(track,table)
  
      parent=reaper.GetParentTrack(track)
      Msend=reaper.GetMediaTrackInfo_Value(track,"B_MAINSEND")
      --reaper.ShowConsoleMsg(tostring(Msend))
      if parent then
         table[#table+1]=parent
         FindBoss(parent,table)
      elseif Msend==0 then
         send_n=reaper.GetTrackNumSends(track,0)
         for abi=1,send_n do
             sends=reaper.BR_GetMediaTrackSendInfo_Track(track,0,abi-1,1)
             table[#table+1]=sends
             FindBoss(sends,table)
         end
      end
  
  end
  
  --------------
  local function SelTrzFilter()
      
      trz={}
      for abi=1,reaper.CountSelectedTracks(0) do
          trz[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      for abi=1,#trz do
          local _,state=reaper.GetTrackState(trz[abi])
          parent=reaper.GetParentTrack(trz[abi])
          if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
             reaper.SetTrackSelected(trz[abi],false)
          elseif state>=512 and state<1024 then
             reaper.SetTrackSelected(trz[abi],false)
          elseif state>=1536 then
             reaper.SetTrackSelected(trz[abi],false)
          end
      end
  end
  
  --------------
  local function Hide(tr)
      
      hide=false
      local _,state=reaper.GetTrackState(tr)
      parent=reaper.GetParentTrack(tr)
      if parent and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
         hide=true
      elseif state>=512 and state<1024 then
         hide=true
      elseif state>=1536 then
         hide=true
      end
      return hide
  
  end
  
  --------------
  local function PlaytilDead(E)
    
    p=reaper.GetPlayPosition()
    
    if  p>=E then
      reaper.Main_OnCommand(40044,0)--play/stop
    else
      reaper.defer(function() PlaytilDead(E) end)
    end
    
  end
  
  --------------
  local function GetItemsInRange(track, areaStart, areaEnd)
      local items = {}
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
                  table.insert(items,item)
          end
      end
  
      return items
  end
  
  --------------
  local function GetRazorEdits()
      local trackCount = reaper.CountTracks(0)
      local areaMap = {}
      local left=60*60*24*30--a month!
      local right=0
      for i = 0, trackCount - 1 do
          local track = reaper.GetTrack(0, i)
          local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
          if area ~= '' then
              --reaper.ShowConsoleMsg(i.."|"..area.."\n")
              --PARSE STRING
              local zone=""
              local str = {}
              for j in string.gmatch(area, "%S+") do
                  table.insert(str, j)
              end
              --FILL AREA DATA
              local j = 1
              while j <= #str do
                  --area data
                  local areaStart = tonumber(str[j])
                  local areaEnd = tonumber(str[j+1])
                  local GUID = str[j+2]
                  local isEnvelope = GUID ~= '""'
                  --get item/envelope data
                  local items = {}
                  local envelopeName, envelope
                  local envelopePoints
                  local items = GetItemsInRange(track, areaStart, areaEnd)
                  if left>areaStart then 
                     left=areaStart
                  end
                  if right<areaEnd then 
                     right=areaEnd
                  end
                  local areaData = {
                      areaStart = areaStart,
                      areaEnd = areaEnd,
                      
                      track = track,
                      items = items,
                      
                      --envelope data
                      isEnvelope = isEnvelope,
                      envelope = envelope,
                      envelopeName = envelopeName,
                      envelopePoints = envelopePoints,
                      GUID = GUID:sub(2, -2)
                  }
                  
                  table.insert(areaMap, areaData)
                  j = j + 3
              end
              --reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS',"", true)
          end
      end
      return areaMap,left,right
  end
  
  --------------
  local function ToggleSoloRazorAreaTracks(razorEdits,key)
     
      local trackz = {}
      reaper.PreventUIRefresh(1)
      solo=0
      for i = 1, #razorEdits do
          local areaData = razorEdits[i]
          if not areaData.isEnvelope then
             local track=areaData.track
             if reaper.GetMediaTrackInfo_Value(track,"I_SOLO")~= 0 then
                solo=solo+1
             end
             trackz[#trackz+1]=track
          end
      end 
      reaper.PreventUIRefresh(-1)
      
      reaper.Main_OnCommand(40297,0)
      
      if key==1 or solo<#trackz then
         for abi=1,reaper.CountTracks(0) do
             tr=reaper.GetTrack(0,abi-1)
             for abii=1,#trackz do
                 if tr~=trackz[abii] then
                    reaper.SetMediaTrackInfo_Value(tr,"I_SOLO",0)
                 end
             end
         end
         for abi=1,#trackz do
             if not Hide(trackz[abi]) then
                reaper.SetTrackSelected(trackz[abi],true)
             end  
         end
         reaper.Main_OnCommand(40281,0)
      else
         for abi=1,#trackz do
             if not Hide(trackz[abi]) then
                reaper.SetTrackSelected(trackz[abi],true)
             end  
         end
         reaper.Main_OnCommand(40281,0)
      end
      
      return razorEdits[1].areaStart,Solo,trackz
  end
  
  --------------
  local function ChangeBufferSize()
  
      for abi=1,reaper.CountTracks(0) do
          local tr=reaper.GetTrack(0,abi-1)
          if reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")==1 then
             cmd=reaper.NamedCommandLookup("_RSbcc69ced35229feaa2b5a1b73638e06b5e19d723")--set buffer size to 64
             reaper.Main_OnCommand(cmd,0)
             return
          end
      end
      
      cmd=reaper.NamedCommandLookup("_RS84cd6d5120685c9c5bad735b576b605ba0dafafd")--set buffer size to 2048
      reaper.Main_OnCommand(cmd,0)
  end
  
  --------------
  local function main()
      
      SaveSelectedTracks(trackzzz)
      local _, _, sec, Cmd = reaper.get_action_context()
      local tog=reaper.GetToggleCommandState(Cmd)
      razor=GetRazorEdits()
      if #razor>0 then
         if tog==0 then
            cmd=reaper.NamedCommandLookup("_BR_SAVE_SOLO_MUTE_ALL_TRACKS_SLOT_4")
            reaper.Main_OnCommand(cmd,0)--save solo and mute states slot 4
         end
         play=reaper.GetPlayState()
         if play==0 or play==2 then
            S,toggle,trackz=ToggleSoloRazorAreaTracks(razor,1)
            if toggle==0 then
               S,toggle,trackz=ToggleSoloRazorAreaTracks(razor,0)
            end
            reaper.SetToggleCommandState( sec, Cmd, 1)
            reaper.SetEditCurPos(S,false,false)
            ChangeBufferSize()
            reaper.Main_OnCommand(40044,0)
            PlaytilDead(razor[1].areaEnd)
         else
            S,toggle,trackz=ToggleSoloRazorAreaTracks(razor,1)
            reaper.SetEditCurPos(razor[1].areaStart,false,true)
            PlaytilDead(razor[1].areaEnd)
            reaper.SetToggleCommandState( sec, Cmd, 1)
         end
      else 
         if tog==1 then
            cmd=reaper.NamedCommandLookup("_BR_RESTORE_SOLO_MUTE_ALL_TRACKS_SLOT_4")
            reaper.Main_OnCommand(cmd,0)--restore solo and mute states slot 4
            reaper.SetToggleCommandState( sec, Cmd, 0)
         else
            SelTrzFilter()
            reaper.Main_OnCommand(40281,0) --solo 
         end
      end
      RestoreSelectedTracks(trackzzz)
  end
  
  reaper.defer(main)
