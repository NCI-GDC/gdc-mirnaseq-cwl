#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repository }}/merge-sqlite:{{ merge_sqlite }}"
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 1000
    ramMax: 1000
    tmpdirMin: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (req_space / 1048576));
      }      
    tmpdirMax: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(2 * (req_space / 1048576));
      }      
    outdirMin: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }      
    outdirMax: |
      ${
      var req_space = 0;
      for (var i = 0; i < inputs.source_sqlite.length; i++) {
          req_space += inputs.source_sqlite[i].size;
        }
      return Math.ceil(req_space / 1048576);
      }

class: CommandLineTool

inputs:
  - id: source_sqlite
    type:
      type: array
      items: File
      inputBinding:
        prefix: "--source_sqlite"

  - id: job_uuid
    type: string
    inputBinding:
      prefix: "--job_uuid"

outputs:
  - id: destination_sqlite
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".db")

  - id: log
    type: File
    outputBinding:
      glob: $(inputs.job_uuid + ".log")

#baseCommand: [merge_sqlite]

