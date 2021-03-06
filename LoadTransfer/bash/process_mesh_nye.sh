#emacs process_mesh_nye.sh

# Change mesh width
h=60

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

# Run filename to edit
run1=Nye_freeslip_n1.sif
run3=Nye_freeslip_n3.sif

# Change mesh name in sif file
sed -i 's/.*$Fname       =.*/$Fname       = "channel_nye"/' Code/$run1
sed -i 's/.*$Fname       =.*/$Fname       = "channel_nye"/' Code/$run3

# Log filenames
fname_log1="RunLogs/tmp_log_n1.log"
fname_log3="RunLogs/tmp_log_n3.log"

# Solve Runs
ElmerSolver Code/$run1 > $fname_log1
ElmerSolver Code/$run3 > $fname_log3

# Filename output
DATE=`date +%Y-%m-%d_%H:%M:%S`
fname_out1=`echo Runlogs/"$DATE"_${run1%.*}.log`
fname_out3=`echo Runlogs/"$DATE"_${run3%.*}.log`

# Export Result from logs
for f_in in $fname_log1 $fname_log3;
do  
    if [ $f_in = $fname_log1 ]
    then 
	fname_out=$fname_out1
    else 
	fname_out=$fname_out3
    fi
    echo "OUTPUT:"
    echo $fname_out
    echo

    # Output
    grep "Reading Model:" $f_in > $fname_out
    grep "Mesh DB" $f_in >> $fname_out
    grep "Output File Name" $f_in >> $fname_out 
    grep "MAIN:  Steady state iteration:" $f_in >> $fname_out
    grep "ComputeChange: NS (ITER=1)" $f_in | grep "navier-stokes" >> $fname_out
    grep "ElmerSolver:" $f_in >> $fname_out
    grep "SOLVER" $f_in >> $fname_out
done

# Copy to post-processing directory
#cp channel_nye/surf_trans* ../../host/LoadTransfer/
