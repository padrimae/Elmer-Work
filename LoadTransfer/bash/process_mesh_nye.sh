#emacs process_mesh_nye.sh

# Change mesh width
sed -i 's/.*h      =.*/h      = 45;/' channel_nye.geo 
sed -i 's/.*l      =.*/l      = 45;/' channel_nye.geo 

# Change gmsh file and produce mesh
gmsh -1 -2 Mesh/channel_nye.geo

# Copy to folder
cp Mesh/channel_nye.msh .

# Convert to Elmer Mesh
ElmerGrid 14 2 channel_nye.msh -autoclean -order 1.0 0.1 0.01

# Clean
rm -fv channel_nye.msh 

# Solve Runs
ElmerSolver Code/circle_Nye_freeslip_n1.sif
ElmerSolver Code/circle_Nye_freeslip_n3.sif

# Copy to post-processing directory
cp channel_nye/surf_trans* ../../host/LoadTransfer/