  
  
  local function rgbToHex(value)
    local hexadecimal = '0X'
  
    --for key, value in pairs(rgb) do
      local hex = ''
  
      while(value > 0)do
        local index = math.fmod(value, 16) + 1
        value = math.floor(value / 16)
        hex = string.sub('0123456789ABCDEF', index, index) .. hex      
      end
  
      if(string.len(hex) == 0)then
        hex = '00'
  
      elseif(string.len(hex) == 1)then
        hex = '0' .. hex
      end
  
      hexadecimal = hexadecimal .. hex
    --end
  
    return hexadecimal
  end
  
  local function PickColor()
  
    item=reaper.GetSelectedMediaItem(0,0)
    tr=reaper.GetSelectedTrack(0,0)
    tr_color=reaper.GetMediaTrackInfo_Value(tr,"I_CUSTOMCOLOR")
    --color=reaper.GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR")
    --r,g,b=reaper.ColorFromNative(color)
    --color=reaper.ColorToNative(160,0,0)|0x1000000
    tr_color=rgbToHex(tr_color)
    --reaper.ShowConsoleMsg(r.."|"..g.."|"..b)
    reaper.ShowConsoleMsg(tr_color)
    --reaper.SetMediaItemInfo_Value(item,"I_CUSTOMCOLOR",color)
    --reaper.UpdateArrange()
    return color
  end
 
  PickColor()
  --reaper.ShowConsoleMsg(color)
  --color=26317201
  --color=25198720
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  
