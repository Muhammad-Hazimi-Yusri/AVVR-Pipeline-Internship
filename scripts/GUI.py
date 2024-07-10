"""
GUI for the pipeline
"""
import tkinter as tk
import tkinter.filedialog
import subprocess, sys
import time
from threading import *
import shutil

file_path =None
createDepth = "0"

def shift_image_selection():
    # This function can be used if you want to perform any action when the checkbox is clicked
    pass

# copy the intermediary output (depth_e.png, material.png, rgb.png from "C:\Project\AV-VR-Internship\edgenet360\Data\Input") 
# to the output folder (C:\Project\AV-VR-Internship\edgenet360\Output)
def copy_intermediary_outputs():
    source_folder = "C:\\Project\\AV-VR-Internship\\edgenet360\\Data\\Input"
    destination_folder = "C:\\Project\\AV-VR-Internship\\edgenet360\\Output"
    files_to_copy = ["depth_e.png", "enhanced_depth_e.png", "material.png", "rgb.png"]
    
    for file_name in files_to_copy:
        source_path = f"{source_folder}\\{file_name}"
        destination_path = f"{destination_folder}\\{file_name}"
        try:
            shutil.copy(source_path, destination_path)
            print(f"Copied {file_name} to {destination_folder}")
        except FileNotFoundError:
            print(f"Warning: {file_name} not found in {source_folder}")

def select_Image(event):
    global file_path 
    file_path = tkinter.filedialog.askopenfilename()
    file_path = file_path.replace("/", "\\").strip('"')  # Remove any quotation marks and normalize slashes
    select_button.configure(text="Selected", bg="red")
    label.configure(text="Image is selected. Press run to create scene.")

def depthmap_creation():
    print("Checked ", check.get())

def stanfordRoom_selection():
    if checkStanford.get() == 1:
        labelStanford = tk.Label(
        text="Please Input Room Area",
        foreground="black", 
        background="white",
        width= 20,
        height=3,
        )
        select_button.pack_forget()
        run_button.pack_forget()
        global stanford_frame
        stanford_frame = tk.Frame(window)
        stanford_frame.pack(fill=tk.X, padx=5, pady=5)
        global labelRoomArea
        labelRoomArea = tk.Label(stanford_frame, text="Please Input Room Area: ")
        labelRoomArea.pack(side="left")
        global stanford_text
        stanford_text = tk.Entry(stanford_frame)
        stanford_text.pack(side="left", fill=tk.X, expand=True)
        select_button.pack(side="top", fill=tk.X, expand=True, padx=5, pady=5)
        run_button.pack(side="top", fill=tk.X, expand=True, padx=5, pady=5)

    else:
        stanford_frame.pack_forget()



def run_Image(event):
    if checkStanford.get() == 0:
        label.configure(text="Pipeline is running. Creating scene...", height=15)
    else:
        label.configure(text="Pipeline is running for Stanford2D3D dataset. Creating scene...", height=15)
        labelRoomArea.configure(text="Room Area Running : ")
        stanford_text.configure(state="disabled")

    select_button.pack_forget()
    run_button.pack_forget()
    depth_check.pack_forget()
    include_top_check.pack_forget()
    stanford_check.pack_forget()
    shift_image_check.pack_forget()
    threading()


def runProcess():
    global file_path
    file_path = str(file_path)
    file_path= file_path.replace("/","\\")
    print("File path is: ", file_path)
    include_top_option = "y" if include_top.get() == 1 else ""
    shift_image_option = "y" if shift_image.get() == 1 else ""
    if checkStanford.get() == 0:
        p = subprocess.Popen(
            ["C:/Project/AV-VR-Internship/scripts/combined.bat", file_path, str(check.get()), include_top_option, shift_image_option],
            stdout=sys.stdout)
        p.communicate()

        poll = p.poll()
        if poll is not None:
            print("error")

    else:
        temp = file_path.split("\\")
        suffices = temp[-1].split("_")
        camera_pos = str(suffices[1])
        room_name = suffices[2]+"_"+suffices[3]
        room_area = stanford_text.get()

        print(room_area,room_name,camera_pos)
        p = subprocess.Popen( 
                ["C:\Project\AV-VR-Internship\scripts\combined_stanford.bat", file_path,camera_pos,str(room_area),room_name],
                stdout=sys.stdout)
        p.communicate()

    copy_intermediary_outputs()

    label.configure(text="Pipeline execution complete, check output folder.")
    try:
        labelRoomArea.pack_forget()
        stanford_text.pack_forget()
    except Exception as e:
        print(e)


def threading():
    thread1 = Thread(target=runProcess)
    thread1.start()

window = tk.Tk()
window.title("Immersive VR scene creator")
check = tk.IntVar()
checkStanford = tk.IntVar()
include_top = tk.IntVar()
shift_image = tk.IntVar()
label = tk.Label(
    text="Please Input a RGB image for scene creation",
    foreground="black", 
    background="white",
    width=50,
    height=10,
)
 

select_button = tk.Button(
    text="Select",
    width=50,
    height=5,
    bg="green",
    fg="white",
)

run_button = tk.Button(
    text="Run",
    width=50,
    height=5,
    bg="green",
    fg="white",
)
depth_check = tk.Checkbutton(window, text='Create a depth map(360 MonoDepth)',variable=check, onvalue=1, offvalue=0, command=depthmap_creation)
stanford_check = tk.Checkbutton(window, text='Run for stanford2D3D dataset',variable=checkStanford, onvalue=1, offvalue=0,command=stanfordRoom_selection )
include_top_check = tk.Checkbutton(window, text='Include Top in Mesh', variable=include_top, onvalue=1, offvalue=0)
shift_image_check = tk.Checkbutton(window, text='Shift input image', variable=shift_image, onvalue=1, offvalue=0, command=shift_image_selection)
label.pack()
depth_check.pack()
stanford_check.pack()
include_top_check.pack()
shift_image_check.pack()
select_button.pack()
run_button.pack()

select_button.bind('<Button-1>', select_Image)
run_button.bind('<Button-1>', run_Image)

window.mainloop()


