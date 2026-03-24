#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/mirna-profiler:{{ mirna_profiler }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.sam.basename)
        entry: $(inputs.sam)
        writable: true

class: CommandLineTool

inputs:
  - id: sam
    type: File

  - id: mirbase
    type: string
    default: "mirbase"
    inputBinding:
      position: 90
      prefix: -m

  - id: ucsc_database
    type: string
    default: "hg38"
    inputBinding:
      position: 91
      prefix: -u

  - id: species_code
    type: string
    default: "hsa"
    inputBinding:
      position: 92
      prefix: -o

  - id: project_directory
    type: string
    default: "."
    inputBinding:
      position: 93
      prefix: -p

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.sam.basename)

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
      -m $(inputs.mirbase)
      -u $(inputs.ucsc_database)
      -o $(inputs.species_code)
      -p $(inputs.project_directory)

baseCommand: [bash, -lc]
