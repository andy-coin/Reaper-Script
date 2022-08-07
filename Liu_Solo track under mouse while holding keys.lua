  
  r=reaper
  
    
    local function main()
      
      play=reaper.GetPlayState()
      --if play==1 or 5 then return end
      
      act = "_RS8bf8d57a35c4af5d9d59e3e6e4251bd13a274835"
      interval = 3
      midi = false
      
      script_path = debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]]
      dofile(script_path .. "Liu_Solo track under mouse while holding keys(sub).lua")
    
    end

    reaper.defer(main)

  


