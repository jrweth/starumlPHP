/* PHP grammar by J. Reuben Wetherbee */

%lex
%%
\s+         /* skip whitespace */
\n+         /* skip carriage returns */
"/*"        return '/*';
"*/"        return '*/';
"class"     return 'CLASS';
"function"  return 'FUNCTION';
"("         return '(';
")"         return ')';
"{"         return "{"
"}"         return "}"
[a-zA-z]+   return 'NAME';
<<EOF>>     return 'EOF';
/lex



%% /* language grammar */

file_sections
  : class EOF
    { return $1; }
  ;

docblock
    : '/*' '*/'
    	{ $$ = 'doc block'; }
	;

class
    : docblock 'CLASS' 'NAME' '{' '}'
    	{$$ = $1 + $2 + $3 + $4 + $5}
    |  'CLASS' 'NAME' '{' '}'
        {$$ = $1 + $2 + $3}
    |  'CLASS' 'NAME' '{' classFunction '}'
        {$$ = $1 + $2 + $3}
    ;
    
classFunction
	: docblock 'FUNCTION' 'NAME' '(' ')' '{' '}'
		{$$ = $1 + $3}
	| 'FUNCTION' 'NAME' '(' ')' '{' '}'
		{$$ = $2}
	;