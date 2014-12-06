classdef Memoriser < handle
    properties
        cache
        baseFunc
    end
    
    methods
        function obj = Memoriser(func)
            obj.cache = containers.Map();
            obj.baseFunc = func;
        end
        
        function cached = inCache(obj, question)
            cached = obj.cache.isKey(stringify(question));
        end
        
        function answer = fromCache(obj, question)
            answer = obj.cache(stringify(question));
        end
        
        function addToCache(obj, question, answer)
            obj.cache(stringify(question)) = answer;
        end
        
        
        function answer = eval(obj,question)
            if obj.inCache(question)
                answer = obj.fromCache(question);
            else
                answer = obj.baseFunc(question);
                obj.addToCache(question, answer)
            end
        end 
        
        
    end
    
end

function str = stringify(vector)
    str = sprintf('%f ', vector);
end 
