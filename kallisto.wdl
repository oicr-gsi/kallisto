version 1.0

workflow kallisto {
    input {
        Array[File] fastqR1
        Array[File] fastqR2
        String outputFileNamePrefix
    }

    parameter_meta {
        fastqR1: "Array of R1 FASTQ files for the sample (e.g., multiple lanes)"
        fastqR2: "Array of R2 FASTQ files for the sample (e.g., multiple lanes)"
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
        author: "Gavin Peng, Monica L. Rojas-Pena"
        email: "gpeng@oicr.on.ca, mrojaspena@oicr.on.ca"
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
        Array[File] fastqR1
        Array[File] fastqR2
        String sampleID
        String modules = "kallisto/0.48.0 kallisto-transcriptome-index/0.48.0"
        Int timeout = 48
        Int jobMemory = 12
    }

    parameter_meta {
        fastqR1: "Array of FASTQ R1 files"
        fastqR2: "Array of FASTQ R2 files"
        jobMemory: "Memory in GB for this job"
        modules: "Names and versions of modules"
        timeout: "Timeout in hours, needed to override imposed limits"
    }

    command <<<
        set -euo pipefail

        # Concatenating input FASTQ files
        cat ~{sep=' ' fastqR1} > R1_combined.fastq
        cat ~{sep=' ' fastqR2} > R2_combined.fastq

        $KALLISTO_ROOT/bin/kallisto quant \
        -i $KALLISTO_TRANSCRIPTOME_INDEX_ROOT/transcriptome_kallisto0.48.0_ensembl104.idx \
        --bootstrap-samples=120 \
        -o outputDir \
        -t 5 \
        R1_combined.fastq \
        R2_combined.fastq

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