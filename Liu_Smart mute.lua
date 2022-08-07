  
  r=reaper
  
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
                  
                  if not isEnvelope then
                      items = GetItemsInRange(track, areaStart, areaEnd)
                  else
                      envelope = reaper.GetTrackEnvelopeByChunkName(track, GUID:sub(2, -2))
                      local ret, envName = reaper.GetEnvelopeName(envelope)
  
                      envelopeName = envName
                      envelopePoints,min,max = GetEnvelopePointsInRange(envelope, areaStart, areaEnd)
                  end
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
              reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS',"", true)
          end
      end
      return areaMap,left,right
  end
  
  --------------
  local function MuteRazorItems(razorEdits)
      local newItems = {}
      local tracks = {}
      reaper.PreventUIRefresh(1)
      for i = 1, #razorEdits do
          local areaData = razorEdits[i]
          if not areaData.isEnvelope then
              local items = areaData.items
              
              --recalculate item data for tracks with previous splits
              if tracks[areaData.track] ~= nil then 
                  items = GetItemsInRange(areaData.track, areaData.areaStart, areaData.areaEnd)
              end
              
              for j = 1, #items do 
                  local item = items[j]
                  --split items 
                  local newItem = reaper.SplitMediaItem(item, areaData.areaStart)
                  if newItem == nil then
                     reaper.SplitMediaItem(item, areaData.areaEnd)
                     table.insert(newItems,item)
                  else
                     reaper.SplitMediaItem(newItem, areaData.areaEnd)
                     table.insert(newItems,newItem)
                  end
              end
  
              tracks[areaData.track] = 1
          end
      end
      reaper.PreventUIRefresh(-1)
      
      for abii=1,#newItems do
          toggle=0
          local tr=reaper.GetMediaItemTrack(newItems[abii])
          if not Hide(tr) then
             if 0==reaper.GetMediaItemInfo_Value(newItems[abii],"B_MUTE") then
                toggle=1
                break
             end
          end
      end
      
      for abii=1,#newItems do
          local tr=reaper.GetMediaItemTrack(newItems[abii])
          if not Hide(tr) then
             reaper.SetMediaItemInfo_Value(newItems[abii],"B_MUTE",toggle)
          end
      end
      
  end
  
  --------------
  local function main()
  
      razor=GetRazorEdits()
      if #razor>0 then
         MuteRazorItems(razor)
      else
         SelTrzFilter()
         reaper.Main_OnCommand(6,0)    
      end
  
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Mute track",-1)
