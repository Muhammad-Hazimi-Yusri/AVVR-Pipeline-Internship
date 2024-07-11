set filePath=%1
set cam_pos=%2
set room_area=%3
set room_name=%4


echo %room_area% %room_name% %cam_pos%


::Splitting 360 Image
cd C:\Project\AVVR-Pipeline-Internship\material_recognition\Dynamic-Backward-Attention-Transformer

call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat base

python split_img.py %filePath%

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 


::Running Material Recognition
call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat material

python train_sota.py --data-root "./datasets" --batch-size 1 --tag dpglt --gpus 1 --num-nodes 1 --epochs 200 --mode 95 --seed 42 --test accuracy/epoch=126-valid_acc_epoch=0.87.ckpt --infer C:/Project/AVVR-Pipeline-Internship/material_recognition/Dynamic-Backward-Attention-Transformer/split_output/

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 



::Combining Material Recognition output to create 360 material map
call C:\Users\kproject\AppData\Local\anaconda3\condabin\activate.bat base

python combine_img.py

call C:\Users\kproject\AppData\Local\anaconda3\condabin\deactivate.bat 



move C:\Project\AVVR-Pipeline-Internship\edgenet360\Data\Input\material.png C:\Project\AVVR-Pipeline-Internship\edgenet360\Data\stanford_processed


::Change to Edgenet Directory
cd C:/Project/AVVR-Pipeline-Internship/edgenet360

echo python infer360_stanford.py "%room_area%" "%room_name%" "%cam_pos%" material.png --base_path=./Data/stanford_processed

wsl bash -c "source /home/kproject/miniconda3/bin/activate tf2 && python infer360_stanford.py %room_area% %room_name% %cam_pos% material.png --base_path=./Data/stanford_processed"

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