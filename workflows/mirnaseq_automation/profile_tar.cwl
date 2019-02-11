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
  - id: inputBam
    type: File

outputs:
  - id: profilingTar 
    type: File
    outputSource: tar_mirna_profiling/OUTPUT 

steps:
  - id: mirna_profiling
    run: mirna_profiling.cwl
    in:
      - id: awk_expression
        valueFrom: "{arr[length($10)]+=1} END {for (i in arr) {print i\" \"arr[i]}}"
      - id: bam
        source: inputBam
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

  - id: tar_mirna_profiling_alignment_stats
    run: ../../tools/tar_dir_no_paths.cwl
    in:
      - id: INPUT
        source: mirna_profiling/mirna_alignment_stats_features
      - id: file
        valueFrom: features.tar
    out:
      - id: OUTPUT

  - id: tar_mirna_profiling_graph_libs
    run: ../../tools/tar_dir_no_paths.cwl
    in:
      - id: INPUT
        source: mirna_profiling/mirna_graph_libs_jpgs
      - id: file
        valueFrom: graph_libs_jpgs.tar
    out:
      - id: OUTPUT

  - id: tar_mirna_profiling
    run: ../../tools/tar_no_paths.cwl
    in:
      - id: INPUT
        source: [
          mirna_profiling/mirna_adapter_report_sorted_output,
          tar_mirna_profiling_alignment_stats/OUTPUT,
          tar_mirna_profiling_graph_libs/OUTPUT,
          mirna_profiling/mirna_expression_matrix_expn_matrix_txt,
          mirna_profiling/mirna_expression_matrix_expn_matrix_norm_txt,
          mirna_profiling/mirna_expression_matrix_expn_matrix_norm_log_txt,
          mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_txt,
          mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_norm_txt,
          mirna_profiling/mirna_expression_matrix_mimat_expn_matrix_mimat_norm_log_txt,
          mirna_profiling/mirna_tcga_isoforms_quant,
          mirna_profiling/mirna_tcga_mirnas_quant
        ]
      - id: file
        valueFrom: profile_tar_mirna_profiling.tar.xz
    out:
      - id: OUTPUT
