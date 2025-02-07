# FASM DLL Injector (x86)
A simple x86 DLL injector written in [FASM (Flat Assembler)](https://flatassembler.net).

# Requirements
- [FASM (Flat Assembler)](https://flatassembler.net) installed.
- Windows OS

# Usage
- In the `.data` section, replace `processId dd 0` with the target process ID.
- Set the correct DLL path.
- Compile and run as admin.

# Image
![image](https://github.com/user-attachments/assets/50268bd2-a976-46fc-ba98-591494f7ecf8)
![image](https://github.com/user-attachments/assets/5261d736-1ea7-46b9-aacf-c17647ce18d0)


# If injection Fails
- Ensure the process ID is correct.
- Verify the DLL path is accessible.
- Check if the target process has sufficient permissions.
