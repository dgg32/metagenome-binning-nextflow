# metagenome-binning-nextflow



This repository contains the nextflow scripts for my article [Metagenomic Binning with NextFlow](https://dgg32.medium.com/metagenomic-binning-with-nextflow-866f6c0b0d0c)

  


# Prerequisite

Java

Nextflow  

Docker (if you run it locally)

# Run

The config file has defined three deployments: local, Slurm and AWS.

To run it locally
```console
nextflow run main.nf  --reads '[your-input-path]/*_R{1,2}.fastq.gz' -profile local
```

To run the computation on AWS:
```console
nextflow run main.nf -resume -bucket-dir [your-working-S3-address] --reads '[your-input-path]/*_R{1,2}.fastq.gz' -profile aws
```

The results are stored in the "results" folder.

You can even run this pipeline with Nextflow Tower. Simply paste the URL of this repo (https://github.com/dgg32/metagenome-binning-nextflow) into the "Pipeline to launch" field and run it.

## Authors

  

*  **Sixing Huang** - *Concept and Coding*

  

## License

  

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
