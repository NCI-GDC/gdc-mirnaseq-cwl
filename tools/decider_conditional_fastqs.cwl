#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: conditional_fastq1
    format: "edam:format_1930"
    type:
      type: array
      items: File
  - id: conditional_fastq2
    format: "edam:format_1930"
    type:
      type: array
      items: File
      
outputs:
  - id: output
    format: "edam:format_1930"
    type: file
    
# If the second BAM exists, take it. Otherwise take the first BAM.
expression: |
  ${
      if (inputs.conditional_fastq2.length == 1 && inputs.conditional_fastq1.length == 1) {
          var output = inputs.conditional_fastq2[0];
      }
      else if (inputs.conditional_fastq2.length == 0 && inputs.conditional_fastq1.length == 1) {
          var output = inputs.conditional_fastq1[0];
      }
      else {
          throw "unhandled"
      }
      return {'output': output};
  }
