-- EXP07 PC route: automatic C4 activation, with keyboard and mouse only.
local last_guard_blocked=false
local function suspend_actions()
    router.sample(nil,{down=false,pressed=false},{down=false,pressed=false})
    actions.step(false,M.elapsed_ms,{allowed=false})
end
local function tick(dt)
    M.phase='before_original_update';M.tick=M.tick+1
    if type(dt)=='number' and dt>=0 and dt<math.huge then M.elapsed_ms=M.elapsed_ms+dt*1000 end
    local md,mp=sample(marker)
    if mp and marker.down~=true then emit('manual_marker',{input='F7',enabled=M.capture}) end
    marker.down=md
    local ld,lp,lr=sample(mouse[1]);local rd,rp,rr=sample(mouse[2])
    last_guard_blocked=input_guard.sample(cancel_keys)
    local released=not ld and not rd and not lp and not rp
    last_controls_released=released
    last_controls_allowed=gameplay_guard.sample(focus(),last_guard_blocked,released)
    local owned=gate.sync(last_controls_allowed,released)
    -- The router's first channel detonates and its second channel deploys.
    local request=router.sample(owned and gate.identity or nil,
        {down=rd,pressed=rp,released=rr,label='RMB'},
        {down=ld,pressed=lp,released=lr,label='LMB'})
    poll_mouse(mouse[1],ld,lp,lr);poll_mouse(mouse[2],rd,rp,rr)
    actions.step(owned and last_controls_allowed,M.elapsed_ms,{
        deploy=request.deploy,detonate=request.detonate,allowed=last_controls_allowed,
        mouse=false,deploy_input='LMB',detonate_input='RMB'})
    if file and M.tick%60==0 then assert(file:flush(),'log_flush_failed') end
end
local function after_update()
    M.phase='after_original_update'
    last_controls_allowed=gameplay_guard.sample(focus(),last_guard_blocked,last_controls_released)
        and not M.disabled
    local owned=gate.sync(last_controls_allowed,last_controls_released)
    if not owned or not last_controls_allowed then suspend_actions() end
end
