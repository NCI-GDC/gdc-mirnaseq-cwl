#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
 - class: StepInputExpressionRequirement
 - class: MultipleInputFeatureRequirement

inputs:
  - id: bai
    type: File
  - id: bam
    type: File
  - id: mirnas
    type: File
  - id: isoforms
    type: File
  - id: input_state
    type: string
  - id: job_uuid
    type: string

outputs:
  - id: sqlite
    type: File
    outputSource: merge_sqlite/destination_sqlite

steps:
  - id: bai_ls_l
    run: ../tools/ls_l.cwl
    in:
      - id: INPUT
        source: bai
    out:
      - id: OUTPUT

  - id: bai_md5sum
    run: ../tools/md5sum.cwl
    in:
      - id: INPUT
        source: bai
    out:
      - id: OUTPUT

  - id: bai_sha256
    run: ../tools/sha256sum.cwl
    in:
      - id: INPUT
        source: bai
    out:
      - id: OUTPUT

  - id: bam_ls_l
    run: ../tools/ls_l.cwl
    in:
      - id: INPUT
        source: bam
    out:
      - id: OUTPUT

  - id: bam_md5sum
    run: ../tools/md5sum.cwl
    in:
      - id: INPUT
        source: bam
    out:
      - id: OUTPUT

  - id: bam_sha256
    run: ../tools/sha256sum.cwl
    in:
      - id: INPUT
        source: bam
    out:
      - id: OUTPUT

  - id: mirnas_ls_l
    run: ../tools/ls_l.cwl
    in:
      - id: INPUT
        source: mirnas
    out:
      - id: OUTPUT

  - id: mirnas_md5sum
    run: ../tools/md5sum.cwl
    in:
      - id: INPUT
        source: mirnas
    out:
      - id: OUTPUT

  - id: mirnas_sha256
    run: ../tools/sha256sum.cwl
    in:
      - id: INPUT
        source: mirnas
    out:
      - id: OUTPUT

  - id: isoforms_ls_l
    run: ../tools/ls_l.cwl
    in:
      - id: INPUT
        source: isoforms
    out:
      - id: OUTPUT

  - id: isoforms_md5sum
    run: ../tools/md5sum.cwl
    in:
      - id: INPUT
        source: isoforms
    out:
      - id: OUTPUT

  - id: isoforms_sha256
    run: ../tools/sha256sum.cwl
    in:
      - id: INPUT
        source: isoforms
    out:
      - id: OUTPUT

  - id: bai_integrity_to_db
    run: ../tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: bai_ls_l/OUTPUT
      - id: md5sum_path
        source: bai_md5sum/OUTPUT
      - id: sha256sum_path
        source: bai_sha256/OUTPUT
      - id: job_uuid
        source: job_uuid
    out:
      - id: OUTPUT

  - id: bam_integrity_to_db
    run: ../tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: bam_ls_l/OUTPUT
      - id: md5sum_path
        source: bam_md5sum/OUTPUT
      - id: sha256sum_path
        source: bam_sha256/OUTPUT
      - id: job_uuid
        source: job_uuid
    out:
      - id: OUTPUT

  - id: mirnas_integrity_to_db
    run: ../tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: mirnas_ls_l/OUTPUT
      - id: md5sum_path
        source: mirnas_md5sum/OUTPUT
      - id: sha256sum_path
        source: mirnas_sha256/OUTPUT
      - id: job_uuid
        source: job_uuid
    out:
      - id: OUTPUT

  - id: isoforms_integrity_to_db
    run: ../tools/integrity_to_sqlite.cwl
    in:
      - id: input_state
        source: input_state
      - id: ls_l_path
        source: isoforms_ls_l/OUTPUT
      - id: md5sum_path
        source: isoforms_md5sum/OUTPUT
      - id: sha256sum_path
        source: isoforms_sha256/OUTPUT
      - id: job_uuid
        source: job_uuid
    out:
      - id: OUTPUT

  - id: merge_sqlite
    run: ../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
        bai_integrity_to_db/OUTPUT,
        bam_integrity_to_db/OUTPUT,
        mirnas_integrity_to_db/OUTPUT,
        isoforms_integrity_to_db/OUTPUT
        ]
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log
