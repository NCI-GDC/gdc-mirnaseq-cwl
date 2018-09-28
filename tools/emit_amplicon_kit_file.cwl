#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: SchemaDefRequirement
    types:
      - $import: amplicon_kit.yml
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  - id: amplicon_kit_amplicon_file
    type: File

  - id: amplicon_kit_target_file
    type: File

outputs:
  - id: output
    type: amplicon_kit.yml#amplicon_kit_set_file

expression: |
  ${
    var output = {'amplicon_kit_amplicon_file': inputs.amplicon_kit_amplicon_file,
                  'amplicon_kit_target_file': inputs.amplicon_kit_target_file};
    return {'output': output};
  }
