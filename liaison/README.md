Liaison code has two jobs.

1. Prepares packages and feed them to the supercomputer.
2. Download results from the supercomputer and unpackage them for storage and further analysis.

## Scripts

### create_pbs_script.sh

Compute clusters typically are set up with a queuing system to manage the jobs and the hardware allocation for them. This script writes another script that informs the cluster what kind of environment to set up, what hardware requirements are necessary, and what to execute.


