"""Script used to automate flippin mesh normals such that mesh is visible on unity"""

import bpy
import pathlib
import sys
from _ctypes import ArgumentError

def generate_flipped_mesh(obj_file_path):
    # Delete the default cube object
    bpy.ops.object.select_all(action = 'DESELECT')
    bpy.data.objects['Cube'].select_set(True)
    bpy.ops.object.delete()

    # import mesh
    str_filepath = obj_file_path.as_posix()
    bpy.ops.wm.obj_import(filepath = str_filepath, import_vertex_groups = True)

    # flip normals
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.select_all(action = 'SELECT')
    bpy.ops.mesh.flip_normals()

    # translate object to "floor" height
    for obj in bpy.context.selected_objects:
        mtx_w = obj.matrix_world
        z_diff = min((mtx_w @ v.co).z for v in obj.data.vertices)
        mtx_w.translation.z -= z_diff

    # Save the object
    output_file_path = obj_file_path.with_stem("final_output_scene_mesh")
    str_filepath = output_file_path.as_posix()
    bpy.ops.wm.obj_export(filepath = str_filepath,
                          export_material_groups = True)

def get_filepath(input_str):
    candidate = pathlib.Path(*input_str).resolve()
    if candidate.exists():
        return candidate
    else:
        raise ArgumentError("File not found.")

if __name__ == "__main__":
    # get filepath to obj file
    if len(sys.argv) > 2:
        raise ArgumentError("Supply one argument (folder path) or none.")
    obj_file_path = get_filepath(sys.argv[1:])
    generate_flipped_mesh(obj_file_path)
