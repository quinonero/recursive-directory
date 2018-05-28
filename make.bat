@echo off
c:\masm32\bin\ml /c /Zd /coff dirrec.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE dirrec.obj
pause