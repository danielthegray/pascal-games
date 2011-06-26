unit word_cas;

interface
     uses crt;
     procedure capitalize(var a:string);
     function lowcase(a:char):char;
     procedure namecase(var a:string);

implementation
     procedure capitalize(var a:string);
     {procedure that capitalizes a string}
     var
        i:byte; {local variable}
     begin
          for i:=1 to length(a) do
          begin
               a[i]:=upcase(a[i]);
          end; {for}
     end; {capitalize}

     function lowcase(a:char):char;
         begin
              if (a in ['A'..'Z']) then lowcase:=chr((ord(a)-65)+97)
              else lowcase:=a;
         end;  {lowcase}

     procedure namecase(var a:string);
     var
        i:byte;
     begin
          a[1]:=upcase(a[1]);
          if (not(length(a)=1)) then
               for i:=2 to length(a) do a[i]:=lowcase(a[i]);
     end; {namecase}
end.