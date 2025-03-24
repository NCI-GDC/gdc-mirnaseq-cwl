#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: {{ docker_repository }}/samtools:{{ samtools }}"
  - class: InitialWorkDirRequirement
    listing:
      - entryname: $(inputs.input.basename)
        entry: $(inputs.input)
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 5000
    ramMax: 5000
    tmpdirMin: 50
    tmpdirMax: 50
    outdirMin: 50
    outdirMax: 50

class: CommandLineTool

inputs:
  - id: input
    type: File

  - id: thread_count
    type: long
    inputBinding:
      prefix: -@
      position: 0

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)
    secondaryFiles:
      - ^.bai

arguments:
  - valueFrom: $(inputs.input.basename)
    position: 1

  - valueFrom: $(inputs.input.nameroot + ".bai")
    position: 2

baseCommand: [/usr/local/bin/samtools, index]

