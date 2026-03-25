#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/mirna-profiler:{{ mirna_profiler }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.sam.basename)
        entry: $(inputs.sam)
      - entryname: $(inputs.stats_miRNA_txt.basename)
        entry: $(inputs.stats_miRNA_txt)
      - entryname: $(inputs.stats_crossmapped_txt.basename)
        entry: $(inputs.stats_crossmapped_txt)
      - entryname: $(inputs.stats_isoforms_txt.basename)
        entry: $(inputs.stats_isoforms_txt)

inputs:
  - id: genome_version
    type: string
    default: hg38

  - id: mirbase_db
    type: string
    default: mirbase

  - id: project_directory
    type: string
    default: "."

  - id: species_code
    type: string
    default: hsa

  - id: sam
    type: File

  - id: stats_miRNA_txt
    type: File

  - id: stats_crossmapped_txt
    type: File

  - id: stats_isoforms_txt
    type: File

outputs:
  - id: isoforms_quant
    type: File
    outputBinding:
      glob: $(inputs.sam.nameroot + "_features/tcga/isoforms.txt")

  - id: mirnas_quant
    type: File
    outputBinding:
      glob: $(inputs.sam.nameroot + "_features/tcga/mirnas.txt")

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

      /usr/mirna/code/custom_output/tcga/tcga.pl
      -g "$(inputs.genome_version)"
      -m "$(inputs.mirbase_db)"
      -p "$(inputs.project_directory)"
      -o "$(inputs.species_code)"
