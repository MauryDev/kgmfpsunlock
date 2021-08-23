

format PE GUI 4.0 DLL
entry DllEntryPoint

include 'win32a.inc'
macro DO_API_UnityPlay offset,method_ptr
{
    mov eax,[UnityPlayerAddress]
    add eax,offset
    mov [method_ptr],eax
}
macro UnityInvoke proc,[arg]                ; indirectly call Unity procedure
 { common
    size@ccall = 0
    if ~ arg eq
   reverse
    pushd arg
    size@ccall = size@ccall+4
   common
    end if
    call dword [proc]
    if size@ccall
    add esp,size@ccall
    end if }
section '.text' code readable executable

proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
        cmp [fdwReason],1
        jne .continue
        push UnityPlayerNameDLL
        call dword [GetModuleHandleA]
        mov [UnityPlayerAddress],eax
        call ResolveMethods
        .continue:
        mov eax,TRUE
        ret
endp

proc SetFPS
     push ebp
     mov ebp,esp
     UnityInvoke set_VSCount,0
     mov eax,[FPS_Limit_Value]
     mov ebx,[ebp+8]
     mov [eax],ebx
     pop ebp
     ret
endp 

proc ResolveMethods
     push ebp
     mov ebp,esp
     DO_API_UnityPlay 0x749770,set_VSCount
     DO_API_UnityPlay 0x10B0B3C,FPS_Limit_Value
     pop ebp
     ret
endp

section '.data' data readable writeable

UnityPlayerNameDLL:
db "UnityPlayer.dll",0
UnityPlayerAddress:
dd 0
set_VSCount:
dd 0
FPS_Limit_Value:
dd 0

section '.idata' import data readable writeable
  library kernel,'kernel32.dll'

  import kernel,\
         GetModuleHandleA,'GetModuleHandleA'

section '.edata' export data readable

  export 'FPSUnlock.DLL',\
         SetFPS,'SetFPS'

section '.reloc' fixups data readable discardable

  if $=$$
    dd 0,8              ; if there are no fixups, generate dummy entry
  end if
