; HELPER: https://gist.github.com/gabe31415/fe2a7bd7213739b2bc407ecf0e100f9a
; HELPER: https://gist.github.com/sankarara/5498337c33d42cb99efd
; HELPER: https://www.autohotkey.com/docs/KeyList.htm

; 1. Prettyfy: http://sl5.it/SL5_preg_contentFinder/examples/AutoHotKey/converts_your_autohotkey_code_into_pretty_indented_source_code.php
; 2. Author of "system-sound-output": https://github.com/davuxcom

CommandName := a_args[1]
CommandValue := a_args[2]

Switch CommandName
{
    ; ----------------------------------------------------------------
    ; MONITOR
    ; ----------------------------------------------------------------
    Case "monitor-off":
      SendMessage 0x112, 0xF170, 2, , Program Manager
    ; ----------------------------------------------------------------
    ; VOLUME
    ; ----------------------------------------------------------------
    Case "volume-toggle":
      Send {Volume_Mute}
    Case "volume-set":
      SoundSet CommandValue
    Case "volume-up":
      SoundSet +10
    Case "volume-down":
      SoundSet -10
    Case "volume-up-by":
      SoundSet +CommandValue
    Case "volume-down-by":
      SoundSet -CommandValue
    ; ----------------------------------------------------------------
    ; MEDIA
    ; ----------------------------------------------------------------
    Case "media-toggle": 
      Send {Media_Play_Pause}
    Case "media-forward": 
      Send {Right}
    Case "media-rewind": 
      Send {Left}
    Case "media-fullscreen": 
      Send {F}
    ; ----------------------------------------------------------------
    ; SYSTEM || TODO: SHUTDOWN, SLEEP
    ; ----------------------------------------------------------------
    Case "system-lock":
      Run RunDll32.exe user32.dll`,LockWorkStation
    Case "printscreen":
      Send {PrintScreen}
    Case "system-sound-output":
      Devices := {}
      IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
      
      DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+3*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 0x1, "UPtrP", IMMDeviceCollection, "UInt")
      ObjRelease(IMMDeviceEnumerator)
      
      DllCall(NumGet(NumGet(IMMDeviceCollection+0)+3*A_PtrSize), "UPtr", IMMDeviceCollection, "UIntP", Count, "UInt")
      Loop % (Count)
      {
         DllCall(NumGet(NumGet(IMMDeviceCollection+0)+4*A_PtrSize), "UPtr", IMMDeviceCollection, "UInt", A_Index-1, "UPtrP", IMMDevice, "UInt")
         DllCall(NumGet(NumGet(IMMDevice+0)+5*A_PtrSize), "UPtr", IMMDevice, "UPtrP", pBuffer, "UInt")
         DeviceID := StrGet(pBuffer, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "UPtr", pBuffer)
         DllCall(NumGet(NumGet(IMMDevice+0)+4*A_PtrSize), "UPtr", IMMDevice, "UInt", 0x0, "UPtrP", IPropertyStore, "UInt")
         ObjRelease(IMMDevice)
         VarSetCapacity(PROPVARIANT, A_PtrSize == 4 ? 16 : 24)
         VarSetCapacity(PROPERTYKEY, 20)
         DllCall("Ole32.dll\CLSIDFromString", "Str", "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", "UPtr", &PROPERTYKEY)
         NumPut(14, &PROPERTYKEY + 16, "UInt")
         DllCall(NumGet(NumGet(IPropertyStore+0)+5*A_PtrSize), "UPtr", IPropertyStore, "UPtr", &PROPERTYKEY, "UPtr", &PROPVARIANT, "UInt")
         DeviceName := StrGet(NumGet(&PROPVARIANT + 8), "UTF-16")
         DllCall("Ole32.dll\CoTaskMemFree", "UPtr", NumGet(&PROPVARIANT + 8))
         ObjRelease(IPropertyStore)
         ObjRawSet(Devices, DeviceName, DeviceID)
      }
      ObjRelease(IMMDeviceCollection)
      
      SetDefaultEndpoint(DeviceID)
      {
         IPolicyConfig := ComObjCreate("{870af99c-171d-4f9e-af0d-e63df40c2bc9}", "{F8679F50-850A-41CF-9C72-430F290290C8}")
         DllCall(NumGet(NumGet(IPolicyConfig+0)+13*A_PtrSize), "UPtr", IPolicyConfig, "UPtr", &DeviceID, "UInt", 0, "UInt")
         ObjRelease(IPolicyConfig)
      }
      
      GetDeviceID(Devices, Name)
      {
         For DeviceName, DeviceID in Devices
         If (InStr(DeviceName, Name))
         Return DeviceID
      }
      
      if(a_args[2]){
         SetDefaultEndpoint( GetDeviceID(Devices, a_args[2]) )
      }else  {
         SetDefaultEndpoint( GetDeviceID(Devices, "Speakers") )
      }
   Default:
      MsgBox % default CommandName CommandValue
}              