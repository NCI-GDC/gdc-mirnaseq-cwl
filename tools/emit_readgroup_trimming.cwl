#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.yml
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: input
    type: readgroup.yml#readgroup_meta

outputs:
  - id: output
    type:
      type: array
      items: long

expression: |
  ${
    const output = inputs.input.run_fastq_trimming;
    return {'output': output};
  }
