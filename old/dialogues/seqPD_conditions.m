str = {'comp_preop','aulfp_perop','lfpmeg_postop','comportement'}
[selection,ok] = listdlg('PromptString','Select a condition',...
                         'SelectionMode','single',...
                         'ListString',str, ...
                         'ListSize', [ 100 100 ] )