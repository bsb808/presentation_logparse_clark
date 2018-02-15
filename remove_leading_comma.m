function newl = remove_leading_comma(oldl)

newl = oldl;  % default
if (length(oldl)>2)
    if (oldl(1)==',')
        newl = oldl(2:end);
    end
end
return

        