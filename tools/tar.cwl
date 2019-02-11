#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/xz:b8f105f87b8d69a0414f8997bd5b586e502d9a1aa74d429314ec97cbddd81ff8
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

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
    default: true
    inputBinding:
      prefix: --xz
      position: 2

  - id: INPUT
    type:
      type: array
      items: File

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.file)

arguments:
  - position: 99
    shellQuote: false
    valueFrom: |
      ${
          function local_basename(path) {
              var basename = path.split(/[\\/]/).pop();
              return basename
          }
          function local_dirname(path) {
              return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');
          }
          var output = [];
          var i;
          for (i in inputs.INPUT) {
              output.push("-C " + local_dirname(inputs.INPUT[i].path) + " " + local_basename(inputs.INPUT[i].path) + " ");
          }
          return output;
      }

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.file)

baseCommand: ["tar"]
