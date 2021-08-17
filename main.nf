
params.reads = "$baseDir/data/*R{1,2}.fastq.gz"
params.outdir = 'results'

println "BINNING   PIPELINE    "
println "================================="
println "reads              : ${params.reads}"

read_pairs = Channel.fromFilePairs(params.reads, flat: true)

process fastp {
    tag "$pair_id"

    publishDir params.outdir, mode: 'copy'  

    container = 'bromberglab/fastp'

    input:
    set pair_id, file(R1), file(R2) from read_pairs

    output:
    tuple file("${pair_id}_nocarp_R1.fastq.gz"), file("${pair_id}_nocarp_R2.fastq.gz") into clean

    """
    fastp -i $R1 -I $R2 -o "${pair_id}_nocarp_R1.fastq.gz" -O "${pair_id}_nocarp_R2.fastq.gz" --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -g --detect_adapter_for_pe -l 100
    """
}