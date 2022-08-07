  
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
  local function SelItemFilter()
  
      itemz={}
      for abi=1,reaper.CountSelectedMediaItems(0) do
          itemz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
      end
      
      abi=1
      for abi=1,#itemz do
          tr=reaper.GetMediaItemTrack(itemz[abi])
          if Hide(tr) then
             reaper.SetMediaItemSelected(itemz[abi],false)
          end
      end
      
  end
  
  --------------
  local function CheckCompTrack(p)
      
      reaper.SetOnlyTrackSelected(p)
      cmd=reaper.NamedCommandLookup("_SWS_SELCHILDREN2")
      reaper.Main_OnCommand(cmd,0)--select trildren
      
      
      for i=1,reaper.CountSelectedTracks(0) do
          local tr=reaper.GetSelectedTrack(0,i-1)
          local _,layout=reaper.GetSetMediaTrackInfo_String(tr,"P_TCP_LAYOUT","",false)
          if layout =="d1 -- Fader" then
             mom=tr
          end
          if layout =="d5 -- Tmp" then
             Tmp=tr
          end
          if mom and Tmp then break end
      end
      
      return mom,Tmp
      
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
              reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', true)
          end
      end
      return areaMap
  end
  
  --------------
  local function KillRazorItems(razorEdits)
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
      
      reaper.Main_OnCommand(40289,0)
      for abii=1,#newItems do
          reaper.SetMediaItemSelected(newItems[abii],true)
      end
      reaper.Main_OnCommand(40006,0)--selete items
  end
  
  --------------
  local function main()
      
      local Tn=reaper.CountSelectedTracks(0)
      local In=reaper.CountSelectedMediaItems(0)
      local Env=reaper.GetSelectedEnvelope(0)
      
      if Tn==0 and In==0 and not Env then return "Delete nothing" end
      
      win,seg=reaper.BR_GetMouseCursorContext()
      
      razor=GetRazorEdits()
      
      if #razor>0 then
         abi=1
         for abi=1,#razor do
             if not razor[abi].isEnvelope then
                if abi==1 then
                   KillRazorItems(razor)
                end
             end
             if razor[abi].envelope then
                reaper.DeleteEnvelopePointRange(razor[abi].envelope,razor[abi].areaStart,razor[abi].areaEnd)
             end
         end
         return "Delete razor area"
      end
      
      if win~="tcp" and win~="mcp" or Tn==0 then
         ITM=true
      end
      
      for abi=1,reaper.CountSelectedTracks(0) do
          local tr=reaper.GetSelectedTrack(0,abi-1)
          if reaper.GetMediaTrackInfo_Value(tr,"I_RECARM")==1 then
             local it_n=reaper.CountTrackMediaItems(tr)
             if it_n~=0 then
                for abii=1,it_n do
                    local item=reaper.GetTrackMediaItem(tr,abii-1) 
                    if reaper.GetMediaItemInfo_Value(item,"B_UISEL")==1 then
                       rectrack=true
                       break
                    end
                end
             end
          end
      end
      
      if Env then
         local Env_item_n=reaper.CountAutomationItems(Env)
         local En=reaper.CountEnvelopePoints(Env)
         if Env_item_n>0 then 
            for abi=1,Env_item_n do
                sel=reaper.GetSetAutomationItemInfo(Env,abi-1,"D_UISEL",0,false)
                if sel==1 then
                   reaper.Main_OnCommand(42088,0)
                   action="Delete Selected Automation Item"
                   break
                else  
                   if En>0 and win~="tcp" then
                      reaper.Main_OnCommand(40333,0)--delete envelope point
                      action="Delete Selected Envelope point(s)"
                   elseif win=="tcp" and seg=="envelope" then
                      action="Delete Selected Envelope"
                      reaper.Main_OnCommand(40065,0)--delete envelope
                   end
                end
            end
            return action
         end
         if En>0 then
         action="Delete Selected Envelope"
         NoPoint=true
            for abi=1,En do
                retval, point_time, value, shapeOut, tension, selected = reaper.GetEnvelopePoint(Env,abi-1)
                if selected then 
                   NoPoint=false
                   reaper.Main_OnCommand(40333,0)--delete envelope point
                   action="Delete Selected Envelope point(s)"
                   break
                end
            end
            if NoPoint then
               reaper.Main_OnCommand(40065,0)--delete envelope
            end
         else
            reaper.Main_OnCommand(40065,0)--delete envelope
         end
      elseif In>0 and ITM then
         action="Delete selected item(s)"
         SelItemFilter()
         reaper.Main_OnCommand(40006,0)--delete items
      elseif Tn>0 then
         if rectrack then
            action="Delete selected item(s)"
            SelItemFilter()
            reaper.Main_OnCommand(40006,0)--delete items
            return action
         else
            goto delete_TR 
         end
         ::delete_TR::
         action="Delete selected track(s)"
         tr={}
         redFader={}
         SelTrzFilter()
         for abi=1,Tn do
             tr[abi]=reaper.GetSelectedTrack(0,abi-1)
             TV=reaper.GetParentTrack(tr[abi])
             if TV and 0==reaper.GetMediaTrackInfo_Value(TV,"I_SELECTED") then
                redFader[#redFader+1]=TV
             end
         end
         no_first=reaper.GetMediaTrackInfo_Value(tr[1],"IP_TRACKNUMBER")
         no_last=reaper.GetMediaTrackInfo_Value(tr[#tr],"IP_TRACKNUMBER")
         for abi=1,Tn do
             idx=reaper.GetMediaTrackInfo_Value(tr[abi],"IP_TRACKNUMBER")
             _,layout=reaper.GetSetMediaTrackInfo_String(tr[abi],"P_TCP_LAYOUT","",false)
             if layout == "d5 -- Tmp" then 
                tmp=reaper.GetTrack(0,idx-2)
                _,layout=reaper.GetSetMediaTrackInfo_String(tmp,"P_TCP_LAYOUT","",false)
                if layout=="" then
                   reaper.GetSetMediaTrackInfo_String(tmp,"P_TCP_LAYOUT","d5 -- Tmp",true)
                end
             elseif 1==reaper.GetMediaTrackInfo_Value(tr[abi],"I_FOLDERDEPTH") then
                abii=0
                idx=reaper.GetMediaTrackInfo_Value(tr[abi],"IP_TRACKNUMBER")
                repeat
                    child=reaper.GetTrack(0,idx+abii)
                    reaper.SetTrackSelected(child,true)
                    if reaper.GetMediaTrackInfo_Value(child,"I_FOLDERDEPTH")==-1 then
                       break
                    end
                    abii=abii+1
                until abii>=500
             end
         end
         reaper.Main_OnCommand(40005,0)--delate tracks
         for abi=1,#redFader do
             if 0==reaper.GetMediaTrackInfo_Value(redFader[abi],"I_FOLDERDEPTH") then
                reaper.GetSetMediaTrackInfo_String(redFader[abi],"P_TCP_LAYOUT","",true)
             end
         end
         if reaper.CountTracks(0)~=0 then
            last=reaper.GetTrack(0,no_last-1)
            if not last then 
               last=reaper.GetTrack(0,no_first)
               if not last then
                  last=reaper.GetTrack(0,no_first-2)
                  if not last then
                     last=reaper.GetTrack(0,0)
                  end
               end
            end
            if last then
               reaper.SetOnlyTrackSelected(last)
            end
         end
      end
      return action
  end
  
  reaper.Undo_BeginBlock()
  Act=main()
  reaper.Undo_EndBlock(Act,-1)
