
function [subPaths] =  getSubdirs(basedir)
%GETSUBDIRS Returns all subdirectories of the basedirectory, does not
%return self, or parent, or hidden directories.
    if basedir(end)~='/'
        basedir = [basedir,'/'];
    end
        
    children = dir(basedir);
    children = {children([children.isdir]).name};
    subdirs = children(cellfun(@(c) c(1)~='.', children));
    subPaths = strcat(basedir, subdirs, '/');

end

