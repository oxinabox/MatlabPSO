function [ ret ] = transpose_struct_array( operand )
    % based on from http://wiki.stdout.org/matlabcookbook/Arrays/Transposing%20an%20array%20of%20structs%20into%20a%20struct%20of%20arrays/
    % "Matlab cookbook" Author unknown
    
    if all(size(operand)==[0 0])
        error('Empty Operand Passed')
    elseif all(size(operand)==[1 1]) %HACK Structures of arrays are all size 1x1
        structOfArrays=operand;
        fields = fieldnames( structOfArrays );
        % Preallocate the array so it doesn't grow in the loop
        arrayLength = length(structOfArrays.(fields{1}));
        arrayOfStructs(arrayLength).(fields{1}) = [];

        for i = 1:length(fields)
            field = fields{i};
            array = structOfArrays.(field);
            for j = 1:length(array)
                arrayOfStructs(j).(field) = array(j);
            end
        end

        ret = arrayOfStructs;
    else
        arrayOfStructs=operand;
        fields = fieldnames(arrayOfStructs(1));

        for i = 1:length(fields)
            field = fields{i};
            structOfArrays.(field) = [arrayOfStructs.(field)];
        end
        ret = structOfArrays;
    end

end

