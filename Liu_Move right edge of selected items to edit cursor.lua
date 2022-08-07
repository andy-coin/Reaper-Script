  
  r=reaper
  
  -----------------------SAVE INITIAL SELECTED ITEMS------------------------------------
  itemzzz = {}
  local function SaveSelectedItems (table)--itemzzz
    for i = 0, reaper.CountSelectedMediaItems(0)-1 do
      table[i+1] = reaper.GetSelectedMediaItem(0, i)
    end
    return table
  end
  
  -----------------------------RESTORE INITIAL SELECTED ITEMS------------------------------------
  
  local function RestoreSelectedItems (table)--itemzzz
    reaper.Main_OnCommand(40289, 0) 
    for _, item in ipairs(table) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
  
  --------------
  local function main()
      
      SaveSelectedItems(itemzzz)
      
      reaper.Main_OnCommand(40289,0)
      
      abi=1
      repeat
          reaper.SetMediaItemSelected(itemzzz[abi],true)
          local tr=reaper.GetMediaItemTrack(itemzzz[abi])
          i=1
          repeat
              if abi+1<=#itemzzz then 
                 next=reaper.GetMediaItemTrack(itemzzz[abi+i])
                 if tr==next then
                    reaper.SetMediaItemSelected(itemzzz[abi+i],true)
                    i=i+1
                 else
                    abi=abi+i
                    break
                 end
              else 
                 abi=abi+1
                 break
              end
          until abi>#itemzzz
          reaper.Main_OnCommand(41307,0)
          reaper.Main_OnCommand(40289,0)
      until abi>#itemzzz 
      
      RestoreSelectedItems(itemzzz)
      
  end
  
  main()
