%{
	#include <stdio.h>
     #include <string.h>

	int yylex();
	int yyerror(const char *msg);

     int EsteCorecta = 1;
	char msg[500];

class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}



%union { char* sir; int val; }




%token TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIV TOK_LEFT TOK_RIGHT TOK_DECLARE TOK_ERROR TOK_ASIGN TOK_PROGRAM TOK_BEGIN TOK_END TOK_INTEGER TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token <val> TOK_NUMBER
%token <sir> TOK_VARIABLE

%type <val> exp factor term
%type <sir> id_list


%locations 

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%
prog : TOK_PROGRAM prog_name TOK_DECLARE dec_list TOK_BEGIN stmt_list TOK_END '.'
		|
		error 

	{
		EsteCorecta=0;
	}
;

prog_name: TOK_VARIABLE
;

dec_list: dec
	   |
	  dec_list ';' dec
;

dec: id_list ':' type
{
	char*aux=strtok($1,",");
	while(aux!=NULL)
	{
		if(ts != NULL)
	{
	  if(ts->exists(aux) == 1)
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s are initializari multiple ", @1.first_line, @1.first_column, aux);
	    yyerror(msg);
	    YYERROR;
	  }
	  else
	  {
	  	ts->add(aux);
	  }
	}
	else
	{
		ts=new TVAR();
		ts->add(aux);
	}
	aux=strtok(NULL,",");
	}
}
;

type: TOK_INTEGER
;

id_list: TOK_VARIABLE
{
	
}
	  |
	id_list ',' TOK_VARIABLE
	{
		strcat($$,",");
		
		strcat($$,$3);
	}
	|
	
	error
	   {
	   EsteCorecta=0;
	   }
	;
stmt_list: stmt
	    |
	   stmt_list ';' stmt
	   

;

stmt: assign
	|
	read
	|
	write
	|
	for
	|
	error
	   {
	   EsteCorecta=0;
	   }
;

assign: TOK_VARIABLE TOK_ASIGN exp
{
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1, $3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }

; 

exp: term
{
	$$=$1;
}
	|
	exp TOK_PLUS term
	{
		$$=$1+$3;
	}
	|
	exp TOK_MINUS term
	{
		$$=$1-$3;
	}
;

term: factor {$$=$1;}
	|
     term TOK_MULTIPLY factor
     {
     	$$=$1*$3;
     }
	|
     term TOK_DIV factor
     {
     	if($3 !=0)
     	{
     		$$=$1/$3;
     	}
     	else
     	{
     		sprintf(msg,"%d:%d Eroare semantica: Nu se poate imparti la 0!", @1.first_line, @1.first_column);
	    yyerror(msg);
	    YYERROR;
     	}
     }
;

factor: TOK_VARIABLE
{
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    $$=ts->getValue($1);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }

	|
	TOK_NUMBER
	{
		$$=$1;
	}
	|
	TOK_LEFT exp TOK_RIGHT
	{
		$$=$2;
	}
;

read: TOK_READ TOK_LEFT id_list TOK_RIGHT
{
if(ts != NULL)
	{
	  if(ts->exists($3) == 1)
	  {
	   
	   // printf("Dati un numar de la tastatura:\n");
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	  yyerror(msg);
	  YYERROR;
	}
}
      
;

write: TOK_WRITE TOK_LEFT id_list TOK_RIGHT
{
	if(ts != NULL)
	{
	  if(ts->exists($3) == 1)
	  {
	    if(ts->getValue($3) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $3);
	      yyerror(msg);
	      YYERROR;
	    }
	    else
	    {
	      //printf("%d\n",ts->getValue($3));
	    }
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $3);
	  yyerror(msg);
	  YYERROR;
	}
}
;

for: TOK_FOR index_exp TOK_DO body
;

index_exp: TOK_VARIABLE TOK_ASIGN exp TOK_TO exp
{
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1,$3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      
}
;

body: stmt
	|
	TOK_BEGIN stmt_list TOK_END
;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	
	else
	{
		printf("GRESITA\n");
	}

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	EsteCorecta=0;
	return 1;
}
