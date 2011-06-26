unit swap_var;

interface
    uses crt;
    procedure change_str(var a,b:string);
    procedure change_num(var a,b:real);
    procedure change_bool(var a,b:boolean);
    procedure change_char(var a,b:char);

implementation
    procedure change_str(var a,b:string);
    var
       aux : string;
    begin
         aux := a;
         a   := b;
         b   := aux;
    end;

    procedure change_num(var a,b:real);
    var
       aux : real;
    begin
         aux := a;
         a   := b;
         b   := aux;
    end;

    procedure change_bool(var a,b:boolean);
    var
       aux : boolean;
    begin
         aux := a;
         a   := b;
         b   := aux;
    end;

    procedure change_char(var a,b:char);
    var
       aux : char;
    begin
         aux := a;
         a   := b;
         b   := aux;
    end;
end.