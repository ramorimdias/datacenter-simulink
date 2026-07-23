function add_in(path, name, port_number, position)
    add_block('simulink/Ports & Subsystems/In1', [path '/' name], ...
        'Port', num2str(port_number), 'Position', position);
end
