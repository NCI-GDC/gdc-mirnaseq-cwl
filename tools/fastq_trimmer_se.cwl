#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/dmiller15/cutadapt
  - class: InlineJavascriptRequirement

class: CommandLineTool

inputs:
  - id: input_fastq 
    type: File
    inputBinding:
      position: 0
  - id: five_prime_adapter
    type: 'string[]?'
    inputBinding:
      prefix: '-g'
      itemSeparator: ' -g '
  - id: three_prime_adapter
    type: 'string[]?'
    inputBinding:
      prefix: '-a'
      itemSeparator: ' -a '
  - id: five_prime_bases_removed
    type: int?
    inputBinding:
      prefix: '-u'
  - id: three_prime_bases_removed
    type: int?
    inputBinding:
      prefix: '-u -'
      separate: false
  - id: minimum_length
    type: int?
    inputBinding:
      prefix: '-m'
  - id: output_name
    inputBinding:
      prefix: '-o'
    type: string

outputs:
  - id: output_fastq 
    type: File
    outputBinding:
      glob: $(inputs.output_name)

baseCommand:
  - cutadapt
  - --discard-casava
