process LINKS {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/links:2.0.1--h4ac6f70_5'
        : 'biocontainers/links:2.0.1--h4ac6f70_5'}"

    input:
    tuple val(meta), path(assembly), path(reads)

    output:
    tuple val(meta), path("*.scaffolds.fa"), emit: scaffolds
    tuple val(meta), path("*.scaffolds"), emit: scaffold_csv
    tuple val(meta), path("*.gv"), emit: graph
    tuple val(meta), path("*.log"), emit: log
    path "versions.yml", emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "${reads}" > readfile.fof
    LINKS -f ${assembly} -s readfile.fof -j 3 -b ${prefix} -t 40,200 -d 500,2000,5000
    sed -i 's/\\(scaffold[0-9]*\\).*/\\1/' ${prefix}.scaffolds.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        LINKS: \$(echo \$(LINKS | grep -o 'LINKS v.*' | sed 's/LINKS v//'))
    END_VERSIONS
    """
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.scaffolds.fa
    touch ${prefix}.scaffolds
    touch ${prefix}.gv
    touch ${prefix}.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        LINKS: \$(echo \$(LINKS | grep -o 'LINKS v.*' | sed 's/LINKS v//'))
    END_VERSIONS
    """
}
