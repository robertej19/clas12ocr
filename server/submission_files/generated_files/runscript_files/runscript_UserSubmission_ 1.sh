#!/bin/csh

# Run Script Header
# -----------------

source /etc/profile.d/environment.csh
setenv RCDB_CONNECTION mysql://null

set submissionID=$1


# saving date for bookmarking purposes:
set startDate = `date`

echo Running directory: `pwd`

printf "Job submitted by: robertej"
printf "Job Project: CLAS12"
echo
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

# copying gcard to gemc.gcard
cp `cat job.gcard` gemc.gcard

echo
echo GEMC executable: `which gemc`
gemc -USE_GUI=0 -OUTPUT="evio, gemc.evio" -N=100  -INPUT_GEN_FILE="lund, sidis.dat"  gemc.gcard
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
printf "Running evio2hipo with torus current scale:  $torusField and solenoid current scale: $solenField"
echo
echo
echo executing: evio2hipo -r 11 -t -1 -s -1 -i gemc.evio -o gemc.hipo
evio2hipo -r 11 -t -1 -s -1 -i gemc.evio -o gemc.hipo
echo
printf "evio2hipo Completed on: "; /bin/date
echo
echo "Directory Content After evio2hipo:"
ls -l
echo

# End of evio2hipo
# ----------------



# Run Reconstruction
# ------------------

# saving date for bookmarking purposes:
set reconstructionDate = `date`

set configuration = `echo YAML file: rga_fall2018.yaml`
echo
echo
echo executing: recon-util -y rga_fall2018.yaml -i gemc.hipo -o recon.hipo
recon-util -y rga_fall2018.yaml -i gemc.hipo -o recon.hipo
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

