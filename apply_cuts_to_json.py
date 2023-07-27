#!/bin/sh

import json
import os

# Reconstruction selections to apply to secondary vertexer 
sv_cuts = 'svertexer.minCosPAXYMeanVertex=-1;svertexer.minDCAToPV=0.001;svertexer.minCosPA=-1;svertexer.maxChi2=5;svertexer.maxDCAXYToMeanVertexV0Casc=10.;svertexer.maxDCAXYCasc=0.9;svertexer.maxDCAZCasc=0.9;svertexer.minRDiffV0Casc=0.1;svertexer.checkV0Hypothesis=false;svertexer.checkCascadeHypothesis=false;svertexer.maxPVContributors=3;svertexer.minCosPAXYMeanVertexCascV0=-1'

# read json
json_dict = json.load(open('workflow.json'))
json_items = json_dict['stages']
for item in json_items:
    if item['name'].startswith('svfinder'):
        cmd_list = item['cmd'].split(' ')
        for cmd_ind,cmd in enumerate(cmd_list):
            if cmd.startswith('--configKeyValues'):
                cmd_list[cmd_ind+1] = cmd_list[cmd_ind+1][:-1] + ';' + sv_cuts + cmd_list[cmd_ind+1][-1:]
                new_cmd = ' '.join(cmd_list)
                item['cmd'] = new_cmd

json.dump(json_dict, open('workflow_mod.json','w'), indent=4)
                            
