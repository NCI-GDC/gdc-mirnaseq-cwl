#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/samtools_metrics_sqlite:{{ samtools_metrics_sqlite }}"
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 2000
    ramMax: 2000
    tmpdirMin: 5
    tmpdirMax: 5
    outdirMin: 5
    outdirMax: 5

class: CommandLineTool

inputs:
  - id: bam
    type: string
    inputBinding:
      prefix: --bam

  - id: input_state
    type: string
    inputBinding:
      prefix: --input_state

  - id: metric_path
    type: File
    inputBinding:
      prefix: --metric_path

  - id: job_uuid
    type: string
    inputBinding:
      prefix: --job_uuid


  - id: metric_name
    type: string
    default: flagstat
    inputBinding:
      prefix: --metric_name

outputs:
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.job_uuid+"_samtools_flagstat.log")

  - id: sqlite
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".db")


