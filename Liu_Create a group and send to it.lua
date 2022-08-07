  
  r=reaper
  
  ---------------------------------------------------------------------------------------------------------------------
  local function promt(tr_name)
    
    if tr_name:find("Track ") then 
       tr_name="Bus name"
    end
    
    local bool,name = reaper.GetUserInputs("Bus name",1,"Dr.=0  Str.=1  B.V.=2  Gtr.=3  P.G.=4,extrawidth=50,",tr_name)
    
    if not bool then return end
    if name == "0" then name = "Drums" end
    if name == "1" then name = "Strings" end
    if name == "2" then name = "Backing Vocal" end
    if name == "3" then name = "Guitar" end
    if name == "4" then name = "Program" end
    if name == "(Bus name)" then name = "Bus" end
    return name
  end
  
  ---------------------------------------------------------------------------------------------------------------------
  local function AllGroup(n)
    
    two = {}
    for abi = 1,32 do 
      local abii=1
      local abiii=1
      repeat
      abiii = abiii+abiii
      abii=abii+1
      until abii==abi or abii==33
      two[abi]=abiii
    end
    two[1]=1
    return two[n],two
  end
  
  ---------------------------------------------------------------------------------------------------------------------
  local function FindGroup(N)
  
    local groupID={}
    local two = {}
    for abi = 1,32 do
      two[abi] = AllGroup(abi)
    end
    
    i={}
    for abi = 1,32 do
    i[abi]=33-abi
    end
    
    --reaper.ShowConsoleMsg("N = "..N.."\n")
      ten = N
      s = -1
    repeat
      ten = math.floor(ten/10)
      s=s+1
    until 0 == math.floor(ten) or time1 == os.time()-5
    
    if s == 0 then abigel = 28
    elseif s == 1 then abigel = 25
    elseif s == 2 then abigel = 22
    elseif s == 3 then abigel = 18
    elseif s == 4 then abigel = 15
    elseif s == 5 then abigel = 12
    elseif s == 6 then abigel = 8
    elseif s == 7 then abigel = 5
    elseif s == 8 then abigel = 2
    elseif s == 9 then abigel = 0
    end
    
    abigel = abigel+1
    
    local time1 = os.time()
    for abi=1,32 do
 
      local time2 = os.time()
      repeat
        if N-two[i[abigel]] >= 0 then 
           N = N-two[i[abigel]]
           groupID[abi]=i[abigel]
           --reaper.ShowConsoleMsg("group = "..groupID[abi].."\n")
          break 
        end
        abigel = abigel+1
      until abigel == 33 or time2 == os.time()-5
      
      if N == 0 then break end
      if N < 0 then return false end
    end
    
    table.sort(groupID)
    
    for apple=1,#groupID do
      --reaper.ShowConsoleMsg(groupID[apple].."|")
    end
    
    return groupID
  
  end
  
  -------------------------------------------------------------------------------------------------------------
  local function UsedGroup(bit)
    
    local time = os.time()
    local abiiiii=1
    repeat
      if AllGroup(abiiiii) == nil then break end
      if bit[abiiiii]==AllGroup(abiiiii)then
      --reaper.ShowConsoleMsg(bit[abiiiii].."|"..AllGroup(abiiiii).."\n")
      else
        return AllGroup(abiiiii),#bit
      end
      abiiiii = abiiiii+1
    until abiiiii > #bit+1 or time == os.time()-20
    
      return nil,32
  end
  
  ---------------------------------------------------------------------------------------------------------------------
  local function UnusedGroupHigh()
    
    local ID = {}
    local _,groupID=AllGroup()
    local tr = {}
    local delete={}
    
    for abi=1,reaper.CountTracks(0) do
      tr[abi]=reaper.GetTrack(0,abi-1)
      abii = 1
      local string = { 
      "VOLUME_FOLLOW","VOLUME_VCA_FOLLOW","PAN_FOLLOW","WIDTH_FOLLOW","MUTE_FOLLOW","SOLO_FOLLOW","RECARM_FOLLOW",
      "POLARITY_FOLLOW","AUTOMODE_FOLLOW"}
      repeat
        if 0 ~= reaper.GetSetTrackGroupMembershipHigh(tr[abi],string[abii],0,0) then
          ID[abii]=FindGroup(reaper.GetSetTrackGroupMembershipHigh(tr[abi],string[abii],0,0))
          --reaper.ShowConsoleMsg(" abii = "..abii.."\nstring = "..string[abii].."\n#string = "..(#string+1).."\n\n")
          table.remove(string,abii)
          for abiii=1,#ID[abii] do
            delete[#delete+1] = groupID[ID[abii][abiii]]
            --reaper.ShowConsoleMsg("ID = "..(ID[abii][abiii]).."\n".."delete = "..delete[#delete].."\n")
          end
        else
        abii = abii +1
        end
      until  abii > #string or time6 < os.time()-5
      table.sort(delete)
      local time10 = os.time()
      local lab=1
      repeat
      if delete[lab+1] == nil then break end
        if delete[lab]==delete[lab+1]then
          table.remove(delete,lab+1)
        else
          lab=lab+1
        end
      until lab == #delete or time10 == os.time()-20
      if #delete == 32 then break end --]]
    end
    
    return delete
  
  end
  
  ---------------------------------------------------------------------------------------------------------------------
  local function UnusedGroup()
    
    local ID = {}
    local _,groupID=AllGroup()
    local tr = {}
    local delete={}
    time6 = os.time() 
    
    for abi=1,reaper.CountTracks(0) do
      tr[abi]=reaper.GetTrack(0,abi-1)
      abii = 1
      local string = { 
      "VOLUME_FOLLOW","VOLUME_VCA_FOLLOW","PAN_FOLLOW","WIDTH_FOLLOW","MUTE_FOLLOW","SOLO_FOLLOW","RECARM_FOLLOW",
      "POLARITY_FOLLOW","AUTOMODE_FOLLOW"}
      repeat
        if 0 ~= reaper.GetSetTrackGroupMembership(tr[abi],string[abii],0,0) then
          ID[abii]=FindGroup(reaper.GetSetTrackGroupMembership(tr[abi],string[abii],0,0))
          --reaper.ShowConsoleMsg(" abii = "..abii.."\nstring = "..string[abii].."\n#string = "..(#string+1).."\n\n")
          table.remove(string,abii)
          for abiii=1,#ID[abii] do
            delete[#delete+1] = groupID[ID[abii][abiii]]
            --reaper.ShowConsoleMsg("ID = "..(ID[abii][abiii]).."\n".."delete = "..delete[#delete].."\n")
          end
        else
          abii = abii +1
        end
      until  abii > #string or time6 < os.time()-5
      table.sort(delete)
      local time10 = os.time()
      local lab=1
      repeat
      if delete[lab+1] == nil then break end
        if delete[lab]==delete[lab+1]then
          table.remove(delete,lab+1)
        else
          lab=lab+1
        end
      until lab == #delete or time10 == os.time()-20
      if #delete == 32 then break end --]]
    end
    
    return delete
    
  end
  
  -------------------------------------------------------------------------------
  local function main() 
    
    if 1 >= reaper.CountSelectedTracks(0) then 
       return 
    end
     
    local first_sel = reaper.GetSelectedTrack(0, 0)
    
    if not first_sel then return end
    local _,tr_name=reaper.GetTrackName(first_sel)
    local height=reaper.GetMediaTrackInfo_Value(first_sel,"I_TCPH")
    local color=reaper.GetTrackColor(first_sel)
    local name = promt(tr_name)
    if name == nil then return end
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh( 1 ) 
    
    ID1,ID1_n = UsedGroup(UnusedGroup())
    --reaper.ShowConsoleMsg("\n"..ID1_n.."|")
    if ID1_n == 32 then
       ID2,ID2_n = UsedGroup(UnusedGroupHigh())
      --reaper.ShowConsoleMsg(ID2_n.."\n")
      if ID2_n == 32 then
        reaper.ShowMessageBox("There is no more available group !  >_<","Groups are all full !!",0)
        return
      end
    end
    
    local idx = reaper.GetMediaTrackInfo_Value(first_sel, "IP_TRACKNUMBER") - 1
    reaper.InsertTrackAtIndex(idx, true)
    
    bus = reaper.GetTrack(0, idx)
    reaper.GetSetMediaTrackInfo_String( bus, "P_NAME",name, true )
    
    
    -- Loop through all tracks in the project
    for i = 0, reaper.CountSelectedTracks(0) - 1 do
      
      children = reaper.GetSelectedTrack(0, i)
      
      -- Disable Master Out
      reaper.SetMediaTrackInfo_Value(children, "B_MAINSEND", 0)
        
        local send = reaper.CreateTrackSend(children, bus)
        
        -- Make sure send is at unity, post-fader (overriding default send values)
        reaper.SetTrackSendInfo_Value(children, 0, send, "D_VOL", 1)
        reaper.SetTrackSendInfo_Value(children, 0, send, "I_SENDMODE", 0)
        
        if color ~= 0 then 
           reaper.SetTrackColor(children,color)
        end
    end
    
    reaper.SetMediaTrackInfo_Value(bus,"I_FOLDERDEPTH",1)--make parent
    reaper.SetMediaTrackInfo_Value(children,"I_FOLDERDEPTH",-1)--make children
    
    if color ~= 0 then 
       reaper.SetTrackColor(bus,color)
    else
       reaper.SetTrackSelected(bus,true)
       c_chart={
       25182272,25196864,21790784,21004396,20994432,23085184,25182310,27487390,
       25187136,24346688,21004358,21004416,20989568,24330368,25182291,25192000,
       23101504,21004377,20999296,21774464,25182329,27487340,27500140,24617836,
       23896979,23888547,25652387,27487373,27491436,26780524,23896945,23896995,
       23884195,26766499,27487356,27495788,25666412,23896962,23892899,24603811}
       local extname="color"
       local color_num = reaper.GetExtState(extname,"color",true)
       color_num=color_num%40+1
       for abi=1,reaper.CountSelectedTracks(0) do
         local track=reaper.GetSelectedTrack(0,abi-1)
         reaper.SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR",c_chart[color_num])
       end
      
       reaper.UpdateArrange()
       color_num=color_num%40+1
       reaper.SetExtState(extname,"color",color_num,true)
    end
    
    reaper.SetTrackSelected(bus,false)
    
    local tr={}
    for abi=1,reaper.CountSelectedTracks(0) do
        tr[abi] = reaper.GetSelectedTrack(0,abi-1)
        if ID1 ~= nil then
           reaper.GetSetTrackGroupMembership(bus,"VOLUME_VCA_LEAD",ID1,ID1)
           for abii=1,#string do
               reaper.GetSetTrackGroupMembership(tr[abi],string[abii],ID1,ID1)
           end
        else
           reaper.GetSetTrackGroupMembershipHigh(bus,"VOLUME_VCA_LEAD",ID2,ID2)
           for abii=1,#string do
               reaper.GetSetTrackGroupMembershipHigh(tr[abi],string[abii],ID2,ID2)
           end
        end
    end
    
    reaper.SetOnlyTrackSelected(bus)
    cmd=reaper.NamedCommandLookup("_SWS_MINTRACKS")
    reaper.Main_OnCommand(cmd,0)
    
    for abi=1,(height-22)/2 do 
        reaper.Main_OnCommand(41327,0) 
    end
    
    reaper.PreventUIRefresh( -1 )
    reaper.TrackList_AdjustWindows( false )
    reaper.UpdateArrange()
    reaper.Undo_EndBlock("Create bus for selected tracks and reroute them", 0)
    
  end
  
  string = { 
  "VOLUME_FOLLOW","VOLUME_VCA_FOLLOW","PAN_FOLLOW","WIDTH_FOLLOW","MUTE_FOLLOW","SOLO_FOLLOW","RECARM_FOLLOW",
  "POLARITY_FOLLOW","AUTOMODE_FOLLOW"}
  

  main()



