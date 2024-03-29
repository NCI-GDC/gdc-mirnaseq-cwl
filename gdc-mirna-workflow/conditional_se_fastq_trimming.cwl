#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../tools/readgroup.yml

class: Workflow

inputs:
  - id: input
    type: '../tools/readgroup.yml#readgroup_fastq_se_file'

outputs:
  - id: output
    type: ../tools/readgroup.yml#readgroup_fastq_se_file
    outputSource: emit_readgroup_fastq_se_file/output

steps:
  - id: emit_readgroup_trimming
    run: ../tools/emit_readgroup_trimming.cwl
    in:
      - id: input 
        source: input
        valueFrom: $(self.readgroup_meta)
    out:
      - id: output
   
  - id: fastq_adapter_trimmer_se
    run: ../tools/fastq_trimmer_se.cwl
    scatter: run_fastq_trimming
    in:
      - id: three_prime_adapter
        source: input
        valueFrom: $(self.readgroup_meta.three_prime_adapter_to_trim) 
      - id: five_prime_adapter
        source: input
        valueFrom: $(self.readgroup_meta.five_prime_adapter_to_trim)
      - id: input_fastq
        source: input
        valueFrom: $(self.fastq) 
      - id: minimum_length
        source: input
        valueFrom: $(self.readgroup_meta.minimum_read_length)
      - id: output_name
        source: input
        valueFrom: $(self.fastq.basename)
      - id: run_fastq_trimming
        source: emit_readgroup_trimming/output 
    out:
      - id: output_fastq 

  - id: fastq_prime_trimmer_se
    run: ../tools/fastq_trimmer_se.cwl
    scatter: input_fastq 
    in:
      - id: three_prime_bases_removed
        source: input
        valueFrom: $(self.readgroup_meta.three_prime_bases_to_trim)
      - id: five_prime_bases_removed
        source: input
        valueFrom: $(self.readgroup_meta.five_prime_bases_to_trim)
      - id: input_fastq
        source: fastq_adapter_trimmer_se/output_fastq 
      - id: minimum_length
        source: input
        valueFrom: $(self.readgroup_meta.minimum_read_length)
      - id: output_name
        source: input 
        valueFrom: $(self.fastq.basename)
    out:
      - id: output_fastq

  - id: decide_fastq
    run: ../tools/decider_conditional_fastqs.cwl
    in:
      - id: conditional_fastq1
        source: input
        valueFrom: $(self.fastq) 
      - id: conditional_fastq2
        source: fastq_prime_trimmer_se/output_fastq
    out:
      - id: output

  - id: emit_readgroup_fastq_se_file
    run: ../tools/emit_readgroup_fastq_se_file.cwl
    in:
      - id: fastq
        source: decide_fastq/output 
      - id: readgroup_meta
        source: input
        valueFrom: $(self.readgroup_meta)
    out:
      - id: output
