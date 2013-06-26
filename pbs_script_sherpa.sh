#!/bin/bash

#PBS -m ea
#PBS -l nodes=1:ppn=8
#PBS -l walltime=8:00:00
#PBS -N sherpa_147298

dataset="147298"
### This tells mpi the number of threads to create (should equal the number of cores available = nodes*ppn)
export OMP_NUM_THREADS=8

### Loads useful modules on the batch node
module load core
module load gsl/1.15
module load swig/2.0.8
module load boost/1.52.0
module load openmpi/gnu/1.6.3

### This copies Rivet,fastjet,lhapdf,Sherpa to the batch node and sets the proper env variables
### If I change batch_root here, then I also need to change it in rivetenv-batch.sh
batch_root="/scratch"
cp -r $HOME/Rivet ${batch_root}
source /scratch/Rivet/rivetenv-batch.sh

### this block of code makes a /work/your_user_name/this_job directory & stores a copy of the script file there.
# my_input_directory is the BASH variable hardcoded with the absolute path to the directory where the input files live;
# using this, the script will glob an expected pattern to find the input files.
my_input_directory="/N/u/${USER}/Quarry/Sherpa_Run_dat"
# this conditional makes my_input_directory if it does not already exist.
if [[ ! -d ${my_input_directory} ]]; then
	echo	""${my_input_directory}" is not a directory or does not exist."
	exit	1
fi

# my_script_name is the name of the script file
my_script_name="sherpa.sh"
my_original_script="${my_input_directory}/${my_script_name}"
# my_run_card_name is the name of the Sherpa Run card
my_run_card_name="Run.dat"
my_sherpa_run_card="${my_input_directory}/${dataset}/${my_run_card_name}"
# sanity check: this conditional checks that my_original_script actually exists and is a file.
if [ ! -f "${my_original_script}" ] ; then
	echo	""${my_original_script}" is not a regular file."
	exit	1
fi
if [ ! -f "${my_sherpa_run_card}" ] ; then
	echo	""${my_sherpa_run_card}" is not a regular file."
	exit	1
fi

# Designates home_area as the relevant folder on the login node (final destination for job output)
home_area="${my_input_directory}/${dataset}"
# Designates work_area as the relevant folder on the batch node (where the output is generate on batch node)
work_area=/scratch/sherpa_${dataset}_${PBS_JOBID}
# this conditional makes work_area if it does not already exist.
if [[ ! -d ${work_area} ]]; then
	mkdir -p ${work_area}
fi

# change directory command
cd ${work_area}

# copy command, makes a copy of my_original_script,my_sherpa_run_card and stores it in work_area
cp -f ${my_original_script} ${work_area}
cp -f ${my_sherpa_run_card} ${work_area}
mv ${my_script_name} ${dataset}_${my_script_name}
my_script_name="${dataset}_${my_script_name}"

# WORK_script is assigned the location of the copy of the script file that is stored in work_area.
WORK_script="${work_area}/${my_script_name}"
# sanity check: this conditional checks that WORK_script actually exists.
if [ ! -f "${WORK_script}" ] ; then
	echo	""${WORK_script}" is not a regular file."
	exit	1
fi

# Print out the nodes where the jobs run
echo "Execute node list:"
sort -u $PBS_NODEFILE

###	This block of code builds the command that is passed
# app_flags is assigned all the command line options that my executable needs.
app_flags="${my_input_directory}"

# app is assigned all the path of my executable
app="mpirun -np $OMP_NUM_THREADS -machinefile $PBS_NODEFILE ${WORK_script} LOG_FILE=out_${dataset}.log"

# app_command is assigned the entire command for running my executable with it's command line options.
app_command="${app}"

# app_out is assigned the name of the file to which the console output from my program will be redirected.
app_out="${PBS_JOBID}.out"

# job_start is a timestamp of when the job started.
job_start=`date +%s`

# this next line is the actual invocation of my executable. This is where the program runs; after this, the program has finished.
$app_command > $app_out

# job_result is assigned the return code of the invocation.
job_result=$?

# job_start is a timestamp of when the job finished.
job_finish=`date +%s`

# copy output from work_area in batch node back to home_area in login node
cp -r ${work_area} ${home_area}

# May think about deleting /scratch/Rivet/ and ${work_area}

###	this block of code generates some useful debug information; you can use this to see what each of these were defined as.
echo	"***post-job report***"
echo	"app_command:	${app_command}"
echo	"work_area:	${work_area}"
echo	"	app_out:	${app_out}"
echo	"home_area: ${home_area}"
echo	"job_result:	${job_result}"
echo	"job_start:	${job_start}"
echo	"job_finish:	${job_finish}"
echo
echo	"qsub host is ${PBS_O_HOST}"
echo	"original queue is ${PBS_O_QUEUE}"
echo	"qsub working directory absolute is ${PBS_O_WORKDIR}"
echo	"pbs environment is ${PBS_ENVIRONMENT}"
echo	"pbs batch id ${PBS_JOBID}"
echo	"pbs job name from me is ${PBS_JOBNAME}"
echo	"Name of file containing nodes is ${PBS_NODEFILE}"
echo	"contents of nodefile is:	"
cat 	$PBS_NODEFILE
echo	"Name of queue to which job went is ${PBS_QUEUE}"
echo
