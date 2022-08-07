  
  r=reaper
  
  -----------------------------------RAZOR AREA CHECK-----------------------------------------------
    local function RazorAreaCheck()
        local trackCount = reaper.CountTracks(0)
        local bool=false
        local tr={}
        local AREA={}
        local min=reaper.GetProjectLength(0)
        local max=0
            for i = 0, trackCount - 1 do
                local track = reaper.GetTrack(0, i)
                local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
                if area ~= '' then
                    
                    bool=true
                    tr[#tr+1]=track
                    AREA[#AREA+1]=area
                    local str = {}
                    for j in string.gmatch(area,"%S+") do
                        table.insert(str,j)
                    end
                    
                    local j = 1
                    while j <= #str do
                        local areaStart = tonumber(str[j])
                        local areaEnd = tonumber(str[j+1])
                        if min>areaStart then 
                          min = areaStart 
                        end
                        if max<areaEnd then 
                          max=areaEnd 
                        end
                        j = j + 3
                    end
                end
            end 
      
        if bool == false then
            return false
        else
            return min,max,AREA
        end
    end
  
  ------------------------------------------SET RAZOR-----------------------------------------------
  local function SetRazor(number,zone)
    if zone then
      for abi=1,#zone do
        reaper.GetSetMediaTrackInfo_String(number[abi],'P_RAZOREDITS',zone[abi],true)
      end
    end
  end
  
  --------------
  local function GetProjectLength()
      
      min=reaper.GetProjectLength(0)
      max=min
      
      for abi=1,reaper.CountTracks(0) do
          tr=reaper.GetTrack(0,abi-1)
          it=reaper.GetTrackMediaItem(tr,0)
          if it then
             S=reaper.GetMediaItemInfo_Value(it,"D_POSITION")
             if min>S then
                min=S
             end
          end
      end
      
      return min,max
  end
  
  ----------------------------------------------MAIN-----------------------------------------------
  local function main()
  
      local m,M,razor=RazorAreaCheck()
      local self = ({reaper.get_action_context()})[4]
      local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
      local P=reaper.GetCursorPosition()
      local it_n=reaper.CountSelectedMediaItems(0)
      
      if it_n>0 then
         S=reaper.GetProjectLength(0)
         E=0
         for abi=1,it_n do
             it=reaper.GetSelectedMediaItem(0,abi-1)
             s=reaper.GetMediaItemInfo_Value(it,"D_POSITION")
             l=reaper.GetMediaItemInfo_Value(it,"D_LENGTH")
             e=s+l
             if S>s then
                S=s
             end
             if E<e then
                E=e
             end
         end
      else
         min,max=GetProjectLength()
      end
      
      local cmd=reaper.NamedCommandLookup("_SWS_SAVELOOP1")
      if starttime == endtime then
         if m then
             reaper.GetSet_LoopTimeRange2(0, true, false, m, M, false)
         elseif it_n >0 then
             reaper.Main_OnCommand(41039,0)
         elseif it_n ==0 then
             reaper.GetSet_LoopTimeRange2(0, true, false, min,max, false)
         end
         reaper.Main_OnCommand(cmd,0)
      else
         if m then
            if m~=starttime or M~=endtime then
               reaper.GetSet_LoopTimeRange2(0, true, false, m, M, false)
               reaper.Main_OnCommand(cmd,0)
            else
               reaper.GetSet_LoopTimeRange2(0, true, false, 0, 0, false) 
               if 1 == reaper.GetToggleCommandState(1068) then
                   --reaper.Main_OnCommand(1068,0)
               end
            end
         elseif it_n>0 then
            if S~=starttime or E~=endtime then
               reaper.GetSet_LoopTimeRange2(0, true, false, S, E, false)
               reaper.Main_OnCommand(cmd,0)
            end
         elseif it_n==0 and starttime~=min or endtime~=max then
            reaper.GetSet_LoopTimeRange2(0, true, false, min, max, false) 
            reaper.Main_OnCommand(cmd,0)
         else
            reaper.GetSet_LoopTimeRange2(0, true, false, 0, 0, false)
         end
      end
      
      if 1 == reaper.GetToggleCommandState(1068) then
          reaper.Main_OnCommand(1068,0)
      end
      
      reaper.SetEditCurPos(P,false,false)
      SetRazor(razor)
  end
  
  reaper.defer(main)
  
  
  
  
