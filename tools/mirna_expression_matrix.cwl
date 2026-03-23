#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/mirna-profiler:{{ mirna_profiler }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.stats_mirna_species_txt.basename)
        entry: $(inputs.stats_mirna_species_txt)
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
      position: 93
      prefix: -p
      shellQuote: false

  - id: species_code
    type: string
    default: "hsa"
    inputBinding:
      position: 92
      prefix: -o
      shellQuote: false

  - id: stats_mirna_species_txt
    type: File

outputs:
  - id: expn_matrix_txt
    type: File
    outputBinding:
      glob: expn_matrix.txt

  - id: expn_matrix_norm_txt
    type: File
    outputBinding:
      glob: expn_matrix_norm.txt

  - id: expn_matrix_norm_log_txt
    type: File
    outputBinding:
      glob: expn_matrix_norm_log.txt

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
      /usr/mirna/code/library_stats/expression_matrix.pl
    position: 0
    shellQuote: false

baseCommand: [bash, -lc]
