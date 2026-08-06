#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/bwa:{{ bwa }}"

  - class: InlineJavascriptRequirement

  - class: SchemaDefRequirement
    types:
      - $import: readgroup.yml

  - class: ShellCommandRequirement

  - class: ResourceRequirement
    coresMin: $(inputs.thread_count)
    coresMax: $(inputs.thread_count)
    ramMin: 10000
    ramMax: 10000
    tmpdirMin: $(Math.ceil(2 * inputs.fastq.size / 1048576))
    tmpdirMax: $(Math.ceil(2 * inputs.fastq.size / 1048576))
    outdirMin: $(Math.ceil(2 * inputs.fastq.size / 1048576))
    outdirMax: $(Math.ceil(2 * inputs.fastq.size / 1048576))

class: CommandLineTool

inputs:
  - id: fastq
    type: File

  - id: fasta
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa

  - id: readgroup_meta
    type: readgroup.yml#readgroup_meta

  - id: fastqc_json_path
    type: File
    inputBinding:
      loadContents: true
      valueFrom: $(null)

  - id: samse_maxOcc
    type: long
    default: 10

  - id: thread_count
    type: long

outputs:
  - id: OUTPUT
    type: File
    outputBinding:
      glob: $(inputs.readgroup_meta["ID"] + ".bam")

arguments:
  - position: 1
    valueFrom: |
      ${
        function to_rg() {
          var readgroup_str = "@RG";
          var keys = Object.keys(inputs.readgroup_meta).sort();

          for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var value = inputs.readgroup_meta[key];

            if (key.length == 2 && value != null) {
              readgroup_str =
                readgroup_str + "\\t" + key + ":" + value;
            }
          }

          return readgroup_str;
        }

        /*
         * FastQC may report a single value such as:
         *
         *   "51"
         *
         * or a range such as:
         *
         *   "15-51"
         *
         * Extract all integers and use the maximum observed read length.
         */
        function parse_max_readlength(raw_readlength) {
          if (
            raw_readlength === null ||
            raw_readlength === undefined
          ) {
            throw new Error(
              "Missing FastQC Sequence length for " +
              inputs.fastq.basename
            );
          }

          var matches =
            String(raw_readlength).match(/\d+/g);

          if (!matches || matches.length === 0) {
            throw new Error(
              "Unable to parse FastQC Sequence length for " +
              inputs.fastq.basename +
              ": " +
              raw_readlength
            );
          }

          var max_readlength = 0;

          for (var i = 0; i < matches.length; i++) {
            var current_length =
              parseInt(matches[i], 10);

            if (
              !isNaN(current_length) &&
              current_length > max_readlength
            ) {
              max_readlength = current_length;
            }
          }

          if (max_readlength <= 0) {
            throw new Error(
              "Invalid FastQC Sequence length for " +
              inputs.fastq.basename +
              ": " +
              raw_readlength
            );
          }

          return max_readlength;
        }

        /*
         * Normalize only invalid unmapped records:
         *
         *   FLAG contains 0x4
         *   MAPQ is set to 0
         *
         * All mapped records and optional tags are preserved.
         */
        function normalize_unmapped_mapq() {
          return [
            "awk",
            "'BEGIN {OFS=\"\\t\"}",
            "/^@/ {print; next}",
            "{if (int($2/4)%2==1) $5=0; print}'"
          ].join(" ");
        }

        function bwa_aln_33(rg_str, outbam) {
          var cmd = [
            "bwa", "aln",
            "-t", inputs.thread_count,
            inputs.fasta.path,
            inputs.fastq.path,
            ">", "aln.sai",

            "&&",

            "bwa", "samse",
            "-n", inputs.samse_maxOcc,
            "-r", "\"" + rg_str + "\"",
            inputs.fasta.path,
            "aln.sai",
            inputs.fastq.path,

            "|",
            normalize_unmapped_mapq(),

            "|",
            "samtools", "view",
            "-Shb",
            "-o", outbam,
            "-"
          ];

          return cmd.join(" ");
        }

        function bwa_aln_64(rg_str, outbam) {
          var cmd = [
            "bwa", "aln",
            "-I",
            "-t", inputs.thread_count,
            inputs.fasta.path,
            inputs.fastq.path,
            ">", "aln.sai",

            "&&",

            "bwa", "samse",
            "-n", inputs.samse_maxOcc,
            "-r", "\"" + rg_str + "\"",
            inputs.fasta.path,
            "aln.sai",
            inputs.fastq.path,

            "|",
            normalize_unmapped_mapq(),

            "|",
            "samtools", "view",
            "-Shb",
            "-o", outbam,
            "-"
          ];

          return cmd.join(" ");
        }

        function bwa_mem(rg_str, outbam) {
          var cmd = [
            "bwa", "mem",
            "-t", inputs.thread_count,
            "-T", "0",
            "-R", "\"" + rg_str + "\"",
            inputs.fasta.path,
            inputs.fastq.path,

            "|",
            normalize_unmapped_mapq(),

            "|",
            "samtools", "view",
            "-Shb",
            "-o", outbam,
            "-"
          ];

          return cmd.join(" ");
        }

        /*
         * Preserve the original alignment cutoff.
         *
         * Maximum read length < 70:
         *   bwa aln + bwa samse
         *
         * Maximum read length >= 70:
         *   bwa mem
         */
        var MEM_ALN_CUTOFF = 70;

        var fastqc_json;

        try {
          fastqc_json =
            JSON.parse(inputs.fastqc_json_path.contents);
        } catch (error) {
          throw new Error(
            "Unable to parse FastQC JSON: " +
            error.message
          );
        }

        var fastq_basename =
          inputs.fastq.basename;

        if (
          !Object.prototype.hasOwnProperty.call(
            fastqc_json,
            fastq_basename
          )
        ) {
          throw new Error(
            "FastQC JSON has no entry for " +
            fastq_basename
          );
        }

        var fastqc_record =
          fastqc_json[fastq_basename];

        var raw_readlength =
          fastqc_record["Sequence length"];

        var readlength =
          parse_max_readlength(raw_readlength);

        var encoding =
          fastqc_record["Encoding"];

        if (
          encoding === null ||
          encoding === undefined
        ) {
          throw new Error(
            "FastQC Encoding is missing for " +
            fastq_basename
          );
        }

        var rg_str = to_rg();

        var outbam =
          inputs.readgroup_meta["ID"] + ".bam";

        if (
          encoding == "Illumina 1.3" ||
          encoding == "Illumina 1.5"
        ) {
          return bwa_aln_64(rg_str, outbam);
        }

        if (
          encoding == "Sanger / Illumina 1.9"
        ) {
          if (readlength < MEM_ALN_CUTOFF) {
            return bwa_aln_33(rg_str, outbam);
          }

          return bwa_mem(rg_str, outbam);
        }

        throw new Error(
          "Unsupported FASTQ encoding for " +
          fastq_basename +
          ": " +
          encoding
        );
      }

baseCommand:
  - bash
  - -c
