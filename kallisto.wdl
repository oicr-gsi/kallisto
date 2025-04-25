version 1.0


workflow kallisto {
    input {
        File fastqR1
        File fastqR2
        String outputFileNamePrefix
    }

    parameter_meta {
        fastqR1: "Input fastqR1 file for analysis sample"
        fastqR2: "Input fastqR2 file for analysis sample"
        outputFileNamePrefix: "Output prefix, customizable."
    }

    # run kallisto
    call runKallisto 
        { 
            input: 
                fastqR1 = fastqR1,
                fastqR2 = fastqR2,
                sampleID = outputFileNamePrefix
        }

    meta {
        author: "Gavin Peng"
        email: "gpeng@oicr.on.ca"
        description: "kallisto is a program for quantifying abundances of transcripts from RNA-Seq data, or more generally of target sequences using high-throughput sequencing reads. It is based on the novel idea of pseudoalignment for rapidly determining the compatibility of reads with targets, without the need for alignment."
        dependencies: [
            {
                name: "kallisto/0.48.0",
                url: "https://github.com/pachterlab/kallisto"
            }
        ]
        output_meta: {
            abundanceH5: {
                description: "a HDF5 binary file containing run info, abundance esimates, bootstrap estimates, and transcript length information length. This file can be read in by sleuth",
                vidarr_label: "abundanceH5"
            },
            abundanceTsv: {
                description: "a plaintext file of the abundance estimates. It does not contains bootstrap estimates.",
                vidarr_label: "abundanceTsv"
            },
            runinfoJson: {
                description: "a json file containing information about the run",
                vidarr_label: "runinfoJson"
            }
        }
    }

    output {
        File abundanceH5 = runKallisto.abundance_h5
        File abundanceTsv = runKallisto.abundance_tsv
        File runinfoJson = runKallisto.runinfo_json
    }

}

# ==========================
#  configure and run kallisto
# ==========================
task runKallisto {
    input {
        File fastqR1
        File fastqR2
        String sampleID
        String modules = "kallisto/0.48.0 kallisto-transcriptome-index/0.48.0"
        Int timeout = 48
        Int jobMemory = 12
    }

    parameter_meta {
        fastqR1: "Input fastqR1 file for analysis sample"
        fastqR2: "Input fastqR2 file for analysis sample"
        jobMemory: "Memory in Gb for this job"
        modules: "Names and versions of modules"
        timeout: "Timeout in hours, needed to override imposed limits"
    }

    command <<<
        $KALLISTO_ROOT/bin/kallisto quant \
        -i $KALLISTO_TRANSCRIPTOME_INDEX_ROOT/transcriptome_kallisto0.48.0_ensembl104.idx \
        --bootstrap-samples=120 \
        -o outputDir \
        -t 5 \
        ~{fastqR1} \
        ~{fastqR2}

        mv outputDir/abundance.h5 ~{sampleID}.abundance.h5 
        mv outputDir/abundance.tsv  ~{sampleID}.abundance.tsv
        mv outputDir/run_info.json ~{sampleID}.run_info.json
    >>>

    runtime {
        memory:  "~{jobMemory} GB"
        modules: "~{modules}"
        timeout: "~{timeout}"
    }

    output {
        File abundance_h5    = "~{sampleID}.abundance.h5"
        File abundance_tsv = "~{sampleID}.abundance.tsv"
        File runinfo_json = "~{sampleID}.run_info.json"
    }
}