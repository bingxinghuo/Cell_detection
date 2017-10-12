treedata=loadjson('regions.json');
%%
Nregions=length(treedata);
for i=517:Nregions
    id=treedata{i}.id;
    id=strtrim(id);
    idN=str2num(treedata{i}.id_num);
    
    idx=find(strcmp([Fulllist(:,2)],id));
    if isempty(idx)
        id(strfind(id,'_'))='/';
        idx=find(strcmp([Fulllist(:,2)],id));
    end
    if isempty(idx)
        id(strfind(id,'/'))='-';
        idx=find(strcmp([Fulllist(:,2)],id));
    end
    if isempty(idx)
        id(strfind(id,'-'))=' ';
        idx=find(strcmp([Fulllist(:,2)],id));
    end
    Fulllist{idx,4}=idN;
end
%%
Ntree=size(Fulllist,1);
parents=cell(8,1);
parents{1}=Fulllist{1,2};
Fulllist=[Fulllist,cell(Ntree,1)];
for i=1:Ntree
    while isempty(Fulllist{i,5})
        for k=1:9
            if Layer(i)==k-1
                Fulllist{i,5}=parents{k};
                parents{k+1}=Fulllist{i,2};
            end
        end
    end
end
%%
% jsontree=cell(Ntree,1);
% for i=1:Ntree
% jsontree{i}=struct('parent_num',Fulllist{i,1},'parent',Fulllist{i,5},'id_num',Fulllist{i,4},'id',Fulllist{i,2},'full_name',Fulllist{i,3});
% end
jsontree=struct('parent_num',Fulllist(:,1),'parent',Fulllist(:,5),'id_num',Fulllist(:,4),'id',Fulllist(:,2),'full_name',Fulllist(:,3));
savejson('Whole Brain',jsontree(2:end,:),'Filename','braintree.json');