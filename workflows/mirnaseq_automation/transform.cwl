#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
    types:
      - $import: ../../tools/readgroup.yml
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  - id: bam_name
    type: string
  - id: job_uuid
    type: string
  - id: readgroup_fastq_pe_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_pe_file
  - id: readgroup_fastq_se_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroup_fastq_se_file
  - id: readgroups_bam_file_list
    type:
      type: array
      items: ../../tools/readgroup.yml#readgroups_bam_file
  - id: reference_sequence
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .fai
      - .pac
      - .sa
      - ^.dict
  - id: thread_count
    type: long
  - id: run_fastq_trimming
    type: 'long[]'
  - id: three_prime_adapter_to_trim
    type: 'string[]?'
  - id: three_prime_bases_to_trim
    type: int?
  - id: minimum_read_length
    type: int?
  - id: five_prime_adapter_to_trim
    type: 'string[]?'
  - id: five_prime_bases_to_trim
    type: int?

outputs:
  - id: output_bam
    type: File
    outputSource: bam_index/output
  - id: sqlite
    type: File
    outputSource: merge_all_sqlite/destination_sqlite
  - id: mirna_profiling_mirna_adapter_report_sorted_output
    type: File
    outputSource: mirna_profiling/mirna_adapter_report_sorted_output
  - id: mirna_profiling_mirna_alignment_stats_features
    type: Directory
    outputSource: mirna_profiling/mirna_alignment_stats_features
  - id: mirna_profiling_mirna_expression_matrix_expn_matrix_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_expn_matrix_txt
  - id: mirna_profiling_mirna_expression_matrix_expn_matrix_norm_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_expn_matrix_norm_txt
  - id: mirna_profiling_mirna_expression_matrix_expn_matrix_norm_log_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_expn_matrix_norm_log_txt
  - id: mirna_profiling_mirna_expression_matrix_mimat_expn_matrix_mimat_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_txt
  - id: mirna_profiling_mirna_expression_matrix_mimat_expn_matrix_mimat_norm_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_norm_txt
  - id: mirna_profiling_mirna_expression_matrix_mimat_expn_matrix_mimat_norm_log_txt
    type: File
    outputSource: mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_norm_log_txt
  - id: mirna_profiling_mirna_graph_libs_jpgs
    type: Directory
    outputSource: mirna_profiling/mirna_graph_libs_jpgs
  - id: mirna_profiling_mirna_tcga_isoforms_quant
    type: File
    outputSource: mirna_profiling/mirna_tcga_isoforms_quant
  - id: mirna_profiling_mirna_tcga_mirnas_quant
    type: File
    outputSource: mirna_profiling/mirna_tcga_mirnas_quant

steps:
  - id: fastq_clean_pe
    run: fastq_clean_pe.cwl
    scatter: input
    in:
      - id: input
        source: readgroup_fastq_pe_file_list
      - id: job_uuid
        source: job_uuid
    out:
      - id: output
      - id: sqlite

  - id: fastq_clean_se
    run: fastq_clean_se.cwl
    scatter: input
    in:
      - id: input
        source: readgroup_fastq_se_file_list
      - id: job_uuid
        source: job_uuid
    out:
      - id: output
      - id: sqlite

  - id: merge_sqlite_fastq_clean_pe
    run: ../../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: fastq_clean_pe/sqlite
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: merge_sqlite_fastq_clean_se
    run: ../../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: fastq_clean_se/sqlite
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: readgroups_bam_to_readgroups_fastq_lists
    run: readgroups_bam_to_readgroups_fastq_lists.cwl
    scatter: readgroups_bam_file
    in:
      - id: readgroups_bam_file
        source: readgroups_bam_file_list
    out:
      - id: pe_file_list
      - id: se_file_list
      - id: o1_file_list
      - id: o2_file_list

  - id: merge_bam_pe_fastq_records
    run: ../../tools/merge_pe_fastq_records.cwl
    in:
      - id: input
        source: readgroups_bam_to_readgroups_fastq_lists/pe_file_list
    out:
      - id: output

  - id: merge_pe_fastq_records
    run: ../../tools/merge_pe_fastq_records.cwl
    in:
      - id: input
        source: [
        merge_bam_pe_fastq_records/output,
        fastq_clean_pe/output
        ]
    out:
      - id: output

  - id: merge_bam_se_fastq_records
    run: ../../tools/merge_se_fastq_records.cwl
    in:
      - id: input
        source: readgroups_bam_to_readgroups_fastq_lists/se_file_list
    out:
      - id: output

  - id: merge_se_fastq_records
    run: ../../tools/merge_se_fastq_records.cwl
    in:
      - id: input
        source: [
        merge_bam_se_fastq_records/output,
        fastq_clean_se/output
        ]
    out:
      - id: output

  - id: merge_o1_fastq_records
    run: ../../tools/merge_se_fastq_records.cwl
    in:
      - id: input
        source: readgroups_bam_to_readgroups_fastq_lists/o1_file_list
    out:
      - id: output

  - id: merge_o2_fastq_records
    run: ../../tools/merge_se_fastq_records.cwl
    in:
      - id: input
        source: readgroups_bam_to_readgroups_fastq_lists/o2_file_list
    out:
      - id: output

  - id: conditional_se_fastq_trimming
    run: conditional_se_fastq_trimming.cwl
    scatter: input 
    in:
      - id: input
        source: merge_se_fastq_records/output
      - id: three_prime_adapter_to_trim
        source: three_prime_adapter_to_trim
      - id: three_prime_bases_to_trim
        source: three_prime_bases_to_trim
      - id: minimum_read_length
        source: minimum_read_length
      - id: five_prime_adapter_to_trim
        source: five_prime_adapter_to_trim
      - id: five_prime_bases_to_trim
        source: five_prime_bases_to_trim
      - id: run_fastq_trimming
        source: run_fastq_trimming
    out:
      - id: output

  - id: bwa_pe
    run: bwa_pe.cwl
    scatter: readgroup_fastq_pe
    in:
      - id: job_uuid
        source: job_uuid
      - id: reference_sequence
        source: reference_sequence
      - id: readgroup_fastq_pe
        source: merge_pe_fastq_records/output
      - id: thread_count
        source: thread_count
    out:
      - id: bam
      - id: sqlite

  - id: bwa_se
    run: bwa_se.cwl
    scatter: readgroup_fastq_se
    in:
      - id: job_uuid
        source: job_uuid
      - id: reference_sequence
        source: reference_sequence
      - id: readgroup_fastq_se
        source: conditional_se_fastq_trimming/output
      - id: thread_count
        source: thread_count
    out:
      - id: bam
      - id: sqlite

  - id: bwa_o1
    run: bwa_se.cwl
    scatter: readgroup_fastq_se
    in:
      - id: job_uuid
        source: job_uuid
      - id: reference_sequence
        source: reference_sequence
      - id: readgroup_fastq_se
        source: merge_o1_fastq_records/output
      - id: thread_count
        source: thread_count
    out:
      - id: bam
      - id: sqlite

  - id: bwa_o2
    run: bwa_se.cwl
    scatter: readgroup_fastq_se
    in:
      - id: job_uuid
        source: job_uuid
      - id: reference_sequence
        source: reference_sequence
      - id: readgroup_fastq_se
        source: merge_o2_fastq_records/output
      - id: thread_count
        source: thread_count
    out:
      - id: bam
      - id: sqlite

  - id: merge_sqlite_bwa_pe
    run: ../../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: bwa_pe/sqlite
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: merge_sqlite_bwa_se
    run: ../../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: bwa_se/sqlite
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log

  - id: picard_mergesamfiles
    run: ../../tools/picard_mergesamfiles_aoa.cwl
    in:
      - id: INPUT
        source: [
        bwa_pe/bam,
        bwa_se/bam,
        bwa_o1/bam,
        bwa_o2/bam
        ]
      - id: OUTPUT
        source: bam_name
    out:
      - id: MERGED_OUTPUT

  - id: bam_reheader
    run: ../../tools/bam_reheader.cwl
    in:
      - id: input
        source: picard_mergesamfiles/MERGED_OUTPUT
    out:
      - id: output

  - id: bam_index
    run: bam_index.cwl
    in:
      - id: bam
        source: bam_reheader/output
      - id: thread_count
        source: thread_count
    out:
      - id: output
      - id: sqlite

  - id: picard_validatesamfile
    run: ../../tools/picard_validatesamfile.cwl
    in:
      - id: INPUT
        source: bam_index/output
      - id: VALIDATION_STRINGENCY
        valueFrom: "STRICT"
    out:
      - id: OUTPUT

  #need eof and dup QNAME detection
  - id: picard_validatesamfile_to_sqlite
    run: ../../tools/picard_validatesamfile_to_sqlite.cwl
    in:
      - id: bam
        source: bam_index/output
        valueFrom: $(self.basename)
      - id: input_state
        valueFrom: "mirnaseq_readgroups"
      - id: metric_path
        source: picard_validatesamfile/OUTPUT
      - id: job_uuid
        source: job_uuid
    out:
      - id: sqlite

  - id: metrics
    run: metrics.cwl
    in:
      - id: bam
        source: bam_index/output
      - id: input_state
        valueFrom: "mirnaseq_readgroups"
      - id: job_uuid
        source: job_uuid
    out:
      - id: sqlite

  - id: mirna_profiling
    run: mirna_profiling.cwl
    in:
      - id: awk_expression
        valueFrom: "{arr[length($10)]+=1} END {for (i in arr) {print i\" \"arr[i]}}"
      - id: bam
        source: bam_index/output
      - id: mirbase_db
        valueFrom: "mirbase"
      - id: species_code
        valueFrom: "hsa"
      - id: project_directory
        valueFrom: "."
      - id: ucsc_database
        valueFrom: "hg38"
    out:
      - id: mirna_adapter_report_sorted_output
      - id: mirna_alignment_stats_features
      - id: mirna_expression_matrix_expn_matrix_txt
      - id: mirna_expression_matrix_expn_matrix_norm_txt
      - id: mirna_expression_matrix_expn_matrix_norm_log_txt
      - id: mirna_expression_matrix_mimat_expn_matrix_mimat_txt
      - id: mirna_expression_matrix_mimat_expn_matrix_mimat_norm_txt
      - id: mirna_expression_matrix_mimat_expn_matrix_mimat_norm_log_txt
      - id: mirna_graph_libs_jpgs
      - id: mirna_tcga_isoforms_quant
      - id: mirna_tcga_mirnas_quant

  - id: integrity
    run: integrity.cwl
    in:
      - id: bai
        source: bam_index/output
        valueFrom: $(self.secondaryFiles[0])
      - id: bam
        source: bam_index/output
      - id: mirnas
        source: mirna_profiling/mirna_tcga_mirnas_quant
      - id: isoforms
        source: mirna_profiling/mirna_tcga_isoforms_quant
      - id: input_state
        valueFrom: "mirnaseq_readgroups"
      - id: job_uuid
        source: job_uuid
    out:
      - id: sqlite

  - id: merge_all_sqlite
    run: ../../tools/merge_sqlite.cwl
    in:
      - id: source_sqlite
        source: [
          merge_sqlite_fastq_clean_pe/destination_sqlite,
          merge_sqlite_fastq_clean_se/destination_sqlite,
          merge_sqlite_bwa_pe/destination_sqlite,
          merge_sqlite_bwa_se/destination_sqlite,
          bam_index/sqlite,
          metrics/sqlite,
          integrity/sqlite
          ]
      - id: job_uuid
        source: job_uuid
    out:
      - id: destination_sqlite
      - id: log
