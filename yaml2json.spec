# -*- mode: python -*-
import os, six
block_cipher = None

a = Analysis(['yaml2json.py'],
             pathex=None,
             binaries=None,
             datas=[
             ],
             hiddenimports=['pyaml'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)

pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='yaml2json',
          debug=False,
          strip=True,
          upx=True,
          console=True)
