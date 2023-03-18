function WITH(OBJ, props)

p = inputParser;

% must be struct or object
OBJreq = @(x) isstruct(x) || isobject(x);

% must be a cell containing pseudo- name-value pairs
propreq = @(x) iscell(x) && mod(numel(x),2)==0;

addRequired(p,'OBJ', OBJreq)
addRequired(p,'props', propreq)

parse(p,OBJ, props);
OBJ         = p.Results.OBJ;
props       = p.Results.props;

% reshape props cell 
if isequal(size(props), [2 2])
    [fieldflag, ~, ~] = validateField(OBJ, props{2,1});
    if ~fieldflag
        props = props.';
    end
else
    props = reshapeprop(props);
end
n = numel(props)/2;

% split args into their field/properties and the value to set
fields  = props(:,1);
vals    = props(:,2);
for i = 1:n
    myfield = fields{i};
    myval = vals{i};
    if ~isstring(myfield) && ~ischar(myfield)
        warning('Field must be a string or char. Skipping.')
        continue;
    end
    myfield = char(myfield); % turn into char for easier validation
    [fieldflag, k, subfields] = validateField(OBJ, myfield);

    % try setting the field to the property; skip if unable
    if fieldflag == true
        try
            if ~isempty(k)
                OBJ = setfield(OBJ,subfields{:},myval);
            else
                OBJ.(myfield) = myval;
            end
        catch
            warning(['Could not set field `' myfield '`. Skipping.'])
            continue
        end
    else
        warning([myfield ' is not a valid field. Skipping.'])
        continue
    end
end
end

function newprop = reshapeprop(oldprop)
[rows,cols] = size(oldprop);
if rows == 1 || cols == 1
    newprop = reshape(oldprop,2,[]).';
elseif cols == 2 && rows ~= 2
    newprop = oldprop;
elseif rows == 2  && cols > 2 
    newprop = oldprop.';
else
    error('Invalid input for properties')
end
end

function [fieldflag, k, subfields] = validateField(OBJ, myfield)
% field validation
k = strfind(myfield,'.');
if ~isempty(k)  % check for nesting
    subfields = strsplit(myfield,'.');
    OBJtemp = OBJ;
    for m = 1:numel(subfields)-1
        try
            OBJtemp = OBJtemp.(subfields{m});
            if isfield(OBJtemp,subfields{m+1}) || isprop(OBJtemp,subfields{m+1})
                fieldflag=true;
            else
                fieldflag=false;
                break;
            end
        catch
            fieldflag = false;
        end
    end
else
    try
        if isfield(OBJ,myfield) || isprop(OBJ,myfield)
            fieldflag=true;
        else
            fieldflag=false;
        end
    catch
        fieldflag=false;
    end
    subfields=[];
end
end