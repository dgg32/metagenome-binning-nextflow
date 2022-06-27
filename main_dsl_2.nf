//reads: 's3://nextflow-tower-sixing-asset/raw/*_R{1,2}.fastq.gz'
//nextflow run main.nf --reads '/home/sih13/Downloads/fastq/*_R{1,2}.fastq.gz'
nextflow.enable.dsl=2

params.threads = 16
params.reads = "$baseDir/data/*_R{1,2}.f*q.gz"
params.outdir = 'results'

println "BINNING   PIPELINE    "
println "================================="
println "reads              : ${params.reads}"



process fastp {

    publishDir params.outdir, mode: 'copy' 

    container "dgg32/fastp"

    input:
    tuple val(sample_id), file(reads) 

    output:
    tuple val(sample_id), file('*.fastq.gz')

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \
    -o ${sample_id}_trim_R1.fastq.gz -O ${sample_id}_trim_R2.fastq.gz \
    --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -g --detect_adapter_for_pe -l 100 -w ${params.threads}
    """
}


process megahit {

    publishDir params.outdir, mode: 'copy' 

    container = 'dgg32/megahit'

    input:
    tuple val(sample_id), file(reads) 

    output:
    tuple val(sample_id), path("${sample_id}_megahitout"), file(reads)

    script:
    """
    megahit -1 ${reads[0]} -2 ${reads[1]} -o ${sample_id}_megahitout -t ${params.threads}
    """
}


process maxbin {

    publishDir params.outdir, mode: 'copy'

    container = 'nanozoo/maxbin2'

    input:
    tuple val(sample_id), path(megathitout), file(reads)

    output:
    tuple val(sample_id), path("${sample_id}_maxbinout")

    script:
    """
    mkdir ${sample_id}_maxbinout

    run_MaxBin.pl -contig ${megathitout}/final.contigs.fa -out ${sample_id}_maxbinout/maxbin  -reads ${reads[0]} -reads2 ${reads[1]} -thread ${params.threads}
    """
}

process checkm {

    publishDir params.outdir, mode: 'copy'

    container = 'dgg32/checkm'

    input:
    tuple val(sample_id), path(maxbinout)

    output:
    tuple val(sample_id), path('*_checkmout')


    script:
    """
    checkm lineage_wf -t 32 -x fasta $maxbinout ${sample_id}_checkmout
    """
}

workflow {
    Channel.fromFilePairs( params.reads).ifEmpty { error "Cannot find any reads matching" }.set {read_pairs}  //read_pairs.view()

    polished_reads = fastp(read_pairs)

    assembly = megahit(polished_reads)

    bins = maxbin(assembly)

    checkm(bins)

}
