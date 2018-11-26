clear all; close all; clc
addpath('GSEA_package')

% set options
opts = default_GSEA_opts();
opts.show = true;       %if plot results
opts.save = false;      %if save results
opts.perm_nb = 1000;    %number of permutations

% load('data_GSE6344.mat')
T=readtable('input.txt');
genelist=string(T.Gene);
generank=T.Residual_CV;

% load \\cvm-research-dr.cvm.tamu.edu\CaiLab\Cai-Terra3\DATA\DISK4T\ref_gene_sets\msigdb_v62\msigdb_v62_c5.mat
load msigdb_v62_c5.mat GeneSet GeneSetName

[res_pos,res_neg,res_descr,p_gene] = MrGSEA_rank(generank,genelist,...
                                     GeneSet,GeneSetName,'test_rank',opts);

Tp=cell2table(res_pos);
Tp.Properties.VariableNames=res_descr(1:end-1);
Tn=cell2table(res_neg);
Tn.Properties.VariableNames=res_descr(1:end-1);

