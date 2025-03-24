#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: {{ docker_repository }}/samtools:{{ samtools }}"
  - class: InlineJavascriptRequirement

class: CommandLineTool

inputs:
  - id: INPUT
    type: File
    inputBinding:
      position: 0

  - id: header_included
    type: boolean
    default: true
    inputBinding:
      prefix: -h

  - id: output_format
    type: string
    default: "BAM"
    inputBinding:
      prefix: --output-fmt

  - id: threads
    type: long
    default: 1
    inputBinding:
      prefix: --threads

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: |
        ${
          return inputs.INPUT.nameroot + "." + inputs.output_format.toLowerCase();
        }

arguments:
  - valueFrom: |
      ${
        return inputs.INPUT.nameroot + "." + inputs.output_format.toLowerCase();
      }
    prefix: -o

baseCommand: [/usr/local/bin/samtools, view]

