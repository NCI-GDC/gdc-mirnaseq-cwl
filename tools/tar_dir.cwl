#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: {{ docker_repository }}/bio-alpine:base
  - class: InlineJavascriptRequirement

class: CommandLineTool

inputs:
  - id: create
    type: boolean
    default: true
    inputBinding:
      prefix: --create
      position: 0

  - id: file
    type: string
    inputBinding:
      prefix: --file
      position: 1

  - id: xz
    type: boolean
    default: false
    inputBinding:
      prefix: --xz
      position: 2

  - id: INPUT
    type: Directory
    inputBinding:
      position: 3

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.file)

baseCommand: ["tar", "--dereference"]
