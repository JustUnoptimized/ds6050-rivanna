# Rivanna Guide

Justin Lee

jgh2xh@virginia.edu

Last modified 2025-10-02

Version 0.0.2

---------------------

**Our goal is to provide a standardized environment for everyone (students and instructors) and avoid dependency hell.** When we receive your code for grading, we expect your code to run in our standardized environment without raising exceptions.

## Accessing Rivanna

UVA hosts a High Performance Computing (HPC) system consisting of multiple CPUs and GPUs, one of which is Rivanna. This guide will detail how you can access these resources. If you have any further questions, feel free to reach out to me!

See https://www.rc.virginia.edu/userinfo/hpc/ for a more in-depth overview.

### Open OnDemand IDE
The simplest way is to use Open OnDemand, a system hosted by UVA to access HPC *without needing a VPN*.

1. Open a browser and open: https://www.rc.virginia.edu/userinfo/hpc/login/
2. Under the Web-based Access section, click the link `Launch Open OnDemand`
3. Log in using your UVA credentials
4. At the top of the page, under the `Interactive Apps` dropdown menu, select an option:
    - JupyterLab - Opens up a JupyterLab instance where you can run Jupyter Notebooks
    - Code Server - Opens up a VSCode instance, where you can also run Jupyter Notebooks (which may require installing some extensions to add this functionality)
5. Enter the details for your HPC request
    - Partition - Standard for CPU only, GPU for NVIDIA GPU
    - Number of hours
    - Number of cores
    - Memory Request
    - Allocation - This must be set to `shakeri_ds6050`
    - Working Directory - See [below](#navigating-in-open-ondemand-jupyterlab-or-code-server)

### Open OnDemand Terminal (not recommended for heavy coding)
Open OnDemand also allows terminal access to HPC. Follow steps 1-3 above, then under the `Clusters` dropdown menu select `HPC Shell Access`. This will open up a terminal in your browser. This alone will not give you access to CPU or GPU compute but you can navigate, submit slurm jobs, and do some light scripting. If you want to [get access to CPU or GPU compute for interactive use](#accessing-cpus-and-gpus-on-rivanna), you will need to start an interactive slurm job. 

### SSH
You can also SSH from your own terminal into Rivanna, but you will either need to be on grounds and using the UVA wifi network, or a VPN connection to the UVA network. Like the Open OnDemand terminal, you will need to take some extra steps to [get access to CPU and GPU compute resources](#accessing-cpus-and-gpus-on-rivanna). The additional benefit of this approach is that **you can use SSH to connect via your favorite VScode client beefed up with LLM agents**.

The instructions below will generally require working from the terminal (or powershell for Windows)

#### Logging into Rivanna
0. If you live off-grounds and do not have access to the UVA wifi network `eduroam`, then first install the UVA VPN at https://virginia.service-now.com/its?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0 and connect to it before proceeding.
1. Create a public-private key pair from the terminal using the command `ssh-keygen -t ed25519`. Do not set a password, and optionally set a filename. This will generate a key-pair located at `~/.ssh/`. Your private key will have no extension (e.g. `id_ed25519`), and you do not want to share this with anyone else. Your public key will have the `.pub` extension (e.g. `id_ed25519.pub`).
2. Create an empty text file named `config` (no extensions) inside the `~/.ssh/` directory and fill it with the following text:
```
Host <servername>
    HostName login.hpc.virginia.edu
    User <your computing id>
    ServerAliveInternal 60
    IdentityFile ~/.ssh/id_ed25519
```

For example, my `~/.ssh/config` file looks like
```
Host riv
    HostName login.hpc.virginia.edu
    User jgh2xh
    ServerAliveInteral 60
    IdentityFile ~/.ssh/id_ed25519
```
3. Now we need to copy our public key into our Rivanna home directory. Mac users and Windows users have different commands, given below.
```
### For Mac users
ssh-copy-id -i <keyname> <servername>
## I would type:
## ssh-copy-id -i id_ed25519 riv

### For Windows users
cat .\<keyname>.pub | ssh <servername> "cat >> .ssh/authorized_keys"
## I would type:
## cat .\id_ed25519.pub | ssh riv "cat >> .ssh/authorized_keys"
```
This step may require you to enter your UVA password. Do not be surprised if it looks like the cursor doesn't move as you type; this is intended behavior. Once you type your password, press `Enter`.

4. Confirm that you can now login to Rivanna using the command `ssh <servername>` from the `<servername>` set in your `config` file. If successful, you should see something like:
```
Welcome to UVA_HPC
-bash-4.4$
```
Congratulations, you are now logged into UVA Rivanna via SSH! If you want to be extra sure, type the command `pwd` and you should see the output `/home/<your computing id>`. For example, I would see `/home/jgh2xh`.

#### Connecting VSCode
Once you have the above set up, connecting to Rivanna via VSCode is quite painless.

1. Install the `Remote Development` extension pack on VSCode.
2. Click on the blue `><`-looking symbol in the bottom left of the window. This should open up a dropdown menu.
3. Select `Connect to Host` and you should see the `<servername>` from the `config` file.
4. Your VSCode should now be connected to Rivanna! Like previously, open up a terminal instance and you should see `-bash-4.4$`. You can again type `pwd` to hopefully see the output `/home/<your computing id>`.

#### Accessing CPUs and GPUs on Rivanna
Because many people are accessing Rivanna at any given time, workload and resource distribution is managed by a dedicated workload manager called Slurm. Long story short, you will need to request resources from Slurm to actually get the CPUs or GPUs you need. I will give you some basic commands that you should be able to use out-of-the-box which should cover most use-cases, but feel free to explore the documentation in the links below for more fine-grained control.

UVA hosts a detailed introduction here: https://www.rc.virginia.edu/userinfo/hpc/slurm/
If you really want to see all the nitty-gritty: https://slurm.schedmd.com/overview.html

For starting an interactive job:
```
## CPU only
ijob -J <jobname> -A shakeri_ds6050 -p standard -c 1 -t <walltime> --mem=<memory> -v

## GPU
ijob -J <jobname> -A shakeri_ds6050 -p gpu --gres=gpu:1 -t <walltime> --mem=<memory> -v

## Smaller GPU so hopefully less wait for resources
ijob -J <jobname> -A shakeri_ds6050 -p gpu-mig --gres=gpu:1 -t <walltime> --mem=<memory> -v
```

`<jobname>` is just a name for the submitted `ijob`. I don't think it's necessary but I like to provide one. `<walltime>` is how long you will have access to the resources, and it is in the format `[d-]hh:mm:ss`. For example, `3-00:00:00` is a valid time for 3 days. The day is optional, so you can also do `48:00:00` for 2 days. Do note that the max `<walltime>` for CPU jobs are 7 days, and for GPU jobs are 3 days. `<memory>` is the amount of total memory and can be specified as `<memory>G` (for gigabytes). For example, if I wanted a GPU job for 24 hours and 64G of memory, I would use the command
```
ijob -J my_ijob -A shakeri_ds6050 -p gpu --gres=gpu:1 -t 1-00:00:00 --mem=64G -v
```

Once you get the job, you will see something similar to
```
salloc: Nodes udc-aw34-3c0 are ready for job
```
which means you have successfully gotten the compute resources![^ijobnote] This next section will detail some information about how Rivanna is structured, followed by instructions on how to set up your virtual environment for developing and running code.

#### Slurm Batch Jobs
Typically the `ijob`s above are used for drafting and debugging code. When you are ready to send everything for heavy/long training, you should consider using a batch job. Unlike `ijob`s, you do not need to keep your connection to Rivanna alive. Once you submit the job, Slurm will automatically handle running the code in the background so you can basically fire-and-forget. You can even submit multiple jobs at the same time to, for instance, speed up a hyperparameter search or ablation study!

Submitting jobs through slurm require setting up a Bash script containing the relevant flags and options. This includes things like the allocation, max walltime (and slurm will automatically kill jobs which exceed this limit), cpu/gpu, where to save printed output, etc.

You can actually separate output by regular output and error output, which may be useful in de-cluttering any printed outputs. They correspond respectively to output streams called `stdout` and `stderr`.

I will provide a very basic script and detail what each line means. Like I mentioned above, feel free to customize your own script. Also, please read the HPC slurm overview linked at the top of the document for a much more in-depth description of submitting slurm jobs.

```bash
#!/bin/bash

# the above bin/bash line is required to be at the top of your bash script

## Set slurm options and flags
#SBATCH -A shakeri_ds6050               # your allocation
#SBATCH -p gpu                          # use standard for cpu, gpu for gpu
#SBATCH --gres=gpu:1                    # required if using gpu. Can optionally choose a desired gpu
#SBATCH --ntasks=1                      # number of tasks
#SBATCH --nodes=1                       # number of nodes
#SBATCH --mem=64G                       # Amount of memory to allocate for the job
#SBATCH -c 1                            # cpus per task
#SBATCH -t 72:00:00                     # max wall clock time. 3 days is the limit for gpus. 7 days for cpus.
#SBATCH -o ./slurmlogs/train_%A_%a.out  # stdout output file
#SBATCH -e ./slurmlogs/train_%A_%a.err  # stderr output file

# For the output files, %A refers to the job id (assigned by slurm)
#                       %a refers to the array index (applicable if you submit an array job)
# If the job id is 1234 and there is no array index
# the outfile should be saved to <current directory>/slurmlogs/train_1234_.out
# Just to be safe, make sure the path to the output files exist
# which in this case means that the directory <current directory>/slurmlogs/ should exist.

## set up environment and python executable
CONDA_ENV_PATH="/path/to/dsvenv"
PIP_EX="$CONDA_ENV_PATH/bin/pip"
PYTHON_EX="$CONDA_ENV_PATH/bin/python"

## Gather current slurm job info
now=$(date -Iseconds)
wallclock=$(squeue -h -j $SLURM_ARRAY_JOB_ID -o %l)
gpuname=$(nvidia-smi --query-gpu=name --format=csv,noheader)

## print current slurm job info to stdout (and therefore train.out)
printf "\n\n======================================\n"
printf "[ JOB ID ]     : $SLURM_ARRAY_JOB_ID\n"
printf "[ ARRAY ID ]   : $SLURM_ARRAY_TASK_ID\n"
printf "[ WALLCLOCK  ] : $wallclock\n"
printf "[ START TIME ] : $now\n"
printf "[ GPU ]        : $gpuname\n\n"

## print current slurm job info to stderr (and therefore train.err)
printf "\n\n======================================\n" >&2
printf "[ JOB ID ]     : $SLURM_ARRAY_JOB_ID\n" >&2
printf "[ ARRAY ID ]   : $SLURM_ARRAY_TASK_ID\n" >&2
printf "[ WALLCLOCK  ] : $wallclock\n" >&2
printf "[ START TIME ] : $now\n" >&2
printf "[ GPU ]        : $gpuname\n\n" >&2


# script to run your python script here

# For example, suppose I had a python script called trainmodel.py
$PYTHON_EX trainmodel.py

# $PYTHON_EX gets the value stored in the variable PYTHON_EX
# which in this case will expand to /path/to/dsvenv/bin/python
# so the full command that gets executed is:
# /path/to/dsvenv/bin/python trainmodel.py
```

Now suppose this script is called `runner.slurm`, located at `/scratch/<computing id>/ds6050/`. Also suppose I have the directory `slurmlogs/`. Execute the script using the command
```
# make sure you are located at /scratch/<computing id>/ds6050
sbatch runner.slurm
```
which should output something like
```
Submitted batch job 1234
```

It might take some time for slurm to actually run the script, but once it does, you should see the files `train_1234_.out` and `train_1234_.err` inside `slurmlogs/`. Make sure to check the error file once in a while to make sure no bugs or errors came up in your code (or job submit). I've had times where I thought the job was successfully submitted, only to check the next day that there was some error in my submit script...

## Rivanna Directory Structure
When storing files in Rivanna, you will typically have access to two major partitions: `HOME` and `SCRATCH`. Both locations should be private--only you can access, read, and write files in your allocated `HOME` and `SCRATCH` spaces. Their purposes are somewhat self-explanatory.

`HOME` is your home directory and has "permanent" storage. On the terminal, you can access here using `cd /home/<your computing id>`, `cd $HOME`, or `cd ~`. Actual storage space, however, is limited to ~50GB, which you may find restrictive.

`SCRATCH` is a "temporary" storage space (the policy is roughly that files untouched for >90 days are subject to random deletion based on system storage needs). You can access this location using `cd /scratch/<your computing id>`. On the flip side, unlike `HOME`, you get up to 10TB.

### Choosing a Workspace
Given the limited storage space on `HOME`, I suggest working in `SCRATCH` especially if you ever need to save large datasets and/or parameters of any models you train. The 90 day policy should be long enough for any assignments throughout the semester, but feel free to also keep everything important backed up on a personal GitHub repository as well.

### Navigating in Open OnDemand JupyterLab or Code Server
The Open OnDemand interactive JupyterLab and Code Server sessions require you to set a Work Directory. If using JuypterLab, this setting determines the files you can see on the file-explorer sidebar. For example, suppose you have some file located somewhere in `HOME`, but you set your workspace to `SCRATCH`. You will not be able to open that file in your JupyterLab instance because you will have no way to navigate to it (at least using the GUI). E.g. You cannot access `/home/<your computing id>/foo.py` if you opened JupyterLab with workspace `SCRATCH` and vice versa.

If using Code Server, you can just change your workspace directory.

## Setting up your virtual environment on Rivanna
Great! You've managed to get into Rivanna. You will now need some additional setup to be able to run Jupyter Notebooks and other python scripts with the necessary packages.

I suggest setting up a virtual environment and installing all packages there. You can then set up that virtual environment as the Jupyter kernel for running your code. Instructions below:

0. Download the supplied [requirements.txt](requirements.txt) file and place it into your home directory.
1. Open up a terminal (either through Open OnDemand JupyterLab, or Code Server, or your SSH connection) and navigate to your home directory.
2. Run the command `module load miniforge/24.11.3-py3.12` which gives you access to the conda environment manager.
3. Run the command `conda create -n dsvenv python=3.12` and follow any subsequent instructions to set up a virtual environment named `dsvenv` running python 3.12. You can ignore any warnings about updating conda.
4. Activate the virtual environment using `conda activate dsvenv`. Your terminal should now show an additional `(dsvenv)` to indicate the active virtual environment.
5. Move to the cloned GitHub repository using `cd ds6050-rivanna`.
6. Run `pip install -r requirements.txt` to install the appropriate packages.

At this point, you are able to run python scripts which use any of the packages in the `requirements.txt` file.[^venvnote] The next step will allow you to access this virtual environment for your Jupyter Notebooks.

6. Run `python -m ipykernel install --name dsvenv --display-name dsvenv --prefix ~/.local` to set up a kernel for Jupyter Notebooks to access this virtual environment. <!-- **Warning**: You must run this command from outside JupyterLab because of some pesky directory reference/linking issue! The safest option is to use the Open OnDemand terminal. -->

If you are working through Open OnDemand, you should now be set. Create a new Jupyter notebook, and you should find `dsvenv` among the available kernels. If using SSH over VSCode, continue along to the next section. 

### Running Jupyter Notebooks on VSCode SSH
This section is for only if you are accessing via SSH on VSCode (assuming you have the Jupyter Notebook extensions installed). You need a few final steps to access your Jupyter kernel. First make sure that you have gotten the CPU and/or GPU compute from an `ijob`. If not, your Jupyter kernel will not have access to these resources! Then, follow the instructions.

7. Run the following two lines
```
## Gives you access to jupyterlab
module load jupyterlab

## Spin up the server
jupyter-notebook --no-browser --ip=0.0.0.0
```
This will start up a Jupyter server, and give you some URLs at the bottom. You are interested in the one that looks like `http://<nodename>:<port>/?token=<tokenstring>`. This will change depending on whatever node the Slurm manager decided to give you. For example, when I ran the commands just now, I got `http://udc-aw34-3c0:8888/?token=b6f22d46857481c89280570fc297c972d17b2685da4fa6e9`. In any case, copy this URL.

8. In your VSCode, open up a Jupyter notebook. In the top right, click on `Select Kernel` (it may display `Detecting Kernels` instead).

9. Select `Existing Jupyter Server`, paste in the URL from step 7, and select a server name (this does not really matter).[^jupyternote]

10. If all went well, you should now see a list of kernels, one of which is hopefully the `dsvenv` you installed in steps 0-6. Select it, and you are finally able to work on Jupyter notebooks from your own VSCode instance on Rivanna using CPU and/or GPU compute!

[^ijobnote]: You have to re-request resources using `ijob` each time you login to Rivanna.

[^venvnote]: Every time you re-login to HPC, you will need to re-activate the virtual environment as in step 4 to use the packages for any python scripts you write. In order to do so, you need to load miniforge as in step 2. Given the clunky names and commands, you can also open up `~/.bashrc` which is a text file and edit it to include the line `module load miniforge/24.11.3-py3.12` somewhere after the `alias vi='vim'` line. Then, on all future logins, you will automatically load miniforge so you can immediately activate the virtual environment using conda.

[^jupyternote]: The default name is the name of the node provided by the Slurm ijob. This may change each time you request an ijob. Moreover, in a new ijob instance, the saved name will refer to a Jupyter server which no longer exists so you cannot reconnect via selecting the saved name.
