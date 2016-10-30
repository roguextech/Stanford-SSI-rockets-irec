function [compression, sigma] = aero_loads(maxq,rocket,metric, fin)
% Ian Gomez, Oct 28, 2016
% This function spits out the maximum compressive load and bending moment
% on the rocket based on max Q, angle of attack, and rocket geometry


in2m = 0.0254; % m/in
if metric == 1;
    rocket.bodytube.OD = rocket.bodytube.OD *in2m;
    rocket.bodytube.ID = rocket.bodytube.ID * in2m;
    rocket.cg = rocket.cg *in2m;
    rocket.length = rocket.length *in2m;
    rocket.bodytube.S_ref = rocket.bodytube.S_ref * in2m^2;
    fin.rootlength = fin.rootlength * in2m;
    fin.S = fin.S * in2m^2
end
% calculate moment based on alpha
transverse_q = maxq.*sind(rocket.alpha);
%Area above and below the CG
%Factor of four on the fins cause two face the air, then top and bottom on
%each
area = [rocket.bodytube.OD.*rocket.cg,...           % area above cg
    rocket.bodytube.OD.*(rocket.length-rocket.cg) + fin.S * 4] % area below cg
transverse_force = [transverse_q.*area(1); transverse_q.*area(2)];
%The force from the fins dominates the second term, so moment arm from the
%center of them
resultant_force_location = [rocket.cg/2, (rocket.length-rocket.cg) - fin.rootlength/2]; % from the center of gravity

%Inertia of a hollow cylindrical cross section
inertia_body = pi * (rocket.bodytube.OD.^4 - rocket.bodytube.ID.^4) / 64;
c = rocket.bodytube.OR;

compression = zeros(1,length(rocket.alpha));
sigma = zeros(1,length(rocket.alpha));
M = zeros(1,length(rocket.alpha));

for i = 1:length(rocket.alpha)
    
    M(i) = transverse_force(1,i).*resultant_force_location(1) -...
        transverse_force(2,i).*resultant_force_location(2);
    compression(i) = maxq .* cosd(rocket.alpha(i)).*rocket.bodytube.S_ref;
    sigma(i) = M(i).*c./inertia_body;
    
end

figure
set(gcf,'color','w');
scaling = 1e3; % Pa -> kPa, ft to kft
plot(rocket.alpha,compression)
if metric == 1
    ylabel('Compression force (N)')
    xlabel('Angle of attack (deg)')
else
    ylabel('Compression force (lbs)')
    xlabel('Angle of attack (deg)')
end
title('Max compression with different angle of attacks')
grid on

figure
set(gcf,'color','w');
if metric == 1
    plot(rocket.alpha,sigma)
    ylabel('Bending stress (N-m)')
    xlabel('Angle of attack (deg)')
else
    plot(rocket.alpha,sigma./scaling)
    ylabel('Bending stress (kip-in)')
    xlabel('Angle of attack (deg)')
end
title('Max bending stress with different angle of attacks')
grid on

end