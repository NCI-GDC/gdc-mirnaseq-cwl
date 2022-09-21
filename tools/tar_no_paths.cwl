#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: docker.osdc.io/ncigdc/bio-alpine:base 
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

class: CommandLineTool

inputs:
  - id: file
    type: string
    inputBinding:
      position: -1

  - id: INPUT
    type: 
      type: array
      items: File
      inputBinding:
        prefix: -C
        valueFrom: |
          ${
          return self.dirname + " " + self.basename;
          }
        position: 99
        shellQuote: false

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.file)

baseCommand: ["tar", "-Jcf"]
