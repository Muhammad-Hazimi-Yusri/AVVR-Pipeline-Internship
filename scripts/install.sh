#!/usr/bin/env sh
cd extensions/chamfer_dist
python setup.py install --user
cd ../pointops
python setup.py install --user

