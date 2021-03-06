@Codes = {}

# Codes.Default = """
# r = y / HEIGHT;
# r *= r;
# g = sin(time * 3 + y/3) * 0.5 + 0.5;
# return [r,g,0];
# """

Codes["1D noise"] = """
v = noise.simplex3(0, y / 50 + .5 * time, time);
return [v,v,v];
"""
Codes.Random = """
v = sin((y - time) *cos(y + time));
return [v,0,v*0.3];
"""

Codes.Bars = """
if (floor(y / 10) == floor(time * 5 % 10)) {
  r = 1;
} else {
  r = 0;
}
g = 0
b = 0
return [r,g,b];
"""

Codes.smoke = """
v = noise.simplex3(x, y / 50 + .5 * time, time);
return [v,v,v];
"""

Codes["2D noise"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
g = noise.simplex3(x / 10, y / 50 + .5 * time, time + 100);
b = noise.simplex3(x / 100, y / 40, time / 10 + 300);
return [r,g,b];
"""

Codes.Barber = """
v = Math.abs(Math.sin(x / 2 - y / 2 + time * 10)) % 1;
return [1, 1-v, 1-v]
"""

Codes.Pulser = """
size = 0.5 + 0.5 * Math.sin(time * 10)
dist =1 - Math.abs(HEIGHT / 2 - y) * size / 2
return [0, dist,dist];
"""

Codes["Digital"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
g = noise.simplex3(x * 1000, y * 50 + .5 * time, time + 100);
b = noise.simplex3(x * 1000, y * 40, time / 10 + 300);
return [r,g,b];
"""

Codes["Heat (buggy)"] = """
r = noise.simplex3(x / 10, y / 50 + .5 * time, time);
return heatColor(r * 8000);
"""
