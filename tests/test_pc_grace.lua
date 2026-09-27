-- The PC controller uses a synthetic native action lifecycle; no game calls.
local Controller=dofile('src/pc_action_controller.lua')
local passed=0
local function test(name,fn)
    local ok,err=pcall(fn)
    assert(ok,name..': '..tostring(err));passed=passed+1;print('PASS '..name)
end
local function make()
    local s={identity='C4-A',scope=false,active=false,native_block=false,
        native_fire_held=false,ability_id=nil,calls={},events={}}
    local backend={}
    function backend.snapshot()
        if not s.identity then return nil,'outside_c4' end
        local gate=s.native_block and 'NATIVE_WEAPON_BLOCKED' or
            s.scope and 'OUTSIDE_EXP03_AVATAR_SCOPE' or
            s.native_fire_held and 'ORIGINAL_FIRE_ACTIVE' or
            s.active and 'NATIVE_ACTION_ACTIVE' or 'READY'
        local row={context_status='c4_context_observed',current_weapon='C4_DETONATOR',
            current_fire_mode='DEPLOY',selected_entity_id=s.identity,
            action_gate=gate,test_avatar_allowed=not s.scope,
            native_fire_held=s.native_fire_held,native_action_active=s.active,
            active_ability_id=s.ability_id,deploy_ammo_ready=true}
        local cap={identity=s.identity,blocked=s.native_block or s.scope or s.native_fire_held,
            interrupt=s.scope or s.native_fire_held,active=s.active,
            ability_id=s.ability_id,deploy_ready=true}
        return row,nil,cap
    end
    function backend.execute(action)
        s.calls[#s.calls+1]=action
        s.active=true;s.ability_id=action=='DEPLOY' and 521 or 520
        return s.ability_id
    end
    s.controller=Controller.new(backend,function(kind,fields)
        s.events[#s.events+1]={kind=kind,fields=fields};return true
    end,{deploy_input='LMB',detonate_input='RMB'})
    function s.step(now,action,allowed)
        s.controller.step(allowed~=false,now,{allowed=allowed~=false,
            deploy=action=='DEPLOY',detonate=action=='DETONATE',
            deploy_input='LMB',detonate_input='RMB'})
    end
    function s.event(kind)
        for i=#s.events,1,-1 do
            if s.events[i].kind==kind then return s.events[i].fields end
        end
    end
    s.step(0)
    return s
end

for _,delay in ipairs({50,100,200}) do
    test('RMB tap survives '..delay..' ms transient scope veto',function()
        local s=make();s.scope=true;s.step(20,'DETONATE')
        assert(#s.calls==0 and s.event('scope_grace_started'))
        s.scope=false;s.step(20+delay)
        assert(#s.calls==1 and s.calls[1]=='DETONATE')
        assert(s.event('action_call').press_to_call_ms==delay)
        s.step(250);assert(#s.calls==1)
    end)
end
test('scope veto beyond 200 ms expires without later detonation',function()
    local s=make();s.scope=true;s.step(20,'DETONATE')
    s.step(221);assert(s.event('scope_grace_dropped').reason=='scope_grace_expired')
    s.scope=false;s.step(280);assert(#s.calls==0)
end)
test('repeated RMB edge coalesces while grace is waiting',function()
    local s=make();s.scope=true;s.step(20,'DETONATE');s.step(40,'DETONATE')
    assert(s.event('action_rejected').reason=='scope_grace_coalesced')
    s.scope=false;s.step(90);assert(#s.calls==1)
end)
test('brief scope veto during Deploy transfers to original one-slot queue',function()
    local s=make();s.step(20,'DEPLOY');assert(#s.calls==1)
    s.scope=true;s.step(30,'DETONATE');s.scope=false;s.step(80)
    assert(#s.calls==1 and s.event('action_queued').reason=='scope_grace_recovered')
    s.active=false;s.ability_id=nil;s.step(300)
    assert(#s.calls==2 and s.calls[2]=='DETONATE')
    assert(s.event('action_call').press_to_call_ms==270)
end)
test('queued Detonate keeps its original 1.5-second deadline',function()
    local s=make();s.step(20,'DEPLOY')
    s.scope=true;s.step(30,'DETONATE');s.scope=false;s.step(80)
    s.step(1540);assert(s.event('pending_dropped').reason=='pending_expired')
    s.active=false;s.ability_id=nil;s.step(1600);assert(#s.calls==1)
end)
for _,kind in ipairs({'pause','weapon','native_block','fire_held','new_deploy'}) do
    test('grace cancels on '..kind,function()
        local s=make();s.scope=true;s.step(20,'DETONATE')
        if kind=='pause' then s.step(60,nil,false)
        elseif kind=='weapon' then s.identity=nil;s.step(80)
        elseif kind=='native_block' then s.scope=false;s.native_block=true;s.step(80)
        elseif kind=='fire_held' then s.scope=false;s.native_fire_held=true;s.step(80)
        else s.step(80,'DEPLOY') end
        s.scope=false;s.native_block=false;s.native_fire_held=false
        if kind=='weapon' then s.identity='C4-B' end
        s.step(160);s.step(240)
        assert(#s.calls==0)
        assert(s.event('scope_grace_dropped'))
    end)
end
test('left click and other weapons never use the RMB grace',function()
    local s=make();s.scope=true;s.step(20,'DEPLOY')
    assert(#s.calls==0 and not s.event('scope_grace_started'))
    s.scope=false;s.step(80);assert(#s.calls==0)
    s.identity=nil;s.step(140,'DETONATE')
    assert(#s.calls==0 and not s.event('scope_grace_started'))
end)
print('PC grace tests:',passed)
