#!/usr/bin/env bash

set -euxo pipefail

respect_exe=/home/roberto/Workspace/ReSpect-mDKS/build_master/respect
inpdir=$PWD/../inputs

run_calc()
{
    nsteps_prev=$1
    nsteps_next=$2
    input=$3
    shift; shift; shift;
    input="${input%.inp}"
    fullname="${nsteps_next}"_"${input}"
    cp "${input}".inp "${fullname}".inp
    sed -i -e "s/NSTEPS/${nsteps_next}/g" "${fullname}".inp
    echo "Running simulation from ${nsteps_prev} to ${nsteps_next}"
    if [ "$nsteps_prev" -eq "0" ]; then
        ln -sf scf.50 "${fullname}".50
        ${respect_exe} --tdscf --inp="${fullname}"
    else
        ln -sf "${nsteps_prev}"_"${input}".50 "${fullname}".50
        ${respect_exe} --tdscf --inp="${fullname}" --restart
    fi
}

# Clean up output from previous calculations
rm -f ./*.50.backup ./*.out* ./*.molden

# Run SCF
cp "$inpdir"/scf.inp "$PWD"
${respect_exe} --scf --inp=scf

# Run TDSCF (20 steps) for a field applied in the three Cartesian directions, in turn
export dir_x="1.0 0.0 0.0"
export dir_y="0.0 1.0 0.0"
export dir_z="0.0 0.0 1.0"
nsteps_prev=0
for dir in x y z; do
    echo "Running 1 simulation (20 steps) in the ${dir} direction"
    cp "$inpdir"/tdscf.inp "$PWD"/tdscf_${dir}.inp
    subst="dir_${dir}"
    sed -i -e "s/XYZXYZXYZ/${!subst}/g" tdscf_${dir}.inp
    run_calc ${nsteps_prev} 20 tdscf_${dir}.inp
done
