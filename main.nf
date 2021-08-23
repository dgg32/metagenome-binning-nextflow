//reads: 's3://nextflow-tower-sixing-asset/raw/*_R{1,2}.fastq.gz'
//nextflow run main.nf --reads '/home/sih13/Downloads/fastq/*_R{1,2}.fastq.gz'

params.threads = 16
params.reads = "$baseDir/data/*_R{1,2}.fastq.gz"
params.outdir = 'results'

println "BINNING   PIPELINE    "
println "================================="
println "reads              : ${params.reads}"

Channel.fromFilePairs(params.reads, checkIfExists: true).set{ read_pairs }  //read_pairs.view()

process fastp {

    publishDir params.outdir, mode: 'copy' 

    container "dgg32/fastp"

    input:
    tuple sample_id, file(reads) from read_pairs

    output:
    tuple sample_id, file('*.fastq.gz') into fastp_out_ch

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
    tuple sample_id, file(reads) from fastp_out_ch

    output:
    tuple sample_id, path("${sample_id}_megahitout"), file(reads) into megahit_result_ch

    script:
    """
    megahit -1 ${reads[0]} -2 ${reads[1]} -o ${sample_id}_megahitout -t ${params.threads}
    """
}

process maxbin {

    publishDir params.outdir, mode: 'copy'

    container = 'nanozoo/maxbin2'

    input:
    tuple sample_id, path(megathitout), file(reads) from megahit_result_ch

    output:
    tuple sample_id, path("${sample_id}_maxbinout") into maxbin_result_ch

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
    tuple sample_id, path(maxbinout) from maxbin_result_ch

    output:
    tuple sample_id, path('*_checkmout') into checkm_result_ch


    script:
    """
    checkm lineage_wf -t 32 -x fasta $maxbinout ${sample_id}_checkmout
    """
}
