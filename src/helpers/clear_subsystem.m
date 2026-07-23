function clear_subsystem(path)
    lines = find_system(path, 'FindAll', 'on', 'SearchDepth', 1, ...
        'Type', 'line');
    for idx = 1:numel(lines)
        delete_line(lines(idx));
    end
    blocks = find_system(path, 'SearchDepth', 1, 'Type', 'Block');
    blocks = blocks(~strcmp(blocks, path));
    for idx = 1:numel(blocks)
        delete_block(blocks{idx});
    end
end
