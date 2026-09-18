import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, PillowWriter

INPUT = 'results/velocity.dat'
OUTPUT = 'results/velocity.gif'
FPS = 10

data = np.loadtxt(INPUT)

t = data[:, 0]
x = data[:, 1]
y = data[:, 2]
u = data[:, 3]
v = data[:, 4]

times = np.unique(t)

# Grid dimensions
x_values = np.unique(x)
y_values = np.unique(y)

nx = len(x_values)
ny = len(y_values)

X = x[:nx * ny].reshape(nx, ny)
Y = y[:nx * ny].reshape(nx, ny)

init_mask = t == times[0]

U = u[init_mask].reshape(nx, ny)
V = v[init_mask].reshape(nx, ny)
speed = np.sqrt(U**2 + V**2)

print(f'Infered values: Grid shape = {X.shape}. Time stamps = {len(times)}. Plotting...')

fig, ax = plt.subplots()

image = ax.pcolormesh(X, Y, speed, shading='auto')
cbar = fig.colorbar(image, ax=ax)
cbar.set_label('Velocity magnitude')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_aspect('equal')
title = ax.set_title(f'$t = {times[0]:.6g}$')

# Keep the color scale fixed throughout the animation
image.set_clim(0, np.max(np.sqrt(u**2 + v**2)))


def update(frame):
    mask = t == times[frame]

    U = u[mask].reshape(nx, ny)
    V = v[mask].reshape(nx, ny)
    speed = np.sqrt(U**2 + V**2)

    image.set_array(speed.ravel())
    title.set_text(f'$t = {times[frame]:.6g}$')

    return image, title

animation = FuncAnimation(fig, update, frames=len(times), interval=1000 / FPS, blit=True)

animation.save(OUTPUT, writer=PillowWriter(fps=FPS))

print(f'Saved: {OUTPUT}')
