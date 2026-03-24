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
        writable: true

inputs:
  - id: sam
    type: File

  - id: mirbase
    type: string
    default: mirbase

  - id: ucsc_database
    type: string
    default: hg38

  - id: species_code
    type: string
    default: hsa

  - id: project_directory
    type: string
    default: "."

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.sam.basename)

baseCommand:
  - bash
  - -lc

arguments:
  - position: 0
    valueFrom: >-
      chmod 1777 /tmp &&
      mkdir -p /var/run/mysqld &&
      /usr/sbin/mysqld
      --datadir=/var/lib/mysql
      --socket=/var/run/mysqld/mysqld.sock
      --pid-file=/var/run/mysqld/mysqld.pid
      --bind-address=127.0.0.1
      --daemonize &&
      mysqladmin --socket=/var/run/mysqld/mysqld.sock ping --silent &&
      /usr/mirna/code/annotation/annotate.pl
      -m "$(inputs.mirbase)"
      -u "$(inputs.ucsc_database)"
      -o "$(inputs.species_code)"
      -p "$(inputs.project_directory)"
