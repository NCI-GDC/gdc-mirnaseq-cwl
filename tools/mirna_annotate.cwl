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
      mkdir -p /var/run/mysqld /var/lib/mysql /var/lib/mysql-files &&

      if [ ! -d /var/lib/mysql/mysql ]; then
        rm -rf /tmp/mysql-init &&
        mkdir -p /tmp/mysql-init &&
        mysql_install_db --datadir=/tmp/mysql-init --basedir=/opt/mysql57 &&
        cp -a /tmp/mysql-init/mysql /var/lib/mysql/ &&
        [ -d /tmp/mysql-init/performance_schema ] && cp -a /tmp/mysql-init/performance_schema /var/lib/mysql/ || true &&
        [ -d /tmp/mysql-init/sys ] && cp -a /tmp/mysql-init/sys /var/lib/mysql/ || true &&
        [ -f /tmp/mysql-init/ibdata1 ] && cp -a /tmp/mysql-init/ib* /var/lib/mysql/ || true &&
        [ -f /tmp/mysql-init/auto.cnf ] && cp -a /tmp/mysql-init/auto.cnf /var/lib/mysql/ || true &&
        cp -a /var/lib/mysql-seed/hg38 /var/lib/mysql/ || true &&
        cp -a /var/lib/mysql-seed/mirbase /var/lib/mysql/ || true;
      fi &&

      /usr/sbin/mysqld
      --datadir=/var/lib/mysql
      --socket=/var/run/mysqld/mysqld.sock
      --pid-file=/var/run/mysqld/mysqld.pid
      --bind-address=127.0.0.1
      --skip-networking=0
      --daemonize &&

      mysqladmin --socket=/var/run/mysqld/mysqld.sock ping --silent &&
      /usr/mirna/code/annotation/annotate.pl
      -m "$(inputs.mirbase)"
      -u "$(inputs.ucsc_database)"
      -o "$(inputs.species_code)"
      -p "$(inputs.project_directory)"
