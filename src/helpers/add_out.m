function add_out(path, name, port_number, position)
    block_path = [path '/' name];
    add_block('simulink/Ports & Subsystems/Out1', block_path, ...
        'Port', num2str(port_number), 'Position', position);
    try
        set_param(block_path, 'BackgroundColor', 'red');
    catch
        % Cosmetic styling varies by Simulink release.
    end
end
