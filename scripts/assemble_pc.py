#!/usr/bin/env python3
"""Assemble the PC-only successor without changing the historical releases."""
import hashlib
import json

from assemble_automatic import ROOT, assemble as assemble_automatic
from assemble_context import replace_once


def assemble():
    assemble_automatic()
    source=(ROOT/'src/c4_dual_input_auto.lua').read_text()
    source=replace_once(source,"version='0.6.1-exp06'","version='0.7.1-exp07'")
    source=replace_once(source,
        '-- EXP06: automatic C4 mouse/gamepad routing; temporary reload/UI/focus pauses.',
        '-- EXP07: automatic PC mouse/keyboard C4 routing; temporary reload/UI/focus pauses.')
    module='local GamepadInput=(function()\n'+(ROOT/'src/gamepad_input.lua').read_text()+'\nend)()\n'
    source=replace_once(source,module,'')
    old='local ActionController=(function()\n'+(ROOT/'src/action_controller.lua').read_text()+'\nend)()\n'
    new='local ActionController=(function()\n'+(ROOT/'src/pc_action_controller.lua').read_text()+'\nend)()\n'
    source=replace_once(source,old,new)
    source=replace_once(source,
        'local file,actions,focus,gate,router,cancel_keys,gamepad,input_guard,gameplay_guard\nlocal last_pad_available=true',
        'local file,actions,focus,gate,router,cancel_keys,input_guard,gameplay_guard')
    source=replace_once(source,(ROOT/'src/automatic_tick.lua').read_text(),
        (ROOT/'src/pc_tick.lua').read_text())
    source=replace_once(source,'    gamepad=GamepadInput.new(engine,emit)\n','')
    source=replace_once(source,
        ",gamepad_mapping='LT_L2_DEPLOY_RT_R2_DETONATE'",'')
    source=replace_once(source,
        '[C4 Dual Input EXP06] Automatic C4; LMB/LT/L2 Deploy; RMB/RT/R2 Detonate; F7 marker. Log: ',
        '[C4 PC EXP07] Automatic C4; LMB Deploy; RMB Detonate; F7 marker. Log: ')
    # The current PC build uses its own guarded native layout. Historical
    # EXP04/EXP05/EXP06 sources and ZIPs continue to target their old build.
    layout=json.loads((ROOT/'evidence/pc-layout.json').read_text())
    old_layout_line=next(line for line in source.splitlines() if line.startswith('local ActionLayout='))
    signatures=','.join('{rva='+str(s['rva'])+',hex="'+s['hex']+'"}' for s in layout['signatures'])
    new_layout_line='local ActionLayout={module_sha256="'+layout['module_sha256']+'",signatures={'+signatures+'}}'
    source=replace_once(source,old_layout_line,new_layout_line)
    def change(old,new):
        nonlocal source
        assert old in source,old
        source=source.replace(old,new)
    globals_new={
        '0x276c190':'0x3326468','0x276c318':'0x33265e8',
        '0x276c370':'0x3326640','0x276c390':'0x3326660',
        '0x276c3b8':'0x3326688','0x276c3d0':'0x33266a0',
        '0x276c448':'0x3326718','0x276c468':'0x3326738',
        '0x276c728':'0x3326a10','0x276c788':'0x3326a70',
        '0x276c7c0':'0x3326aa8','0x276c928':'0x3326c10',
        '0x276c9f0':'0x3326ce0','0x276ca00':'0x3326cf0',
        '0x276ca30':'0x3326d20','0x276f0c0':'0x346bf98',
        '0xf19a70':'0xf1aeb0','0xf21a88':'0xf22ec8','0xf31ad8':'0xf32f18',
        '0xf11888':'0xf12cd0','0xf113a8':'0xf12820',
        '0x7c21a0':'0x7caf40','0x73ca00':'0x744690',
        '0x73bf20':'0x742900','0x74b220':'0x7533c0',
        '0x7cd36b':'0x7d60db','0x7cd310':'0x7d6080',
        '0x211c5b0':'0x23c6d70',
        '0x738be0':'0x7406a0','0x73ce40':'0x744ad0',
        '0x73cf80':'0x744c20',
        '0x73d210':'0x744ec0','0x91c940':'0x927050',
        '0x76f3d0':'0x7777a0','0x76f320':'0x7776f0',
        '0x76a1e0':'0x7725b0',
        '0x4f7ff0':'0x4fdd20','0x4f7bc0':'0x4fd8e0',
        '0x508be0':'0x50e2c0'}
    for old,new in globals_new.items():
        if old in source:change(old,new)
    change('24826606','25480438')
    change('local base=ptr(wd+0x58,true)+di*0x3e0',
           'local base=ptr(wd+0x58,true)+di*0x3f0')
    change('local types=read(base+0x340,16,true)',
           'local types=read(base+0x350,16,true)')
    change('local start=tonumber(hash:sub(9,16),16)%16',
           'local start=0\n    for i=1,16,2 do start=(start*256+tonumber(hash:sub(i,i+1),16))%18 end')
    change('for probe=0,15 do','for probe=0,17 do')
    change('((start+probe)%16)*16','((start+probe)%18)*16')
    change("assert(ti<16,'ability_template_index_limit')",
           "assert(ti<18,'ability_template_index_limit')")
    change('templates+256+ti*0x58','templates+0x120+ti*0x58')
    change('local si=index(wm,0x28,e.weapon_id)',
           'local si=index(wm,0x1030,e.weapon_id)')
    change('ptr(wm+0x50,true)+si*0x1b8+0x19c',
           'ptr(wm+0x1058,true)+si*0x1b8+0x19c')
    change('override*0x84,0x84,true','override*0x88,0x88,true')
    change(')%46 end',')%50 end')
    change('for probe=0,45 do','for probe=0,49 do')
    change('((start+probe)%46)*16','((start+probe)%50)*16')
    change("assert(ti<46,'rounds_template_index_limit')",
           "assert(ti<50,'rounds_template_index_limit')")
    change('templates+0x2e0+ti*0x84,0x84,true',
           'templates+0x320+ti*0x88,0x88,true')
    change('0x1148','0x2148')
    change('00001148','00002148')
    change('Weapon.flags.bit12','Weapon.flags.bit13')
    change("'\\72\\17\\0\\0'","'\\72\\33\\0\\0'")
    change("'\\17'","'\\33'")
    output=ROOT/'src/c4_pc_auto.lua'
    output.write_text(source,newline='\n')
    return hashlib.sha256(source.encode()).hexdigest()


if __name__=='__main__':print(assemble())
