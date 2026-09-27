-- Exercise the PC input layer without mocking the new game's native memory.
local InputGuard=dofile('src/input_guard.lua')
local GameplayGuard=dofile('src/gameplay_guard.lua')
local MouseRouter=dofile('src/mouse_router.lua')
local passed=0
local function test(name,fn)
    local ok,err=pcall(fn)
    assert(ok,name..': '..tostring(err));passed=passed+1;print('PASS '..name)
end
local function scenario()
    local s={calls={},events={},focus=true,selected=true,cursor=false}
    local state={left={},right={},marker={},r={},esc={}}
    local function button(which,label)
        local value=state[which]
        local device={button=function() return value.down or false end,
            pressed=function() return value.pressed or false end,
            released=function() return value.released or false end}
        return {device=device,id=0,label=label,down=nil,held_ticks=0}
    end
    local mouse={button('left','LMB'),button('right','RMB')}
    local marker=button('marker','F7')
    local cancel_keys={button('r','R'),button('esc','Esc')}
    local function emit(kind,row)
        s.events[#s.events+1]={kind=kind,row=row};return true
    end
    local engine={Window={has_focus=function()return s.focus end,
        show_cursor=function()return s.cursor end,
        mouse_focus=function()return s.focus end}}
    local gate={identity='C4'}
    function gate.sync(allowed)return allowed and s.selected end
    local actions={}
    function actions.step(enabled,_,request)
        if enabled and request then
            if request.deploy then s.calls[#s.calls+1]='DEPLOY' end
            if request.detonate then s.calls[#s.calls+1]='DETONATE' end
        end
    end
    local router=MouseRouter.new(emit)
    local env=setmetatable({M={tick=0,elapsed_ms=0,capture=true,disabled=false},
        mouse=mouse,marker=marker,cancel_keys=cancel_keys,
        input_guard=InputGuard.new(emit),gameplay_guard=GameplayGuard.new(engine,emit),
        router=router,actions=actions,gate=gate,emit=emit,
        focus=function()return s.focus end,
        sample=function(b)return b.device.button(b.id),b.device.pressed(b.id),b.device.released(b.id) end,
        poll_mouse=function(b,down)b.down=down end},{__index=_G})
    local f=assert(io.open('src/pc_tick.lua','rb'))
    local source=f:read('*a');f:close()
    local chunk=assert(loadstring(source..'\nreturn tick,after_update'))
    setfenv(chunk,env)
    local tick,after_update=chunk()
    function s.step(dt)
        tick(dt or 1/60);after_update()
        for _,v in pairs(state) do v.pressed=false;v.released=false end
    end
    function s.press(which,dt)
        state[which].down=true;state[which].pressed=true;s.step(dt)
    end
    function s.release(which,dt)
        state[which].down=false;state[which].released=true;s.step(dt)
    end
    function s.begin()s.step();s.step() end
    return s
end

for _,hz in ipairs({30,60,144}) do
    test('mouse edges and holds at '..hz..' Hz',function()
        local s=scenario();s.begin();s.press('left',1/hz)
        for _=1,hz do s.step(1/hz) end
        assert(#s.calls==1 and s.calls[1]=='DEPLOY')
        s.release('left');s.press('right',1/hz)
        for _=1,hz do s.step(1/hz) end
        assert(#s.calls==2 and s.calls[2]=='DETONATE')
    end)
end
test('simultaneous mouse buttons prioritize Detonate',function()
    local s=scenario();s.begin()
    -- A single frame contains both fresh edges.
    local f=assert(io.open('src/pc_tick.lua','rb'));local source=f:read('*a');f:close()
    assert(source:find("label='RMB'",1,true) and source:find("label='LMB'",1,true))
    -- MouseRouter's priority is also covered by the existing router regression.
    local router=MouseRouter.new(function(kind,row)
        assert(kind=='simultaneous_input' and row.resolution=='DETONATE_PRIORITY');return true
    end)
    router.sample('C4',{down=false,pressed=false},{down=false,pressed=false})
    local r=router.sample('C4',{down=true,pressed=true,label='RMB'},
        {down=true,pressed=true,label='LMB'})
    assert(r.detonate and not r.deploy)
end)
test('reload and UI require released baseline',function()
    local s=scenario();s.begin();s.press('r');s.press('left');s.release('r')
    for _=1,5 do s.step() end
    assert(#s.calls==0)
    s.release('left');s.step();s.press('left')
    assert(#s.calls==1 and s.calls[1]=='DEPLOY')
    s.release('left');s.cursor=true;s.step();s.press('right')
    s.cursor=false;s.step();assert(#s.calls==1)
    s.release('right');s.step();s.press('right')
    assert(#s.calls==2 and s.calls[2]=='DETONATE')
end)
test('other weapon has no C4 action route',function()
    local s=scenario();s.selected=false;s.begin();s.press('left');s.press('right')
    assert(#s.calls==0)
end)
test('assembled PC runtime has no controller input source',function()
    local f=assert(io.open('src/c4_pc_auto.lua','rb'))
    local source=f:read('*a');f:close()
    assert(not source:find('GamepadInput',1,true))
    assert(not source:find('engine.Pad',1,true))
    assert(not source:find('pad.sample',1,true))
end)
print('PC input tests:',passed)
