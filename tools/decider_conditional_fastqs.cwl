#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: conditional_fastq1
    format: "edam:format_1930"
    type: File
  - id: conditional_fastq2
    format: "edam:format_1930"
    type:
      type: array
      items: File
      
outputs:
  - id: output
    format: "edam:format_1930"
    type: File

# If the second BAM exists, take it. Otherwise take the first BAM.
# There should only be one BAM from the second conditional so throw unhandled if other than 1 or 0
expression: |
  ${
      if (inputs.conditional_fastq2.length == 1) {
          var output = inputs.conditional_fastq2[0];
      }
      else if (inputs.conditional_fastq2.length == 0) {
          var output = inputs.conditional_fastq1;
      }
      else {
          throw "unhandled"
      }
      return {'output': output};
  }

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
