#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/readgroup.yml
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: readgroups_bam_file
    type: ../../tools/readgroup.yml#readgroups_bam_file

outputs:
  - id: pe_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_pe_file
    outputSource: emit_readgroup_pe_files/output
  - id: se_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_se_file
    outputSource: emit_readgroup_se_files/output
  - id: o1_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_se_file
    outputSource: emit_readgroup_o1_files/output
  - id: o2_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_se_file
    outputSource: emit_readgroup_o2_files/output

steps:
  - id: biobambam_bamtofastq
    run: ../../tools/biobambam2_bamtofastq.cwl
    in:
      - id: filename
        source: readgroups_bam_file
        valueFrom: $(self.bam)
    out:
      - id: output_fastq1
      - id: output_fastq2
      - id: output_fastq_o1
      - id: output_fastq_o2
      - id: output_fastq_s

  - id: emit_readgroup_pe_files
    run: ../../tools/emit_readgroup_fastq_pe_files.cwl
    in:
      - id: forward_fastq_list
        source: biobambam_bamtofastq/output_fastq1
      - id: reverse_fastq_list
        source: biobambam_bamtofastq/output_fastq2
      - id: readgroup_meta_list
        source: readgroups_bam_file
        valueFrom: $(self.readgroup_meta_list)
    out:
      - id: output

  - id: emit_readgroup_se_files
    run: ../../tools/emit_readgroup_fastq_se_files.cwl
    in:
      - id: fastq_list
        source: biobambam_bamtofastq/output_fastq_s
      - id: readgroup_meta_list
        source: readgroups_bam_file
        valueFrom: $(self.readgroup_meta_list)
    out:
      - id: output

  - id: emit_readgroup_o1_files
    run: ../../tools/emit_readgroup_fastq_se_files.cwl
    in:
      - id: fastq_list
        source: biobambam_bamtofastq/output_fastq_o1
      - id: readgroup_meta_list
        source: readgroups_bam_file
        valueFrom: $(self.readgroup_meta_list)
    out:
      - id: output

  - id: emit_readgroup_o2_files
    run: ../../tools/emit_readgroup_fastq_se_files.cwl
    in:
      - id: fastq_list
        source: biobambam_bamtofastq/output_fastq_o2
      - id: readgroup_meta_list
        source: readgroups_bam_file
        valueFrom: $(self.readgroup_meta_list)
    out:
      - id: output
