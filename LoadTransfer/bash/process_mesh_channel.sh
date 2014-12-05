#emacs process_mesh_nye.sh

# Change mesh width
h=45
a=1
c=3;
f=0.05;
echo "Parameters: h=$h, a=$a"
# Replace
sed -i 's/.*h      =.*/h      = '$h';/' Mesh/channel_ld_meshdiff.geo
sed -i 's/.*l      =.*/l      = '$h';/' Mesh/channel_ld_meshdiff.geo
sed -i 's/.*a      =.*/a      = '$a';/' Mesh/channel_ld_meshdiff.geo
sed -i 's/.*coarse1=.*/coarse1= '$c';/' Mesh/channel_ld_meshdiff.geo
sed -i 's/.*coarse2=.*/coarse2= '$c';/' Mesh/channel_ld_meshdiff.geo
sed -i 's/.*fine1  =.*/fine1  = '$f';/' Mesh/channel_ld_meshdiff.geo

# Filename
path="Mesh"
fname_geo="channel_ld_h$h""_a$a""_c$c.geo"
fname_msh="channel_ld_h$h""_a$a""_c$c.msh"
echo "$fname_geo"
echo "$fname_msh"

# Create file
cp $path/channel_ld_meshdiff.geo $path/$fname_geo

# Change gmsh file and produce mesh
gmsh -1 -2 $path/$fname_geo

# Copy to folder
cp $path/$fname_msh .

# Convert to Elmer Mesh
ElmerGrid 14 2 ./$fname_msh -autoclean -order 1.0 0.1 0.01

# Clean
rm -fv ./$fname_msh

# Solve Runs
#ElmerSolver Code/circle_Nye_freeslip_n1.sif
#ElmerSolver Code/circle_Nye_freeslip_n3.sif

# Copy to post-processing directory
#cp channel_nye/surf_trans* ../../host/LoadTransfer/