/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
// WorkflowGenomeassembler.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
ch_input = Channel.fromPath( params.input, checkIfExists: true )
    .ifEmpty { exit 1, 'Error: Input samplesheet not specified!' }
// if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
// include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { PREPARE_INPUT } from "$projectDir/subworkflows/local/prepare_input"

include { BUILD_FASTK_DATABASES as BUILD_HIFI_FASTK_DATABASE     } from "$projectDir/subworkflows/local/build_fastk_database"
include { BUILD_FASTK_DATABASES as BUILD_HIC_FASTK_DATABASE      } from "$projectDir/subworkflows/local/build_fastk_database"
include { BUILD_FASTK_DATABASES as BUILD_ONT_FASTK_DATABASE      } from "$projectDir/subworkflows/local/build_fastk_database"
include { BUILD_FASTK_DATABASES as BUILD_ILLUMINA_FASTK_DATABASE } from "$projectDir/subworkflows/local/build_fastk_database"

include { BUILD_MERYL_DATABASES as BUILD_HIFI_MERYL_DATABASE     } from "$projectDir/subworkflows/local/build_meryl_database"
include { BUILD_MERYL_DATABASES as BUILD_HIC_MERYL_DATABASE      } from "$projectDir/subworkflows/local/build_meryl_database"
include { BUILD_MERYL_DATABASES as BUILD_ONT_MERYL_DATABASE      } from "$projectDir/subworkflows/local/build_meryl_database"
include { BUILD_MERYL_DATABASES as BUILD_ILLUMINA_MERYL_DATABASE } from "$projectDir/subworkflows/local/build_meryl_database"

include { HIFI_DATA_PROPERTIES     } from "$projectDir/subworkflows/local/hifi_data_properties"
include { HIC_DATA_PROPERTIES      } from "$projectDir/subworkflows/local/hic_data_properties"
include { ONT_DATA_PROPERTIES      } from "$projectDir/subworkflows/local/ont_data_properties"
include { ILLUMINA_DATA_PROPERTIES } from "$projectDir/subworkflows/local/illumina_data_properties"

include { MERYL_GENOME_PROPERTIES as HIFI_MERYL_GENOME_PROPERTIES     } from "$projectDir/subworkflows/local/meryl_genome_properties"
include { MERYL_GENOME_PROPERTIES as HIC_MERYL_GENOME_PROPERTIES      } from "$projectDir/subworkflows/local/meryl_genome_properties"
include { MERYL_GENOME_PROPERTIES as ONT_MERYL_GENOME_PROPERTIES      } from "$projectDir/subworkflows/local/meryl_genome_properties"
include { MERYL_GENOME_PROPERTIES as ILLUMINA_MERYL_GENOME_PROPERTIES } from "$projectDir/subworkflows/local/meryl_genome_properties"

include { FASTK_GENOME_PROPERTIES as HIFI_FASTK_GENOME_PROPERTIES     } from "$projectDir/subworkflows/local/fastk_genome_properties"
include { FASTK_GENOME_PROPERTIES as HIC_FASTK_GENOME_PROPERTIES      } from "$projectDir/subworkflows/local/fastk_genome_properties"
include { FASTK_GENOME_PROPERTIES as ONT_FASTK_GENOME_PROPERTIES      } from "$projectDir/subworkflows/local/fastk_genome_properties"
include { FASTK_GENOME_PROPERTIES as ILLUMINA_FASTK_GENOME_PROPERTIES } from "$projectDir/subworkflows/local/fastk_genome_properties"

include { MASH_SKETCH } from "$projectDir/modules/nf-core/mash/sketch/main"

include { CONTAMINATION_SCREEN as HIFI_CONTAMINATION_SCREEN     } from "$projectDir/subworkflows/local/contamination_screen"
include { CONTAMINATION_SCREEN as HIC_CONTAMINATION_SCREEN      } from "$projectDir/subworkflows/local/contamination_screen"
include { CONTAMINATION_SCREEN as ONT_CONTAMINATION_SCREEN      } from "$projectDir/subworkflows/local/contamination_screen"
include { CONTAMINATION_SCREEN as ILLUMINA_CONTAMINATION_SCREEN } from "$projectDir/subworkflows/local/contamination_screen"

include { ASSEMBLY_COMPARISON } from "$projectDir/subworkflows/local/assembly_comparison"

include { MERYL_KMER_COMPLETENESS as HIFI_MERYL_KMER_COMPLETENESS     } from "$projectDir/subworkflows/local/meryl_kmer_completeness"
include { MERYL_KMER_COMPLETENESS as HIC_MERYL_KMER_COMPLETENESS      } from "$projectDir/subworkflows/local/meryl_kmer_completeness"
include { MERYL_KMER_COMPLETENESS as ONT_MERYL_KMER_COMPLETENESS      } from "$projectDir/subworkflows/local/meryl_kmer_completeness"
include { MERYL_KMER_COMPLETENESS as ILLUMINA_MERYL_KMER_COMPLETENESS } from "$projectDir/subworkflows/local/meryl_kmer_completeness"

include { FASTK_KMER_COMPLETENESS as HIFI_FASTK_KMER_COMPLETENESS     } from "$projectDir/subworkflows/local/fastk_kmer_completeness"
include { FASTK_KMER_COMPLETENESS as HIC_FASTK_KMER_COMPLETENESS      } from "$projectDir/subworkflows/local/fastk_kmer_completeness"
include { FASTK_KMER_COMPLETENESS as ONT_FASTK_KMER_COMPLETENESS      } from "$projectDir/subworkflows/local/fastk_kmer_completeness"
include { FASTK_KMER_COMPLETENESS as ILLUMINA_FASTK_KMER_COMPLETENESS } from "$projectDir/subworkflows/local/fastk_kmer_completeness"

include { EVALUATE_GENE_SPACE } from "$projectDir/subworkflows/local/evaluate_gene_space"
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
// include { FASTQC                      } from '../modules/nf-core/modules/fastqc/main'
// include { MULTIQC                     } from '../modules/nf-core/modules/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from "$projectDir/modules/nf-core/custom/dumpsoftwareversions/main"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow GENOMEASSEMBLER {

    ch_versions = Channel.empty()

    // Check stage
    def workflow_steps = params.step.tokenize(",")
    // Define constants - TODO: Move to JSON validation
    def workflow_permitted_stages = ['data_qc','preprocess','assemble','validate','curate']
    if ( ! workflow_steps.every { it in workflow_permitted_stages } ) {
        error "Unrecognised workflow step in $params.step ( $workflow_permitted_stages )"
    }

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    PREPARE_INPUT (
        ch_input
    )
    ch_versions = ch_versions.mix ( PREPARE_INPUT.out.versions )

    // - TODO: Fetch Genome properties from GOAT

    // BUILD KMER DATABASES
    // builds k-mer databases as a separate step to allow reuse with resume
    if ( params.kmer_counter == 'meryl' && ['data_qc','validate'].any { it in workflow_steps } ) {
        BUILD_HIFI_MERYL_DATABASE ( PREPARE_INPUT.out.hifi )
        BUILD_HIC_MERYL_DATABASE ( PREPARE_INPUT.out.hic)
        BUILD_ILLUMINA_MERYL_DATABASE ( PREPARE_INPUT.out.illumina )
        if( params.enable_ont_kmer_analyses ) {
            BUILD_ONT_MERYL_DATABASE ( PREPARE_INPUT.out.ont )
        }
    } else if ( params.kmer_counter == 'fastk' && ['data_qc','validate'].any { it in workflow_steps } ) {
        BUILD_HIFI_FASTK_DATABASE ( PREPARE_INPUT.out.hifi )
        BUILD_HIC_FASTK_DATABASE ( PREPARE_INPUT.out.hic)
        BUILD_ILLUMINA_FASTK_DATABASE ( PREPARE_INPUT.out.illumina )
        if ( params.enable_ont_kmer_analyses ) {
            BUILD_ONT_FASTK_DATABASE ( PREPARE_INPUT.out.ont )
        }
    }

    if( 'data_qc' in workflow_steps ) {
        // DATA QUALITY CHECKS:
        // - Check data properties
        HIFI_DATA_PROPERTIES ( PREPARE_INPUT.out.hifi )
        HIC_DATA_PROPERTIES ( PREPARE_INPUT.out.hic )
        ONT_DATA_PROPERTIES ( PREPARE_INPUT.out.ont )
        ILLUMINA_DATA_PROPERTIES ( PREPARE_INPUT.out.illumina )

        // - Check genome properties
        if ( params.kmer_counter == 'meryl' ) {
            HIFI_MERYL_GENOME_PROPERTIES ( BUILD_HIFI_MERYL_DATABASE.out.histogram )
            HIC_MERYL_GENOME_PROPERTIES ( BUILD_HIC_MERYL_DATABASE.out.histogram )
            ILLUMINA_MERYL_GENOME_PROPERTIES ( BUILD_ILLUMINA_MERYL_DATABASE.out.histogram )
            if ( params.enable_ont_kmer_analyses ){
                ONT_MERYL_GENOME_PROPERTIES ( BUILD_ONT_MERYL_DATABASE.out.histogram )
            }
        } else if ( params.kmer_counter == 'fastk' ) {
            HIFI_FASTK_GENOME_PROPERTIES ( BUILD_HIFI_FASTK_DATABASE.out.histogram.join( BUILD_HIFI_FASTK_DATABASE.out.ktab ) )
            HIC_FASTK_GENOME_PROPERTIES ( BUILD_HIC_FASTK_DATABASE.out.histogram.join( BUILD_HIC_FASTK_DATABASE.out.ktab ) )
            ILLUMINA_FASTK_GENOME_PROPERTIES ( BUILD_ILLUMINA_FASTK_DATABASE.out.histogram.join( BUILD_ILLUMINA_FASTK_DATABASE.out.ktab ) )
            if ( params.enable_ont_kmer_analyses ){
                ONT_FASTK_GENOME_PROPERTIES ( BUILD_ONT_FASTK_DATABASE.out.histogram.join( BUILD_ONT_FASTK_DATABASE.out.ktab ) )
            }
        }

        // - Screen for contaminants
        Channel.fromPath ( params.mash_screen_db, checkIfExists: true )
            .branch {
                sketch: it.name.endsWith('.msh')
                fasta : it.name.endsWith('.fasta')
                    return [ [ id: it.baseName ], it ] // Reformat for MASH_SKETCH
            }.set { ch_mash_screen }
        MASH_SKETCH ( ch_mash_screen.fasta )
        ch_mash_db = ch_mash_screen.sketch
            .mix( MASH_SKETCH.out.mash
                .map { meta, sketch -> sketch }
            ).collect()
        HIFI_CONTAMINATION_SCREEN (
            PREPARE_INPUT.out.hifi,
            ch_mash_db
        )
        HIC_CONTAMINATION_SCREEN (
            PREPARE_INPUT.out.hic,
            ch_mash_db
        )
        ONT_CONTAMINATION_SCREEN (
            PREPARE_INPUT.out.ont,
            ch_mash_db
        )
        ILLUMINA_CONTAMINATION_SCREEN (
            PREPARE_INPUT.out.illumina,
            ch_mash_db
        )

        // - Compare library content ( between files within platform, between platforms )
        //   - Mash
        //   - KAT_COMP ( optional )
    }

    if ( 'preprocess' in workflow_steps ) {
        // PREPROCESSING:
        // - adapter trimming
        // - read correction
        // - contaminant filtering
        // - downsampling
        // - normalisation
    }

    if ( 'assemble' in workflow_steps ) {
        // ASSEMBLY:
        // - assemble
        // - scaffold
        // - polish
    }

    if ( 'curate' in workflow_steps ) {
        // ASSEMBLY CURATION:
        // - Purge duplications
        // - Fix misassemblies
        // - Separate organelles, plasmids, etc
        // - recircularize circular genomes
        // - contamination removal
        // - reevaluate assemblies after
    }

    if ( 'validate' in workflow_steps ) {
        // ASSEMBLY EVALUATION:
        ch_assemblies_for_evaluation = PREPARE_INPUT.out.assemblies.mix (
            Channel.empty() // TODO: Replace with workflow assembled and curated genomes
        )
        // - Compare assemblies
        ch_reference = params.reference ? Channel.fromPath( params.reference, checkIfExists: true ).collect() : Channel.value( [] )
        ASSEMBLY_COMPARISON (
            ch_assemblies_for_evaluation,
            ch_reference
        )
        // - Check K-mer completeness
        if ( params.kmer_counter == 'meryl' ) {
            HIFI_MERYL_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_HIFI_MERYL_DATABASE.out.uniondb
            )
            HIC_MERYL_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_HIC_MERYL_DATABASE.out.uniondb
            )
            ILLUMINA_MERYL_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_ILLUMINA_MERYL_DATABASE.out.uniondb
            )
            if ( params.enable_ont_kmer_analyses ){
                ONT_MERYL_KMER_COMPLETENESS (
                    ch_assemblies_for_evaluation,
                    BUILD_ONT_MERYL_DATABASE.out.uniondb
                )
            }
        } else if ( params.kmer_counter == 'fastk' ) {
            HIFI_FASTK_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_HIFI_FASTK_DATABASE.out.histogram.join ( BUILD_HIFI_FASTK_DATABASE.out.ktab )
            )
            HIC_FASTK_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_HIC_FASTK_DATABASE.out.histogram.join ( BUILD_HIC_FASTK_DATABASE.out.ktab )
            )
            ILLUMINA_FASTK_KMER_COMPLETENESS (
                ch_assemblies_for_evaluation,
                BUILD_ILLUMINA_FASTK_DATABASE.out.histogram.join ( BUILD_ILLUMINA_FASTK_DATABASE.out.ktab )
            )
            if ( params.enable_ont_kmer_analyses ) {
                ONT_FASTK_KMER_COMPLETENESS (
                    ch_assemblies_for_evaluation,
                    BUILD_ONT_FASTK_DATABASE.out.histogram.join ( BUILD_ONT_FASTK_DATABASE.out.ktab )
                )
            }
        }
        // - Check read alignment
            // - HiLine for HiC QC - https://github.com/wtsi-hpag/HiLine
        // - Check gene space
        EVALUATE_GENE_SPACE (
            ch_assemblies_for_evaluation,
            params.busco_lineage_path ? file( params.busco_lineage_path, checkIfExists: true ) : []
        )
        // - Check contamination
        // - Visualize assembly graph
        // - Generate annotation tracks
    }

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    //
    // MODULE: MultiQC
    //
    // workflow_summary    = WorkflowGenomeassembler.paramsSummaryMultiqc(workflow, summary_params)
    // ch_workflow_summary = Channel.value(workflow_summary)

    methods_description    = WorkflowGenomeassembler.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    ch_methods_description = Channel.value(methods_description)

    // ch_multiqc_files = Channel.empty()
    // ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    // ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

    // MULTIQC (
    //     ch_multiqc_files.collect(),
    //     ch_multiqc_config.toList(),
    //     ch_multiqc_custom_config.toList(),
    //     ch_multiqc_logo.toList()
    // )
    // multiqc_report = MULTIQC.out.report.toList()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
