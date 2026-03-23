#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/bam_reheader:{{ bam_reheader }}"
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 10000
    ramMax: 10000
    tmpdirMin: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    tmpdirMax: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    outdirMin: $(Math.ceil(1.1 * inputs.input.size / 1048576))
    outdirMax: $(Math.ceil(1.1 * inputs.input.size / 1048576))

class: CommandLineTool

inputs:
  - id: input
    type: File
    inputBinding:
      prefix: --bam_path

  - id: header_path
    type: File
    inputBinding:
      prefix: --header_path

outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input.basename)

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.input.basename + ".log")

baseCommand: [/usr/local/bin/bam_reheader]
