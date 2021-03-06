#!/bin/bash

#-----------------------
#-----    MESH     -----
#-----------------------
# Change mesh parameters
h=60   # Ice height and half length
r=1    # Channel Radius
c=3    # Mesh coarse (sides)
f=0.05 # Mesh fine (channel)
echo "Parameters: height=$h, radius=$r"

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

#-----------------------
#-----    SOLVE    -----
#-----------------------
# Run filename to edit
run1=Nye_freeslip_n1.sif
run3=Nye_freeslip_n3.sif

# Change mesh name in sif file
sed -i 's/.*$Fname       =.*/$Fname       = "'${fname_msh%.*}'"/' Code/$run1
sed -i 's/.*$Fname       =.*/$Fname       = "'${fname_msh%.*}'"/' Code/$run3

# Log filenames
fname_log1="RunLogs/tmp_${run1}.log"
fname_log3="RunLogs/tmp_${run3}.log"

# Solve Runs
ElmerSolver Code/$run1 > $fname_log1
ElmerSolver Code/$run2 > $fname_log1

#-----------------------
#-----   OUTPUT    -----
#-----------------------
echo
echo "OUTPUT:"

# Filename output
DATE=`date +%Y-%m-%d_%H:%M:%S`
fname_out1=`echo Runlogs/"$DATE"_${run1%.*}.log`
fname_out3=`echo Runlogs/"$DATE"_${run3%.*}.log`

# Export Result from logs
for f_in in $fname_log1 $fname_log3;
do  
    if [ $f_in = $fname_log1 ]
    then 
	f_out=$fname_out1
    else 
	f_out=$fname_out3
    fi
    
    # Echo output
    echo $f_out

    # Output
    grep "Reading Model:" $f_in > $f_out
    grep "Mesh DB" $f_in >> $f_out
    grep "Output File Name" $f_in >> $f_out 
    grep "MAIN:  Steady state iteration:" $f_in >> $f_out
    grep "ComputeChange: NS (ITER=1)" $f_in | grep "navier-stokes" >> $f_out
    grep "ElmerSolver:" $f_in >> $f_out
    grep "SOLVER" $f_in >> $f_out
done
echo

# Copy to post-processing directory
path_post="../../PostProc/Data"
[ ! -d "$path_post/${fname_msh%.*}" ] && mkdir $path_post/${fname_msh%.*}
cp ${fname_msh%.*}/${run1%.*}_surf* $path_post/${fname_msh%.*}
cp ${fname_msh%.*}/${run3%.*}_surf* $path_post/${fname_msh%.*}
