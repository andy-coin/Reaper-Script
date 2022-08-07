
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
  
      return envelopePoints,min,max
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
                  SS=tostring(areaStart).." "
                  EE=tostring(areaEnd).." "
                  if j<4 and isEnvelope then
                     SS=tostring(areaEnd).." "
                     EE=tostring(2*areaEnd-areaStart).." "
                     zone=SS..EE..GUID
                  else
                     zone=zone.." "..SS..EE..GUID
                  end
                  j = j + 3
              end
              --reaper.ShowConsoleMsg(zone.."\n")
              reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS',zone, true)
          end
      end
      return areaMap,left,right
  end
  
  --------------
  local function DuplicateRazorItems(razorEdits)
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
          reaper.SetMediaItemSelected(newItems[abii],true)
      end
      
      as,ae=reaper.BR_GetArrangeView(0)
      pos=reaper.GetCursorPosition()
      reaper.Main_OnCommand(41295,0)
      reaper.BR_SetArrangeView(0,as,ae)
      reaper.SetEditCurPos(pos,false,false)
      
  end
  
  --------------
  local function TrackState(tr)
      
      if not tr then return nil end
      --normal
      if nil == reaper.GetParentTrack(tr) 
         and 0 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then return 0
      --children
      elseif nil ~= reaper.GetParentTrack(tr) 
         and 1 ~= reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then return -1
      --parent[Abi]
      elseif nil == reaper.GetParentTrack(tr) 
         and 1 == reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERDEPTH") then 
         if reaper.GetMediaTrackInfo_Value(tr,"I_FOLDERCOMPACT")~=0 then
            return 0,true
         else
            return 1,true
         end
      end
  end 
  
  --------------
  local function DuplicateRazorEnvelope(EL,ELP,x)
      
      for abigel=1,#ELP do
          reaper.InsertEnvelopePoint(EL,ELP[abigel].time+x,ELP[abigel].value,ELP[abigel].shape,ELP[abigel].tension,true,false)  
      end

  end
  
  --------------
  local function GetNextTrack(tr,ori)
      
      ::BEGIN::
      hide=false
      local id=reaper.GetMediaTrackInfo_Value(tr,"IP_TRACKNUMBER")
      if id==reaper.CountTracks(0) then return nil end 
      local next=reaper.GetTrack(0,id)
      _,state=reaper.GetTrackState(next)
      parent=reaper.GetParentTrack(next)
      if state>=512 and state <1024 then
         hide=true
      elseif state>=1536 then
         hide=true
      elseif parent then--and reaper.GetMediaTrackInfo_Value(parent,"I_FOLDERCOMPACT")==2 then
         hide=true
      end
      
      if hide and reaper.GetMediaTrackInfo_Value(ori,"I_FOLDERDEPTH")==1 then
         tr=next
         goto BEGIN
      end
      
      --reaper.ShowConsoleMsg(stop)
      return next
      
  end
  
  --------------
  local function main()
      
      SelTrzFilter()
      SelItemFilter()
      local Tn=reaper.CountSelectedTracks(0)
      local In=reaper.CountSelectedMediaItems(0)
      local Env=reaper.GetSelectedEnvelope(0)
      local razor,min,max,AREA=GetRazorEdits()
      if Tn==0 then return end
      --if In==0 and not Env and razor==0 then return end
      
      reaper.Undo_BeginBlock()
      
      win,Seg=reaper.BR_GetMouseCursorContext()
      
      if win~="tcp" and win~="mcp" or Tn==0 then
         ITM=true
      end
      
      if #razor>0 then
         Act="Duplicate razor area"
         abi=1
         for abi=1,#razor do
             if not razor[abi].isEnvelope then
                if abi==1 then
                   DuplicateRazorItems(razor)
                end
             end
             if razor[abi].envelope then
                reaper.DeleteEnvelopePointRange(razor[abi].envelope,max+0.0000000001,max+(max-min)+0.0000000001)
                DuplicateRazorEnvelope(razor[abi].envelope,razor[abi].envelopePoints,max-min)
             end
         end
      elseif Env then
         local En=reaper.CountEnvelopePoints(Env)
         Act="Nothing"
         if En>0 then
         NoPoint=false
         min=60*60*24*30--a month!
         max=0
            for abi=1,En do
                retval, point_time, value, shapeOut, tension, selected = reaper.GetEnvelopePoint(Env,abi)
                if selected then 
                   Act="Duplicate selected envelope points"
                   if min>point_time then 
                      min=point_time
                   end
                   if max<point_time then
                      max=point_time
                   end 
                end
            end
            if not NoPoint then
               reaper.DeleteEnvelopePointRange(Env,max+0.0000000001,max+(max-min)+0.0000000001)
               cmd=reaper.NamedCommandLookup("_RSbdbdf040df097fd57022f539c4b62b8e297c12cd")
               reaper.Main_OnCommand(cmd,0)
            end
         end
      elseif In>0 and ITM then
         Act="Duplicate selected items"
         as,ae=reaper.BR_GetArrangeView(0)
         pos=reaper.GetCursorPosition()
         reaper.Main_OnCommand(41295,0)
         reaper.BR_SetArrangeView(0,as,ae)
         reaper.SetEditCurPos(pos,false,false)
      elseif Tn>0 then
         Act="Duplicate selected tracks"
         trz={}
         
         abi=0
         time=reaper.time_precise()
         repeat
             local tr=reaper.GetSelectedTrack(0,abi)
             trz[#trz+1]=tr
             local _,parent=TrackState(tr)
             if parent then
                abii=0
                idx=reaper.GetMediaTrackInfo_Value(tr,"IP_TRACKNUMBER")
                repeat
                    child=reaper.GetTrack(0,idx+abii)
                    reaper.SetTrackSelected(child,false)
                    if reaper.GetMediaTrackInfo_Value(child,"I_FOLDERDEPTH")==-1 then
                       break
                    end
                    abii=abii+1
                until abii>=500 or time<(reaper.time_precise()-1)
             end
             abi=abi+1
         until abi==reaper.CountSelectedTracks(0) or time<(reaper.time_precise()-1)
         
         copy={}
         if #trz==1 then 
            reaper.Main_OnCommand(40062,0)
            copy[1]=reaper.GetSelectedTrack(0,0)
            goto FIT 
         end
         
         abi=1
         time=reaper.time_precise()
         
         repeat
             reaper.SetOnlyTrackSelected(trz[abi],true)
             
             repeat 
                 next=GetNextTrack(trz[abi],trz[abi])
                 same=TrackState(trz[abi])==TrackState(next)
                 
                 if trz[abi+1] and next and next==trz[abi+1] and same then
                 
                    reaper.SetTrackSelected(trz[abi+1],true)
                    abi=abi+1
                 
                 else
                    
                    reaper.Main_OnCommand(40062,0)--duplicate
                    
                    for abigel=1,reaper.CountSelectedTracks(0) do
                        copy[#copy+1]=reaper.GetSelectedTrack(0,abigel-1)
                    end
                    
                    last=reaper.GetSelectedTrack(0,reaper.CountSelectedTracks(0)-1)
                    if TrackState(last)==1 then
                       
                       abii=0
                       idx=reaper.GetMediaTrackInfo_Value(last,"IP_TRACKNUMBER")
                       
                       repeat
                           child=reaper.GetTrack(0,idx+abii)
                           if reaper.GetMediaTrackInfo_Value(child,"I_FOLDERDEPTH")==-1 then
                              bottom=reaper.GetMediaTrackInfo_Value(child,"IP_TRACKNUMBER")
                              break
                           end
                           abii=abii+1
                       until abii>=500 or time<(reaper.time_precise()-time)
                    
                    else
                       
                       bottom=reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,reaper.CountSelectedTracks(0)-1),"IP_TRACKNUMBER")
                    
                    end
                    
                    if TrackState(last)==-1 then
                       folder=2
                    else
                       folder=0
                    end
                    
                    reaper.ReorderSelectedTracks(bottom,folder)
                    abi=abi+1
                    break
                 end
                 
             until time<(reaper.time_precise()-1)
             
         until abi==#trz+1 or time<(reaper.time_precise()-1)
         
         for abi=1,#copy do
             reaper.SetTrackSelected(copy[abi],true)
         end
         
         ::FIT::
         
         toggle=reaper.GetExtState("editor_toggle","editor_toggle",false)
          
         if toggle=="1" then
            first=reaper.GetTrack(0,0)
            TCPH=reaper.GetMediaTrackInfo_Value(first,"I_TCPH")
            tcph=reaper.GetMediaTrackInfo_Value(copy[1],"I_TCPH")
            
            times=(TCPH-tcph)/2
            
            if times>0 then
               for abi=1,times do
                   reaper.Main_OnCommand(41327,0)
               end
            
            elseif times<0 then
                for abi=1,-times do
                    reaper.Main_OnCommand(41328,0)
                end
            end
         end
      end
      
      reaper.Undo_EndBlock(Act,-1)
      
  end
  
  main()
