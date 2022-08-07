   
  r=reaper
  
  local midi=18639925--21004358
  local audio=18696831
  local video=28685749
  
  local function ResetColor()
  
    local n=reaper.CountSelectedMediaItems(0)
    
    for abi=1,n do
      local item=reaper.GetSelectedMediaItem(0,abi-1)
      local _,chunk=reaper.GetItemStateChunk(item,"",false)
      local name=chunk:match("FILE".."[^\n]+")
      local ext=name:match("m4a")
      local tr=reaper.GetMediaItemTrack(item)
      local color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
      if color==12599296 or color == 0 then
         take=reaper.GetActiveTake(item)
         source=reaper.GetMediaItemTake_Source(take)
         TYPE=reaper.GetMediaSourceType( source, '' )
         if TYPE=="MIDI" then
            reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",midi)
         elseif TYPE=="VIDEO" and not ext then
            reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",video)
         else
            reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",audio)
         end
      else
         reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",color)
      end
      reaper.UpdateArrange()
    end
    
    if n == 0 then
      for abi=1,reaper.CountSelectedTracks(0) do
        local track=reaper.GetSelectedTrack(0,abi-1)
        reaper.SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR",0)
      end
      reaper.UpdateArrange()
    end
    
  end

  local function main()
  
    c_chart={25182272,25196864,21790784,21004396,20994432,
    23085184,25182310,25187136,24346688,21004358,21004416,
    20989568,24330368,25182291,25192000,23101504,21004377,
    20999296,21774464,25182329,27487340,27500140,24617836,
    23896979,23888547,25652387,27487373,27491436,26780524,
    23896945,23896995,23884195,26766499,27487356,27495788,
    25666412,23896962,23892899,24603811,27487390}
    
    extname="color"
    local color = reaper.GetExtState(extname,"color",false)
    if color=="" then 
      color = 0
    end
    color=color%40+1
    toggle=0
    if reaper.CountSelectedMediaItems(0) ~= 0 then
      
      for abi=1,reaper.CountSelectedMediaItems(0) do
          item=reaper.GetSelectedMediaItem(0,abi-1)
          local _,chunk=reaper.GetItemStateChunk(item,"",false)
          local name=chunk:match("FILE".."[^\n]+")
          local ext=name:match("m4a")
          local tr=reaper.GetMediaItemTrack(item)
          local color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
          local check=reaper.GetDisplayedMediaItemColor(item)
          
          if color==12599296 or color ==0 then
           
             take=reaper.GetActiveTake(item)
             source=reaper.GetMediaItemTake_Source(take)
             TYPE=reaper.GetMediaSourceType(source, '' )
            
             if TYPE=="MIDI" then
                if check~=midi then
                   ResetColor()
                   toggle=1
                   break
                end
             elseif TYPE=="VIDEO" and not ext then
                if check~=video then
                   ResetColor()
                   toggle=1
                   break
                end
             else
                if check~=audio and check~= 0 then
                   ResetColor()
                   toggle=1
                   break 
                end
             end
          else
             if check~=color then
                ResetColor()
                toggle=1
                break
             end
          end
      end
      
      if toggle==0 then
        for abi=1,reaper.CountSelectedMediaItems(0) do
          item=reaper.GetSelectedMediaItem(0,abi-1)
          reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",c_chart[color])
          color=color%40+1
          reaper.SetExtState(extname,"color",color,false)
        end
        reaper.UpdateArrange()
        return 
      end
      
    elseif  reaper.CountSelectedTracks(0) ~= 0 then 
      
      for abi=1,reaper.CountSelectedTracks(0) do
        local track=reaper.GetSelectedTrack(0,abi-1)
        local xx=reaper.GetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR")
        if 0 ~= xx and xx~= 12599296 then
          ResetColor()
          toggle=1
          break 
        end
      end
     
      if toggle==0 then
      
        for abi=1,reaper.CountSelectedTracks(0) do
          track=reaper.GetSelectedTrack(0,abi-1)
          reaper.SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR",c_chart[color])
          color=color%40+1
          reaper.SetExtState(extname,"color",color,false)
        end
        
        reaper.UpdateArrange()
        return 
      end
    end
    
  end
      
  main()
  
  
