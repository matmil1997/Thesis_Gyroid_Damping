%% Gyroid_Mesh_Script

a = 1; % Periodicity

gyroid_dimensions = [3 3 3];

too_long = a/4; % Maximum mesh edge length

res = 0.05;

% X,Y,Z centred at origin
X = -gyroid_dimensions(1)/2:res:gyroid_dimensions(1)/2;
Y = -gyroid_dimensions(2)/2:res:gyroid_dimensions(2)/2;
Z = -gyroid_dimensions(3)/2:res:gyroid_dimensions(3)/2;

[x,y,z] = meshgrid(X,Y,Z);

gyroid = sin(2*pi*x/a).* cos(2*pi*y/a) + sin(2*pi*y/a).* cos(2*pi*z/a) + sin(2*pi*z/a).* cos(2*pi*x/a);

% Add Gaussian random error to gyroid surface
% random = normrnd(0,0.05,size(gyroid));
% gyroid = gyroid+random;

[F, V] = isosurface(X,Y,Z,gyroid,0);

%% MAKE SURFACE

figure()
col = rand(size(V));
% patch('Faces', F, 'Vertices', V, 'EdgeColor','yellow', 'FaceColor', 'interp')
patch('Faces', F, 'Vertices', V, 'FaceVertexCData',col,'FaceColor','interp', 'EdgeColor','none')
daspect([1 1 1])
xlabel("x")
ylabel("y")
zlabel("z")
hold on

% Write OBJ
FV.faces = F;
FV.vertices = V;
% obj_write(FV,'x5_y5_z1_a1_t0')

at = V(F(:, 2), :) - V(F(:, 1), :);
bt = V(F(:, 3), :) - V(F(:, 1), :);
ct = cross(at, bt, 2);
area = 1/2 * sum(sqrt(sum(ct.^2, 2)));
fprintf('\nThe surface area is %f\n\n', area);

% Write STL
stlwrite('unitcell.stl', F, V)
%% ADD THICKNESS TO SURFACE
gyroid_thickness = 0.1;
% 0.245 is when the gyroid loses orthogonal pores

% [F_t1, V_t1] = surf2solid(F, V, 'thickness', gyroid_thickness/2);
% patch('Faces', F_t1, 'Vertices', V_t1, 'EdgeColor','black', 'FaceColor', 'none')
% 
% [F_t2, V_t2] = surf2solid(F, V, 'thickness', -gyroid_thickness/2);
% patch('Faces', F_t2, 'Vertices', V_t2, 'EdgeColor','black', 'FaceColor', 'none')

[V1, V_wall1, V_extrude1,F1, F_wall1, F_extrude1] = mod_surf2solid(F, V, 'thickness', gyroid_thickness/2);
allVertices1 = [V_wall1; V_extrude1];
allFaces1 = [F_wall1; F_extrude1+size(V_wall1,1)];

[V2, V_wall2, V_extrude2,F2, F_wall2, F_extrude2] = mod_surf2solid(F, V, 'thickness', -gyroid_thickness/2);
allVertices2 = [V_wall2; V_extrude2];
allFaces2 = [F_wall2; F_extrude2+size(V_wall2,1)];

allVertices = [allVertices1; allVertices2];
allFaces = [F_wall1; F_extrude1+size(V_wall1,1); 
    F_wall2+size(allVertices1,1); 
    F_extrude2+size(allVertices1,1)+size(V_wall2,1)];

allFaces = remove_bad_faces(allFaces, allVertices, too_long);

patch('Faces', allFaces, 'Vertices', allVertices, 'EdgeColor','black', 'FaceColor', 'green')

fprintf('\nThe volume is %f\n\n', area*gyroid_thickness);
fprintf('\nThe volume fraction is %f\n\n', area*gyroid_thickness/prod(gyroid_dimensions));
% Max volume fraction is 0.757615 when the thickness is maximum (0.245)

daspect([1 1 1])
% xlim([-0.5 0.5])
% ylim([-0.5 0.5])
% zlim([-0.5 0.5])
hold on

% stlwrite('x3_y3_z1_t0-18.stl', allFaces, allVertices)
%% DRAW CUBOIDS FOR WALLS
% t = 0.1234;
% overlap = 0.01;
% 
% %[V_top, F_top] = DrawCuboid([gyroid_dimensions(1)+gyroid_thickness gyroid_dimensions(2)+gyroid_thickness t], [gyroid_dimensions(1)/2, (gyroid_dimensions(2)/2), gyroid_dimensions(3)+(t/2)-(gyroid_dimensions(3)*overlap)]);
% [V_top, F_top] = DrawCuboid([gyroid_dimensions(1)+gyroid_thickness gyroid_dimensions(2)+gyroid_thickness t], [0,0,-overlap+(gyroid_dimensions(3)+t)/2]);
% V_top = V_top';
% patch('Faces', F_top, 'Vertices', V_top, 'EdgeColor','green', 'FaceColor', 'green','FaceAlpha',0.1);
% 
% top_cuboid.vertices = V_top;
% top_cuboid.faces = F_top;
% 
% %[V_bottom, F_bottom] = DrawCuboid([gyroid_dimensions(1)+gyroid_thickness gyroid_dimensions(2)+gyroid_thickness t], [gyroid_dimensions(1)/2, (gyroid_dimensions(2)/2), -(t/2)+(gyroid_dimensions(3)*overlap)]);
% [V_bottom, F_bottom] = DrawCuboid([gyroid_dimensions(1)+gyroid_thickness gyroid_dimensions(2)+gyroid_thickness t], [0,0,overlap-(gyroid_dimensions(3)+t)/2]);
% V_bottom = V_bottom';
% patch('Faces', F_bottom, 'Vertices', V_bottom, 'EdgeColor','green', 'FaceColor', 'green','FaceAlpha',0.1);
% 
% bottom_cuboid.vertices = V_bottom;
% bottom_cuboid.faces = F_bottom;
% 
% daspect([1 1 1])
% hold on

%% INTERSECT GYROID WITH CUBIODS
% close all
% 
% % Create Surface #1
% Surface1 = gyroid_mesh;
% % Create Surface #2
% Surface2 = top_cuboid;
% % Plot them
% clf; hold on
% S=Surface1; trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'FaceAlpha', 0.5, 'FaceColor', 'r');
% S=Surface2; trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'FaceAlpha', 0.5, 'FaceColor', 'g');
% % view([3 1 1])
% % axis equal
% % title ('Test surfaces')
% % legend({'#1', '#2'});
% 
% [intersect12, Surf12] = SurfaceIntersection(Surface1, Surface2);
% 
% clf; hold on
% S=Surf12; trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r');
% title ('Surface/Surface intersections')
% legend({'#1/#2'});
% view([3 1 1])
% axis equal

%% Gyroid volume fraction vs thickness

a = 1; % Periodicity
gyroid_dimensions = [1 1 1];
res = 0.005;
X = -gyroid_dimensions(1)/2:res:gyroid_dimensions(1)/2;
Y = -gyroid_dimensions(2)/2:res:gyroid_dimensions(2)/2;
Z = -gyroid_dimensions(3)/2:res:gyroid_dimensions(3)/2;
[x,y,z] = meshgrid(X,Y,Z);
gyroid = sin(2*pi*x/a).* cos(2*pi*y/a) + sin(2*pi*y/a).* cos(2*pi*z/a) + sin(2*pi*z/a).* cos(2*pi*x/a);
[F, V] = isosurface(X,Y,Z,gyroid,0);
at = V(F(:, 2), :) - V(F(:, 1), :);
bt = V(F(:, 3), :) - V(F(:, 1), :);
ct = cross(at, bt, 2);
area = 1/2 * sum(sqrt(sum(ct.^2, 2)));

thickness_vec = 0.001:0.001:0.245;
volume_fraction_vec = zeros(size(thickness_vec));
i = 1;

for gyroid_thickness = 0.001:0.001:0.245
    volume = area*gyroid_thickness;
    volume_fraction = area*gyroid_thickness/prod(gyroid_dimensions);
    volume_fraction_vec(i) = volume_fraction;
    i = i+1;
end

slope = thickness_vec'\volume_fraction_vec'; % Same as area of single unit cell

plot(thickness_vec,volume_fraction_vec, "LineWidth", 3);
hold on
scatter([0.06,0.1,0.2],[0.185,0.31,0.62],100,"r","filled")
yline(0.757615, "--")
xlabel("Gyroid Thickness");
ylabel("Volume Fraction");