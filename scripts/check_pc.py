#!/usr/bin/env python3
"""Validate the PC-only 0.7.1 source and record reproducible input hashes."""
import hashlib
import json
import re
import subprocess

from assemble_pc import ROOT,assemble


def sha(path):return hashlib.sha256((ROOT/path).read_bytes()).hexdigest()


def main():
    source_hash=assemble()
    source=(ROOT/'src/c4_pc_auto.lua').read_text()
    project=json.loads((ROOT/'project.json').read_text())
    layout=json.loads((ROOT/'evidence/pc-layout.json').read_text())
    assert project['source']=='src/c4_pc_auto.lua'
    assert project['game_build']==layout['game_build']=='25480438'
    assert source_hash==project['tested_source_sha256']
    assert layout['module_sha256'] in source
    assert len(layout['signatures'])>=25
    assert "version='0.7.1-exp07'" in source
    assert 'GamepadInput' not in source and 'engine.Pad' not in source
    assert 'pad.sample' not in source and 'gamepad_mapping' not in source
    assert "deploy_key='LMB', detonate_key='RMB'" in source
    assert "mouse_mapping='LMB_DEPLOY_RMB_DETONATE'" in source
    assert source.count('k.WriteProcessMemory(')==1
    assert "k.WriteProcessMemory(process,ffi.cast('void *',flags_address+1),target,1,count)" in source
    for pattern in (r'VirtualProtect',r'VirtualAlloc',r'SendInput',r'mouse_event',
                    r'keybd_event',r'XInputSetState',r'ffi\.C\.',r'\.set_down_threshold\('):
        assert not re.search(pattern,source),pattern
    calls=re.findall(r"ffi\.cast\('[^'\n]*\(\*\)[^'\n]*',game\+(0x[0-9a-f]+)\)",source)
    assert calls==['0x7caf40','0x744690','0x742900','0x7533c0'],calls
    assert "deadline_ms=200" in source and 'scope_grace_started' in source
    commands=[['luajit','tests/test_pc.lua'],
              ['luajit','tests/test_pc_grace.lua'],
              ['luajit','-e',"assert(loadfile('src/c4_pc_auto.lua')); print('PASS PC runtime Lua syntax')"]]
    runs=[]
    for command in commands:
        run=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
        print(run.stdout,end='');print(run.stderr,end='')
        runs.append(dict(command=command,exit_code=run.returncode,
                         stdout=run.stdout,stderr=run.stderr))
    files={str(p.relative_to(ROOT)) for directory,pattern in
           [('src','*.lua'),('scripts','*.py'),('tests','test_pc*.lua'),
            ('evidence','*-layout.json')] for p in (ROOT/directory).glob(pattern)}
    files.update({'dependencies.lock.json','project.json','docs/INSTALL.txt','LICENSE'})
    report=dict(evidence_kind='PC_INPUT_MOCK_AND_STATIC',version=project['version'],
        source_sha256=source_hash,layout_sha256=sha('evidence/pc-layout.json'),
        exit_code=0 if all(r['exit_code']==0 for r in runs) else 1,
        passed=sum(r['stdout'].count('PASS ') for r in runs),runs=runs,
        direct_native_calls=calls,game_executed=False,
        native_actions_live_tested=False,controller_support=False,
        mapping=dict(mouse='LMB Deploy / RMB Detonate'),
        files={p:sha(p) for p in sorted(files)})
    (ROOT/'evidence/pc-offline-tests.json').write_text(json.dumps(report,indent=2)+'\n',newline='\n')
    raise SystemExit(report['exit_code'])


if __name__=='__main__':main()
