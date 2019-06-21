/* lexical grammar */
%lex

%%
\s+                         /* skip whitespace */
"//".*                      /* ignore comment */
"/*"([^*]|\*[^/])*"*/"     /* ignore comment */

"si"                                return 'SI';
"entonces"                          return 'ENTONCES';
"sino"                              return 'SINO';
"fin si"                            return 'FINSI';

"mientras"                          return 'MIENTRAS';
"fin mientras"                      return 'FINMIENTRAS';
"hacer"                             return 'HACER';

"segun"                             return 'SEGUN';
"caso"                              return 'CASO';
"por defecto"                       return 'PORDEFECTO';
"fin segun"                         return 'FINSEGUN';
"romper"                            return "ROMPER";
"continuar"                         return "CONTINUAR";

"repetir"                           return 'REPETIR';
"que"                               return 'QUE';

"para"                              return 'PARA';
"cada"                              return 'CADA';
"hasta"                             return 'HASTA';
"fin para"                          return 'FINPARA';

"funcion"                           return 'FUNCION';
"devolver"                          return'DEVOLVER';
"fin funcion"                       return 'FINFUNCION';

//booleanos
'verdadero'          return 'TRUE'
'falso'              return 'FALSE'

//Para la Consola/Terminal
'leer'                  return 'LEER';
'imprimir'              return 'IMPRIMIR';

([a-zA-Z_])?'"'('.'|[^'"'])*'"'	 return 'STRING_LITERAL';

//SIMBOLO APUNTADOR
"->"                    return '->';

//RELACIONALES
"=="                    return '==';
("!="|"<>")             return '!=';
">="                    return '>=';
"<="                    return '<=';
">"                     return '>';
"<"                     return '<';


//ASIGNACION (CON POSIBLE OPERACION)
("/"|"*"|"+"|"-"|"%")?"="    return '=';

//LOGICOS
("&&")                  return 'AND';
("||")                  return 'OR';
("!")                   return 'EXCL';

//ALGEBRAICOS
"/"                     return '/';
"-"                     return '-';
"+"                     return '+';
("^"|"**")              return '^';
"*"                     return '*';
("%"|"MOD")             return 'MOD';

//SIMBOLOS
"{"                     return '{';
"}"                     return '}';
"["                     return '[';
"]"                     return ']';
"("                     return '(';
")"                     return ')';

//CARACTERES IMPORTANTES
":"                     return ':';
","                     return ',';
'"'                     return '"'; //SOLO se admiten comillas dobles en este lenguaje
"'"                     return "'"; //Sin embargo, puede haber una en los literales ;)

//

[0-9]+("."[0-9]+)?\b            return 'NUMERO';
("_"|"$")?[a-zA-Z_][a-zA-Z0-9_]*  return 'ID';


<<EOF>>               return 'EOF';

.					  {};

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left MOD '^'
%left UMINUS
%left '(' ')'
%left AND, OR, EXCL

%start Programa

%% /* language grammar */

Programa
    : ListaSentencias EOF       { console.log($1); return "(function(){"+$1+" "+NewLineMark(@2)+"})(); " }
    ;

ListaSentencias
    : {{ $$ = ''; }}
    | Sentencia ListaSentencias { $$ = [NewLineMark(@1), $1, $2].join("\n"); }
    ;

Sentencia
    : SentAsignacion
    | SentFuncion
    | SentSi
    | SentPara
    | SentMientras
    | SentSegun         
    | SentRepetir       
    | SentEstructura
    | SentImprimir
    | SentLeer
    | SentDevolver
    | SentRomperContinuar
    | SentLLamadaFuncion        { $$ = $1+";"; }
    ;

SentDevolver
    : DEVOLVER ValorAsignado    { $$ = 'return '+$2+';'; }
    ;
    
SentRomperContinuar
    : ROMPER        { $$ = 'break;'; }
    | CONTINUAR     { $$ = 'continue;'; }
    ;

SentImprimir
    :   IMPRIMIR Output         { $$ = 'imprimir('+$2+');'; }
    ;
    
Output
    : ValorAsignado ',' Output  {{ $$ = $1+", "+$3; }}
    | ValorAsignado             {{ $$ = $1; }}
    ;

SentLeer
    :   LEER IdOApuntador       {
                                    if($2.indexOf(']') != -1){
                                        $$ =  "";
                                        match = /\[[0-9]+\-[0-9]+\]/.exec($2);
                                        if(match != null && match.length){
                                            match.map(function(m){
                                                var number = m.replace('[', '').replace(']', '').split('-').map(Number);
                                                $2 = $2.replace(m, '['+(number[0] - number[1])+']');
                                            });
                                        }
                                    }else{
                                        $$ =  "if(!"+$2+") var "+$2+"; ";
                                    }
                                    $$ += $2+" = leer('"+escape($2)+"');";
                                }
    ;


/*
    JEAN BENITEZ: [23/OCTUBRE/2015]
    Ahora mismo, las variables globales no se pueden acceder desde una funcion
    Y ésto es por la palabra reservada 'var' que hace que la variable se haga local en la funcion
    entonces si una variable global tiene ese mismo nombre, no podrá ser reescrita desde la funcion
    pero si va a poder ser accedida.
    Para que pueda ser reescrita, solo es quitar la palabra 'var' y descomentar las funciones 'existe' y 'defvar'
*/
SentAsignacion
    : ID '=' ValorAsignado              { tmp = String(Date.now()); $$ = "/*if(!existe('"+$1+"')){ defvar('"+$1+"'); }*/ defvar2('"+$1+"'); /*assignvar('"+$1+"', "+$3+");*/   "+$1+" "+$2+" "+$3+";   NodoModif('"+$1+"'); "; }
//    | ID '=' MALLOC                     { tmp = String(Date.now()); $$ = "/*if(!existe('"+$1+"')){ defvar('"+$1+"'); }*/ defvar2('"+$1+"'); /*assignvar('"+$1+"', malloc());*/ "+$1+"=  malloc(); NodoModif('"+$1+"'); "; }
    | ID '->' ID  '=' ValorAsignado     { $$ = $1+"['"+$3+"'] "+$4+" "+$5+";  NodoModif('"+$1+"');"; }
    | ID '[' ValorAsignado  ']'  '=' ValorAsignado                              { $$ = $1+"["+$3+"-1] "+$5+" "+$6+";"; }
    | ID '[' ValorAsignado  ']' '[' ValorAsignado  ']'  '=' ValorAsignado       { $$ = $1+"["+$3+"-1]["+$6+"-1] "+$8+" "+$9+";"; }
    ;
    
    
SentLLamadaFuncion
    : ID '(' ListaParametros ')'            { $$ = $1+'('+$3+')'; }
    ;
    
IdOApuntador
    : ID                                                        { $1 = new String($1); $1.esID = true; $$ = $1; }
    | ID '->' ID                                                { $$ = $1+"['"+$3+"']";  }
    | ID '[' ValorAsignado  ']'                                 { $$ = $1+"["+$3+"-1]"; }
    | ID '[' ValorAsignado  ']' '[' ValorAsignado  ']'          { $$ = $1+"["+$3+"-1]["+$6+"-1]"; }
    ;


ValorAsignado
    : Condicion
    ;

SentFuncion
    : FUNCION ID '(' ListaParametrosFuncion ')' HACER ListaSentencias FINFUNCION { $$ =  "var "+$2+" = function("+$4+"){"+$7+"};" }
    ;

ListaParametrosFuncion
    :   {{ $$ = ''; }}
    | ID ListaParametrosFuncionContinua    { $$ = $1+$2; }
    ;

ListaParametrosFuncionContinua
    :   {{ $$ = ''; }}
    | ',' ID ListaParametrosFuncionContinua    { $$ = ", "+$2+$3; }
    ;

ListaParametros
    :   {{ $$ = ''; }}
    // Sirve para pasar como referencia elementos de vis.js (ingeniado esto tambien por mi, seee)
    | ValorAsignado ListaParametrosContinua {
                                                //if($1.esID){
                                                //    $$ = " InjectParams("+$1+", '"+$1+"')"+$2;
                                                //    //$$ = "(("+$1+"['ref'] = '"+escape($1)+"') !== '"+escape($1)+"' || "+$1+")"+$2;
                                                //}else
                                                $$ = $1+$2;
                                            }
    ;

ListaParametrosContinua
    :   {{ $$ = ''; }}
    | ',' ValorAsignado ListaParametrosContinua {
                                                    $$ = ", ";
                                                    //if($2.esID){
                                                    //    $$ += " InjectParams("+$2+", '"+$2+"')"+$3;
                                                    //    //$$ += "(("+$2+"['ref'] = '"+escape($2)+"') !== '"+escape($2)+"' || "+$2+")"+$3;
                                                    //}else
                                                    $$ += $2+$3;
                                                }
    ;

SentSi
    : SI Condicion ENTONCES ListaSentencias SentSino FINSI  { $$ = "if("+$2+"){"+$4+"}"+$5; }
    ;

SentSino
    :   {{ $$ = ''; }}
    | SINO ListaSentencias              {$$ = "else{"+$2+"}";}
    ;

SentPara
    : PARA ID '=' ValorAsignado HASTA Expresion HACER ListaSentencias FINPARA 
        %{
            $$ = "for(var "+$2+" = "+$4+"; "+$2+" <= "+$6+" ; "+$2+"++){ "+$8+" }";
        %}
    | PARA CADA ID ',' IdOApuntador HACER ListaSentencias FINPARA 
        %{
            $$ = "for(var "+$3+" in ("+$5+".split ? "+$5+".split('') : "+$5+")){ "+$3+" = "+$5+"["+$3+"]; "+$7+" }";
        %}
    ;

MasOMenos
    : '+' {$$ = '+';}
    | '-' {$$ = '-';}
    ;

SentMientras
    : MIENTRAS Condicion HACER ListaSentencias FINMIENTRAS      {$$ = "while("+$2+"){"+$4+"}";}
    ;

SentRepetir
    : REPETIR ListaSentencias HASTA QUE Condicion        {$$ = "do{"+$2+"}while(!("+$5+"));";}
    ;

SentSegun
    : SEGUN Condicion HACER ListaCasos FINSEGUN        {$$ = "switch("+$2+"){"+$4+"}";}
    ;
    
ListaCasos
    :
    | CASO ExpresionMatematica ":" ListaSentencias ListaCasos       {$$ = "case "+$2+": "+$4+" break;"+$5;}
    | PORDEFECTO ":" ListaSentencias ListaCasos                     {$$ = "default: "+$3+" break;"+$4;}
    ;

Condicion
    : Expresion '==' Expresion           { $$ = $1+" === "+$3;  }   //Corrige BUG de JS-Interpreter
    | Expresion '!=' Expresion           { $$ = $1+" !== "+$3;  }
    | Expresion '>'  Expresion           { $$ = $1+" "+$2+" "+$3;  }
    | Expresion '<'  Expresion           { $$ = $1+" "+$2+" "+$3;  }
    | Expresion '>=' Expresion           { $$ = $1+" "+$2+" "+$3;  }
    | Expresion '<=' Expresion           { $$ = $1+" "+$2+" "+$3;  }
    | EXCL Condicion                     { $$ = "(!"+$2+")";  }
    | Condicion AND Condicion            { $$ = $1+" "+$2+" "+$3;  }
    | Condicion OR Condicion             { $$ = $1+" "+$2+" "+$3;  }
    | Expresion                          { $$ = $1; }
    ;

Expresion
    : ExpresionMatematica       { $$ = $1; }
    | ExpresionLogica           { $$ = $1; }
    ;

ExpresionMatematica
    : ExpresionMatematica '+' ExpresionMatematica       { $$ = $1+$2+$3; }
    | ExpresionMatematica '-' ExpresionMatematica       { $$ = $1+$2+$3; }
    | ExpresionMatematica '*' ExpresionMatematica       { $$ = $1+$2+$3; }
    | ExpresionMatematica '/' ExpresionMatematica       { $$ = $1+$2+$3; }
    | ExpresionMatematica MOD ExpresionMatematica       { $$ = $1+$2+$3; }
    | ExpresionMatematica '^' ExpresionMatematica       { $$ = "Math.pow("+$1+","+$3+")"; }
    | '-' ExpresionMatematica %prec UMINUS              { $$ = $1+$2; }
    | '(' ExpresionMatematica ')'                       { $$ = "("+$2+")"; }
    | IdOApuntador                                      { $$ = $1; }
    | SentLLamadaFuncion                                { $$ = $1; }
    | NUMERO                                            { $$ = yytext; }
    | Literal
    ;

ExpresionLogica
    : TRUE          { $$ = "true"; }
    | FALSE         { $$ = "false"; }
    ;

Literal
    : STRING_LITERAL       {$$ = ""+$1+"";}
    ;

%%

var NewLineMark = function(pos){
    return "NewLineMark(" +
        (pos.first_line-1) +
        ", " +
        (pos.first_column) +
        ", " +
        (pos.last_line-1 ) +
        ", " +
        pos.last_column +
        ");";
};