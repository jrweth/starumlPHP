/* PHP grammar by J. Reuben Wetherbee */

%lex
%%
\s+         /* skip whitespace */
\n+         /* skip carriage returns */
"//".*      /* skip single line comments */
[/]\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*[/]+ return 'COMMENTBLOCK';
['](?:[^'\\]|\\.)*[']  return 'QUOTED_STRING';
["](?:[^"\\]|\\.)*["]  return 'QUOTED_STRING';
"<?php"     return 'STARTPHP';
"?>"        return 'ENDPHP';
"use"       return 'USE';
"as"        return 'AS';
"class"     return 'CLASS';
"function"  return 'FUNCTION';
"static"    return 'STATIC';
public|private|protected return "VISIBILITY";
"namespace" return 'NAMESPACE';
"$"         return '$';
"!"         return '!';
","         return ',';
"="         return '=';
"\\"        return 'NS_SEPARATOR';
"("         return '(';
")"         return ')';
"{"         return "{";
"}"         return "}";
";"         return ";";
"@"         return "@";
['](\'|[^'])*['] return "QUOTED_STRING";

[A-Za-z_][A-Za-z0-9_]*   return 'IDENTIFIER';
[0-9]+(\.[0-9]+)? return 'NUMBER';
<<EOF>>     return 'EOF';
[^\s]      return "MISC";
/lex



%% /* language grammar */

file
  : STARTPHP fileSections EOF
    { console.log($2); return $2;
    }
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
    | useDeclaration
    | classDeclaration
    ;

namespaceDeclaration
    : 'NAMESPACE' namespaceIdentifier ';'
        {$$ = {'type': 'namespace', 'namespace': $2}}
    ;

namespaceIdentifier
    : 'IDENTIFIER'
        {$$ = $1;}
    | namespaceIdentifier 'NS_SEPARATOR' 'IDENTIFIER'
        {$$ = $1 + "\\" + $3;  }
    ;


useDeclaration
    : 'USE' namespaceIdentifier ';'
        {$$ = {'type': 'use', 'use': $2}}
    | 'USE' namespaceIdentifier 'AS' 'IDENTIFIER' ';'
        {$$ = {'type': 'use', 'use': $2, 'as': $4}}
    ;

classDeclaration
    : 'COMMENTBLOCK' 'CLASS' 'IDENTIFIER' '{' classBodyDeclarations '}'
    	{$$ = {
            'docBlock'  : $1,
            'className' : $3,
            'classBody' : $5
        }}
    |  'CLASS' 'IDENTIFIER' '{' classBodyDeclarations '}'
    	{$$ = {
            'className' : $3,
            'classBody' : $5
        }}
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
        }}
    | 'COMMENTBLOCK'classFunction
        {$$ = {
            'type': 'function',
            'definition': $2,
            'docBlock': $1
        }}
    | classAttribute
        {$$ = {
            'type': 'attribute',
            'definition': $1,
        }}
    | 'COMMENTBLOCK' classAttribute
        {$$ = {
            'type': 'attribute',
            'definition': $2,
            'docBlock': $1
        }}
    ; 

classFunction
	: cModifiers 'FUNCTION' 'IDENTIFIER' '(' paramList ')' '{' classFunctionBody '}'
		{$$ = {
            'modifiers': $1,
            'functionName': $3
        }
        }
	| 'FUNCTION' 'IDENTIFIER' '(' paramList ')' '{' classFunctionBody  '}'
		{$$ = {
            'functionName': $2
        }
        }
	;

paramList
    : %empty
    | param
    | paramList ',' param
    ;

param
    : '$' 'IDENTIFIER'
    | namespaceIdentifier '$' 'IDENTIFIER'
    | '$' 'IDENTIFIER' equivalence
    | namespaceIdentifier '$' 'IDENTIFIER' equivalence
    ;

equivalence
    : '=' primative
    ;

primative
    : 'NUMBER'
    | 'QUOTED_STRING'
    ;

classAttribute
    : cModifiers '$' 'IDENTIFIER' ';'
        {$$ = {
            'name': $3,
            'modifiers': $1,
        }}
    | '$' 'IDENTIFIER' ';'
        {$$ = {
            'name': $2
        }}
    ;

cModifiers
    : cModifier
        {$$ = [$1]}
    | cModifiers cModifier
        {
            $1.push($2);
            $$ = $1;
        }
    ;

cModifier
    : 'VISIBILITY'
        {$$ = $1}
    | 'STATIC'
        {$$ = $1}
    ;

classFunctionBody
    : %empty /* empty */
    | classFunctionBodyPart1
    ;

classFunctionBodyPart1
    : miscCode
    | classFunctionBodyPart1 miscCode
    | classFunctionBodyPart1 '{' classFunctionBodyPart1 '}'
    | classFunctionBodyPart1 '{' '}'
    | '{' '}'
    | '{' classFunctionBodyPart1 '}'
    ;

miscCode1
    : %empty
    | miscCode1 miscCode
    ;

miscCode
    : 'CLASS'
    | 'USE'
    | 'AS'
    | 'FUNCTION'
    | 'NAMESPACE'
    | 'NS_SEPARATOR'
    | "!"
    | '('
    | ')'
    | ";"
    | "="
    | ","
    | "$"
    | "@"
    | "NUMBER"
    | "QUOTED_STRING"
    | "IDENTIFIER"
    | "MISC"
    | "COMMENTBLOCK"
    ; 

