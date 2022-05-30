-- dump print, also logs
function dprint(msg)
  if game then 
    if settings.global["fpf-debug"].value then
      game.print({"", msg })
    end
    
    lprint(msg)
  end
end

-- log print
function lprint(msg)
  if game then 
    if settings.global["fpf-logging"].value then
      game.write_file("fpf-logs.txt", { "", msg .. "\r\n" }, true)
    end
  end
end


