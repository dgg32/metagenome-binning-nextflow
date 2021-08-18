
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = 'results'

println "BINNING   PIPELINE    "
println "================================="
println "reads              : ${params.reads}"

Channel.fromFilePairs(params.reads, checkIfExists: true).set{ read_pairs }  //read_pairs.view()

process fastp {
    tag "$pair_id"

    publishDir params.outdir, mode: 'copy' // publish only trimmed fastq files 

    container = 'bromberglab/fastp'

    input:
    tuple sample_id, file(reads) from read_pairs

    output:
    file('*.fastq.gz') into result_ch

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \
    -o ${sample_id}_trim_R1.fastq.gz -O ${sample_id}_trim_R2.fastq.gz \
    --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -g --detect_adapter_for_pe -l 100
    """
}