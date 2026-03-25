#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/mirna-profiler:{{ mirna_profiler }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.stats_crossmapped_txt.basename)
        entry: $(inputs.stats_crossmapped_txt)
      - entryname: $(inputs.stats_mirna_txt.basename)
        entry: $(inputs.stats_mirna_txt)

inputs:
  - id: mirbase_db
    type: string
    default: mirbase

  - id: project_directory
    type: string
    default: "."

  - id: species_code
    type: string
    default: hsa

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

baseCommand:
  - bash
  - -lc

arguments:
  - position: 0
    valueFrom: >-
      set -euo pipefail &&
      mkdir -p /var/run/mysqld /var/lib/mysql /var/lib/mysql-files &&
      test -f /var/lib/mysql/mysql/user.frm &&
      test -f /var/lib/mysql/mysql/plugin.frm &&
      /usr/sbin/mysqld
      --datadir=/var/lib/mysql
      --socket=/var/lib/mysql/mysql.sock
      --pid-file=/var/run/mysqld/mysqld.pid
      --bind-address=127.0.0.1
      --skip-networking=0
      --daemonize &&

      for i in 1 2 3 4 5 6 7 8 9 10; do
        mysqladmin --socket=/var/lib/mysql/mysql.sock ping --silent && break;
        sleep 1;
      done &&

      mysqladmin --socket=/var/lib/mysql/mysql.sock ping --silent &&

      /usr/mirna/code/library_stats/expression_matrix_mimat.pl
      -m "$(inputs.mirbase_db)"
      -p "$(inputs.project_directory)"
      -o "$(inputs.species_code)"
