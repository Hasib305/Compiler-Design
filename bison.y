%{

    #include <stdio.h>
    #include <string.h>
    #include <math.h>
    #include <stdlib.h>
  

    int yylex();
    int yyerror(char* s);

    
  int op=0;

 int in_function_scope = 0;
    int function_declared_flag = 0;

    typedef struct {

        int *int_val ,array_check,type,length;
        double *dec_val;
        char **str_val;
        char *name;
        
       
    } detail;
    detail *current_var_point;

  int TOT_VAR = 0;
    int TOT_FUN = 0;
    int current_function = 0;
    int tot_param = 0;
    int fun_rej = 0;

    typedef struct {
        char *fname;  detail *fptr; int var_cnt;
    } fun_detail;
    fun_detail *funcptr;

    int unique(char *name) {
        for(int i = 0; i < TOT_VAR; ++i) {
            if(strcmp(current_var_point[i].name, name) == 0) {
                return -1;
            }
        }
        return 1;
    } 


    int find_v_indx(char *name) {
        for(int i = 0; i < TOT_VAR; ++i) {
            if(strcmp(current_var_point[i].name, name) == 0) {
                return i;
            }
        }
        return -1;
    }
      void var_not_found(char *name) {
        printf("\n** Error : Variable : \"%s\" doesn't exist. **\n", name);
    }
 void save_val(char *n, int t, int l, int p, void *v, int is_Array) {
    current_var_point[p].name = strdup(n);
    current_var_point[p].type = t;
    current_var_point[p].length = l;
    current_var_point[p].array_check = is_Array;

    switch (t) {
        case 1: {
            int *value = (int *)v;
            current_var_point[p].int_val = malloc(l * sizeof(int));
            for (int i = 0; i < l; ++i) {
                current_var_point[p].int_val[i] = value[i];
            }
            printf("\nVariable: %s, Value: %d\n", current_var_point[p].name, current_var_point[p].int_val[0]);

            break;
        }
        case 2: {
            double *value = (double *)v;
            current_var_point[p].dec_val = malloc(l * sizeof(double));
            for (int i = 0; i < l; ++i) {
                current_var_point[p].dec_val[i] = value[i];
            }
         printf("\nVariable: %s, Value: %lf\n", current_var_point[p].name, current_var_point[p].dec_val[0]);

            break;
        }
        case 3: {
            char **s = ((char**) v);
            current_var_point[p].str_val = malloc(l * sizeof(char**));
            for (int i = 0; i < l; ++i) {
                current_var_point[p].str_val[i] = s[i];
            }
            printf("\nVariable: %s, Value: %s\n", current_var_point[p].name, current_var_point[p].str_val[0]);

            break;
        }
        default:
            printf("\n** Error : Invalid data type.**\n");
    }
}

void scan_val(char *name, int p) {
    printf("Scan Variable %s\n", name);
    int index = find_v_indx(name);
    
    if (index == -1) {
        var_not_found(name);
    } else {
        if (p >= current_var_point[index].length) {
            printf("\n** Error :Variable Limit Crossed.**\n");
        } else {
            switch (current_var_point[index].type) {
                case 1:
                    scanf("%d", &current_var_point[index].int_val[p]);
                    
                    break;
                case 2:
                    scanf("%lf", &current_var_point[index].dec_val[p]);
                    break;
                case 3: {
                    char str[1000];
                    scanf("%s", str);
                    current_var_point[index].str_val[p] = strdup(str);
                    break;
                }
                default:
                    printf("\n** Error : Invalid data type. **\n");
            }
        }
    }
}


        void duplicate(char *name) {
        printf("\n*** Error : Variable : \"%s\" Repeated. ***\n", name);
    }

  
    void print_value(char *name) {
        int index = find_v_indx(name);
        if(index == -1) {
            var_not_found(name);
        } else {
            if(current_var_point[index].array_check) {

            } else {
                printf("Value of %s is: ", name);
                if(current_var_point[index].type == 1) {
                    printf("%d\n", current_var_point[index].int_val[0]);
                } else if(current_var_point[index].type == 2) {
                    printf("%lf\n", current_var_point[index].dec_val[0]);
                } else if(current_var_point[index].type == 3) {
                    printf("%s\n", current_var_point[index].str_val[0]);
                }
            }
        }
    }
    
    int get_function_index(char *name){
        for(int i = 0; i < TOT_FUN; ++i) {
            if(strcmp(funcptr[i].fname, name) == 0) {
                return i;
            }
        }
        return -1;
    }
    
    
%}

%error-verbose
%debug
%union {
	int integer;
	double real;
	char *string;
}

%token HEADER SINCOM MULCOM EOL MAIN
%token VAR ARROW READ SHOW
%token NUM_TYPE DECI_TYPE STR_TYPE OPTION CHANGE OTHER
%token NUM_VAL DECI_VAL STR_VAL STR_SHOW
%token POW SIN COS TAN LOG10 LOG2 LN ROOT
%token AND OR XOR NOT
%token INC DEC
%token LT GT EQUAL NEQUAL LEQUAL GEQUAL
%token IF ELIF ELSE
%token LOOP IN WHILE BY
%token FUN INVOKE

%type <integer> NUM_VAL if_blocks elif_block
%type <real> DECI_VAL statements statement assignment expr  POW SIN COS TAN LOG10 LOG2 LN ROOT Itr_loop while_loop
%type <string> VAR NUM_TYPE DECI_TYPE STR_TYPE STR_VAL

%nonassoc ELIF 
%nonassoc ELSE

%left INC DEC
%left AND OR XOR NOT
%left LT GT EQUAL NEQUAL LEQUAL GEQUAL
%left '+' '-'
%left '*' '/' '%'

%%
program:comment heads comment functions  MAIN '{' statements '}' { printf("^_^ Compilation Completed Successfully!! ^_^")} ;

heads: heads HEADER {  printf("Header Library Declared Here\n");  }
	| HEADER {  printf("Header Library Declared Here\n");  }
	
	;


comment : comment SINCOM
        | comment MULCOM
        | SINCOM
        | MULCOM
        | 
        ;

statements:
    {}
    |statements statement
;

statement: 
    EOL
    |statement EOL statement
    |SINCOM
    |MULCOM
    |input EOL
    |print EOL
    |declarations EOL
    |assignments EOL
    |strshow EOL
    |if_blocks {
        printf("\n  IF-ELSE Condition Returns: %d\n",$1);
    }
    |Itr_loop
    |while_loop
    |option_statement
    |function_call EOL
     |VAR '=' expr ';' {
     
        int index = find_v_indx($1);
        if (index != -1) {
            current_var_point[index].int_val[0] = $3;
            printf("\n Assigned %d to variable %s\n", current_var_point[index].int_val[0], $1);
        } else {
            var_not_found($1);
        }
    }
;

print:
    SHOW '(' output_variable ')' {}
;
output_variable:
    output_variable ',' VAR {
        print_value($3);
    }
    |VAR {
        print_value($1);

    }
;

input:
    READ '(' input_variable ')' {
    }
;
strshow:
   STR_SHOW '(' STR_VAL ')' {
printf("%s\n",$3);

   }
input_variable:
    input_variable ',' VAR {
        scan_val($3, 0);
    }
    |VAR {
        scan_val($1, 0);
    }
functions:functions function_declare|
			function_declare
            |
            ;

function_declare:
    FUN function_name '(' function_variable ')' ARROW return_types '{' statement '}' {
        if(function_declared_flag){
         printf("\n--> Function Declared Successfully <--\n"); 
         function_declared_flag=0;

        }
    else {
        printf("\n **Error :Function didnot created **\n");
    }
    }
;
return_types:
    NUM_TYPE
    |DECI_TYPE
    |STR_TYPE
;

function_name:
    VAR {
        int index = get_function_index($1);
        if (index != -1) {
            printf("\nError: Function '%s' already declared.\n", $1);
            // Handle the error as needed, maybe exit or recover
        } else {
            function_declared_flag =1 ;
            printf("\n -->Declaring Function: %s\n", $1);
            funcptr[TOT_FUN].fname = malloc((strlen($1) + 1) * sizeof(char));
            strcpy(funcptr[TOT_FUN].fname, $1);
            funcptr[TOT_FUN].var_cnt = 0;
            funcptr[TOT_FUN].fptr = malloc(4 * sizeof(fun_detail));
            TOT_FUN++;
        }
    }

function_variable:
    |function_variable ',' single_variable
    | single_variable
;

single_variable:
    NUM_TYPE VAR {
        if (TOT_FUN > 0) {
            int index = funcptr[TOT_FUN - 1].var_cnt;
            int value = 0;
            save_val($2, 1, 1, TOT_VAR, &value, 0);
            funcptr[TOT_FUN - 1].fptr[index] = current_var_point[TOT_VAR];
            TOT_VAR++;
            funcptr[TOT_FUN - 1].var_cnt++;
        } else {
            printf("\n**Error: No function declared to add variables to. **\n");
            
        }
    }
    | DECI_TYPE VAR {
        if (TOT_FUN > 0) {
            int index = funcptr[TOT_FUN - 1].var_cnt;
            double value = 0;
            save_val($2, 2, 1, TOT_VAR, &value, 0);
            funcptr[TOT_FUN - 1].fptr[index] = current_var_point[TOT_VAR];
            TOT_VAR++;
            funcptr[TOT_FUN - 1].var_cnt++;
        } else {
            printf("\n**Error: No function declared to add variables to.**\n");
            
        }
    }
;
function_call:
    INVOKE user_function_name '(' parameters ')' {
        if (fun_rej) {
            printf("\n** Error: Function Not Declared. **\n");
        } else {
            printf("\n-->Function Successfully Called.<--\n");
           
        }
    }
;

user_function_name:
    VAR {
        int index = get_function_index($1);
        if (index == -1) {
            printf("\n**Error: Function '%s' Doesn't Exist. **\n", $1);
            fun_rej = 1;
        } else {
            current_function = index;
            tot_param = 0;
            fun_rej = 0;
        }
    }
;

parameters:
    parameters ',' single_parameter
    | single_parameter
;

single_parameter: 
    VAR {
        int index = find_v_indx($1);
        if (fun_rej) {
           
        } else if (tot_param >= funcptr[current_function].var_cnt) {
            printf("\n**Error: Way too many arguments.**\n");
            fun_rej = 1;
        } else if (funcptr[current_function].fptr[tot_param].type != current_var_point[index].type) {
            printf("\n**Error: Data Types Don't Match.**\n");
            fun_rej = 1;
        } else {
            tot_param++;
        }
    }
;

Itr_loop:
  LOOP  VAR IN '(' expr ARROW expr BY expr ')' '{' statements '}' {
        printf("\n--> Loop Started <--\n");
        int from = $5 ,to =$7 ,inc =$9;
      
        int range = to - from;
        if (range * inc < 0) {
            printf("**Error :Iterate infinitely**\n");
        } else {
          
            for (int i = from,u=1; i <= to; i += inc) {
                printf("Loop Iteration NO : %d\n", u);
                u++;
                  $$ =$12 ;
            }
            printf("Loop Iteration ENDED\n");

          
        }
    }
while_loop:
    WHILE '(' expr ')' '{' statements '}' {
        printf("<--WHILE BLOCK Executes Successfully-->\n");
          $$ = $6
    }
;



option_statement: CHANGE ARROW '{' options '}'
	{
		op=0;
		printf("\n-->Change ENDED<--");
	};
	

options: options option
		| option
		;

option: OPTION expr ARROW statements {
							if($2)
							{
								printf("\n-->Option Matched<--\n" ); 
								op = 1 ;
							}
						}

	|OTHER ARROW statements { if(op==0)
							{
								printf("\n-->No Option Matched<--\n");
								op=0;
							}
						}
	;



if_blocks:
    IF '(' expr ')' '{' if_blocks '}' elif_block {
        if ($3) {
            $$ = $6; 
        } else {
            $$ = $8; 
        }
    }
    | IF '(' expr ')' '{' if_blocks '}' {
        if ($3) {
            $$ = $6;
        }
    }
    | expr   {
        $$ = $1;
    }
    ;

elif_block:
    ELIF '(' expr ')' '{' if_blocks '}' elif_block {
          if ($3) {
            $$ = $6; 
        } else {
            $$ = $8; 
        }
    }
    | ELSE '{' if_blocks '}' {
        $$ = $3;
    }
    | ELIF '(' expr ')' '{' if_blocks '}' {
        if ($3) {
            $$ = $6;
        }
    }
    ;

declarations: NUM_TYPE num_vars |DECI_TYPE dec_vars|STR_TYPE str_vars ;

str_vars: str_vars ',' str_var|str_var;

str_var:
    VAR '=' STR_VAL {
        int exists = unique($1);
        if(exists == -1) {  duplicate($1); } 
        else { char *value = $3;
            save_val($1, 3, 1, TOT_VAR, &value, 0);
            TOT_VAR++;
        }
    }
    |VAR {
        char *value = "";
        save_val($1, 3, 1, TOT_VAR, &value, 0);
        TOT_VAR++;
    }
dec_vars:  dec_vars ',' dec_var |dec_var ;
dec_var:
    VAR '=' expr {
        if(unique($1) == -1) {
            duplicate($1);
        } else {  double value = $3;
            save_val($1, 2, 1, TOT_VAR, &value, 0);
            TOT_VAR++;
        }
    }
    |VAR {
        double value = 0.0;
        save_val($1, 2, 1, TOT_VAR, &value, 0);
        TOT_VAR++;
    }

num_vars: 
    num_vars ',' num_var
    |num_var
;

num_var: 
    VAR '=' expr {
        if(unique($1) == 1) {
            int value = $3;
            save_val($1, 1, 1, TOT_VAR, &value, 0);
            TOT_VAR++;
        } else {
            duplicate($1);
        }
    }
    |VAR {
        int value = 0;
        save_val($1, 1, 1, TOT_VAR, &value, 0);
        TOT_VAR++;
    }
;

assignments:
    assignments ',' assignment
    |assignment
;

assignment:
    VAR '=' expr {
        int i = find_v_indx($1);
        if (i == -1) {
            var_not_found($1);
            $$ = 0;
        } else if (current_var_point[i].type == 1) {
            current_var_point[i].int_val[0] = $3; 
            $$ = current_var_point[i].int_val[0];

             printf("Variable name is: %s\n", current_var_point[i].name);
              printf("Updated value is: %d\n", *current_var_point[i].int_val);

        } else if (current_var_point[i].type == 2) {
            current_var_point[i].dec_val[0] = $3; 
            $$ = current_var_point[i].dec_val[0];
        }
    }
    ;

expr:
    NUM_VAL               { $$ = $1; }
    | DECI_VAL            { $$ = $1; }
    | VAR                 {  int i = find_v_indx($1);
                            if(i == -1) {
                            var_not_found($1);
                             $$ = 0;
                            } else if(current_var_point[i].type == 1) {
                                $$ = current_var_point[i].int_val[0];
                            } else if(current_var_point[i].type == 2) {
                               $$ = current_var_point[i].dec_val[0];
                                                                   } }
    | '+' expr            { $$ = $2; }
    | '-' expr            { $$ = -$2; }
    | INC expr            { $$ = $2; }
    | DEC expr            { $$ = $2; }
    | expr '+' expr       { $$ = $1 + $3; }
    | expr '-' expr       { $$ = $1 - $3; }
    | expr '*' expr       { $$ = $1 * $3; } 
    | expr '/' expr       { $$ = $1 / $3; }
    | expr '%' expr       { $$ = (int)$1 % (int)$3; }
    | expr POW expr       { $$ = pow($1, $3); }
    | expr EQUAL expr     { $$ = ($1 == $3); }
    | expr NEQUAL expr    { $$ = ($1 != $3); }
    | expr LT expr        { $$ = ($1 < $3); }
    | expr GT expr        { $$ = ($1 > $3); }
    | expr LEQUAL expr    { $$ = ($1 <= $3); }
    | expr GEQUAL expr    { $$ = ($1 >= $3); }
    | expr AND expr       { $$ = ($1 && $3); }
    | expr OR expr        { $$ = ($1 || $3); }
    | expr XOR expr       { $$ = ((int)$1 ^ (int)$3); }
    | NOT expr            { $$ = !$2; }
    | VAR INC             {      int index = find_v_indx($1);
                                if(index == -1) {
                               var_not_found($1);
                                } else if(current_var_point[index].type != 1) {
                                printf("Can't Increment Incompatible Types.\n");
                                     } else {
                                   current_var_point[index].int_val[0]++;
                            $$ = current_var_point[index].int_val[0];

                                                              } }
    | VAR DEC             {   int index = find_v_indx($1);
                               if(index == -1) {
                                  var_not_found($1);
                              } else if(current_var_point[index].type != 1) {
                               printf("Can't Increment Incompatible Types.\n");
                               } else {
                                current_var_point[index].int_val[0]--;
                             $$ = current_var_point[index].int_val[0];

                                                                } }
    | '(' expr ')'        { $$ = $2; }
    | LOG10 '(' expr ')'  { $$ = log10($3); }
    | LOG2 '(' expr ')'   { $$ = log2($3); }
    | LN '(' expr ')'     { $$ = log($3); }
    | ROOT '(' expr ')'   { $$ = sqrt($3); }
    | SIN '(' expr ')'    { $$ = sin($3); }
    | COS '(' expr ')'    { $$ = cos($3); }
    | TAN '(' expr ')'    { $$ = tan($3); }
   
    ;


%%
int main() {
    current_var_point = malloc(20 * sizeof(detail));

    funcptr = malloc(20 * sizeof(fun_detail));
    


    FILE *yyin = freopen("input.txt", "r", stdin);
    FILE *yyout = freopen("output.txt", "w", stdout);
    
    yyparse();


    fclose(yyin);
    fclose(yyout);
    
    free(current_var_point);
    free(funcptr);
    
    return 0;
}