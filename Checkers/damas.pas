Program Damas;
{ por Daniel Gray }
{ Junio 2005 }

uses
    Crt,
    Graph,
    Swap_Var;

type
    Table  = array[1..8, 'A'..'H'] of ShortInt;
    Column = array['A'..'H'] of ShortInt;

const
     C1: Column = (3, -1, 3, -1, 0, -1, 1, -1);
     C2: Column = (-1, 3, -1, 0, -1, 1, -1, 1);

var
   Board: Table;
   grDriver: Integer;
   grMode: Integer;
   Nam1, Nam2, Who: String;
   Let1, Let2, X, Y: Char;
   Num1, Num2, Player: ShortInt;
   Instruc, CaptPoss, Error: Boolean;
   Code, ErrCode: Integer;

label CoordInput;

procedure Beep;
{
este procedimiento hace que el altavoz interno emita un sonido
de 800 Hz que dura 0.25 segundos
}
begin
     Sound(800);
     Delay(250);
     NoSound;
end;

procedure TitleScreen;
{
Es solo como una pantalla de introduccion donde dice el nombre del juego
y del que lo program¢
}
begin
     SetColor(15);
     SetBkColor(1);
     ClearViewPort;
     SetTextStyle(1, HorizDir, 10);
     SetTextJustify(CenterText, CenterText);
     OutTextXY(320, 100,'DAMAS');
     SetTextStyle(7, HorizDir, 5);
     OutTextXY(320, 250, 'POR');
     SetTextStyle(4, HorizDir, 8);
     OutTextXY(320, 350, 'Daniel Gray');
end;

procedure DrawBoard;
var
   Letter: Char;
   Number: Byte;
begin
     SetFillStyle(1,4);
     SetTextStyle(6, HorizDir, 3);
     SetColor(4);
     SetBkColor(0);
     ClearViewPort;
     Rectangle(0,0,288,291);
     Bar(0,0,36,35);
     Bar(73,0,107,35);
     Bar(144,0,179,35);
     Bar(216,0,251,35);
     Bar(36,36,72,72);
     Bar(108,36,144,72);
     Bar(180,36,216,72);
     Bar(252,36,288,72);
     Bar(0,73,36,109);
     Bar(73,73,108,109);
     Bar(145,73,180,109);
     Bar(216,73,252,109);
     Bar(37,110,72,145);
     Bar(109,110,144,146);
     Bar(180,110,216,146);
     Bar(252,110,288,146);
     Bar(0,146,36,183);
     Bar(73,146,108,183);
     Bar(144,147,180,183);
     Bar(217,147,251,183);
     Bar(37,184,72,219);
     Bar(108,184,144,219);
     Bar(181,184,216,219);
     Bar(252,184,288,219);
     Bar(0,220,36,255);
     Bar(72,220,108,255);
     Bar(144,220,180,255);
     Bar(216,220,252,255);
     Bar(37,255,72,291);
     Bar(108,255,144,291);
     Bar(180,255,216,291);
     Bar(252,255,288,291);
     SetTextJustify(CenterText, CenterText);
     SetColor(15);
     OutTextXY(18, 306, '1');
     OutTextXY(54, 306, '2');
     OutTextXY(90, 306, '3');
     OutTextXY(126, 306, '4');
     OutTextXY(162, 306, '5');
     OutTextXY(198, 306, '6');
     OutTextXY(234, 306, '7');
     OutTextXY(270, 306, '8');
     OutTextXY(309, 18, 'A');
     OutTextXY(309, 54, 'B');
     OutTextXY(309, 90, 'C');
     OutTextXY(309, 126, 'D');
     OutTextXY(309, 162, 'E');
     OutTextXY(309, 198, 'F');
     OutTextXY(309, 234, 'G');
     OutTextXY(309, 270, 'H');
end;

function MovePoss(var Board: Table; X: ShortInt; Y: Char): Boolean;
{
Esta funci¢n nos dice si la piece con las coordenadas X,Y puede moverse.
}
var
   Piece: ShortInt;
begin
     Piece := Board[X, Y];
     case Piece of
          -1: MovePoss := False;
           0: MovePoss := False;
           1: MovePoss := (Board[Pred(X), Pred(Y)] = 0) or
                          (Board[Succ(X), Pred(Y)] = 0);
           2: MovePoss := (Board[Pred(X), Pred(Y)] = 0) or
                          (Board[Pred(X), Succ(Y)] = 0) or
                          (Board[Succ(X), Pred(Y)] = 0) or
                          (Board[Succ(X), Succ(Y)] = 0);
           3: MovePoss := (Board[Pred(X), Succ(Y)] = 0) or
                          (Board[Succ(X), Succ(Y)] = 0);
           4: MovePoss := (Board[Pred(X), Pred(Y)] = 0) or
                          (Board[Pred(X), Succ(Y)] = 0) or
                          (Board[Succ(X), Pred(Y)] = 0) or
                          (Board[Succ(X), Succ(Y)] = 0);
     end;
end;

procedure InstructionScreen;
{
Este procedimiento muestra las instrucciones a los jugadores,
junto con algunos ejemplos.
}
var
   Y: ShortInt;
begin
     RestoreCrtMode;
     TextColor(15);
     TextBackground(1);
     ClrScr;
     WriteLn('ÛßßßßßßßßßßßßßßßßßßßßßßßßÛ');
     WriteLn('Û INSTRUCCIONES DE DAMAS Û');
     WriteLn('ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ');
     WriteLn;
     WriteLn('Damas es un juego para dos personas.');
     WriteLn('Cada jugador tiene 12 piezas. On conjunto es rojo y el otro es');
     WriteLn('gris.  Las piezas se pueden mover s¢lo diagonalmente, un cuadrado');
     WriteLn('a la vez, hacia el lado del otro jugador.');
     WriteLn('El objetivo del juego es capturar todas las piezas enemigas.');
     WriteLn('Puedes capturar una pieza saltando sobre ella, y esa pieza ser ');
     WriteLn('eliminada.  Al capturar, tambi‚n debes moverte diagonalmente,');
     WriteLn('Tienes que saltar desde el cuadrado adyacente a tu objetivo y ');
     WriteLn('aterrizar al otro lado diagonalmente.  El cuadrado al otro lado');
     WriteLn('debe estar vac¡o.  Si puedes capturar a una pieza en un turno,');
     WriteLn('Si puedes capturar a varias piezas seguidamente con la misma pieza');
     WriteLn('debes hacerlo.  Si logras que una de tus piezas llegue a la £ltima');
     WriteLn('fila del lado de tu oponente, esta pieza se vuelve una reina.  Un');
     WriteLn('c¡rculo amarillo aparecer  sobre tal pieza.  Ahora esa pieza puede');
     WriteLn('moverse y capturar hacia adelante o atr s, pero siempre diagonalmente.');
     Write('Presiona cualquier tecla para continuar');
     Delay(200);
     if KeyPressed then ReadKey;
     ReadKey;
     SetGraphMode(2);
     SetColor(4);
     SetBkColor(0);
     SetFillStyle(1, 4);
     SetTextJustify(LeftText, CenterText);
     SetTextStyle(6, HorizDir, 3);
     PieSlice(18, 18, 0, 360, 10);
     SetColor(15);
     OutTextXY(40, 18, 'Esta es una pieza roja');
     SetColor(4);
     SetFillStyle(1, 4);
     PieSlice(18, 54, 0, 360, 10);
     SetColor(14);
     SetFillStyle(1, 14);
     PieSlice(18, 54, 0, 360, 5);
     SetColor(15);
     OutTextXY(40, 54, 'Esta es una pieza roja que es reina');
     SetColor(7);
     SetBkColor(0);
     SetFillStyle(1, 7);
     PieSlice(18, 90, 0, 360, 10);
     SetColor(15);
     OutTextXY(40, 90, 'Esta es una pieza gris');
     SetColor(7);
     SetBkColor(0);
     SetFillStyle(1, 7);
     PieSlice(18, 126, 0, 360, 10);
     SetColor(14);
     SetFillStyle(1, 14);
     PieSlice(18, 126, 0, 360, 5);
     SetColor(15);
     OutTextXY(40, 126, 'Esta es una pieza gris que es reina');
     OutTextXY(18, 162, 'Presiona cualquier tecla para continuar');
     Delay(200);
     if Keypressed then ReadKey;
     ReadKey;
     DrawBoard;
     SetTextJustify(LeftText, TopText);
     OutTextXY(18, 350, 'Para introducir las coordenadas, presiona un n£mero y luego una letra');
     Delay(4000);
     OutTextXY(18, 380, 'Por ejemplo, "3H" est  en el punto negro.');
     SetColor(9);
     SetFillStyle(1, 9);
     PieSlice(((3-1)*36)+18, ((Ord('H')-65)*36)+18, 0, 360, 10);
     Delay(3500);
     SetColor(15);
     OutTextXY(18, 410, '"4E" est  en el punto verde.');
     SetColor(2);
     SetFillStyle(1, 2);
     PieSlice(((4-1)*36)+18, ((Ord('E')-65)*36)+18, 0, 360, 10);
     SetColor(15);
     OutTextXY(17, 440, 'Presiona cualquier tecla para continuar');
     ReadKey;
     DrawBoard;
     SetColor(4);
     SetFillStyle(1, 4);
     PieSlice(((4-1)*36)+18, ((Ord('E')-65)*36)+18, 0, 360, 10);
     SetColor(15);
     SetTextJustify(LeftText, TopText);
     OutTextXY(18, 350, 'Para mover una pieza de "4E" a "5D":');
     Delay(3500);
     OutTextXY(350, 36, '4');
     Delay(1000);
     OutTextXY(368, 36, 'E  A');
     Delay(1500);
     OutTextXY(423, 36, '  5');
     Delay(1000);
     OutTextXY(455, 36, 'D');
     Delay(1000);
     SetColor(4);
     PieSlice(((5-1)*36)+18, ((Ord('D')-65)*36)+18, 0, 360, 10);
     SetColor(0);
     SetFillStyle(1, 0);
     PieSlice(((4-1)*36)+18, ((Ord('E')-65)*36)+18, 0, 360, 10);
     SetColor(15);
     OutTextXY(18, 380, 'Press any key to Exit.');
     if Keypressed then ReadKey;
     ReadKey;
end;

procedure KingCheck(var Board: Table);
{
This only checks to see if there are any pieces that have reached the
last row so that they can be crowned and move in any direction
}
begin
     if (Board[2,'A'] = 1) then Board[2,'A'] := 2;
     if (Board[4,'A'] = 1) then Board[4,'A'] := 2;
     if (Board[6,'A'] = 1) then Board[6,'A'] := 2;
     if (Board[8,'A'] = 1) then Board[8,'A'] := 2;
     if (Board[1,'H'] = 3) then Board[1,'H'] := 4;
     if (Board[3,'H'] = 3) then Board[3,'H'] := 4;
     if (Board[5,'H'] = 3) then Board[5,'H'] := 4;
     if (Board[7,'H'] = 3) then Board[7,'H'] := 4;
end;

procedure NameInput(var Nam1, Nam2: String; var Instruc: Boolean);
{
Everything this does is input the player's names and see if they want to see
the instructions
}
var
   Option, Choice, Choice2: Char;
   Rand: Integer;
begin
     RestoreCrtMode;
     TextColor(15);
     TextBackground(1);
     ClrScr;
     GotoXY(1,5);
     Write('Player A, please input your name. ');
     ReadLn(Nam1);
     Write('Player B, please input your name. ');
     ReadLn(Nam2);
     WriteLn('Who Starts?');
     Delay(750);
     if KeyPressed then ReadKey;
     WriteLn('Do you want the computer to decide? (Y/N)');
     repeat
           Choice := UpCase(ReadKey);
           if Not(Choice in ['Y', 'N']) then Beep;
     until (Choice in ['Y', 'N']);
     if (Choice = 'Y') then
     begin
          Rand := Random(10+1);
          Delay(750);
          if KeyPressed then ReadKey;
          if (Rand>5) then Change_Str(Nam1, Nam2);
     end
     else
     begin
          WriteLn('Press:');
          WriteLn('1 for ', Nam1, ' to start.');
          WriteLn('2 for ', Nam2, ' to start.');
          repeat
                Choice2 := ReadKey;
                if Not(Choice2 in ['1', '2']) then Beep;
          until (Choice2 in ['1', '2']);
          if (Choice2 = '2') then Change_Str(Nam1, Nam2);
     end;
     WriteLn(Nam1, ' starts.');
     WriteLn;
     Write('Do you want instructions? (Y/N)');
     repeat
           Option := UpCase(ReadKey);
           if Not(Option in ['Y', 'N']) then Beep;
     until (Option in ['Y', 'N']);
     Instruc := (Option = 'Y');
     Delay(500);
     SetGraphMode(2);
end;

procedure BoardSetup(var Board: Table);
var
   CX: Boolean;
   F: Char;
   N: Integer;
begin
     CX := True;
     for N := 1 to 8 do
     begin
          if CX
             then
                 for F := 'A' to 'H' do Board[N, F] := C2[F]
             else
                 for F := 'A' to 'H' do Board[N, F] := C1[F];
          CX := Not CX;
     end;
end;

function Capture (var Board: Table; X: ShortInt; Y: Char) : Boolean;
var
   Piece: ShortInt;
begin
     Piece := Board[X, Y];
     case Piece of
          -1:  Capture := False;
           0:  Capture := False;
           1:  Capture := ((Board[Pred(X), Pred(Y)] in [3, 4]) and
                           (Board[Pred(Pred(X)), Pred(Pred(Y))] = 0)) or
                          ((Board[Succ(X), Pred(Y)] in [3, 4]) and
                           (Board[Succ(Succ(X)), Pred(Pred(Y))] = 0));
           2:  Capture := ((Board[Pred(X), Pred(Y)] in [3, 4]) and
                           (Board[Pred(Pred(X)), Pred(Pred(Y))] = 0)) or
                          ((Board[Pred(X), Succ(Y)] in [3, 4]) and
                           (Board[Pred(Pred(X)), Succ(Succ(Y))] = 0)) or
                          ((Board[Succ(X), Pred(Y)] in [3, 4]) and
                           (Board[Succ(Succ(X)), Pred(Pred(Y))] = 0)) or
                          ((Board[Succ(X), Succ(Y)] in [3, 4]) and
                           (Board[Succ(Succ(X)), Succ(Succ(Y))] = 0));
           3:  Capture := ((Board[Pred(X), Succ(Y)] in [1, 2]) and
                           (Board[Pred(Pred(X)), Succ(Succ(Y))] = 0)) or
                          ((Board[Succ(X), Succ(Y)] in [1, 2]) and
                           (Board[Succ(Succ(X)), Succ(Succ(Y))] = 0));
           4:  Capture := ((Board[Pred(X), Pred(Y)] in [1, 2]) and
                           (Board[Pred(Pred(X)), Pred(Pred(Y))] = 0)) or
                          ((Board[Pred(X), Succ(Y)] in [1, 2]) and
                           (Board[Pred(Pred(X)), Succ(Succ(Y))] = 0)) or
                          ((Board[Succ(X), Pred(Y)] in [1, 2]) and
                           (Board[Succ(Succ(X)), Pred(Pred(Y))] = 0)) or
                          ((Board[Succ(X), Succ(Y)] in [1, 2]) and
                           (Board[Succ(Succ(X)), Succ(Succ(Y))] = 0));
     end;
end;

procedure Winner(var Board: Table; var Player: ShortInt);
{
The Winner procedure checks to see if there is a winner.
If somebody has zero pieces, the procedure will make the output parameter
"Player" take the value of 1 if player 1 won, and will take the value of 2
if player 2 won.
}
var
   X, Piece, P1Pieces, P2Pieces: ShortInt;
   Y: Char;
begin
     for X := 1 to 8 do
     begin
          for Y := 'A' to 'H' do
          begin
               Piece := Board[X,Y];
               case Piece of
                    1: P1Pieces := P1Pieces+1;
                    2: P1Pieces := P1Pieces+1;
                    3: P2Pieces := P2Pieces+1;
                    4: P2Pieces := P2Pieces+1;
               end;
          end;
     end;
     if (P1Pieces = 0) then Player := 2
     else if (P2Pieces = 0) then Player := 1
     else Player := 0;
end;

procedure Move(var Board: Table;
                   X1: ShortInt; Y1: Char;
                   X2: ShortInt; Y2: Char;
               var Error, CaptPoss: Boolean;
                   Who: String);

{
The Board parameter is the array containing the pieces of the board.
X1 and Y1 are the coordinates of the piece that will move
X2 and Y2 are the coordinates of the place where the piece will move
Error is an output parameter that will have the value TRUE if anything
      invalid ocurrs
CaptPoss is another output parameter that will have the value TRUE if
         the piece is able to make another capture (so the person can make
         multiple captures)
Who is an input parameter that contains the name of the person who is
    currently moving a piece (so that he can't move his opponent's pieces
}
var
   Back: Boolean;
   SameSpot: Boolean;
   Beside: Boolean;
   InRange: Boolean;
   X, X3, X4: ShortInt;
   Y, Y3, Y4: Char;
   Piece: ShortInt;
   ToPlace: ShortInt;
begin
     CaptPoss := False;
     InRange  := (X1 in [1..8]) and (X2 in [1..8]) and (Y1 in ['A'..'H'])
                  and (Y2 in ['A'..'H']);
     SameSpot := (X1 = X2) and (Y1 = Y2);
     Error    := (Board[X2, Y2] <> 0) or (not InRange) or SameSpot;
     if Error then Exit;
     Piece   := Board[X1, Y1]; {places the type of piece into Piece variable}
     ToPlace := Board[X2, Y2]; {places the coordinates of destination into
                                ToPlace variable}
     X3 := X1+1;
     X4 := X1-1;
     Y3 := Chr(Ord(Y1)+1);
     Y4 := Chr(Ord(Y1)-1);
     case Piece of
     -1: begin
              Error := True;
              Exit;
         end;
     0: begin
             Error := True;
             Exit;
        end;
     1: begin
             if (Who = Nam2) then
             begin
                  Error := True;
                  Exit;
             end;
             Beside  := ((Y2 = Y4)) and ((X2 = X3) or (X2 = X4));
             if (Not Beside) and (Not((Capture(Board, X1, Y1)))) then
             begin
                  Error := True;
                  Exit;
             end;
             if Beside then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
             end;
             if (Capture(Board, X1, Y1)) then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
                  if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
                  if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
                  if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
                  if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
                  CaptPoss := Capture(Board, X2, Y2);
             end;
        end;
     2: begin
             if (Who = Nam2) then
             begin
                  Error := True;
                  Exit;
             end;
             Beside := ((X2 = X3) or (X2 = X4)) and ((Y2 = Y3) or (Y2 = Y4));
             if (Not Beside) and (Not Capture(Board, X1, Y1)) then
             begin
                  Error := True;
                  Exit;
             end;
             if Beside then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
             end;
             if (Capture(Board, X1, Y1)) then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
                  if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
                  if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
                  if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
                  if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
                  CaptPoss := Capture(Board, X2, Y2);
             end;
        end;
     3: begin
             if (Who = Nam1) then
             begin
                  Error := True;
                  Exit;
             end;
             Beside  := ((Y2 = Y3)) and ((X2 = X3) or (X2 = X4));
             if (Not Beside) and (Not Capture(Board, X1, Y1)) then
             begin
                  Error := True;
                  Exit;
             end;
             if Beside then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
             end;
             if (Capture(Board, X1, Y1)) then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
                  if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
                  if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
                  if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
                  if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
                  CaptPoss := Capture(Board, X2, Y2);
             end;
        end;
     4: begin
             if (Who = Nam1) then
             begin
                  Error := True;
                  Exit;
             end;
             Beside := ((X2 = X3) or (X2 = X4)) and ((Y2 = Y3) or (Y2 = Y4));
             if (Not Beside) and (Not Capture(Board, X1, Y1)) then
             begin
                  Error := True;
                  Exit;
             end;
             if Beside then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
             end;
             if (Capture(Board, X1, Y1)) then
             begin
                  Board[X2, Y2] := Board[X1, Y1];
                  Board[X1, Y1] := 0;
                  if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
                  if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
                  if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
                  if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
                  CaptPoss := Capture(Board, X2, Y2);
             end;
        end;
     end;
end;

procedure RefreshBoard(var Board: Table);
{
This procedure refreshes the display of the board, scanning the array and
moving the pieces according to their positions on the array.
}
var
   X: ShortInt;
   Y: Char;
begin
     for X := 1 to 8 do
     begin
          for Y := 'A' to 'H' do
          begin
               case Board[X, Y] of
                     0: begin
                             SetColor(0);
                             SetFillStyle(1, 0);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
                        end;
                     1: begin
                             SetColor(4);
                             SetFillStyle(1, 4);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
                        end;
                     2: begin
                             SetColor(4);
                             SetFillStyle(1, 4);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
                             SetColor(14);
                             SetFillStyle(1, 14);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 5);
                        end;
                     3: begin
                             SetColor(7);
                             SetFillStyle(1, 7);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
                        end;
                     4: begin
                             SetColor(4);
                             SetFillStyle(1, 4);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
                             SetColor(14);
                             SetFillStyle(1, 14);
                             PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 5)
                        end
               end
          end
     end
end;

begin
     Randomize;
     grDriver := Detect;
     InitGraph(grDriver, grMode,' ');
     ErrCode := GraphResult;
     if (ErrCode <> grOk) then
     begin
          WriteLn('Graphics error:', GraphErrorMsg(ErrCode));
          Halt(1);
     end;
     Delay(3500);
     TitleScreen;
     Delay(4000);
     NameInput(Nam1, Nam2, Instruc);
     Who := Nam1;
     If Instruc then InstructionScreen;
     BoardSetup(Board);
     DrawBoard;
     SetTextJustify(LeftText, CenterText);
     OutTextXY(10, 400, Nam1+' is the     pieces.');
     OutTextXY(10, 440, Nam2+' is the     pieces.');
     SetColor(LightGreen);
     SetTextJustify(CenterText, CenterText);
     SetColor(Red);
     SetFillStyle(SolidFill, Red);
     PieSlice(TextWidth(Nam1+' is the  ')+10,400, 0, 360, 10);
     SetColor(LightGray);
     SetFillStyle(SolidFill, LightGray);
     PieSlice(TextWidth(Nam2+' is the  ')+10,440, 0, 360, 10);
     SetColor(Green);
     SetTextStyle(6, HorizDir, 3);
     SetTextJustify(CenterText, CenterText);
     OutTextXY(500,400,'Press ESC to quit game.');
     SetColor(White);
     SetTextJustify(LeftText, TopText);
     repeat
           RefreshBoard(Board);
           CoordInput:
           SetColor(White);
           SetTextJustify(CenterText, CenterText);
           OutTextXY(470, 20, Who+' moves:');
           SetTextJustify(LeftText, TopText);
           repeat
                 X := ReadKey;
                 if Not(X in ['1'..'8', #27]) then Beep;
           until (X in ['1'..'8', #27]);
           if (X = #27) then Halt(0);
           OutTextXY(350, 36, X);
           Val(X, Num1, Code);
           repeat
                 Y := UpCase(ReadKey);
                 if Not(Y in ['A'..'H', #27]) then Beep;
           until (Y in ['A'..'H', #27]);
           if (Y = #27) then Halt(0);
           OutTextXY(368, 36, Y+' TO');
           Let1 := Y;
           if Not(MovePoss(Board, Num1, Let1)) and Not(Capture(Board, Num1, Let1))
           then
           begin
                SetColor(Black);
                SetFillStyle(SolidFill, Black);
                Bar(350, 36, 600, 100);
                Beep;
                goto CoordInput;
           end;
           repeat
                 X := ReadKey;
                 if Not(X in ['1'..'8', #27]) then Beep;
           until (X in ['1'..'8', #27]);
           if (X = #27) then Halt(0);
           OutTextXY(423, 36, ' '+X);
           Val(X, Num2, Code);
           repeat
                 Y := UpCase(ReadKey);
                 if Not(Y in ['A'..'H', #27]) then Beep;
           until (Y in ['A'..'H', #27]);
           if (Y = #27) then Halt(0);
           OutTextXY(455, 36, Y);
           Let2 := Y;
           if (Board[Num2, Let2] <> 0) then
           begin
                SetColor(Black);
                SetFillStyle(SolidFill, Black);
                Bar(350, 36, 600, 100);
                Beep;
                goto CoordInput;
           end;
           Move(Board, Num1, Let1, Num2, Let2, Error, CaptPoss, Who);
           if Error then
           begin
                Beep;
                SetColor(Black);
                SetFillStyle(SolidFill, Black);
                Bar(350, 36, 600, 100);
                goto CoordInput;
           end;
           if CaptPoss then
           begin
                SetColor(Black);
                SetFillStyle(SolidFill, Black);
                Bar(340,0,600,200);
                Continue;
           end;
           KingCheck(Board);
           if (Who = Nam1) then Who := Nam2 else Who := Nam1;
           Winner(Board, Player);
           SetColor(Black);
           SetFillStyle(SolidFill, Black);
           Bar(340,0,600,200);
     until (Player <> 0);
     OutTextXY(500,200, Who+' wins!');
     ReadKey;
end.