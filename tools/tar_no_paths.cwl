#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/xz:b8f105f87b8d69a0414f8997bd5b586e502d9a1aa74d429314ec97cbddd81ff8
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
