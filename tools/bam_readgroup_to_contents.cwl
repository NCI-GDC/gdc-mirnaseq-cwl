#!/usr/bin/env cwl-runner
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/bam_readgroup_to_json:1.0.1
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: 1
    tmpdirMax: 1
    outdirMin: 1
    outdirMax: 1
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.yml

class: CommandLineTool

inputs:
  - id: INPUT
    type: File
    format: "edam:format_2572"
    inputBinding:
      prefix: --bam_path

  - id: MODE
    type: string
    default: strict
    inputBinding:
      prefix: --mode

outputs:
  - id: OUTPUT
    type:
      type: array
      items: string
    outputBinding:
      glob: "*.json"
      outputEval: |
        ${
          var output_array = [];
          for (var i = 0; i < self.length; i++) {
            var data = self[i].contents;
            // console.log("data: " + data);
            // console.log("typeof(data): " + typeof(data));
            output_array.push(data);
          }
          // console.log("output_array: " + output_array);
          return output_array;
        }
      loadContents: true

  - id: log
    type: File
    outputBinding:
      glob: "output.log"

baseCommand: []

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
