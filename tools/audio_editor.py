import tkinter as tk
from tkinter import ttk, messagebox
import json
import os
import subprocess
import platform
import sys

CONFIG_PATH = "tools/audio_config.json"
GENERATOR_SCRIPT = "tools/generate_audio.py"
AUDIO_DIR = "assets/audio"


def check_tkinter_availability():
    """Check if tkinter is properly available with Tcl/Tk"""
    try:
        # Try to create a basic Tk instance
        test_tk = tk.Tk()
        test_tk.destroy()
        return True
    except tk.TclError as e:
        if "init.tcl" in str(e) or "Tcl" in str(e):
            return False
        # Re-raise other tkinter errors
        raise


class AudioEditor(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Arkanoid Audio Editor")
        self.geometry("800x600")
        
        self.config_data = {}
        self.current_sound = None
        self.track_widgets = []
        
        self.load_config()
        self.create_widgets()
        
    def load_config(self):
        if not os.path.exists(CONFIG_PATH):
            messagebox.showerror("Error", f"Config not found: {CONFIG_PATH}")
            return
        with open(CONFIG_PATH, 'r') as f:
            self.config_data = json.load(f)
            
    def save_config(self):
        # Update current sound data from widgets before saving
        if self.current_sound:
            self.update_data_from_ui()
            
        with open(CONFIG_PATH, 'w') as f:
            json.dump(self.config_data, f, indent=2)
        print("Config saved.")
            
    def create_widgets(self):
        # Layout: PanedWindow with List on left, Editor on right
        paned = tk.PanedWindow(self, orient=tk.HORIZONTAL)
        paned.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # --- Left Panel: List & Global Actions --
        left_frame = ttk.Frame(paned, width=200)
        paned.add(left_frame)
        
        # Sound List
        lbl = ttk.Label(left_frame, text="Sounds")
        lbl.pack(pady=5)
        
        self.sound_listbox = tk.Listbox(left_frame)
        self.sound_listbox.pack(fill=tk.BOTH, expand=True, padx=5)
        self.sound_listbox.bind('<<ListboxSelect>>', self.on_select)
        
        for key in self.config_data.keys():
            self.sound_listbox.insert(tk.END, key)
            
        # Buttons
        btn_frame = ttk.Frame(left_frame)
        btn_frame.pack(pady=10, fill=tk.X, padx=5)
        
        ttk.Button(btn_frame, text="Save JSON", command=self.save_config).pack(fill=tk.X, pady=2)
        ttk.Button(btn_frame, text="Regenerate All Audio", command=self.regenerate_audio).pack(fill=tk.X, pady=2)
        ttk.Button(btn_frame, text="Play Selected", command=self.play_sound).pack(fill=tk.X, pady=2)
        
        # --- Right Panel: Editor ---
        self.right_frame = ttk.Frame(paned)
        paned.add(self.right_frame)
        
        self.header_label = ttk.Label(self.right_frame, text="Select a sound to edit", font=('Arial', 14, 'bold'))
        self.header_label.pack(pady=10)
        
        # Scrollable area for properties
        # (Simplified: Just a frame for now, assume fits in 600px height or use canvas if needed. sounds are simple)
        self.editor_frame = ttk.Frame(self.right_frame)
        self.editor_frame.pack(fill=tk.BOTH, expand=True, padx=10)
        
    def on_select(self, event):
        selection = self.sound_listbox.curselection()
        if not selection:
            return
            
        # If we were editing something, save the UI state to data first?
        # Ideally yes, but for simplicity let's rely on explicit save or focus out.
        # Actually, let's auto-update data when switching.
        if self.current_sound:
            self.update_data_from_ui()
            
        key = self.sound_listbox.get(selection[0])
        self.current_sound = key
        self.header_label.config(text=f"Editing: {key}")
        self.build_editor(self.config_data[key])
        
    def build_editor(self, data):
        # Clear existing widgets
        for widget in self.editor_frame.winfo_children():
            widget.destroy()
        self.track_widgets.clear()
            
        type_val = data.get("type", "sequence")
        ttk.Label(self.editor_frame, text=f"Type: {type_val}").pack(anchor='w')
        
        if type_val == "custom":
            ttk.Label(self.editor_frame, text="Custom generators (Warp/Intro) are not editable via UI yet.").pack(pady=20)
            return
            
        tracks = data.get("tracks", [])
        
        for i, track in enumerate(tracks):
            frame = ttk.LabelFrame(self.editor_frame, text=f"Track {i+1}")
            frame.pack(fill=tk.X, pady=5, padx=5)
            
            # We store the widgets and the track ref to update later
            widgets = {}
            
            # Grid Layout
            # Wave
            ttk.Label(frame, text="Wave:").grid(row=0, column=0, padx=5, pady=2)
            wave_var = tk.StringVar(value=track.get("wave", "sine"))
            wave_cb = ttk.Combobox(frame, textvariable=wave_var, values=["sine", "square", "sawtooth", "noise"], state="readonly", width=10)
            wave_cb.grid(row=0, column=1, padx=5)
            widgets["wave"] = wave_var
            
            # Vol
            ttk.Label(frame, text="Vol:").grid(row=0, column=2, padx=5)
            vol_var = tk.DoubleVar(value=track.get("vol", 0.5))
            tk.Spinbox(frame, from_=0.0, to=1.0, increment=0.1, textvariable=vol_var, width=5).grid(row=0, column=3)
            widgets["vol"] = vol_var
            
            # Start Freq
            ttk.Label(frame, text="Start Freq:").grid(row=1, column=0, padx=5)
            sf_var = tk.DoubleVar(value=track.get("start_freq", 440))
            tk.Spinbox(frame, from_=0, to=2000, increment=10, textvariable=sf_var, width=6).grid(row=1, column=1)
            widgets["start_freq"] = sf_var
            
            # End Freq
            ttk.Label(frame, text="End Freq:").grid(row=1, column=2, padx=5)
            ef_var = tk.DoubleVar(value=track.get("end_freq", 440))
            tk.Spinbox(frame, from_=0, to=2000, increment=10, textvariable=ef_var, width=6).grid(row=1, column=3)
            widgets["end_freq"] = ef_var
            
            # Duration
            ttk.Label(frame, text="Duration:").grid(row=2, column=0, padx=5)
            dur_var = tk.DoubleVar(value=track.get("duration", 0.1))
            tk.Spinbox(frame, from_=0.01, to=2.0, increment=0.01, textvariable=dur_var, width=6).grid(row=2, column=1)
            widgets["duration"] = dur_var
            
            # Delay (Optional)
            ttk.Label(frame, text="Delay:").grid(row=2, column=2, padx=5)
            del_var = tk.DoubleVar(value=track.get("delay", 0.0))
            tk.Spinbox(frame, from_=0.0, to=2.0, increment=0.01, textvariable=del_var, width=6).grid(row=2, column=3)
            widgets["delay"] = del_var
            
            self.track_widgets.append((track, widgets))

    def update_data_from_ui(self):
        # Write values from vars back to config_data
        if not self.current_sound: return
        
        # This function updates the track dicts in place (since we hold refs)
        for track_ref, widgets in self.track_widgets:
            track_ref["wave"] = widgets["wave"].get()
            track_ref["vol"] = widgets["vol"].get()
            track_ref["start_freq"] = widgets["start_freq"].get()
            track_ref["end_freq"] = widgets["end_freq"].get()
            track_ref["duration"] = widgets["duration"].get()
            # Handle delay if it exists or needs to be added (if >0)
            d = widgets["delay"].get()
            if d > 0:
                track_ref["delay"] = d
            elif "delay" in track_ref:
                # If set to 0, keep it 0 or remove? Keep 0 is fine.
                track_ref["delay"] = 0.0

    def regenerate_audio(self):
        self.save_config()
        try:
            # Run the generator script
            subprocess.run(["python3", GENERATOR_SCRIPT], check=True)
            messagebox.showinfo("Success", "Audio assets regenerated!")
        except subprocess.CalledProcessError as e:
            messagebox.showerror("Error", f"Generation failed:\n{e}")

    def play_sound(self):
        if not self.current_sound: return
        self.regenerate_audio() # Regen to make sure we hear latest. Or maybe just regen if dirty? Let's regen to be safe.
        
        # Audio path
        path = os.path.join(AUDIO_DIR, f"{self.current_sound}.wav")
        if not os.path.exists(path):
            messagebox.showerror("Error", "File not found. Try regenerating.")
            return
            
        # Mac OS player
        if platform.system() == "Darwin":
            subprocess.run(["afplay", path])
        elif platform.system() == "Linux":
            subprocess.run(["aplay", path]) # Common on linux
        elif platform.system() == "Windows":
            import winsound
            winsound.PlaySound(path, winsound.SND_FILENAME)

if __name__ == "__main__":
    if not check_tkinter_availability():
        print("ERROR: tkinter is not available or Tcl/Tk is not properly installed.")
        print("")
        print("This appears to be running in Bazel's hermetic environment.")
        print("To run the audio editor GUI, execute it directly with system Python:")
        print("")
        print("  python3 tools/audio_editor.py")
        print("")
        print("Or from the project root:")
        print("  python3 audio_editor.py")
        print("")
        sys.exit(1)

    app = AudioEditor()
    app.mainloop()
