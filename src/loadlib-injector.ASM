; written by flowu


format PE console    ; define PE file format

include 'win32a.inc' ; include set of macros and definitions


entry start          ; define the entry point

section '.text' code readable executable
        start:
             ; get process handle
             push [processId]
             call getHandle
             add esp, 0x4

             mov [processHandle], eax        ; save handle

             ; print path
             push dllPath          ; load path
             push msgPath          ; load message
             call [printf]         ; call printf()
             add esp, 0x8          ; clean up

             ; print path len
             push [dllPathLen]       ; load path
             push msgPathLen       ; load message
             call [printf]         ; call printf()
             add esp, 0x8          ; clean up


             ; print handle
             mov  eax, [processHandle]
             push eax              ; load handle
             push msgHandle        ; load message
             call [printf]         ; call printf()
             add esp, 0x8          ; clean up

             ; virtualAllocEx()
             mov  eax, [processHandle]
             push 0x4              ; flProtect        (PAGE_READWRITE)
             push 0x3000           ; flAllocationType (MEM_COMMIT + MEM_RESERVE)
             push [dllPathLen]     ; dwSize           (size of dll lengtj)
             push 0x0              ; lpAddress        (0x0)
             push eax              ; load the saved/local handle
             call [VirtualAllocEx] ; call virtualalocEx()
             add esp, 0x14         ; clean up

             mov [allocatedAddr], eax        ; save allocated addy

             ; print allocated addr
             push eax              ; load handle
             push msgAllocatedAddr ; load message
             call [printf]         ; call printf()
             add esp, 0x8          ; clean up

             ; call writeProcessMemmory()
             push 0x0              ; *lpNumberOfBytesWritten
             push [dllPathLen]     ; nSize
             push dllPath          ; lpBuffer
             push [allocatedAddr]  ; lpBaseAddress,
             push [processHandle]  ; hProcess
             call [WriteProcessMemory] ; call WriteProcessMemory()
             add esp, 0x18

             ; call CreateRemoteThread()
             push 0x0              ; lpThreadId
             push 0x0              ; dwCreationFlags,
             push [allocatedAddr]  ; lpParameter
             push [LoadLibraryA]   ; lpStartAddress
             push 0x0              ; dwStackSize
             push 0x0              ; lpThreadAttribute
             push [processHandle]  ; hProcess,
             call [CreateRemoteThread] ; call CreateRemoteThread()
             add esp, 0xC          ; clean up

             ; close thread handle
             push eax
             call [CloseHandle]
             add esp, 0x4

             ; close process handle
             push [processHandle]
             call [CloseHandle]
             add esp, 0x4

             push cmdPause         ; load command
             call [system]         ; call system()
             add esp, 0x4          ; clean up

             push 0x0              ; push 0
             call [ExitProcess]    ; call ExitProcess()

        getHandle:
             push ebp
             mov  ebp, esp

             mov eax, [ebp + 0x8]  ; dwProcessId     (process id)
             mov ebx, 0x0          ; bInheritHandle  (0)
             mov ecx, 0x1F0FFF     ; dwDesiredAccess (PROCESS_ALL_ACCESS)

             push eax              ; load process id
             push ebx              ; load bInheritHandle
             push ecx              ; dwDesiredAccess
             call [OpenProcess]    ; call OpenProcess()

             mov esp, ebp
             pop ebp
             ret


section '.data' code readable writeable
        processId       dd  0  ; replace with target process id
        processHandle   dd  0
        allocatedAddr   dd  0

        dllPath         db  'C:\dummy_dll32.dll', 0x0 ; replace dll path
        dllPathLen      dd $ - dllPath

        msgPath          db 'path: %s',     0xA, 0x0
        msgPathLen       db 'path len: %d', 0xA, 0x0
        msgHandle        db 'handle: %X',   0xA, 0x0
        msgAllocatedAddr db 'allocated dll path: 0x%X', 0xA, 0x0

        cmdPause        db 'pause', 0 ; define "pause" + "\0"

section '.idata' import data readable writeable
        ; import library
        library kernel32, 'kernel32.dll', \
                msvcrt, 'msvcrt.dll'


        ; import functions
        import kernel32, \
               ExitProcess,        'ExitProcess', \
               VirtualAllocEx,     'VirtualAllocEx', \
               OpenProcess,        'OpenProcess', \
               WriteProcessMemory, 'WriteProcessMemory', \
               CreateRemoteThread, 'CreateRemoteThread', \
               LoadLibraryA,       'LoadLibraryA', \
               CloseHandle,        'CloseHandle'

        import msvcrt, \
               printf, 'printf', \
               system, 'system'
