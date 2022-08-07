  
  r=reaper
  
  local function main()
      
      local _,grid,swing,swingamt = reaper.GetSetProjectGrid(0,false)--, optional number division, optional integer swingmode, optional number swingamt)
      local triplet = ((1/grid)/3)%1==0
      
      if triplet or swing==0 then
         return
      end
      
      if swingamt ==0 then 
         swingamt=0.6
      end
      
      reaper.GetSetProjectGrid(0,true,grid,1,swingamt+0.03)

      
  end
  
  reaper.defer(main)
