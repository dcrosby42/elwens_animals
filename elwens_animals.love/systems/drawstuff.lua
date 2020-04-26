local Debug = require("mydebug").sub("DrawStuff", true, true, true)

local BOUNDS = false
local TwoPi = 2 * math.pi

local Plugins = {}

local function drawSystem(estore, res)
  local drawBounds = false
  estore:walkEntities(
    hasComps("debug"),
    function(e)
      if e.debugs.drawbounds then
        drawBounds = e.debugs.drawbounds.value
      end
    end
  )

  estore:walkEntities(
    hasComps("pos"),
    function(e)
      for i = 1, #Plugins do
        Plugins[i](e, estore, res)
      end

      --
      -- BUTTON (hold-button)
      --
      if e.button then
        if e.button.shape == "circle" then
          if e.button.kind == "hold" and e.timers and e.timers.holdbutton then
            local elapsed = e.button.holdtime - e.timers.holdbutton.t
            if elapsed > 0 then
              -- local lw = love.graphics.getLineWidth()
              -- love.graphics.setLineWidth(1)

              local x, y = getPos(e)
              local a1 = -math.pi / 2
              local a2 = a1 + (elapsed / e.button.holdtime) * TwoPi
              love.graphics.setColor(1, 1, 1, 0.5)
              love.graphics.arc("fill", x, y, e.button.radius, a1, a2, 30)
            -- Debug.println("arc: "..x..", "..y.." "..a1.." _ "..a2)
            -- love.graphics.setLineWidth(lw)
            end
          elseif e.button and e.button.kind == "tap" and e.button.touchid ~= "" then
            local x, y = getPos(e)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.circle("fill", x, y, e.button.radius)
          end
        end
      end

      --
      -- PIC
      --
      if e.pic then
        local pic = e.pic
        local x, y = getPos(e)
        local r = 0
        if pic.r then
          r = r + pic.r
        end
        if e.pos.r then
          r = r + e.pos.r
        end
        local picRes = res.pics[pic.id]
        if not picRes then
          error("No pic resource '" .. pic.id .. "'")
        end

        local offy = 0
        local offy = 0
        if pic.centerx ~= "" then
          -- offx = pic.centerx * picRes:getWidth() * pic.sx
          offx = pic.centerx * picRes.rect.w
        else
          offx = pic.offx
        end
        if pic.centery ~= "" then
          -- offy = pic.centery * picRes:getHeight() * pic.sy
          offy = pic.centery * picRes.rect.h
        else
          offy = pic.offy
        end

        love.graphics.setColor(unpack(pic.color))

        love.graphics.draw(picRes.image, picRes.quad, x, y, r, pic.sx, pic.sy, offx, offy)

        if pic.drawbounds then
          love.graphics.rectangle(
            "line",
            x - (pic.sx * offx),
            y - (pic.sy * offy),
            picRes.rect.w * pic.sx,
            picRes.rect.h * pic.sy
          )
        end

        if e.names and e.names.mouthcoal_1 then
          Debug.noteObj(
            {e.eid, "mouth1"},
            {
              picRes = tostring(picRes),
              x = x,
              y = y,
              r = r,
              sx = picsx,
              sy = pic.sy,
              offx = offx,
              offy = offy,
              color = colorstring(pic.color)
            }
          )
        end
      end

      --
      -- ANIM
      --
      if e.anims then
        -- local anim = e.anim
        for _, anim in pairs(e.anims) do
          local animRes = res.anims[anim.id]
          if not animRes then
            error("No anim resource '" .. anim.id .. "'")
          end
          local timer = e.timers[anim.name]
          if timer then
            local picRes = animRes.getFrame(timer.t)
            local x, y = getPos(e)
            local r = 0
            if anim.r then
              r = r + anim.r
            end
            if e.pos.r then
              r = r + e.anim.r
            end

            local offy = 0
            local offy = 0
            if anim.centerx ~= "" then
              offx = anim.centerx * picRes.rect.w
            else
              offx = anim.offx
            end
            if anim.centery ~= "" then
              offy = anim.centery * picRes.rect.h
            else
              offy = anim.offy
            end

            love.graphics.setColor(unpack(anim.color))

            love.graphics.draw(picRes.image, picRes.quad, x, y, r, anim.sx, anim.sy, offx, offy)

            if anim.drawbounds then
              love.graphics.rectangle(
                "line",
                x - (anim.sx * offx),
                y - (anim.sy * offy),
                picRes.rect.w * anim.sx,
                picRes.rect.h * anim.sy
              )
            end
          else
            print("For eid=" .. e.eid .. " anim.cid=" .. anim.cid .. " NEED TIMER named '" .. anim.name .. "'")
          end -- end if timer
        end
      end

      --
      -- LABEL
      --
      if e.label then
        local label = e.label
        if label.font then
          local font = res.fonts[label.font]
          if font then
            love.graphics.setFont(font)
          end
        end
        love.graphics.setColor(unpack(label.color))
        local x, y = getPos(e)
        if label.height then
          if label.valign == "middle" then
            local halfLineH = love.graphics.getFont():getHeight() / 2
            y = y + (label.height / 2) - halfLineH
          elseif label.valign == "bottom" then
            local lineH = love.graphics.getFont():getHeight()
            y = y + label.height - lineH
          end
        end
        if label.width then
          local align = label.align
          if not align then
            align = "left"
          end
          love.graphics.printf(label.text, x, y, label.width, label.align)
        else
          love.graphics.print(label.text, x, y)
        end
      end

      --
      -- CIRCLE
      --
      if e.circles then
        for _, circle in pairs(e.circles) do
          local x, y = getPos(e)
          x = x + circle.offx
          y = y + circle.offy
          love.graphics.setColor(unpack(circle.color))
          local style = "line"
          if circle.fill then
            style = "fill"
          end
          love.graphics.circle(style, x, y, circle.radius)
        end
      end

      --
      -- RECTANGLE
      --
      if e.rect then
        local x, y = getPos(e)
        local rect = e.rect
        love.graphics.setColor(unpack(rect.color))
        love.graphics.rectangle(rect.style, x - rect.offx, y - rect.offy, rect.w, rect.h)
      end

      --
      -- POLYGON
      --
      if e.polygonShape then
        local st = e.lineStyle
        local pol = e.polygonShape
        if st and st.draw then
          love.graphics.setColor(unpack(st.color))
          love.graphics.setLineWidth(st.linewidth)
          love.graphics.setLineStyle(st.linestyle)
          local verts = {}
          local x, y = e.pos.x, e.pos.y
          for i = 1, #pol.vertices, 2 do
            verts[i] = x + pol.vertices[i]
            verts[i + 1] = y + pol.vertices[i + 1]
          end
          if st.closepolygon then
            table.insert(verts, x + pol.vertices[1])
            table.insert(verts, y + pol.vertices[2])
          end
          love.graphics.line(verts)
        end
      end

      if BOUNDS or drawBounds then
        if e.pos then
          local x, y = getPos(e)
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.line(x - 5, y, x + 5, y)
          love.graphics.line(x, y - 5, x, y + 5)
          if e.bounds then
            local b = e.bounds
            love.graphics.rectangle("line", x - b.offx, y - b.offy, b.w, b.h)
          end
        end
      end
    end
  )
end

return {
  drawSystem = drawSystem,
  addPlugin = function(fn)
    table.insert(Plugins, fn)
  end
}
