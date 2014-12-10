#!/bin/bash

#-----------------------
#-----    MESH     -----
#-----------------------
# Parameters
h=60
file="channel_nye"
dir="channel_nye"

# Change mesh width
sed -i '' -e 's/.*h      =.*/h      = '$h';/g' Mesh/$file.geo 
sed -i '' -e 's/.*l      =.*/l      = '$h';/g' Mesh/$file.geo 

# Change gmsh file and produce mesh
gmsh -1 -2 Mesh/$file.geo

# Copy to folder
cp Mesh/$file.msh .

# Convert to Elmer Mesh
ElmerGrid 14 2 $file.msh -autoclean -order 1.0 0.1 0.01

# Clean
rm -fv channel_nye.msh 

#-----------------------
#-----    SOLVE    -----
#-----------------------
# Run filename to edit
run1=Nye_freeslip_n1.sif
run3=Nye_freeslip_n3.sif

# Change mesh name in sif file
sed -i '' -e 's/.*$Fname       =.*/$Fname       = "'$dir'"/g' Code/$run1
sed -i '' -e 's/.*$Fname       =.*/$Fname       = "'$dir'"/g' Code/$run3

# Log filenames
fname_log1="RunLogs/tmp_log_n1.log"
fname_log3="RunLogs/tmp_log_n3.log"

# Solve Runs
echo
echo "RUNs:"
echo $run1
ElmerSolver "Code/$run1" > $fname_log1
echo $run3
ElmerSolver "Code/$run3" > $fname_log3


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
[ ! -d "$path_post/$dir" ] && mkdir $path_post/$dir
cp channel_nye/*surf* $path_post/$dir




