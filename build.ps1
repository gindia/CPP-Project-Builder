####
#
#   Windows C++ Project Builder.
#   
#   Author: Omar M.Gindia
#   Date:   25-12-2020
#
#   Sets up folders/directories and builds with MSVC compiler "CL" and clangd lsp
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
"pushd bin
./$($output_file_name)
popd" | Out-File -encoding ASCII run.ps1

##
#   Vim settings, don't forget to add the following commands to your .vimrc file 
#   
#   set exrc
#   set secure
#  
##
    New-Item .exrc
"map <F6> :split<CR>:term ./build<CR>
map <F7> :split<CR>:term ./run<CR>" | Out-File -encoding ASCII .exrc
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

# do not forget spaces
$LIBS='opengl32.lib '
$LIBS+='../libs/glfw3dll.lib '

$CPP_FILES='../src/*.cpp'
$C_FILES='../src/*.c'

$command="cl -EHsc -Zi -Fe`"$($output_file_name)`" $C_FILES $CPP_FILES $LIBS -I../include"

cmd /c $command
popd

$sw.Stop()
Write-Host "-----------------------------------"
Write-Host "----------- COMPILE TIME-----------"
Write-Host "-----------------------------------"
$ctime = $sw.Elapsed.ToString('dd\.hh\:mm\:ss')
Write-Host "            $($ctime)"
Write-Host "-----------------------------------"
