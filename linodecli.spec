# -*- mode: python -*-
import os, six, linodecli
block_cipher = None

a = Analysis(['linode-cli.py'],
             pathex=None,
             binaries=None,
             datas=[
                 (six.__file__, '.'),
                 (os.path.dirname(linodecli.__file__), 'linodecli')
             ],
             hiddenimports=['linodecli'],
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
          name='linode-cli',
          debug=False,
          strip=True,
          upx=True,
          console=True)
