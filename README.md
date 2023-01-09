# WITH.m
Adds a function to MATLAB that acts similarly to how WITH does in Excel VBA

Takes an object or struct along with a cell of pseudo name-value pairs as arguments and sets the fields/properties according to the name-value pair. 

Example:
```
propset = {'YLabel.String','Temperature', 'XLim', [0 inf]};
WITH(fig, propset)
```

is equivalent to 
```
fig.YLabel.String = 'Temperature'; 
fig.XLim = [0 inf];
```


[![View WITH.m on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/123032-with-m)
