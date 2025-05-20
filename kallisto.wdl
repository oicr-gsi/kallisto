version 1.0

struct fastqPairs {
    File fastqR1
    File? fastqR2
}

workflow kallisto {
    input {
        Array[fastqPairs] fastqInputs
        String outputFileNamePrefix
        Boolean isSingleEnd = false
        Int fragmentLength = 200
        Int sd = 30
    }

    parameter_meta {
        fastqInputs: "Array of input FASTQ file pairs. For single-end samples, provide only 'fastqR1'. For paired-end, provide both 'fastqR1' and 'fastqR2'."
        outputFileNamePrefix: "Prefix to use for naming output files."
        isSingleEnd: "Set to true if data is single-end. If false or omitted, paired-end mode is used."
        fragmentLength: "Estimated fragment length for single-end reads. Required only if isSingleEnd is true. Default: 200."
        sd: "Standard deviation of fragment length for single-end reads. Required only if isSingleEnd is true. Default: 30."
    }

    scatter(pair in fastqInputs) {
        Array[File] pairFiles = select_all([pair.fastqR1, pair.fastqR2])
    }

    Array[File] fastqFiles = flatten(pairFiles)

    call runKallisto {
        input:
            fastqFiles = fastqFiles,
            sampleID = outputFileNamePrefix,
            isSingleEnd = isSingleEnd,
            fragmentLength = fragmentLength,
            sd = sd
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
                description: "a HDF5 binary file containing run info, abundance estimates, bootstrap estimates, and transcript length information length. This file can be read in by sleuth",
                vidarr_label: "abundanceH5"
            },
            abundanceTsv: {
                description: "a plaintext file of the abundance estimates. It does not contain bootstrap estimates.",
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
        Array[File] fastqFiles
        String sampleID
        Boolean isSingleEnd
        Int fragmentLength
        Int sd
        String modules = "kallisto/0.48.0 kallisto-transcriptome-index/0.48.0"
        Int timeout = 48
        Int jobMemory = 12
    }

    parameter_meta {
        fastqFiles: "FASTQ files to input to kallisto. Should be one or two files depending on single- or paired-end mode."
        isSingleEnd: "Whether the input data is single-end. If true, '--single' mode is enabled."
        fragmentLength: "Estimated fragment length (required if isSingleEnd = true)."
        sd: "Standard deviation of fragment length (required if isSingleEnd = true)."
        jobMemory: "Memory in GB allocated for the job. Default: 12"
        modules: "Names and versions of modules"
        timeout: "Timeout in hours, needed to override imposed limits. Default: 48"
    }


    command <<<
        
        # Run Kallisto
        $KALLISTO_ROOT/bin/kallisto quant \
        -i $KALLISTO_TRANSCRIPTOME_INDEX_ROOT/transcriptome_kallisto0.48.0_ensembl104.idx \
        --bootstrap-samples=120 \
        -o outputDir \
        -t 5 \
        ~{if isSingleEnd then "--single -l ~{fragmentLength} -s ~{sd}" else ""} \
        ~{sep=' ' fastqFiles}

        # Move output files
        mv outputDir/abundance.h5 ~{sampleID}.abundance.h5 
        mv outputDir/abundance.tsv ~{sampleID}.abundance.tsv
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