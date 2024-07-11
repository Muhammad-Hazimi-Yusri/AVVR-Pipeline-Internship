@echo on
SETLOCAL ENABLEDELAYEDEXPANSION

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


ENDLOCAL