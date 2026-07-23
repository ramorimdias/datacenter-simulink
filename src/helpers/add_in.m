function add_in(path, name, port_number, position)
    block_path = [path '/' name];
    add_block('simulink/Ports & Subsystems/In1', block_path, ...
        'Port', num2str(port_number), 'Position', position);
end
