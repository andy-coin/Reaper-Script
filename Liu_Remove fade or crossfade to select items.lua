
  r=reaper
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  local itemzzz = {}
  local function SaveSelectedItems (table)--itemzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
    return table
  end
  
  ----------------------------RESTORE INITIAL SELECTED ITEMS--------------------------
  local function RestoreSelectedItems (table)--itemzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
  
  --------------------------------------CHECK-------------------------------------
  local function SelectItemsInRange(track, areaStart, areaEnd)
      local itemCount = reaper.CountTrackMediaItems(track)
      local I={}
      local P={}
      local E={}
      local L={}
      for k = 0, itemCount - 1 do 
          local item = reaper.GetTrackMediaItem(track, k)
          local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
          local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
          local itemEndPos = pos+length
  
          --check if item is in area bounds
          if  (itemEndPos > areaStart and itemEndPos <= areaEnd) or
              (pos >= areaStart and pos < areaEnd) or
              (pos <= areaStart and itemEndPos >= areaEnd) then
              reaper.SetMediaItemSelected(item,true)
          end
      end
  end
  
  ----------------------------RESTORE INITIAL SELECTED ITEMS--------------------------
  local function RemoveFadeinView(itemz,Arrange_start,Arrange_end)
    
    local library={}
    
    for abi=1,reaper.CountMediaItems(0) do
        library[abi]=reaper.GetMediaItem(0,abi-1)
    end
    local now=1
    for abi=1,#itemz do
        --clear fade in
        tr=reaper.GetMediaItem_Track(itemz[abi])
        P=reaper.GetMediaItemInfo_Value(itemz[abi],"D_POSITION")
        L=reaper.GetMediaItemInfo_Value(itemz[abi],"D_LENGTH")
        E=L+P
        if P>Arrange_start and P<Arrange_end then
           tmp=nil
           for abii=now,#library do
               if abii>1 and library[abii]==itemz[abi] then
                  tmp=library[abii-1] 
                  tmp_tr=reaper.GetMediaItem_Track(tmp)
                  now=abi
                  break
               end
           end
           if tmp then
              tmp_p=reaper.GetMediaItemInfo_Value(tmp,"D_POSITION")
              tmp_l=reaper.GetMediaItemInfo_Value(tmp,"D_LENGTH")
              tmp_e=tmp_p+tmp_l
              if tmp_e>=P and tr==tmp_tr then
                 reaper.SetMediaItemInfo_Value(tmp,"D_LENGTH",tmp_l-(tmp_e-P)/2)
                 reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN",(tmp_e-P)/2)
                 reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN_AUTO",-1)
                 reaper.BR_SetItemEdges(itemz[abi],P+(tmp_e-P)/2,E)
                 reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",0)
                 reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",-1)
                 goto Next
              end
           end
           reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",0)
           reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",-1)
           ::Next:: 
        end
        -----clear fade out
        if E>Arrange_start and E<Arrange_end then
           tmp=nil
           for abii=now,#library do
               if abii+1<=#library and library[abii]==itemz[abi] then
                  tmp=library[abii+1]
                  tmp_tr=reaper.GetMediaItem_Track(tmp)
                  break
               end
           end
           if tmp then
              tmp_p=reaper.GetMediaItemInfo_Value(tmp,"D_POSITION")
              tmp_l=reaper.GetMediaItemInfo_Value(tmp,"D_LENGTH")
              tmp_e=tmp_p+tmp_l
              if E>=tmp_p and tr==tmp_tr then
                 reaper.BR_SetItemEdges(tmp,tmp_p+(E-tmp_p)/2,tmp_e)
                 reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN",(E-tmp_p)/2)
                 reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN_AUTO",-1)
                 reaper.SetMediaItemInfo_Value(itemz[abi],"D_LENGTH",L-(E-tmp_p)/2)
                 reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",0)
                 reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN_AUTO",-1)
                 goto END
              end
           end
           reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",0)
           reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN_AUTO",-1)
           ::END::
        end
    end
    
  end
  
  -------------------------------------MAIN----------------------------------------------
  local function main()
  
    SaveSelectedItems(itemzzz)
    local _start,_end= reaper.GetSet_ArrangeView2( 0, false, 0, 0)
    local trackCount = reaper.CountTracks(0)
    local areaStart={}
    local areaEnd={}
    local min=reaper.GetProjectLength()
    local max=0
    local razor=false
    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(0, i)
        local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
        if area ~= '' then
            razor=true
            local str = {}
            for j in string.gmatch(area,"%S+") do
                  table.insert(str,j)
            end
            local j = 1
            while j <= #str do
                areaStart[#areaStart+1] = tonumber(str[j])
                areaEnd[#areaEnd+1] = tonumber(str[j+1])
                if min>areaStart[#areaStart] then min=areaStart[#areaStart] end
                if max<areaEnd[#areaEnd] then max=areaEnd[#areaEnd] end
                SelectItemsInRange(track,areaStart[#areaStart],areaEnd[#areaEnd])
                j = j + 3
            end
        end
    end
    
    if razor then
       itemzz={}
       if min>_start then 
          _start=min
       end
       if max<_end then
          _end=max
       end
       for abi=1,reaper.CountSelectedMediaItems(0) do
           itemzz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
       end
       RemoveFadeinView(itemzz,_start,_end)
    else
       RemoveFadeinView(itemzzz,_start,_end)
    end
    RestoreSelectedItems(itemzzz)
    
    reaper.UpdateArrange()
    
    
  end
 
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Remove fade/crossfade to selected items",-1)

  
  
  
  
  
  
  
  
