#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: refgenie seek
inputs:
  registry_path:
    type: string
    inputBinding:
      position: 1
outputs:
  path:
    type: stdout
