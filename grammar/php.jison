/* PHP grammar by J. Reuben Wetherbee */

%lex
%%
\s+         /* skip whitespace */
\n+         /* skip carriage returns */
"//".*      /* skip single line comments */
"/*"        return '/*';
"*/"        return '*/';
"<?php"     return 'STARTPHP';
"?>"        return 'ENDPHP';
"class"     return 'CLASS';
"function"  return 'FUNCTION';
"namespace" return 'NAMESPACE';
"\\"        return 'NS_SEPARATOR';
"("         return '(';
")"         return ')';
"{"         return "{";
"}"         return "}";
";"         return ";";
[A-Za-z_][A-Za-z0-9_]*   return 'IDENTIFIER';
<<EOF>>     return 'EOF';
/lex



%% /* language grammar */

file
  : STARTPHP fileSections EOF
    { console.log($2); return $2; }
  | STARTPHP fileSections ENDPHP EOF
    {console.log($2); return $2; }
;

fileSections
    : fileSection
        {
            $$ = [ $1 ];
        }
    | fileSections fileSection  
        {
            $1.push($2);
            $$ = $1;
        }
    ; 

fileSection
    : namespaceDeclaration
    | useDeclarations
    | class
    ;

class
    : docBlock 'CLASS' 'IDENTIFIER' '{' classBodyDeclarations '}'
    	{$$ = {
            'classDocBlock'  : $1,
            'className' : $3,
            'classBody' : $5
        }}
    |  'CLASS' 'IDENTIFIER' '{' classBodyDeclarations '}'
    	{$$ = {
            'className' : $3,
            'classBody' : $5
        }}
    ;

namespaceDeclaration
    : 'NAMESPACE' namespaceIdentifier ';'
        {$$ = {'namespace': $2}}
    ;

namespaceIdentifier
    : 'IDENTIFIER'
        {$$ = $1;}
    | namespaceIdentifier 'NS_SEPARATOR' 'IDENTIFIER'
        {$$ = $1 + "\\" + $3;  }
    ;

classBodyDeclarations
    :   %empty /* empty */
        {$$ = {}}
    |   classBodyDeclarationl
    ;

classBodyDeclarationl
    :   classBodyDeclaration
        {
            $$ = {
                'functions': [],
                'attributes': [],
                'constants': []
            };
            $$[$1.type+'s'].push($1.definition);
        }
    |   classBodyDeclarationl classBodyDeclaration
        {
            $1[$2.type+'s'].push($2.definition);
            $$ = $1;
        }
    ; 

classBodyDeclaration
    : classFunction
        {$$ = {
            'type': 'function',
            'definition': $1
        }
        }
    ; 

classFunction
	: docBlock 'FUNCTION' 'IDENTIFIER' '(' ')' '{' '}'
		{$$ = {
            'docBlock': $1,
            'functionName': $3
        }
        }
	| 'FUNCTION' 'IDENTIFIER' '(' ')' '{' '}'
		{$$ = {
            'functionName': $2
        }
        }
	;

docBlock
    : '/*' '*/'
    	{ $$ = 'doc block'; }
	;

