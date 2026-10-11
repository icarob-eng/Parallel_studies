
import numpy as np
import matplotlib.pyplot as plt

INPUT = 'results/temperature.dat'
OUTPUT = 'results/temperature.png'

data = np.loadtxt(INPUT, skiprows=1)

times = np.unique(data[:, 0])
positions = np.unique(data[:, 1])
T = data[:, 2].reshape(len(times), len(positions))

plt.figure(figsize=(9, 5))
plt.imshow(
    T,
    origin='lower',
    aspect='auto',
    extent=[
        positions[0], positions[-1] + positions[2],
        times[0], times[-1]
    ],
    cmap='inferno'
)

plt.axvline(positions[1], c='k')
plt.axvline(positions[-1], c='k')

plt.xlabel('Posição (m)')
plt.ylabel('Tempo (s)')
plt.title('Propagação térmica na barra')
plt.colorbar(label='Temperatura (°C)')
plt.tight_layout()
plt.savefig(OUTPUT)
plt.show()