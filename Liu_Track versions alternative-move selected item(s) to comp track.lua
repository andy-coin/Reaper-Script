
  r=reaper
  
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
  local function GetEnvelopePointsInRange(envelopeTrack, areaStart, areaEnd)
      local envelopePoints = {}
  
      for i = 1, reaper.CountEnvelopePoints(envelopeTrack) do
          local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(envelopeTrack, i - 1)
  
          if time >= areaStart and time <= areaEnd then --point is in range
              envelopePoints[#envelopePoints + 1] = {
                  id = i-1 ,
                  time = time,
                  value = value,
                  shape = shape,
                  tension = tension,
                  selected = selected
              }
          end
      end
  
      return envelopePoints
  end
  
  --------------
  local function GetRazorEdits()
      local trackCount = reaper.CountTracks(0)
      local areaMap = {}
      for i = 0, trackCount - 1 do
          local track = reaper.GetTrack(0, i)
          local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
          if area ~= '' then
              --PARSE STRING
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
                      envelopePoints = GetEnvelopePointsInRange(envelope, areaStart, areaEnd)
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
          end
      end
      return areaMap
  end
  
  --------------
  local function SplitRazorEdits(razorEdits)
      local allItems={}
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
                      r_item=reaper.SplitMediaItem(item, areaData.areaEnd)
                      table.insert(newItems,item)
                      table.insert(allItems,item)
                      table.insert(allItems,r_item)
                  else
                      r_item=reaper.SplitMediaItem(newItem, areaData.areaEnd)
                      table.insert(newItems,newItem)
                      table.insert(allItems,item)
                      table.insert(allItems,newItem)
                      table.insert(allItems,r_item)
                  end
              end
  
              tracks[areaData.track] = 1
          end
      end
      reaper.PreventUIRefresh(-1)
      
      return newItems,allItems
  end
  
  --------------
  local function IsCompTrack(it,e)
      
      if it then
         tr=reaper.GetMediaItemTrack(it)
      elseif e then
         tr=reaper.Envelope_GetParentTrack(e)
      end
      if not tr then return false end
      
      local parent=reaper.GetParentTrack(tr)
      if not parent then return false end
      local _,layout=reaper.GetSetMediaTrackInfo_String(parent,"P_TCP_LAYOUT","",false)
      if layout=="d3 ------ Red Fader" then
         return parent
      else
         return false
      end
      
  end
  
  --------------
  local function MoveItem(mom,it)
      reaper.SetOnlyTrackSelected(mom)
      reaper.Main_OnCommand(40289,0)
      reaper.SetMediaItemSelected(it,true)
      point=reaper.GetMediaItemInfo_Value(it,"D_POSITION")
      reaper.Main_OnCommand(40698,0)--copy items
      reaper.SetEditCurPos(point,false,false)
      reaper.Main_OnCommand(42398,0)--paste items
      return reaper.GetSelectedMediaItem(0,0)
  end
  
  --------------
  local function MoveEnv(mom,E,int)
      
      reaper.SetOnlyTrackSelected(mom)
      env=reaper.GetTrackEnvelopeByName(mom,E[int].envelopeName)
      if not env then 
         if     E[int].envelopeName == "Volume" then reaper.Main_OnCommand(40406, 0) -- show track volume envelope
         elseif E[int].envelopeName == "Pan" then reaper.Main_OnCommand(40407, 0)    -- show track pan envelope
         elseif E[int].envelopeName == "Mute" then reaper.Main_OnCommand(40867, 0)   -- show track mute envelope
         elseif E[int].envelopeName == "Volume (Pre-FX)" then reaper.Main_OnCommand(40408, 0) -- show track pre-FX volume envelope
         end
         env=reaper.GetTrackEnvelopeByName(mom,E[int].envelopeName)
      end
      
      reaper.DeleteEnvelopePointRange(env,E[int].areaStart,E[int].areaEnd)
      for abii=1,#E[int].envelopePoints do
          Env=E[int].envelopePoints[abii]
          reaper.InsertEnvelopePoint(env,Env.time,Env.value,Env.shape,Env.tension,true)
      end
  
  end
  
  --------------
  local function main()
  
      reaper.Undo_BeginBlock()
      reaper.PreventUIRefresh(-1)
      local P=reaper.GetCursorPosition()
      
      trackz={}
      for abi=1,reaper.CountSelectedTracks(0) do
          trackz[abi]=reaper.GetSelectedTrack(0,abi-1)
      end
      
      local razorMaps=GetRazorEdits()
      if #razorMaps>0 then 
         new_itemz={}
         itemz,ori_itemz=SplitRazorEdits(razorMaps)
         if #itemz>0 then
            for abi=1,#itemz do
                mom=IsCompTrack(itemz[abi])
                if not mom then goto END end
                new_itemz[#new_itemz+1]=MoveItem(mom,itemz[abi])
                ::END::
            end
            reaper.Main_OnCommand(40289,0)
            for abi=1,#ori_itemz do
                reaper.SetMediaItemSelected(ori_itemz[abi],true)
            end
            reaper.Main_OnCommand(40548,0)--Heal items
            reaper.Main_OnCommand(40289,0)
            for abi=1,#new_itemz do
                reaper.SetMediaItemSelected(new_itemz[abi],true)
            end
         end
         for abi=1,#razorMaps do
             if not razorMaps[abi].isEnvelope then goto NEXT end
             mom=IsCompTrack(_,razorMaps[abi].envelope)
             if not mom then goto NEXT end
             MoveEnv(mom,razorMaps,abi)
             ::NEXT::
         end
      else
         it_n=reaper.CountSelectedMediaItems(0)
         if it_n>0 then
            itemz={}
            for abi=1,it_n do
                itemz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
            end
            for abi=1,#itemz do
                mom=IsCompTrack(itemz[abi])
                if not mom then goto END end
                MoveItem(mom,itemz[abi])
                ::END::
            end
         end
      end
      
      reaper.Main_OnCommand(40297,0)
      for abi=1,#trackz do
          reaper.SetTrackSelected(trackz[abi],true)
      end
      reaper.SetEditCurPos(P,false,false)
      reaper.PreventUIRefresh(1)
      reaper.Undo_EndBlock("Track versions-Comp items",-1)
  end
  
  main()
