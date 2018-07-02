% Write TASBEConfig preferences into a given sheet number and filepath of a
% batch_template spreadsheet
function TASBEConfig_preferences(filename, sheet_num)
    TASBEConfig.checkpoint('init');
    [settings, ~, documentation] = TASBEConfig.list();

    names = fieldnames(documentation);

    preferences = [];

    for i=2:numel(names)
        name = char(names{i});
        doc_section = getfield(documentation, name);
        set_section = getfield(settings, name);
        doc_names = fieldnames(doc_section);
        about_note = getfield(doc_section, doc_names{1});
        row = {name, char(about_note), ''};
        preferences = [preferences; row];
        for j=2:numel(doc_names)
            sub_name = doc_names{j};
            note = getfield(doc_section, doc_names{j});
            value = getfield(set_section, doc_names{j});
            row = {[name '.' char(sub_name)], char(note), num2str(value)};
            preferences = [preferences; row];
        end
    end
    xlswrite(filename, preferences, sheet_num);
end

