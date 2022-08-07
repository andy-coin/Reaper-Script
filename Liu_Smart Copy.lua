  
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
  
  --------------------------------------
  local function CopyEnvelope()
      
      Env=reaper.GetSelectedEnvelope(0)
      
      if not Env then return end
      
      local En=reaper.CountEnvelopePoints(Env)
      NoPoint=true
      if En>0 then
         _,name=reaper.GetEnvelopeName(Env)
         name="<<"..name..">>"
         EP=""
         points=0
         for abi=1,En do
             retval, point_time, value, shapeOut, tension, selected = reaper.GetEnvelopePoint(Env,abi)
             if selected then
                EP=EP.."<<"..point_time..">><<"..value..">><<"..shapeOut..">><<"..tension..">>"
                points=points+1
                NoPoint=false
                reaper.SetEnvelopePoint(Env,abi,point_time,value,shapeOut,tension,false,true)
             end
         end
      end
      if NoPoint then
         local _,chunk=reaper.GetEnvelopeStateChunk(Env,"", false)
         local chunk="<<"..chunk..">>"
         reaper.SetExtState("EnvCopyBuff","EnvCopyBuff","<<Line>>"..name..chunk,false)
      else
         reaper.SetExtState("EnvCopyBuff","EnvCopyBuff","<<Point>>"..name.."<<"..points..">>"..EP,false)
      end
      
  end
  
  -----
  local function main()
  
    FX,_,_,_ = reaper.GetFocusedFX2() 
    ext_name = "Copy state"
    razorMap=GetRazorEdits()
    
    
    if FX == 1 or FX == 2 then
      cmd=reaper.NamedCommandLookup("_RS14e35aed2e60f7466b4185a0c5900c498253f2de")
      reaper.Main_OnCommand(cmd,0)--copy focus FX data
      reaper.SetExtState(ext_name,"Copy state",1,false)
    elseif #razorMap>0 then
      new_itemz={}
      itemz,ori_itemz=SplitRazorEdits(razorMap)
      for abi=1,#itemz do
          reaper.SetMediaItemSelected(itemz[abi],true)
      end
      reaper.Main_OnCommand(40057,0)--normal copy
      reaper.Main_OnCommand(40289,0)
      for abi=1,#ori_itemz do
          reaper.SetMediaItemSelected(ori_itemz[abi],true)
      end
      reaper.Main_OnCommand(40548,0)--Heal items
      reaper.SetExtState(ext_name,"Copy state",2,false)
    elseif reaper.GetSelectedEnvelope(0) then
      CopyEnvelope()
      reaper.SetExtState(ext_name,"Copy state",0,false)
    elseif reaper.GetSelectedMediaItem(0,0) then
      SelItemFilter()
      reaper.Main_OnCommand(40057,0)--normal copy
      reaper.SetExtState(ext_name,"Copy state",2,false)
    elseif reaper.GetSelectedTrack(0,0) then
      cmd=reaper.NamedCommandLookup("_S&M_COPYFXCHAIN5")
      reaper.Main_OnCommand(cmd,0)--copy focus track FX chain
      reaper.SetExtState(ext_name,"Copy state",3,false)
    end  
    reaper.UpdateArrange()
  end
  
  reaper.defer(main)
