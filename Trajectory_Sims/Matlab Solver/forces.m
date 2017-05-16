%%% Forces

% Fdrag, Flift, Thrust curve, and Flight data are provided as inputs
% Flight Data consists of rocket dimensions, time, position, vel,
% acceleration, angle of attack
% Assumption is time starts at t = 0;
% u >= 0, haven't hit apogee yet
% Earth Centered Earth Fixed coordinate system
% rocket contains the mass curve

% Split each force into x and y for earth centered components

function [f_x, f_y, moment, Fdrag, Flift, CD, CL, aoa, gravity] = forces(t, t_step, r, u, T, current_mass, wind, aerodata, rocket, CP, CM)

theta = r(3); % wrt to the vertical (normal to the earth's surface)

% thrust
% thrust curve assumption -- 2 column tabular input
% find index for this
if t < T(end,1)
    k = 1; tol = t_step;
    while(1)
        delta = abs(T(k,1)-t);
        if delta < tol; break; end
        k = k+1;
    end
    thrust = T(k,2);
    Tx = sind(theta)*thrust;
    Ty = cosd(theta)*thrust;
else
    Tx = 0;
    Ty = 0;
end

% where do we assign direction / theta and signs
[Fdrag, Flift, CD, CL, aoa] = aerodynamics(r, u, wind, aerodata, rocket);

% lift
Lx = cosd(theta)*Flift;
Ly = sind(theta)*Flift;

% drag
Dx = sind(theta)*Fdrag;
Dy = cosd(theta)*Fdrag;

% gravity
% mass assumption -- 2 column tabular input
% mdot proportional to thrust (relate to impulse)
G = 3.986E14; r_earth = 6378000;
gravity = (G)/(r_earth + norm(r(1:2))).^2 * current_mass;

site_elevation = 1293;
if r(2) <= site_elevation
    gravity = 0;
end

if wind >= 0; dir = 1; else dir = -1; end % change direction of wind

% Requires CM and CP distance from bottom of the rocket
if u(2) >= 0
    f_x = Tx + Lx + dir*Dx;
    f_y = Ty + Ly - Dy  - gravity;
    moment = (Lx - Dx)*cosd(theta)*(CP-CM) + (Dy + Ly)*sind(theta)*(CP-CM);
else
    f_x = dir*Dx;
    f_y = Dy - gravity;
    moment = 0; %not worth it
end

end
