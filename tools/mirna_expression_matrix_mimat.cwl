#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/mirna-profiler:{{ mirna_profiler }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.stats_crossmapped_txt.basename)
        entry: $(inputs.stats_crossmapped_txt)
      - entryname: $(inputs.stats_mirna_txt.basename)
        entry: $(inputs.stats_mirna_txt)
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  - id: mirbase_db
    type: string
    default: "mirbase"
    inputBinding:
      position: 90
      prefix: -m
      shellQuote: false

  - id: project_directory
    type: string
    default: "."
    inputBinding:
      position: 91
      prefix: -p
      shellQuote: false

  - id: species_code
    type: string
    default: "hsa"
    inputBinding:
      position: 92
      prefix: -o
      shellQuote: false

  - id: stats_crossmapped_txt
    type: File

  - id: stats_mirna_txt
    type: File

outputs:
  - id: expn_matrix_mimat_txt
    type: File
    outputBinding:
      glob: expn_matrix_mimat.txt

  - id: expn_matrix_mimat_norm_txt
    type: File
    outputBinding:
      glob: expn_matrix_mimat_norm.txt

  - id: expn_matrix_mimat_norm_log_txt
    type: File
    outputBinding:
      glob: expn_matrix_mimat_norm_log.txt

arguments:
  - valueFrom: >-
      chmod 1777 /tmp &&
      mkdir -p /var/run/mysqld &&
      chown -R mysql:mysql /var/run/mysqld /var/lib/mysql &&
      /usr/sbin/mysqld
      --user=mysql
      --datadir=/var/lib/mysql
      --socket=/var/run/mysqld/mysqld.sock
      --pid-file=/var/run/mysqld/mysqld.pid
      --bind-address=127.0.0.1
      --daemonize &&
      mysqladmin --socket=/var/run/mysqld/mysqld.sock ping --silent &&
      /usr/mirna/code/library_stats/expression_matrix_mimat.pl
    position: 0
    shellQuote: false

baseCommand: [bash, -lc]
