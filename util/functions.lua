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

local function swap_ingredient_in_ingredient_group(ingredients, ingredientName, substituteIngredient) 
  local newIngredients = {}
  for i, ing in pairs (ingredients) do
    if ing.name ~= ingredientName then
      table.insert(newIngredients, ing)
    else
      table.insert(newIngredients, substituteIngredient)
    end
  end
  return newIngredients
end

function swap_ingredient_in_recipe(recipe, ingredientName, substituteIngredient, substituteExpensiveIngredient) 
  if recipe.expensive then
    recipe.espensive = swap_ingredient_in_ingredient_group(recipe.espensive.ingredients, ingredientName, substituteExpensiveIngredient or substituteIngredient)
    recipe.normal = swap_ingredient_in_ingredient_group(recipe.normal.ingredients, ingredientName, substituteIngredient)
  else
    recipe.ingredients = swap_ingredient_in_ingredient_group(recipe.ingredients, ingredientName, substituteIngredient)
  end
end

