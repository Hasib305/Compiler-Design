%{
    #include <stdio.h>
    #include <string.h>
    #include "bison.tab.h"
%}

IDF    [a-zA-Z][_a-zA-Z0-9]*
INT       [0-9]+
DOUBLE        [0-9]+"."[0-9]+
STRING        \"(\\.|[^"\\])*\"
%%
"bring"[ ]+{IDF}[.][h][ ]* {
    return HEADER;
}

";" {
    return EOL;
}

"#"[ ]* {
      char cmnt[500];
    int i;
    for (i = 0; 1; ++i) {
        char c = input();
        if (c == '\n' || c == EOF) {
            cmnt[i] = '\0';
            break;
        }
        cmnt[i] = c;
    }

    printf(" The Single Line Comment is: \n");
    printf("%s\n", cmnt);

    return SINCOM;
}

"<<"[ ]* {
    char cmnt[500];
    int i = 0;
    while (1) {
        char c = input();
        if (c == '>' && i > 0 && cmnt[i - 1] == '>') {
            cmnt[i - 1] = '\0';
            break;
        }
        cmnt[i++] = c;
    }
    printf(" The Multiline Comment is: \n");
    printf("%s\n", cmnt);
    return MULCOM;
}


"num"[ ]+      { return NUM_TYPE; }
"deci"[ ]+     { return DECI_TYPE; }
"str"[ ]+      { return STR_TYPE; }
"str_show"     { return STR_SHOW; }
"tan"          { return TAN; }
"root"         { return ROOT; }
"elif"         { return ELIF; }
"log10"        { return LOG10; }
"loop"         { return LOOP; }
"change"       {return CHANGE;}
"option"       {return OPTION;}
"other"        {return OTHER;}
"=="           { return EQUAL; }
"read"         { return READ; }
"show"         { return SHOW; }
"++"           { return INC; }
"else"         { return ELSE; }
"**"           { return POW; }
">"            { return GT; }
"ln"           { return LN; }
"sin"          { return SIN; }
"||"           { return OR; }
"->"           { return ARROW; }
"&&"           { return AND; }
"!="           { return NEQUAL; }
"~"            { return NOT; }
"int main()"   {return MAIN;}
"fun"          { return FUN; }
"<="           { return LEQUAL; }
"log2"         { return LOG2; }
"in"           { return IN; }
"<"            { return LT; }
"xor"          { return XOR; }
"--"           { return DEC; }
"if"           { return IF; }
">="           { return GEQUAL; }
"invoke"       { return INVOKE; }
"while"        { return WHILE; }
"by"        { return BY; }

{IDF} {
    yylval.string = strdup(yytext);
    return VAR;
 }



{INT} {
    yylval.integer = atoi(yytext);
    return NUM_VAL;
}

{DOUBLE} {
    yylval.real = atof(yytext);
    return DECI_VAL;
}


 {STRING} {

    char* temp = strdup(yytext);


    int len = strlen(temp);

    yylval.string = malloc(len * sizeof(char));

    memcpy(yylval.string, &temp[1], len  - 2);

    yylval.string[len - 2]= '\0';


    return STR_VAL;
}


[ \t\n]                    { }

[()+\-*/<>=,;%^{}\[\]]     { return yytext[0]; }
.                          {   printf("**Error: Unknown Character - '%s'**\n", yytext);}


%%
int yywrap() {
    return 1;
}

int yyerror(char *s){
	printf("**Syntax ERROR : %s**\n", s);
    return 1;
}
