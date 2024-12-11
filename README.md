# kallisto

kallisto is a program for quantifying abundances of transcripts from RNA-Seq data, or more generally of target sequences using high-throughput sequencing reads. It is based on the novel idea of pseudoalignment for rapidly determining the compatibility of reads with targets, without the need for alignment.

## Overview

## Dependencies

* [kallisto 0.50.0](https://github.com/pachterlab/kallisto)


## Usage

### Cromwell
```
java -jar cromwell.jar run kallisto.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`fastqR1`|File|Input fastqR1 file for analysis sample
`fastqR2`|File|Input fastqR2 file for analysis sample
`outputFileNamePrefix`|String|Output prefix, customizable.


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runKallisto.modules`|String|"kallisto/0.50.0 kallisto-transcriptome-index/0.50.0"|Names and versions of modules
`runKallisto.timeout`|Int|48|Timeout in hours, needed to override imposed limits
`runKallisto.jobMemory`|Int|12|Memory in Gb for this job


### Outputs

Output | Type | Description
---|---|---
`abundanceH5`|File|{'description': 'a HDF5 binary file containing run info, abundance esimates, bootstrap estimates, and transcript length information length. This file can be read in by sleuth', 'vidarr_label': 'abundanceH5'}
`abundanceTsv`|File|{'description': 'a plaintext file of the abundance estimates. It does not contains bootstrap estimates.', 'vidarr_label': 'abundanceTsv'}
`runinfoJson`|File|{'description': 'a json file containing information about the run', 'vidarr_label': 'runinfoJson'}


## Commands
 This section lists command(s) run by WORKFLOW workflow
 
 * Running WORKFLOW
 
 === Description here ===.
 
 <<<
         $KALLISTO_ROOT/bin/kallisto quant \
         -i $KALLISTO_TRANSCRIPTOME_INDEX_ROOT/transcriptome_kallisto0.50.0_ensembl104.idx \
         --bootstrap-samples=120 \
         -o outputDir \
         -t 5 \
         ~{fastqR1} \
         ~{fastqR2}
 
         mv outputDir/abundance.h5 ~{sampleID}.abundance.h5 
         mv outputDir/abundance.tsv  ~{sampleID}.abundance.tsv
         mv outputDir/run_info.json ~{sampleID}.run_info.json
     >>>
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
