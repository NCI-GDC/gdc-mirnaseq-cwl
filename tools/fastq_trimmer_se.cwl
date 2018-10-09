#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/dmiller15/cutadapt
  - class: InlineJavascriptRequirement

class: CommandLineTool

inputs:
  - id: three_prime_adapter
    type: 'string[]'
  - id: untrimmed_fastq
    type: File
  - id: three_prime_bases_removed
    type: int
  - id: five_prime_bases_removed
    type: int
  - id: minimum_length
    type: int
  - id: five_prime_adapter
    type: 'string[]'

outputs:
  - id: adapter_size_trimmed_fastq
    type: File
    outputBinding:
      glob: $(inputs.untrimmed_fastq.basename)

arguments:
  - position: 0
    shellQuote: false
    valueFrom: |
      cutadapt -g $(inputs.five_prime_adapter.join(' -g ')) -a
      $(inputs.three_prime_adapter.join(' -a ')) -m $(inputs.minimum_length)
      $(inputs.untrimmed_fastq.path)
  - position: 99
    shellQuote: false
    valueFrom: |
      ${
          var cmd = "";
          if (inputs.five_prime_bases_removed != 0 || inputs.three_prime_bases_removed != 0) {
              cmd = "| cutadapt -m " + inputs.minimum_length + " -u " + inputs.five_prime_bases_removed + " -u -" + inputs.three_prime_bases_removed + " -o " + inputs.untrimmed_fastq.basename + " -"
          }
          else {
              cmd = "-o " + inputs.untrimmed_fastq.basename
          }
          return cmd
      }

baseCommand: []
