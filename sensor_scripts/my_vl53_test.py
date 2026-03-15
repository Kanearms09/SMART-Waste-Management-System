#!usr/bin/env python3

import time
import vl53l5cx_ctypes as vl53l5cx
import numpy as np

vl53 = vl53l5cx.VL53L5CX()
vl53.set_resolution(8 * 8)
vl53.set_ranging_frequency_hz(15)
vl53.set_integration_time_ms(20)
vl53.start_ranging()

print("Sensor started. Press Ctrl+C to exit.\n")

try:
	while True:
		if vl53.data_ready():
			# Read distance data
			data = vl53.get_data()
			arr = np.array(data.distance_mm).reshape((8, 8))
			
			#Print 8x8 grid
			print("-" * 30)
			for row in arr:
				print(" ".join(f"{d:4}" for d in row))
				
		time.sleep(0.1)
		
		
except KeyboardInterrupt:
	print("\nStopping Sensor...")
	vl53.stop_ranging()