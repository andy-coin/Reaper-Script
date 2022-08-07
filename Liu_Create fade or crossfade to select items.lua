
  r=reaper
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  local itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
  end
  
  ----------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  local function RestoreSelectedItems (table)--itemzzz
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
          if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
             (pos >= areaStart and pos < areaEnd) or
             (pos <= areaStart and itemEndPos >= areaEnd) then
             reaper.SetMediaItemSelected(item,true)
             local In=reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN")
             local Out=reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN")
             reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", 0 )
             reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", 0 )
             reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", In )
             reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", Out )
             I[#I+1]=item
             P[#P+1]=pos
             L[#L+1]=length
             E[#E+1]=itemEndPos
          end
      end
      return I,P,L,E
  end
  
  ----------------------------------------NORMAL-------------------------------------------------
  local function NORMAL(itemz)
    
      reaper.Main_OnCommand(41118,0)
      local library={}
      
      extname="fade_length"
      fadesize=reaper.GetExtState(extname,"fade_length",true)
      fadesize=fadesize/1000
      for abi=1,reaper.CountMediaItems(0) do
          library[abi]=reaper.GetMediaItem(0,abi-1)
      end
      
      local now=1
      
      for abi=1,#itemz do
          tr=reaper.GetMediaItem_Track(itemz[abi])
          P=reaper.GetMediaItemInfo_Value(itemz[abi],"D_POSITION")
          L=reaper.GetMediaItemInfo_Value(itemz[abi],"D_LENGTH")
          E=L+P
          tmp=nil
          for abii=now,#library do
              if abii>1 and library[abii]==itemz[abi] then
                 tmp=library[abii-1] 
                 tmp_tr=reaper.GetMediaItem_Track(tmp)
                 now=abii
                 break
              end
          end
          
          if tmp and tr==tmp_tr then
             tmp_p=reaper.GetMediaItemInfo_Value(tmp,"D_POSITION")
             tmp_l=reaper.GetMediaItemInfo_Value(tmp,"D_LENGTH")
             tmp_e=tmp_p+tmp_l
             if tmp_e>=P then
                if abi==1 then
                   reaper.BR_SetItemEdges(itemz[abi],P-fadesize/2,E)
                   reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",fadesize)
                   reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",fadesize)
                   reaper.SetMediaItemInfo_Value(tmp,"D_LENGTH",tmp_l+fadesize/2)
                   reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN",fadesize)
                   reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN_AUTO",fadesize)
                end
                goto Next
             end
          end
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",fadesize*2)
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",fadesize*2)
          ::Next:: 
          
          tmp=nil
          for abii=now,#library do
              if abii+1<=#library and library[abii]==itemz[abi] then
                 tmp=library[abii+1]
                 tmp_tr=reaper.GetMediaItem_Track(tmp)
                 now=abii
                 break
              end
          end
          if tmp and tr==tmp_tr then
             tmp_p=reaper.GetMediaItemInfo_Value(tmp,"D_POSITION")
             tmp_l=reaper.GetMediaItemInfo_Value(tmp,"D_LENGTH")
             tmp_e=tmp_p+tmp_l
             if E>=tmp_p then
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_LENGTH",L+fadesize)
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",fadesize)
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN_AUTO",fadesize)
                reaper.BR_SetItemEdges(tmp,tmp_p-fadesize/2,tmp_e)
                reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN",fadesize)
                reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN_AUTO",fadesize)
                goto END
             end
          end
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",fadesize*2)
          ::END::
      end
      reaper.Main_OnCommand(41119,0)
  end
  
  -----------------------------------RAZOR AREA CHECK-----------------------------------------------
  local function main()
    
      SaveSelectedItems(itemzzz)
      local trackCount = reaper.CountTracks(0)
      local areaStart={}
      local areaEnd={}
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
                  itemz,ip,il,ie=SelectItemsInRange(track,areaStart[#areaStart],areaEnd[#areaEnd])
                  
                  if #itemz==2 and ie[1]>=ip[2] then
                      reaper.Main_OnCommand(41118,0)
                      reaper.SetMediaItemInfo_Value(itemz[1],"D_LENGTH",il[1]+(areaEnd[1]-ie[1]))
                      center=(ip[2]+ie[1])/2
                      reaper.BR_SetItemEdges(itemz[2],areaStart[1],ie[2])
                      reaper.SetMediaItemInfo_Value(itemz[1], "D_FADEOUTLEN_AUTO",areaEnd[1]-center)
                      reaper.SetMediaItemInfo_Value(itemz[2], "D_FADEINLEN_AUTO",areaEnd[1]-areaStart[1])
                      reaper.SetMediaItemInfo_Value(itemz[2], "D_SNAPOFFSET",0)
                      reaper.Main_OnCommand(41119,0)
                  elseif #itemz==2 and ie[1]<ip[2] then
                      reaper.SetMediaItemInfo_Value(itemz[1], "D_FADEOUTLEN",ie[1]-areaStart[#areaStart])
                      reaper.SetMediaItemInfo_Value(itemz[2], "D_FADEINLEN",areaEnd[#areaEnd]-ip[2])
                  elseif #itemz==1 then
                      if ip[1]>areaStart[#areaStart] then
                          reaper.SetMediaItemInfo_Value(itemz[1], "D_FADEINLEN",areaEnd[#areaEnd]-ip[1])
                      elseif ie[1]<areaEnd[#areaEnd] then
                          reaper.SetMediaItemInfo_Value(itemz[1], "D_FADEOUTLEN",ie[1]-areaStart[#areaStart])
                      end
                  end
                  j = j + 3
              end
          end
      end
      if not razor then 
         cmd=reaper.NamedCommandLookup("_RS2781b4148a9e95f2513dfd6d173bdab1a3a0753f")
         reaper.Main_OnCommand(cmd,0)
         NORMAL(itemzzz)
      end
      RestoreSelectedItems(itemzzz)
      reaper.UpdateArrange()
  end
   
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Create fade/crossfade to selected items",-1)
  
  
