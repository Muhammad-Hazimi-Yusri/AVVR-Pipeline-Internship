@echo on
SETLOCAL ENABLEDELAYEDEXPANSION

cd C:/Project/AV-VR-Internship/edgenet360

wsl bash -c "source /home/kproject/miniconda3/bin/activate tf2 && python enhance360.py DWRC shifted-disparity.png shifted_t.png new_shifted-disparity.png && python infer360.py DWRC new_shifted-disparity.png material.png shifted_t.png DWRC"


ENDLOCAL