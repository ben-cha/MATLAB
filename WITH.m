function varargout = WITH(OBJ, fieldprops, varargin)
% dbstop if caught error
p = inputParser;

% must be struct or object
OBJreq = @(x) isstruct(x) || isobject(x);

% must be a cell containing pseudo- name-value pairs
propreq = @(x) iscell(x) && mod(numel(x),2)==0;

addRequired(p,'OBJ', OBJreq)
addRequired(p,'fieldprops', propreq);
% addRequired(p,'fieldprops', propreq || (~isempty(varargin) && mod(numel(varargin),2)==1));
% addOptional(p, 'props', [], @(x) numel(x)==numel(fieldsprops)) %do later
addParameter(p, 'warning', true, @islogical, 'PartialMatchPriority',1)

parse(p, OBJ, fieldprops, varargin{:});
OBJ         = p.Results.OBJ;
fieldprops       = p.Results.fieldprops;
warn        = p.Results.warning;

% reshape fieldprops cell
if isequal(size(fieldprops), [2 2])
    [fieldflag, ~, ~] = validateField(OBJ(1), fieldprops{2,1});
    if ~fieldflag
        fieldprops = fieldprops.';
    end
else
    fieldprops = reshapeprop(fieldprops);
end
n = numel(fieldprops)/2;

% split args into their field/properties and the value to set
fields  = fieldprops(:,1);
vals    = fieldprops(:,2);

% if isequal(class(OBJ), 'matlab.graphics.primitive.world.Group')
% end

for ii = 1:numel(OBJ)
    MYOBJ = OBJ(ii);
    for i = 1:n
        myfield = fields{i};
        myval = vals{i};
        if ~isstring(myfield) && ~ischar(myfield)
            if warn ~=false
                warning('Field must be a string or char. Skipping.')
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
                    warning(['Could not set field `' myfield '`. Skipping.'])
                end
                continue
            end
        else
            if warn ~=false
                warning([myfield ' is not a valid field. Skipping.'])
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