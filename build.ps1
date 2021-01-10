####
#
#   Windows C++ Project Builder.
#   
#   Author: Omar M.Gindia
#   Date:   25-12-2020
#
#   Sets up folders/directories and builds with MSVC compiler "CL" and clangd lsp
#   
#   Note: make sure that you are working under Microsoft Devoloper Powershell.
#
####

$sw = [Diagnostics.Stopwatch]::StartNew()

$output_file_name="win32_window.exe"

if(!(Test-Path -path ./src))
{
    Write-Host "-----------------------------------"
    Write-Host "------ Setting up the project -----"
    Write-Host "-----------------------------------"
    mkdir src
    mkdir bin
    mkdir libs
    mkdir build
    mkdir assets
    mkdir include

    New-Item compile_commands.json
    
"[
    {
        `"directory`":`"$($pwd.path.replace("\","/"))`",
        `"file`":`"src/main.cpp`",
        `"command`":`"clang src/main.cpp -Iinclude -o $($output_file_name)`"
    }
]" | Out-File -encoding ASCII compile_commands.json
    New-Item run.ps1
"pushd build
./$($output_file_name)
popd" | Out-File -encoding ASCII run.ps1

##
#   Vim settings, don't forget to add the following commands to your .vimrc file 
#   
#       set exrc
#       set secure
#  
#   also add build and run to $PATH.
##
    New-Item .exrc
"map <F6> :!build<CR>
map <F7> :!run<CR>
function! SwitchSourceHeader()
  "update!
  if (expand ("%:e") == "cpp")
    find %:t:r.h
  else
    find %:t:r.cpp
  endif
endfunction

map <F12> :call SwitchSourceHeader()<CR>" | Out-File -encoding ASCII .exrc
}


Write-Host "-----------------------------------"
Write-Host "-----------  COMPILING  -----------"
Write-Host "-----------------------------------"

##
#   edit build settings here !
#   --------------------------
#   cl docs: 
#   https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=msvc-160
#   
#   linker options:
#   https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=msvc-160
##

pushd build

if(Test-Path -path ../bin/*.dll)
{
    # copy .dll files from bin to build
    cp "../bin/*.dll" .
}

# Compiler Flags
$FLAGS="-Fe`"$($output_file_name)`" " 
$FLAGS+="-FC -nologo -fp:fast -WX -W4 -wd4100 -EHsc -Z7 -Oi -Od -MP"

# Linker Flags
$LFLAGS="-INCREMENTAL:no -DEBUG:FASTLINK -opt:ref"

$LIBS='opengl32.lib '
# $LIBS+='../libs/glfw3dll.lib '

$CPP_FILES='../src/*.cpp'
$C_FILES='../src/*.c'

$COMPILE_UNITS ="$CPP_FILES $C_FILES"
$command="cl $FLAGS $COMPILE_UNITS $LIBS -I../include -link $LFLAGS"

cmd /c $command
popd

$sw.Stop()
Write-Host "-----------------------------------"
Write-Host "----------- COMPILE TIME-----------"
Write-Host "-----------------------------------"
$ctime = $sw.Elapsed.ToString('dd\.hh\:mm\:ss')
Write-Host "            $($ctime)"
Write-Host "-----------------------------------"
