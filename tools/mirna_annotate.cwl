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
  - class: ShellCommandRequirement

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
      shellQuote: false

  - id: ucsc_database
    type: string
    default: "hg38"
    inputBinding:
      position: 91
      prefix: -u
      shellQuote: false

  - id: species_code
    type: string
    default: "hsa"
    inputBinding:
      position: 92
      prefix: -o
      shellQuote: false

  - id: project_directory
    type: string
    default: "."
    inputBinding:
      position: 93
      prefix: -p
      shellQuote: false

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.sam.basename)

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
      /usr/mirna/code/annotation/annotate.pl
    position: 0
    shellQuote: false

baseCommand: [bash, -lc]
