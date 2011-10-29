%% Compile
fprintf('COMPILING:\n')

mex BuildGLTree3D.cpp
fprintf('\tBuildGLTree3D : mex succesfully completed.\n') 

mex CuboidSearch3D.cpp
fprintf('\tCuboidSearch3D : mex succesfully completed.\n') 

mex KNNSearch3D.cpp
fprintf('\tKNNSearch3D : mex succesfully completed.\n') 

mex KNNGraph3D.cpp
fprintf('\tKNNGraph3D : mex succesfully completed.\n') 


mex RSearch3D.cpp
fprintf('\tRSearch3D : mex succesfully completed.\n') 

mex NNFilter3D.cpp
fprintf('\tNNFilter3D : mex succesfully completed.\n') 

mex DeleteGLTree3D.cpp
fprintf('\tDeleteGLTree3D : mex succesfully completed.\n\n') 
