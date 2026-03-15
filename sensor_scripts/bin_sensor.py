import time
import vl53l5cx_ctypes as vl53l5cx
import numpy as np


vl53 = vl53l5cx.VL53L5CX()
vl53.set_resolution(8 * 8)

#Enable motion detection

vl53.enable_motion_indicator(8 * 8)
vl53.set_motion_distance(400, 1400)

vl53.start_ranging()

print("Bin sensor activated")

while True:
    
    if vl53.data_ready():
        
        data = vl53.get_data()
        
        motion = list(data.motion_indicator.motion)
        
        if max(motion) > 50:
           print("Motion detected, waiting 5 seconds to detect bin level")
           
           time.sleep(5)
           
           distances = list(data.distance_mm[0])
           print("distance count:", len(distances))
           center_distance = ((distances[35] + distances[36] + distances[43] + distances[44]) / 4)
           print("New bin level:", center_distance, "mm")
           arr = np.array(data.distance_mm).reshape((8,8))
           
           #print 8x8 grid
           
           print("-" * 30)
           for row in arr:
               print(" ".join(f"{d:4}" for d in row))
        
    time.sleep(0.05)