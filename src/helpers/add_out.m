function add_out(path, name, port_number, position)
    add_block('simulink/Ports & Subsystems/Out1', [path '/' name], ...
        'Port', num2str(port_number), 'Position', position);
end
