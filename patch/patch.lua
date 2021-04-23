local mod, mod_name, oi = Mods.new_mod("Compass")

local scenegraph_def = {
  root = {
    scale = "fit",
    size = {
      1920,
      1080
    },
    position = {
      0,
      0,
      UILayer.hud
    }
  }
}

local compass_ui_def = {
  scenegraph_id = "root",
  element = {
    passes = {
      {
        style_id = "compass_text",
        pass_type = "text",
        text_id = "compass_text",
      }
    }
  },
  content = {
    compass_text = "NW",
  },
  style = {
    compass_text = {
      font_type = "hell_shark",
      font_size = 32,
      vertical_alignment = "center",
      horizontal_alignment = "center",
      offset = {
        0,
        500,
        0
      }
    }
  },
  offset = {
    0,
    0,
    0
  }
}

local fake_input_service = {
  get = function ()
    return
  end,
  has = function ()
    return
  end
}


mod.init = function()
  if mod.ui_widget then
    return
  end

  local world = Managers.world:world("top_ingame_view")
  mod.ui_renderer = UIRenderer.create(world, "material", "materials/fonts/gw_fonts")
  mod.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_def)
  mod.ui_widget = UIWidget.init(compass_ui_def)
end

mod.get_rotation = function()
  local player = Managers.player:local_player()
  local unit = player.player_unit
  local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
  local rot = Quaternion.yaw(first_person_extension:current_rotation()) * (-180/math.pi)
  if rot < 0.0 then
    rot = 360.0 + rot
  end
  return rot
end

mod.rot_to_cardinal = function(d)
  local a = 360/16
  if d <= a or d >= a*15 then
    return "N"
  elseif d <= a*3 then
    return "NE"
  elseif d <= a*5 then
    return "E"
  elseif d <= a*7 then
    return "SE"
  elseif d <= a*9 then
    return "S"
  elseif d <= a*11 then
    return "SW"
  elseif d <= a*13 then
    return "W"
  elseif d <= a*15 then
    return "NW"
  else
    return "IDK"
  end
end

local draw_hook = function(func, self, dt, t, my_player)

  if not mod.ui_widget then
    mod.init()
  end

  local rot = 999999
  if not pcall(function () rot = mod.get_rotation() end) then
    return func(self, dt, t, my_player)
  end


  local widget = mod.ui_widget
  local renderer = mod.ui_renderer
  local scenegraph = mod.ui_scenegraph

  widget.content.compass_text = mod.rot_to_cardinal(rot)

  UIRenderer.begin_pass(renderer, scenegraph, fake_input_service, dt)
  UIRenderer.draw_widget(renderer, widget)
  UIRenderer.end_pass(renderer)

  return func(self, dt, t, my_player)
end
Mods.hook.set(mod_name, "IngameHud.update", draw_hook)
