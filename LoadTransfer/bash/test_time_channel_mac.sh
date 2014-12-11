#!/bin/bash


#-----------------------
#-----    MESH     -----
#-----------------------
# Change mesh parameters (metres)
h=100   # Ice height 
l=100   # Ice distance from channel (1 side)
r=0.5   # Channel Radius
cs=10   # Mesh coarse (sides)
ct=20   # Mesh coarse (top)
f=0.05  # Mesh fine (channel)

# Echo Output
echo "Parameters: height_ice  =$h"
echo "            length_ice  =$l"
echo "            radius_chnl =$l"
echo "            coarse_side =$cs"
echo "            coarse_top  =$ct"
echo "            fine_channel=$l"

# Replace
sed -i '' -e 's/.*h      =.*/h      = '$h';/g'  Mesh/channel_ld_meshdiff.geo
sed -i '' -e 's/.*l      =.*/l      = '$l';/g'  Mesh/channel_ld_meshdiff.geo
sed -i '' -e 's/.*r      =.*/r      = '$r';/g'  Mesh/channel_ld_meshdiff.geo
sed -i '' -e 's/.*coarse1=.*/coarse1= '$cs';/g' Mesh/channel_ld_meshdiff.geo
sed -i '' -e 's/.*coarse2=.*/coarse2= '$ct';/g' Mesh/channel_ld_meshdiff.geo
sed -i '' -e 's/.*fine1  =.*/fine1  = '$f';/g'  Mesh/channel_ld_meshdiff.geo

# Filename
path="Mesh"
fname_geo="channel_ld_h$h""_l$l""_r$r""_cs$cs""_ct$ct""_f$f.geo"
fname_msh="channel_ld_h$h""_l$l""_r$r""_cs$cs""_ct$ct""_f$f.msh"
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
run1=trans_freeslip_n3_pwctt.sif
run3=trans_freeslip_n3_pwsin.sif

# Change timestep
hr="*24"
min=""
sec=""
sed -i '' -e 's/.*$dt.*/$dt          = 1.0\/(365.25'$hr$min$sec')/g' Code/$run1
sed -i '' -e 's/.*$MaxIter.*/$MaxIter     = days'$hr$min$sec'/g'     Code/$run3

# Change mesh name in sif file
sed -i '' -e 's/.*$Fname.*/$Fname       = "'${fname_msh%.*}'"/g' Code/$run1
sed -i '' -e 's/.*$Fname.*/$Fname       = "'${fname_msh%.*}'"/g' Code/$run3

# Change Ice thickness
sed -i '' -e 's/.*$Hice.*/$Hice = '$h'/g' Code/$run1
sed -i '' -e 's/.*$Hice.*/$Hice = '$h'/g' Code/$run3

# Log filenames
fname_log1="RunLogs/tmp_$run1.log"
fname_log3="RunLogs/tmp_$run3.log"

# Solve Runs
echo
echo "RUNs:"
echo $run1
ElmerSolver Code/$run1 > $fname_log1
echo $run3
ElmerSolver Code/$run3 > $fname_log3


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
for f_in in $fname_log1 $fname_log3
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
    grep "Timestep Intervals" $f_in >> $f_out
    grep "Timestep Sizes" $f_in >> $f_out
    grep "Glen Exponent" $f_in >> $f_out
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

done
