# pep-cwl

One common task in bioinformatics is to run a bunch of samples independently through a workflow. Often, samples are listed in a CSV sample table with one row per sample. We'd like to be able to easily run a CWL workflow on each row of the sample table.

A standardized format for reading and writing sample tables is [PEP](http://pep.databio.org). This repository demonstrates how to run a standard sample table described in PEP format through an arbitrary CWL pipeline. There are two examples: the [simple demo](/simple_demo), which just runs `wc` on a few text files as input, and a [bioinformatics_demo](/bioinformatics_demo), which runs a basic `bowtie2` alignment on some sequencing reads.

## Simple demo

### CWL tool description

Here is a [CWL tool description](simple_demo/wc-tool.cwl) that runs `wc` to count lines in an input file. Invoke it on a [simple job](simple_demo/wc-tool.yml) like this:

```
cwl-runner wc-tool.cwl wc-job.yml
```

This runs the workflow for one input. How can we run it across multiple samples? CWL has built-in scatterers to do this, but we want to simplify things so we can just run it across a csv sample table.

### PEP-formatted sample metadata

Our sample data is stored in a [sample table](simple_demo/file_list.csv) with two rows, each corresponding to a sample. Each row points to a corresponding input file in the [data](simple_demo/data) subdirectory. This sample table along with the [config file](simple_demo/project_config.yaml) together make up a standard PEP (see [pep.databio.org](http://pep.databio.org) for formal spec).

We'd like to run our CWL workflow/tool on each of these samples, which means running it once per row in the sample table. We can accomplish this with [looper](http://looper.databio.org), which is an arbitrary command runner for PEP-formatted sample data. From a CWL perspective, looper is a *tabular scatterer* -- it will scatter a CWL workflow across each row in a sample table independently.

### Using looper

Looper uses a [pipeline interface](simple_demo/cwl_interface.yaml) to describe how to run `cwl-runner`. In this interface we've simply specified a `command_template:`, which looks like the above CWL command: `cwl-runner {pipeline.path} {sample.yaml_file}`. This command template uses two variables to construct the command: the `{pipeline.path}` refers to `wc-tool.cwl`, pointed to in the `path` attribute in the pipeline interface file. Looper also automatically creates a `yaml` file representing each sample, and the path is accessed with `{sample.yaml_file}`.

To run these commands, invoke `looper run`, passing the project configuration file, like this:

```
looper run project_config.yaml
```

This will run the `cwl-runner wc-tool.cwl ...` command on *each row in the sample table*. While there is also a built-in CWL approach to scatter workflows, there are a few nice things about the looper approach:

- you get all the benefits of PEP project formatting. PEPs are a completely independent specification for describing sample metadata, complete with an [independent validation platform called eido](http://eido.databio.org). PEP also provides powerful portability features like *derived attributes*, and *implied attributes*, which make it easier for you to use a single sample table that works across multiple pipelines and computing environments. PEP also provides project-level features: in a project config file, you can use *imports* to define a hierarchy of project settings, and *amendments* to design projects with similar sub-projects (such as a re-run of a particular sample table with slightly different parameters; or an exact re-run on a separate sample table). Finally, because PEP is independent, and not tied to a specific pipeline framework, your sample annotations are likely to be reusable across other pipelines; for instance, Snakemake can natively read a PEP-formatted project, so someone could take your data as input directly into a Snakemake workflow as well.

- looper provides a CLI with lots of other nice features for job management, outlined in the [looper docs](http://looper.databio.org/en/latest/features/).

## Bioinformatics demo

This demo will run a basic bowtie2 alignment.

Running example:

```
PATH="$PATH:$HOME/apps/bowtie2-2.4.1-linux-x86_64" looper run bioinformatics_demo/pep_bio.yaml
```



### Other looper features

#### Initialize the repository for easier CLI access

```
looper init project_config.yaml
```

Then run from this directory without passing the config file:

```
looper run
```


### Switch back-end computing infrastructure with divvy

Use [divvy](http://divvy.databio.org) to customize available computing once, then use it on all your workflows. 

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



