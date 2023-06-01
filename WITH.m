function varargout = WITH(OBJ, fieldprops, varargin)

%{
Set properties to objects 
`OBJ` must be a struct or object
`fieldprops` can either be a cell vector/matrix of field-property arguments OR it
can be a vector of field arguments
If `fieldprops` is a cell vector of field arguments, `props` must be a vector of the
same length of property arguments
Supports nested fields
%}

p = inputParser;

% must be struct or object
OBJreq = @(x) isstruct(x) || isobject(x);

% must be a cell containing pseudo- name-value pairs
fpreq = @(x) iscell(x) && (mod(numel(x),2)==0) || (iscell(varargin{1}) && numel(varargin{1})==numel(x));
propreq = @(x) iscell(x) && numel(x)==numel(fieldprops) && isvector(x) && isvector(fieldprops);

addRequired(p,'OBJ', OBJreq)
addRequired(p,'fieldprops', fpreq);
addOptional(p, 'props', [], propreq) %do later
addParameter(p, 'warning', true, @islogical, 'PartialMatchPriority',1)

parse(p, OBJ, fieldprops, varargin{:});
OBJ         = p.Results.OBJ;
fieldprops  = p.Results.fieldprops;
props       = p.Results.props;
warn        = p.Results.warning;

if isempty(props)
    % reshape fieldprops cell
    if isequal(size(fieldprops), [2 2])
        [fieldflag, ~, ~] = validateField(OBJ(1), fieldprops{2,1});
        if ~fieldflag
            fieldprops = fieldprops.';
        end
    else
        fieldprops = reshapeprop(fieldprops);
    end
    % split args into their field/properties and the value to set
    fields  = fieldprops(:,1);
    vals    = fieldprops(:,2);
else
    fields = fieldprops;
    vals = props;
end
n = numel(fields);

WID = 'bcha:WITH:FieldError';
for ii = 1:numel(OBJ)
    MYOBJ = OBJ(ii);
    for i = 1:n
        myfield = fields{i};
        myval = vals{i};
        if ~isstring(myfield) && ~ischar(myfield)
            if warn ~=false
                warning(WID, 'Field must be a string or char. Skipping.')
            end
            continue;
        end
        myfield = char(myfield); % turn into char for easier validation
        [fieldflag, k, subfields] = validateField(MYOBJ, myfield);

        % try setting the field to the property; skip if unable
        if fieldflag == true
            try
                if ~isempty(k)
                    MYOBJ = setfield(MYOBJ,subfields{:},myval);
                else
                    MYOBJ.(myfield) = myval;
                end
            catch
                if warn ~=false
                    warning(WID, ['Could not set field `' myfield '`. Skipping.'])
                end
                continue
            end
        else
            if warn ~=false
                warning(WID, [myfield ' is not a valid field for given object. Skipping.'])
            end
            continue
        end
    end
end


if nargout > 0
    varargout{1} = MYOBJ;
end

end

%% Functions
function newprop = reshapeprop(oldprop)
% find which dim the field-prop pairs are listed and reshape if necessary
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

function [fieldflag, k, subfields] = validateField(MYOBJ, myfield)
% field validation
k = strfind(myfield,'.');
if ~isempty(k)  % check for nesting
    subfields = strsplit(myfield,'.');
    OBJtemp = MYOBJ;
    for m = 1:numel(subfields)-1
        try
            OBJtemp = OBJtemp.(subfields{m});
            if ismember(subfields{m+1}, fields(OBJtemp))
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
        if ismember(myfield, fields(MYOBJ))
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