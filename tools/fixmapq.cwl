cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: "{{ docker_repository }}/samtools:{{ samtools }}"
  ShellCommandRequirement: {}

baseCommand:
  - /bin/bash
  - -c

inputs:
  bam:
    type: File

  output_name:
    type: string
    default: fixed_unmapped_mapq.bam

arguments:
  - position: 1
    valueFrom: |
      ${
        return "samtools view -h " + inputs.bam.path +
               " | awk 'BEGIN {OFS=\"\\t\"} /^@/ {print; next} {if (and($2,4) && $5 != 0) $5=0; print}'" +
               " | samtools view -b -o " + inputs.output_name + " -";
      }

outputs:
  output_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_name)
