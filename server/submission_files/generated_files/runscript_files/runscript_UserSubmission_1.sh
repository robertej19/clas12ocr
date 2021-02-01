#!/bin/csh

# Run Script Header
# -----------------

source /etc/profile.d/environment.csh
setenv RCDB_CONNECTION mysql://null

set submissionID=$1


# saving date for bookmarking purposes:
set startDate = `date`

echo Running directory: `pwd`

printf "Job submitted by: testuser"
printf "Job Start time: "; /bin/date
printf "Job is running on node: "; /bin/hostname
echo

echo Directory `pwd` content before starting submissionID $submissionID":"
ls -l
echo

# End of Run Script Header
# ------------------------


# Generator
# ---------

# saving date for bookmarking purposes:
set generatorDate = `date`

echo
printf "Running 100 events with generator >clasdis< with options: --t 10 15"
echo
clasdis --trig 100 --docker --t 10 15
echo
printf "Events Generator Completed on: "; /bin/date
echo
echo "Directory Content After Generator:"
ls -l
echo

# End of Run Generator
# ---------------------


# Run GEMC
# --------

# saving date for bookmarking purposes:
set gemcDate = `date`

# copying the gcard to <conf>.gcard
cp /jlab/clas12Tags/$CLAS12TAG"/config/"rga_fall2018".gcard" rga_fall2018.gcard

echo
echo GEMC executable: `which gemc`

echo "Directory Content before GEMC"
ls -l

gemc -USE_GUI=0 -OUTPUT="evio, gemc.evio" -N=100  -INPUT_GEN_FILE="lund, clasdis.dat"  rga_fall2018.gcard
echo
printf "GEMC Completed on: "; /bin/date
echo
echo "Directory Content After GEMC:"
ls -l
echo

# End of GEMC
# -----------



# Run evio2hipo
# -------------

# saving date for bookmarking purposes:
set evio2hipoDate = `date`

echo
printf "Running evio2hipo with torus current scale: -1.00 and solenoid current scale: -1.00"
echo
echo
echo executing: evio2hipo -r 11 -t -1.00 -s -1.00 -i gemc.evio -o gemc.hipo
evio2hipo -r 11 -t -1.00 -s -1.00 -i gemc.evio -o gemc.hipo
echo
printf "evio2hipo Completed on: "; /bin/date
echo
echo "Directory Content After evio2hipo:"
ls -l
echo

# End of evio2hipo
# ----------------



# Run background merging
# ----------------------

echo "Directory Content Before Background Merging:"
ls -l

bgMerginFilename.sh rga_fall2018 tor-1.00_sol-1.00 45nA_10604MeV get

set bgFile = `ls 0*.hipo`

echo xrootd file to load: $bgFile

bg-merger -b $bgFile -i gemc.hipo -o gemc.merged.hipo -d "DC,FTOF,HTCC,ECAL"

echo "Directory Content After Background Merging:"
ls -l

# End ofbackground merging
# ------------------------



# Run Reconstruction
# ------------------

# saving date for bookmarking purposes:
set reconstructionDate = `date`

# copying the yaml file to recon.yaml
cp /jlab/clas12Tags/$CLAS12TAG"/config/"rga_fall2018.yaml rga_fall2018.yaml

set configuration = `echo YAML file: rga_fall2018.yaml`
echo
echo
echo executing: recon-util -y rga_fall2018.yaml -i gemc.merged.hipo -o recon.hipo
recon-util -y rga_fall2018.yaml -i gemc.merged.hipo -o recon.hipo
echo
printf "recon-util Completed on: "; /bin/date
echo
echo "Directory Content After recon-util:"
ls -l
echo

# End of Reconstruction
# ---------------------


# Removing Unnecessary Files and Creating DST if selected
# -------------------------------------------------------





echo Creating the DST
hipo-utils -filter -b 'RUN::*,RAW::epics,RAW::scaler,HEL::flip,HEL::online,REC::*,RECFT::*,MC::*' -merge -o dst.hipo recon.hipo


echo Removing reconstructed file
rm recon.hipo
	

# Run Script Footer
# -----------------

set endDate = `date`

echo ==== SubMit-Job === Job Start: $startDate
echo ==== SubMit-Job === Generator Start: $generatorDate
echo ==== SubMit-Job === GEMC Start: $gemcDate
echo ==== SubMit-Job === evio2hipoDate Start: $evio2hipoDate
echo ==== SubMit-Job === Reconstruction Start: $reconstructionDate
echo ==== SubMit-Job === Job End: $endDate

# End of Run Script Footer
# ------------------------

