#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
      - $import: readgroup.yml

class: ExpressionTool

inputs:
  - id: input
    type:
      type: array
      items:
        type: array
        items: readgroup.yml#readgroup_fastq_se_file

outputs:
  - id: output
    type:
      type: array
      items: readgroup.yml#readgroup_fastq_se_file

expression: |
  ${
    var output = [];
    var readgroup_array_str = "";
    for (var i = 0; i < inputs.input.length; i++) {
      var readgroup_array = inputs.input[i];
      readgroup_array_str += " " + readgroup_array;
      for (var j = 0; j < readgroup_array.length; j++) {
        var readgroup = readgroup_array[j];
        output.push(readgroup);
      }
    }

    return {'output': output}
  }
