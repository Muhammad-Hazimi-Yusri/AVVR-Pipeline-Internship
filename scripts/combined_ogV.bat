::@echo on
::SETLOCAL ENABLEDELAYEDEXPANSION

::cd 360monodepthexecution
::powershell.exe -File "masterscript.ps1"

::Splitting 360 Image
cd C:\Project\AVVR-Pipeline-Internship\material_recognition\Dynamic-Backward-Attention-Transformer

call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat base

python split_img.py

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 


::Running Material Recognition
call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat material

python train_sota.py --data-root "./datasets" --batch-size 1 --tag dpglt --gpus 1 --num-nodes 1 --epochs 200 --mode 95 --seed 42 --test accuracy/epoch=126-valid_acc_epoch=0.87.ckpt --infer C:/Project/AVVR-Pipeline-Internship/material_recognition/Dynamic-Backward-Attention-Transformer/split_output/

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 



::Combining Material Recognition output to create 360 material map
call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat base

python combine_img.py

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 




::Change to Edgenet Directory
cd C:/Project/AVVR-Pipeline-Internship/edgenet360

wsl bash -c "source /home/kproject/miniconda3/bin/activate tf2 && python infer360.py Input depth_e.png material.png rgb.png  Input --include_top y"

::Deactivate tf2 in WSL
wsl bash -c "source /home/kproject/miniconda3/bin/deactivate"

::Run mesh splitting
call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat base

python replace.py

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 

cd C:\Project\AVVR-Pipeline-Internship\scripts

call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat unity

python blenderFlip.py "C:\Project\AVVR-Pipeline-Internship\edgenet360\Output\Input_prediction_mesh.obj"

call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat unity






ENDLOCAL

pause


::Process for standford2D3D datasets
::Do pre-processing (Ask Atharv how to do, he did for area_3)
:: Run script to generate material_map
:: Move material map from DWRC to stanford_processed
:: Run inference code pyhton infer360_stanford.py area_name room_name camera_suffix material.ong --base_path=./Data/stanford_processed
:: python infer360_stanford.py area_3 lounge_2 1c029f7dc23548cab4ac62429f96eb76 material.png --base_path=./Data/stanford_processed
:: Figure how to run replace.py