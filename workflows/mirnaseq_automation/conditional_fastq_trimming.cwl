#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements: []

class: Workflow

inputs:
  - id: untrimmed_fastq
    type: File
  - id: three_prime_adapter
    type: 'string[]'
  - id: three_prime_bases_removed
    type: int
  - id: minimum_length
    type: int
  - id: five_prime_adapter
    type: 'string[]'
  - id: five_prime_bases_removed
    type: int
  - id: run_fastq_trimming
    type: 'long[]'

outputs:
  - id: output
    type: file
    outputSource:
      - decide_fastq/output

steps:
  - id: fastq_trimmer_se
    run: ../../tools/fastq_trimmer_se.cwl
    scatter: run_fastq_trimming
    in:
      - id: three_prime_adapter
        source:
          - three_prime_adapter
      - id: untrimmed_fastq
        source: untrimmed_fastq
      - id: three_prime_bases_removed
        source: three_prime_bases_removed
      - id: five_prime_bases_removed
        source: five_prime_bases_removed
      - id: minimum_length
        source: minimum_length
      - id: five_prime_adapter
        source:
          - five_prime_adapter
    out:
      - id: adapter_size_trimmed_fastq

  - id: decide_fastq
    run: ../../tools/decider_conditional_fastqs.cwl
    in:
      - id: conditional_fastq1
        source:
          - untrimmed_fastq
      - id: conditional_fastq2
        source:
          - fastq_trimmer_se/adapter_size_trimmed_fastq
    out:
      - id: output

