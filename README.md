# pep-cwl

This repository explores how to run a PEP-formatted samples through a CWL pipeline.


## CWL direct

Here is a [CWL tool description](wc-tool.cwl) that just runs `wc` to count the lines in an input file. You can invoke it on a [simple job](wc-job.yml) like this:

```
cwl-runner wc-tool.cwl wc-job.yml
```

## Using looper

Looper uses a [pipeline interface](cwl_interface.yaml) to describe how to run `cwl-runner`. We have a PEP that is made up of a [config file](project_config.yaml) that points to a [sample table](file_list.csv), which points to two input files in the [data](/data) subdirectory.

Looper will scatter the CWL tool across these samples like this:

```
looper run project_config.yaml
```

Now you can use the looper interface, which provides lots of nice features. For example:

### Initialize the repository for easier CLI access

```
looper init project_config.yaml
```

Then run from this directory without passing the config file:

```
looper run
```


### Switch back-end computing infrastructure with divvy

Use [divvy](http://divvy.databio.org) to customize available computing one, then use it on all your workflows. 

```
looper run --compute slurm
```

Or, run with a different bulker environment for version-controlled software set management:

```
looper run --compute bulker_local
```

### Run just a few samples


Run only the first sample:
```
looper run --limit 1
```

Run only samples with a given name:

```
looper run --sel-attr sample_name --sel-incl frog_1
```

Exclude samples with a given name:

```
looper run --sel-attr sample_name --sel-excl frog_1
```

### Run multiple samples in one slurm job:

```
looper run --compute slurm --lumpn 2
```
