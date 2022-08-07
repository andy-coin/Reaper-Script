
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
      local Bad={}
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
  
  ----------------------------------------NORMAL-------------------------------------------------
  local function GetUserInput()
    
    extname="fade_length"
    last_setting=reaper.GetExtState(extname,"fade_length",true)
    
    local ok, csv = reaper.GetUserInputs("Adjust fade length...", 2,
      "Length :,Time unit:,extrawidth=100",
      last_setting..','..'ms')
    
    if not ok or csv:len() <= 1 then return end
  
    local length_filter,unit_filter = csv:match("^(.*),(.*)$")
    
    if unit_filter ~= 'ms' and unit_filter ~= 's' then
       reaper.ShowMessageBox("Got wrong unit >_< \n please type s or ms !","Oops...",0)
       return false,false
    end
    
    reaper.SetExtState(extname,"fade_length",length_filter:lower(),true)
    
    return unit_filter:lower(), length_filter:lower()
    
  end
  
  ----------------------------------------NORMAL-------------------------------------------------
  local function NORMAL(itemz,len,m,M)
      
      if len==0 then return end
      reaper.Main_OnCommand(41118,0)
      local library={}
      
      for abi=1,reaper.CountMediaItems(0) do
          library[abi]=reaper.GetMediaItem(0,abi-1)
      end
      
      local now=1
      
      for abi=1,#itemz do
          leng=len
          tr=reaper.GetMediaItem_Track(itemz[abi])
          P=reaper.GetMediaItemInfo_Value(itemz[abi],"D_POSITION")
          L=reaper.GetMediaItemInfo_Value(itemz[abi],"D_LENGTH")
          E=L+P
          if leng>=L/2 then
             leng=L/2
          end
          
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
                if m and P<m then goto Next end 
                if abi==1 then
                   reaper.BR_SetItemEdges(itemz[abi],P-0.025,E)
                   reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",0.05)
                   reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",0.05)
                   reaper.SetMediaItemInfo_Value(tmp,"D_LENGTH",tmp_l+0.025)
                   reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN",0.05)
                   reaper.SetMediaItemInfo_Value(tmp,"D_FADEOUTLEN_AUTO",0.05)
                end
                goto Next
             end
          end
          
          if m and P<m then goto Next end 
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN",leng)
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEINLEN_AUTO",leng)
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
             if leng>=tmp_l/2 then
                leng=tmp_l/2
             end
             tmp_e=tmp_p+tmp_l
             if E>=tmp_p then
                if M and E>M then goto END end 
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_LENGTH",L+leng)
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",leng)
                reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN_AUTO",leng)
                reaper.BR_SetItemEdges(tmp,tmp_p-leng/2,tmp_e)
                reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN",leng)
                reaper.SetMediaItemInfo_Value(tmp,"D_FADEINLEN_AUTO",leng)
                goto END
             end
          end
          if M and E>M then goto END end 
          reaper.SetMediaItemInfo_Value(itemz[abi],"D_FADEOUTLEN",leng)
          ::END::
      end
      reaper.Main_OnCommand(41119,0)
            
  end
  
  -----------------------------------RAZOR AREA CHECK-----------------------------------------------
  local function main()
      
      local unit,len=GetUserInput()
      
      if unit == 'ms' then
         len=tonumber(len)/1000
      end
      
      if not len then return end
      
      SaveSelectedItems(itemzzz)
      
      local trackCount = reaper.CountTracks(0)
      local areaStart={}
      local areaEnd={}
      local razor=false
      local min=reaper.GetProjectLength()
      local max=0
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
      
      if reaper.CountSelectedMediaItems(0) == 0 then return end
      
      if razor then
         itemzz={}
         for abi=1,reaper.CountSelectedMediaItems(0) do
             itemzz[abi]=reaper.GetSelectedMediaItem(0,abi-1)
         end
         cmd=reaper.NamedCommandLookup("_RS2781b4148a9e95f2513dfd6d173bdab1a3a0753f")
         reaper.Main_OnCommand(cmd,0)
         NORMAL(itemzz,len,min,max)
      else
         cmd=reaper.NamedCommandLookup("_RS2781b4148a9e95f2513dfd6d173bdab1a3a0753f")
         reaper.Main_OnCommand(cmd,0)
         NORMAL(itemzzz,len)
      end
      RestoreSelectedItems(itemzzz)
      reaper.UpdateArrange()
  end
  
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Adjust fade length",-1)
