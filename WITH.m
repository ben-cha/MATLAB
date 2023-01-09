function WITH(S, props)

p = inputParser;

% must be struct or object
Sreq = @(x) isstruct(x) || isobject(x);

% must be a cell containing pseudo- name-value pairs
propreq = @(x) iscell(x) && mod(numel(x),2)==0;

addRequired(p,'S', Sreq)
addRequired(p,'props', propreq)

parse(p,S,props);
S = p.Results.S;
props = p.Results.props;

n = numel(props)/2;

% split args into their field/properties and the value to set
fields = props(1:2:end);
vals = props(2:2:end);

for i = 1:n
    mystr = fields{i}; 
    myval = vals{i};

    % field validation
    if ~isstring(mystr) && ~ischar(mystr)
        warning('Field must be a string or char. Skipping.')
        continue;
    end
    mystr = char(mystr); % turn into char for easier validation
    k = strfind(mystr,'.'); % check for nesting
    if ~isempty(k) 
        subfields=strsplit(mystr,'.');
        bstr = extractBefore(mystr,k(end));
        astr = extractAfter(mystr,k(end));
        
        if isfield(S.(bstr),astr) || isprop(S.(bstr),astr)
            fieldflag=true; 
        else
            fieldflag=false;
        end
    else
        if isfield(S,mystr) || isprop(S,mystr)
            fieldflag=true;
        else
            fieldflag=false;
        end
    end
    % /field validation

    % try setting the field to the property; skip if unable
    if fieldflag == true
        try
            if ~isempty(k) 
                S = setfield(S,subfields{:},myval);
            else
                S.(mystr) = myval;
            end
        catch
            warning('Could not set field. Skipping.')
            continue
        end
    else
        warning([mystr ' is not a valid field. Skipping.'])
        continue
    end
end