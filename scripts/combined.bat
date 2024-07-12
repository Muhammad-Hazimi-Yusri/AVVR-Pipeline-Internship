@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Input parameters
set inputFilePath=%~1
set depthVar=%2
set includeTop=%3
set shiftImage=%4

:: Directory structure
set workingDir=C:/Project/AVVR-Pipeline-Internship
set scriptDir=%workingDir%/scripts
set monoDepthDir=%scriptDir%/360monodepthexecution
set outputDir=%workingDir%/edgenet360/Output
set condaDir=C:/Users/kproject/AppData/Local/anaconda3
set materialRecogDir=%workingDir%/material_recognition/Dynamic-Backward-Attention-Transformer
set edgeNetDir=%workingDir%/edgenet360

:: File paths
set checkpointFile=%materialRecogDir%/checkpoints/dpglt_mode95/accuracy/epoch=126-valid_acc_epoch=0.87.ckpt
set shiftedImage=%scriptDir%/shifted_t.png
set monoDepthImage=%monoDepthDir%/rgb.jpg

:: Ensure the input file exists
if not exist "%inputFilePath%" (
    echo Error: Input file does not exist: %inputFilePath%
    exit /b 1
)

:: Check if the checkpoint file exists
if not exist "%checkpointFile%" (
    echo Error: Checkpoint file not found: %checkpointFile%
    echo Please ensure the checkpoint file is in the correct location.
    exit /b 1
)

:: Shift the image if the option is selected
if /I "%shiftImage%"=="y" (
    echo Shifting the input image...
    call "%condaDir%\condabin\activate.bat" base
    python "%scriptDir%\shifter.py" "%inputFilePath%" "%shiftedImage%"
    call "%condaDir%\condabin\deactivate.bat"
    set "processFilePath=%shiftedImage%"
) else (
    set "processFilePath=%inputFilePath%"
)

echo Processing file: %processFilePath%

:: Copy file to 360monodepthexecution directory with a unique name
copy "%processFilePath%" "%monoDepthImage%" /Y
if errorlevel 1 (
    echo Error: Failed to copy file to 360monodepthexecution directory.
    exit /b 1
)

:: Run depth estimation if required
if %depthVar%==1 (
    echo Running depth estimation...
    pushd "%monoDepthDir%"
    powershell.exe -File "masterscript.ps1"
    popd
)

:: Splitting 360 Image
echo Splitting 360 image...
pushd "%materialRecogDir%"
call "%condaDir%\condabin\activate.bat" base
python split_img.py "%processFilePath%"
call "%condaDir%\condabin\deactivate.bat"
popd

:: Running Material Recognition
echo Running material recognition...
pushd "%materialRecogDir%"
call "%condaDir%\condabin\activate.bat" material
python train_sota.py --data-root "./datasets" --batch-size 1 --tag dpglt --gpus 1 --num-nodes 1 --epochs 200 --mode 95 --seed 42 --test "%checkpointFile%" --infer "%materialRecogDir%/split_output/"
if errorlevel 1 (
    echo Error: Material recognition failed. Please check the output above for more details.
    call "%condaDir%\condabin\deactivate.bat"
    exit /b 1
)
call "%condaDir%\condabin\deactivate.bat"
popd

:: Combining Material Recognition output
pushd "%materialRecogDir%"
echo Combining material recognition output...
call "%condaDir%\condabin\activate.bat" base
python "%materialRecogDir%\combine_img.py"
call "%condaDir%\condabin\deactivate.bat"
popd

:: Run EdgeNet
echo Running EdgeNet...
pushd "%edgeNetDir%"
set "includeTopFlag="
if /I "%includeTop%"=="y" set "includeTopFlag=--include_top y"
wsl bash -c "source /home/kproject/anaconda3/bin/activate tf2 && python enhance360.py Input depth_e.png rgb.png enhanced_depth_e.png --baseline 2.264 && python infer360.py Input enhanced_depth_e.png material.png rgb.png Input %includeTopFlag%"
wsl bash -c "source /home/kproject/anaconda3/bin/deactivate"
popd

:: Run mesh splitting
echo Running mesh splitting...
pushd "%edgeNetDir%"
call "%condaDir%\condabin\activate.bat" base
python "%edgeNetDir%\replace.py"
call "%condaDir%\condabin\deactivate.bat"
popd

:: Run Blender flip
echo Running Blender flip...
pushd "%edgeNetDir%"
call "%condaDir%\condabin\activate.bat" unity
python "%scriptDir%\blenderFlip.py" "%outputDir%\Input_prediction_mesh.obj" 
call "%condaDir%\condabin\deactivate.bat"
popd

:: Clean up temporary files
::if exist "%shiftedImage%" del "%shiftedImage%"
::if exist "%monoDepthImage%" del "%monoDepthImage%"

echo Processing complete.
ENDLOCAL
pause