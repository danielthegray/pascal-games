Program Checkers;
{ by Daniel E. Gray }
{ June 2005 }

uses
	Crt,
	Graph,
	Mouse,
	SBDSP,
	Swap_Var,
	Utils,
	Word_Cas;

type
	Table     = array[-1..10, '?'..'J'] of ShortInt;
	Column    = array['?'..'J'] of ShortInt;
	CaptTable = array[1..48, 1..2] of ShortInt;
	String15  = String[15];

const
	C1: Column = (-1, -1, 3, -1, 3, -1, 0, -1, 1, -1, -1, -1);
	C2: Column = (-1, -1, -1, 3, -1, 0, -1, 1, -1, 1, -1, -1);

var
	Board: Table;
	grDriver: Integer;
	grMode: Integer;
	Nam1, Nam2, Who: String15;
	Let1, Let2, X, Y, C: Char;
	Num1, Num2, Player: ShortInt;
	FirstTurn, MInstalled, CaptPoss, Error, CPoss: Boolean;
	Code, ErrCode: Integer;
	Captures: CaptTable;
	P1Pieces, P2Pieces: Byte;
	P1P, P2P, Temp: String;
	SavePointerX, SavePointerY: Word;


label
	StartOfGame, CoordInput2;

function Int2Str(I: Integer): String;
var
	S: String;
begin
	Str(I, S);
	Int2Str := S;
end;

procedure Beep;
begin
	Write(Chr(07));
end;

procedure DrawBoard;
var
	Letter: Char;
	Number: Byte;
begin
	SetFillStyle(SolidFill, Red);
	SetTextStyle(SmallFont, HorizDir, 7);
	SetColor(Red);
	SetBkColor(Black);
	ClearDevice;
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
	SetColor(White);
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

function MovePoss(var Board: Table; X: ShortInt; Y: Char; Who, Nam1, Nam2: String): Boolean;
var
	Piece: ShortInt;
	Player: Byte;
begin
	Piece := Board[X, Y];
	if (Who = Nam1) then Player := 1 else Player := 2;
	if (Board[X, Y] in [1, 2]) and (Player = 2)
	or (Board[X, Y] in [3, 4]) and (Player = 1) then
	begin
		SetColor(LightGreen);
		SetTextJustify(LeftText, TopText);
		SetTextStyle(SmallFont, HorizDir, 7);
		OutTextXY(380, 200, 'You can''t select the');
		OutTextXY(377, 200+TextHeight('H'), 'other player''s piece.');
		Beep;
		Delay(750);
		SetColor(Black);
		SetFillStyle(EmptyFill, Black);
		Bar(377, 200, 410+TextWidth('other player''s piece.'), 210+(TextHeight('H')*2));
		MovePoss := False;
		Exit;
	end;
	case Piece of
	  -1: MovePoss := False;
		0: MovePoss := False;
		1: MovePoss := ((Board[Pred(X), Pred(Y)] = 0) or
							(Board[Succ(X), Pred(Y)] = 0)) and
							(Who = Nam1);
		2: MovePoss := ((Board[Pred(X), Pred(Y)] = 0) or
							(Board[Pred(X), Succ(Y)] = 0) or
							(Board[Succ(X), Pred(Y)] = 0) or
							(Board[Succ(X), Succ(Y)] = 0)) and
							(Who = Nam1);
		3: MovePoss := ((Board[Pred(X), Succ(Y)] = 0) or
							(Board[Succ(X), Succ(Y)] = 0)) and
							(Who = Nam2);
		4: MovePoss := ((Board[Pred(X), Pred(Y)] = 0) or
							(Board[Pred(X), Succ(Y)] = 0) or
							(Board[Succ(X), Pred(Y)] = 0) or
							(Board[Succ(X), Succ(Y)] = 0)) and
							(Who = Nam2);
	end;
end;

procedure VictoryScreen(Name: String);
var
	N: Integer;
	IncP, IncQ: Integer;
	Col: Boolean;
begin
	ClearViewPort;
	IncP := 0; IncQ := 0;
	Randomize;
	SetTextJustify(CenterText, CenterText);
	SetFillStyle(SolidFill, White);
	Col := False;
	repeat
		RandSeed := 1962;
		for n := 1 to 1000 do
		if (random(2)=1) then
			PutPixel(Random(GetMaxX), Random(GetMaxY), White)
		else
			PutPixel(Random(GetMaxX),Random(GetMaxY), LightGray);
		col := not col;
		Inc(IncQ);
		Inc(IncP, (IncQ Div 2));
		SetColor(Yellow);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2, 0 + IncP, 2 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2, 180 + IncP, 182 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2, 88 + IncP, 90 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2, 268 + IncP, 270 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2, 45 + IncP, 47 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2, 135 + IncP, 137 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2, 225 + IncP, 227 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2, 315 + IncP, 317 + IncP, 100);

		SetColor(LightBlue);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 + IncP, 0 + IncP, 2 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 + IncP, 180 + IncP, 182 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 + IncP, 88 + IncP, 90 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 + IncP, 268 + IncP, 270 + IncP, 100);
		SetColor(LightRed);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 - IncP, 45 + IncP, 47 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 - IncP, 135 + IncP, 137 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 - IncP, 225 + IncP, 227 + IncP, 100);
		PieSlice(GetMaxX Div 2, GetMaxY Div 2 - IncP, 315 + IncP, 317 + IncP, 100);

		SetColor(LightBlue);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 + IncP, 0 + IncP, 2 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 + IncP, 180 + IncP, 182 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 + IncP, 88 + IncP, 90 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 + IncP, 268 + IncP, 270 + IncP, 100);
		SetColor(LightRed);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 - IncP, 45 + IncP, 47 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 - IncP, 135 + IncP, 137 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 - IncP, 225 + IncP, 227 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 - IncP, 315 + IncP, 317 + IncP, 100);

		SetColor(LightRed);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 - IncP, 0 + IncP, 2 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 - IncP, 180 + IncP, 182 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 - IncP, 88 + IncP, 90 + IncP, 100);
		PieSlice(GetMaxX Div 2 + IncP, GetMaxY Div 2 - IncP, 268 + IncP, 270 + IncP, 100);
		SetColor(LightBlue);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 + IncP, 45 + IncP, 47 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 + IncP, 135 + IncP, 137 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 + IncP, 225 + IncP, 227 + IncP, 100);
		PieSlice(GetMaxX Div 2 - IncP, GetMaxY Div 2 + IncP, 315 + IncP, 317 + IncP, 100);

		Randomize;
		SetColor(Random(GetMaxColor));
		SetTextStyle(GothicFont, HorizDir, 4);
		OutTextXY(GetMaxX div 2, GetMaxY div 2, Name+' wins!');
		SetColor(LightGreen);
		SetTextStyle(SmallFont, HorizDir, 7);
		OutTextXY(GetMaxX div 2, GetMaxY - 17, 'Press any key to Continue');
		Delay(50);
		ClearDevice;

		If IncP >= 220 then Dec(IncQ, 4);
	until KeyPressed;
	ReadKey;
	ClearDevice;
end;

procedure InstructionScreen;
{
This procedure shows the instructions to the players.
}
var
	Y: ShortInt;
	SaveGraphMode: Integer;
begin
	  SaveGraphMode := GetGraphMode;
	  RestoreCrtMode;
	  TextColor(White);
	  TextBackground(Blue);
	  ClrScr;
	  WriteLn('ÛßßßßßßßßßßßßßßßßßßßßßßßÛ');
	  WriteLn('Û CHECKERS INSTRUCTIONS Û');
	  WriteLn('ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ');
	  WriteLn;
	  WriteLn('Checkers is a game played on a checkerboard by two people.');
	  WriteLn('Each player has 12 pieces, called men or checkers.  One set is');
	  WriteLn('red and the other is gray.  The checkers can only be moved on the');
	  WriteLn('diagonal, one square at a time, towards the other player''s side');
	  WriteLn('on the board.');
	  WriteLn('The object of the game is to capture all of your enemy''s pieces');
	  WriteLn('You can capture an enemy checker by hopping over it.  Capturing,');
	  WriteLn('just like moving, is on the diagonal.  You have to jump from the');
	  WriteLn('square directly next to your target and land on the square just');
	  WriteLn('beyond it (diagonally!). Your landing square has to be vacant.');
	  WriteLn('If you have a capture available on a turn, you have to take it.');
	  WriteLn('If you have more than one, it''s your choice.');
	  WriteLn('It is legal, in fact, required, to capture more than one piece on a');
	  WriteLn('single move so long as the jumping checker has vacant landing spots');
	  WriteLn('available to it that will also serve as legal take off points for');
	  WriteLn('another jump(s).  If you can get a checker to the last row of the board');
	  WriteLn('that checker becomes a king.  A yellow circle will appear above the piece.');
	  WriteLn('Now that piece can move, or capture, going in any direction, but always on');
	  WriteLn('the diagonal.');
	  Write('Press any key to go to the examples');
	  CursorOff;
	  ClearKeybBuffer;
	  ReadKey;
	  CursorOn;
	  SetGraphMode(SaveGraphMode);
	  SetColor(Red);
	  SetBkColor(Black);
	  SetFillStyle(SolidFill, Red);
	  SetTextJustify(LeftText, CenterText);
	  SetTextStyle(SmallFont, HorizDir, 7);
	  PieSlice(18, 18, 0, 360, 10);
	  SetColor(15);
	  OutTextXY(40, 18, 'This is a red piece');
	  SetColor(Red);
	  SetFillStyle(SolidFill, Red);
	  PieSlice(18, 54, 0, 360, 10);
	  SetColor(Yellow);
	  SetFillStyle(SolidFill, Yellow);
	  PieSlice(18, 54, 0, 360, 5);
	  SetColor(White);
	  OutTextXY(40, 54, 'This is a crowned red piece');
	  SetColor(LightGray);
	  SetBkColor(Black);
	  SetFillStyle(SolidFill, LightGray);
	  PieSlice(18, 90, 0, 360, 10);
	  SetColor(White);
	  OutTextXY(40, 90, 'This is a gray piece');
	  SetColor(LightGray);
	  SetBkColor(Black);
	  SetFillStyle(SolidFill, LightGray);
	  PieSlice(18, 126, 0, 360, 10);
	  SetColor(Yellow);
	  SetFillStyle(SolidFill, Yellow);
	  PieSlice(18, 126, 0, 360, 5);
	  SetColor(White);
	  OutTextXY(40, 126, 'This is a crowned gray piece');
	  OutTextXY(18, 162, 'Press any key to continue');
	  ClearKeybBuffer;
	  ReadKey;
	  DrawBoard;
	  SetTextJustify(LeftText, TopText);
	  OutTextXY(13, 350, 'You may use your mouse or keyboard to select and move');
	  Delay(4000);
	  OutTextXY(13, 380, '"3H" would be at the blue spot.');
	  SetColor(LightBlue);
	  SetFillStyle(SolidFill, LightBlue);
	  PieSlice(((3-1)*36)+18, ((Ord('H')-65)*36)+18, 0, 360, 10);
	  Delay(3500);
	  SetColor(White);
	  OutTextXY(13, 410, '"4E" would be at the green spot.');
	  SetColor(Green);
	  SetFillStyle(SolidFill, Green);
	  PieSlice(((4-1)*36)+18, ((Ord('E')-65)*36)+18, 0, 360, 10);
	  SetColor(White);
	  OutTextXY(18, 410+TextHeight('H'), 'Press any key to Exit.');
	  ClearKeybBuffer;
	  ReadKey;
end;

procedure KingCheck(var Board: Table);
var
	King: Boolean;
begin
	King := False;
	if (Board[2,'A'] = 1) then
	begin
		Board[2,'A'] := 2;
		King := True;
	end;
	if (Board[4,'A'] = 1) then
	begin
		Board[4,'A'] := 2;
		King := True;
	end;
	if (Board[6,'A'] = 1) then
	begin
		Board[6,'A'] := 2;
		King := True;
	end;
	if (Board[8,'A'] = 1) then
	begin
		Board[8,'A'] := 2;
		King := True;
	end;
	if (Board[1,'H'] = 3) then
	begin
		Board[1,'H'] := 4;
		King := True;
	end;
	if (Board[3,'H'] = 3) then
	begin
		Board[3,'H'] := 4;
		King := True;
	end;
	if (Board[5,'H'] = 3) then
	begin
		Board[5,'H'] := 4;
		King := True;
	end;
	if (Board[7,'H'] = 3) then
	begin
		Board[7,'H'] := 4;
		King := True;
	end;
	if King then
	begin
		ResetMixer;
		PlaySoundRPD('tada.rpd');
		SetVocVolume(13, 13);
	end;
end;

procedure NameInput(var Nam1, Nam2: String15);
var
	Rand, I, N, SaveGraphMode: Integer;
begin
	Randomize;
	SaveGraphMode := GetGraphMode;
	RestoreCrtMode;
	TextMode(C40);
	TextColor(Yellow);
	TextBackground(Black);
	ClrScr;
	Write(' Computer will choose starting player.');
	GotoXY(1, 5);
	WriteLn('Player A, please input your name: ');
	ReadLn(Temp);
	NameCase(Temp);
	Nam1 := Copy(Temp, 1, 15);
	WriteLn;
	WriteLn('Player B, please input your name: ');
	ReadLn(Temp);
	NameCase(Temp);
	Nam2 := Copy(Temp, 1, 15);
	N := Random(10+1);
	for I := 1 to N do Rand := Random(100)+1;
	if (Rand>50) then Change_Str(Nam1, Nam2);
	CursorOn;
	SetGraphMode(SaveGraphMode);
end;

procedure BoardSetup(var Board: Table);
{
This procedure just sets up the board to initial positions to start the game
}
var
	CX: Boolean;
	F: Char;
	N: Integer;
begin
	for N := -1 to 10 do
		for F := '?' to 'J' do
			Board[N, F] := -1;
	CX := True;
	for N := 1 to 8 do
	begin
		if CX then
			for F := 'A' to 'H' do Board[N, F] := C2[F]
		else
			for F := 'A' to 'H' do Board[N, F] := C1[F];
		CX := Not CX
	end
end;

function Capture (var Board: Table; X: ShortInt; Y: Char) : Boolean;
{
This function tells if the Piece that has the coordinates X,Y can capture
}
var
	Piece: ShortInt;
begin
	Piece := Board[X, Y];
	if ((Piece in [1, 2]) and (Who = Nam2))
	or ((Piece in [3, 4]) and (Who = Nam1)) then
	begin
		Capture := False;
		Exit;
	end;
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
							 (Board[Succ(Succ(X)), Succ(Succ(Y))] = 0))
	end
end;

function TwoSquaresAway(X1: ShortInt; Y1: Char; X2: ShortInt; Y2: Char): Boolean;
begin
	TwoSquaresAway := (Abs(X1-X2) = 2) and (Abs(Ord(Y1)-Ord(Y2)) = 2);
end;

function InCaptureList(X: ShortInt; Y: Char): Boolean;
var
	N: Byte;
	X1: ShortInt;
	Y1: Char;
begin
	for N := 1 to 48 do
		if (Captures[N, 1] = X) and (Captures[N, 2] = Ord(Y)) then
		begin
			InCaptureList := True;
			Exit;
		end;
end;

procedure Move(var Board: Table;
						 X1: ShortInt; Y1: Char;
						 X2: ShortInt; Y2: Char;
					var Error, CaptPoss: Boolean;
						 Who: String;
					var P1Pieces, P2Pieces: Byte);

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
	 currently moving a piece (so that he can't move his opponent's pieces)
P1Pieces and P2Pieces is how many pieces each player has.
}
var
	Back, Beside, SameSpot, CaptDone: Boolean;
	X, X3, X4: ShortInt;
	Y, Y3, Y4: Char;
	Piece: ShortInt;
	ToPlace: ShortInt;
	N: Integer;
begin
	CaptPoss := False;
	SameSpot := (X1 = X2) and (Y1 = Y2);
	if SameSpot then
	begin
		SetColor(LightGreen);
		SetTextJustify(LeftText, TopText);
		SetTextStyle(SmallFont, HorizDir, 7);
		OutTextXY(410, 200, 'You can''t move to');
		OutTextXY(410, 200+TextHeight('H'), 'the same spot.');
		Beep;
		Delay(1050);
		SetColor(Black);
		SetFillStyle(EmptyFill, Black);
		Bar(410, 200, 410+TextWidth('You can''t move to'), 210+(TextHeight('H')*2));
	end;
	Error    := (Board[X2, Y2] <> 0) or SameSpot;
	if Error then Exit;
	Piece   := Board[X1, Y1]; {places the type of piece into Piece variable}
	ToPlace := Board[X2, Y2]; {places the coordinates of destination into ToPlace variable}
	X3 := X1+1;
	X4 := X1-1;
	Y3 := Chr(Ord(Y1)+1);
	Y4 := Chr(Ord(Y1)-1);
	case Piece of
  -1: begin
			Error := True;
			Exit
		end;
	0: begin
			Error := True;
			Exit
		end;
	1: begin
			if (Who = Nam2) then
			begin
				Error := True;
				Exit
			end;
			Beside := ((Y2 = Y4)) and ((X2 = X3) or (X2 = X4));
			if (Not Beside) and (Not((Capture(Board, X1, Y1)))) then
			begin
				Error := True;
				Exit
			end;
			if Beside then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0;
				Exit
			end;
			if (Capture(Board, X1, Y1)) then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0;
				if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
				if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
				if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
				if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
				Dec(P2Pieces);
				KingCheck(Board);
				CaptPoss := Capture(Board, X2, Y2)
			end
		end;
	2: begin
			if (Who = Nam2) then
			begin
				Error := True;
				Exit
			end;
			Beside := ((X2 = X3) or (X2 = X4)) and ((Y2 = Y3) or (Y2 = Y4));
			if (Not Beside) and (Not((Capture(Board, X1, Y1)))) then
			begin
			  Error := True;
			  Exit
			end;
			if (Not Beside) and (Not Capture(Board, X1, Y1)) then
			begin
				Error := True;
				Exit
			end;
			if Beside then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0
			end;
			if (Capture(Board, X1, Y1)) then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0;
				if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
				if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
				if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
				if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
				Dec(P2Pieces);
				KingCheck(Board);
				CaptPoss := Capture(Board, X2, Y2)
			end
		end;
	3: begin
			if (Who = Nam1) then
			begin
				Error := True;
				Exit
			end;
			Beside  := ((Y2 = Y3)) and ((X2 = X3) or (X2 = X4));
			if (Not Beside) and (Not((Capture(Board, X1, Y1)))) then
			begin
				Error := True;
				Exit
			end;
			if (Not Beside) and (Not Capture(Board, X1, Y1)) then
			begin
				Error := True;
				Exit
			end;
			if Beside then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0
			end;
			if (Capture(Board, X1, Y1)) then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0;
				if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
				if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
				if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
				if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
				Dec(P1Pieces);
				KingCheck(Board);
				CaptPoss := Capture(Board, X2, Y2)
			end;
		end;
	4: begin
			if (Who = Nam1) then
			begin
				Error := True;
				Exit
			end;
			Beside := ((X2 = X3) or (X2 = X4)) and ((Y2 = Y3) or (Y2 = Y4));
			if (Not Beside) and (Not((Capture(Board, X1, Y1)))) then
			begin
				Error := True;
				Exit
			end;
			if (Not Beside) and (Not Capture(Board, X1, Y1)) then
			begin
				Error := True;
				Exit
			end;
			if Beside then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0
			end;
			if (Capture(Board, X1, Y1)) then
			begin
				Board[X2, Y2] := Board[X1, Y1];
				Board[X1, Y1] := 0;
				if (X2 < X1) and (Y2 < Y1) then Board[X1-1, Pred(Y1)] := 0;
				if (X2 < X1) and (Y2 > Y1) then Board[X1-1, Succ(Y1)] := 0;
				if (X2 > X1) and (Y2 < Y1) then Board[X1+1, Pred(Y1)] := 0;
				if (X2 > X1) and (Y2 > Y1) then Board[X1+1, Succ(Y1)] := 0;
				Dec(P1Pieces);
				KingCheck(Board);
				CaptPoss := Capture(Board, X2, Y2)
			end
		end
	end
end;

procedure AllCaptures;
var
	Index: Byte;
	X: ShortInt;
	Y: Char;
	M, N: Byte;
begin
	for M := 1 to 48 do
		for N := 1 to 2 do
			Captures[M, N] := 0;
	Index := 1;
	for X := 1 to 8 do
		for Y := 'A' to 'H' do
		begin
			if Capture(Board, X, Y) then
			begin
				Captures[Index, 1] := X;
				Captures[Index, 2] := Ord(Y);
				Inc(Index);
			end;
		end;
end;


function OneSquareAway(X1:ShortInt; Y1: Char; X2: ShortInt; Y2: Char): Boolean;
begin
	OneSquareAway := (Abs(X1-X2) = 1) and (Abs(Ord(Y1)-Ord(Y2)) = 1);
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
						SetColor(Black);
						SetFillStyle(SolidFill, Black);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10)
					end;
				1: begin
						SetColor(Red);
						SetFillStyle(SolidFill, Red);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10)
					end;
				2: begin
						SetColor(Red);
						SetFillStyle(SolidFill, Red);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
						SetColor(Yellow);
						SetFillStyle(SolidFill, Yellow);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 5)
					end;
				3: begin
						SetColor(LightGray);
						SetFillStyle(SolidFill, LightGray);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10)
					end;
				4: begin
						SetColor(LightGray);
						SetFillStyle(SolidFill, LightGray);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 10);
						SetColor(Yellow);
						SetFillStyle(SolidFill, Yellow);
						PieSlice(((X-1)*36)+18, ((Ord(Y)-65)*36)+18, 0, 360, 5)
					end
			end
		end
	end
end;

procedure UpdateMouseCursor;
var
	SaveColor: Byte;
begin
	SaveColor := GetColor;
	if (Who = Nam1) then
	begin
		SetColor(Red);
		SetMouseGCursor(MouseUpHand)
	end
	else
	begin
		SetColor(LightGray);
		SetMouseGCursor(MouseDownHand);
	end;
	SetColor(SaveColor);
end;

begin
	ResetDSP (2, 5, 1, 5);
	MInstalled := MouseInstalled;
	Randomize;
	grDriver := Detect;
	InitGraph(grDriver, grMode,' ');
	ErrCode := GraphResult;
	if (ErrCode <> grOk) then
	begin
		WriteLn('Graphics error:', GraphErrorMsg(ErrCode));
		ClearKeybBuffer;
		CursorOff;
		ReadKey;
		ClrScr;
		CursorOn;
		Halt(2)
	end;
	Nam1 := 'Player A';
	Nam2 := 'Player B';
	SavePointerX := GetMaxX div 2;
	SavePointerY := GetMaxY div 2;
	StartOfGame:
	P1Pieces := 12;
	P2Pieces := 12;
	Who := Nam1;
	BoardSetup(Board);
	DrawBoard;
	SetTextJustify(LeftText, CenterText);
	SetTextStyle(SmallFont, HorizDir, 7);
	OutTextXY(10, 400, Nam1+' is the    pieces.');
	OutTextXY(10, 440, Nam2+' is the    pieces.');
	SetColor(LightGreen);
	SetTextJustify(CenterText, CenterText);
	SetColor(Red);
	SetFillStyle(SolidFill, Red);
	PieSlice(TextWidth(Nam1+' is the  ')+10,400, 0, 360, 10);
	SetColor(LightGray);
	SetFillStyle(SolidFill, LightGray);
	PieSlice(TextWidth(Nam2+' is the  ')+10,440, 0, 360, 10);
	SetColor(Green);
	SetTextStyle(SmallFont, HorizDir, 7);
	SetTextJustify(CenterText, CenterText);
	OutTextXY(500, 380, 'Press ESC to quit game.');
	SetColor(White);
	SetTextJustify(LeftText, TopText);
	RefreshBoard(Board);
	ResetMouse;
	FirstTurn := True;
	repeat
		CPoss := False;
		AllCaptures;
		CPoss := not ((Captures[1, 1] = 0) and (Captures[1, 2] = 0));
		SetColor(White);
		SetTextStyle(SmallFont, HorizDir, 7);
		SetTextJustify(CenterText, CenterText);
		OutTextXY(470, 20, Who+' moves:');
		OutTextXY(380, 45, 'From: ');
		if FirstTurn then
		begin
			SetTextStyle(SmallFont, HorizDir, 5);
			OutTextXY(500, 250, 'Click to Input Player Names');
			Rectangle(380, 242, 610, 262);
			OutTextXY(500, 200, 'Click to Reverse Start Order');
			Rectangle(380, 192, 610, 212);
		end;
		SetTextStyle(SmallFont, HorizDir, 6);
		SetColor(LightRed);
		OutTextXY(500, 300, 'Click for New Game');
		Rectangle(400, 292, 590, 315);
		PointerOn;
		UpdateMouseCursor;
		PointerToXY(SavePointerX, SavePointerY);
		repeat
			Num1 := 0; Let1:= '@';
			ReadMouse;
			if Left then
			begin
				if (PointerX >= 400) and (PointerX <= 590)
				and (PointerY >= 292) and (PointerY <= 315)
				then
				begin
					repeat
						ReadMouse;
					until not Left;
					SavePointerX := PointerX;
					SavePointerY := PointerY;
					goto StartOfGame;
				end;
				if (PointerX >= 380) and (PointerX <= 610) and FirstTurn
				and (PointerY >= 242) and (PointerY <= 262) then
				begin
					NameInput(Nam1, Nam2);
					goto StartOfGame;
				end;
				if (PointerX >= 380) and (PointerX <= 610) and FirstTurn
				and (PointerY >= 192) and (PointerY <= 212) then
				begin
					repeat
						ReadMouse;
					until not Left;
					Change_Str(Nam1, Nam2);
					SavePointerX := PointerX;
					SavePointerY := PointerY;
					goto StartOfGame;
				end;
				case PointerX of
					0..36: Num1 := 1;
					37..73: Num1 := 2;
					74..109: Num1 := 3;
					110..145: Num1 := 4;
					146..181: Num1 := 5;
					182..217: Num1 := 6;
					218..253: Num1 := 7;
					254..289: Num1 := 8;
					else Num1 := 0;
				end;
				case PointerY of
					0..36: Let1 := 'A';
					37..73: Let1 := 'B';
					74..110: Let1 := 'C';
					111..146: Let1 := 'D';
					147..184: Let1 := 'E';
					185..220: Let1 := 'F';
					221..255: Let1 := 'G';
					256..292: Let1 := 'H';
					else Let1 := '@';
				end;
			end;
			if KeyPressed then C := ReadKey;
			if (C = #27) then
			begin
				CloseGraph;
				Halt(0);
			end;
			{
			if (C in ['1'..'8']) then
			begin
				Num1 := Ord(C)-48;
				OutTextXY(380+TextWidth('From: '), 45, C);
				SavePointerX := PointerX;
				SavePointerY := PointerY;
				PointerOff;
				repeat
					C := ReadKey;
				until (C in ['A'..'H']);
				Let1 := C;
				PointerOn;
				PointerToXY(SavePointerX, SavePointerY);
			end;
			}
		until ((Num1 in [1..8]) and (Let1 in ['A'..'H'])) or Right;
		FirstTurn := False;
		repeat
			ReadMouse;
		until not Left;
		SavePointerX := PointerX;
		SavePointerY := PointerY;
		PointerOff;
		SetColor(Black);
		SetFillStyle(EmptyFill, Black);
		Bar(380, 242, 610, 262);
		Bar(380, 192, 610, 212);
		if Right then
		begin
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(350, 0, 600, 200);
			RefreshBoard(Board);
			Continue;
		end;
		Left := False; Center := False; Right := False;
		if (Board[Num1, Let1] = -1) then
		begin
			SetTextStyle(SmallFont, HorizDir, 7);
			SetColor(LightGreen);
			SetTextJustify(CenterText, TopText);
			OutTextXY(480, 200, 'You can''t select a');
			OutTextXY(480, 200+TextHeight('H'), 'red square.');
			Beep;
			Delay(1050);
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(370, 200, 410+TextWidth('You can''t select a'), 210+(TextHeight('H')*2));
			Bar(340, 0, 600, 200);
			Continue;
		end
		else
		if (Board[Num1, Let1] = 0) then
		begin
			SetTextStyle(SmallFont, HorizDir, 7);
			SetColor(LightGreen);
			SetTextJustify(CenterText, TopText);
			OutTextXY(480, 200, 'You can''t select an');
			OutTextXY(480, 200+TextHeight('H'), 'empty square.');
			Beep;
			Delay(1050);
			SetColor(Black);
			SetFillStyle(SolidFill, Black);
			Bar(370, 200, 410+TextWidth('You can''t select an'), 210+(TextHeight('H')*2));
			Bar(340, 0, 600, 200);
			Continue;
		end
		else
		if Not(MovePoss(Board, Num1, Let1, Who, Nam1, Nam2)) and Not(Capture(Board, Num1, Let1)) then
		begin
			if not(((Board[Num1, Let1] in [3, 4]) and (Who = Nam1))
			or ((Board[Num1, Let1] in [1, 2]) and (Who = Nam2))) then Beep;
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(340, 0, 600, 200);
			RefreshBoard(Board);
			Continue;
		end;
		SetColor(White);
		SetTextStyle(SmallFont, HorizDir, 7);
		OutTextXY(380+TextWidth('From: '), 45, Int2Str(Num1)+Let1);
		SetColor(LightGreen);
		SetFillStyle(SolidFill, LightGreen);
		PieSlice(((Num1-1)*36)+18, ((Ord(Let1)-65)*36)+18, 0, 360, 4);

		CoordInput2:
		SetColor(White);
		OutTextXY(380, 45+TextHeight('From:')+3, 'To: ');
		UpdateMouseCursor;
		PointerOn;
		PointerToXY(SavePointerX, SavePointerY);
		repeat
			Num2 := 0; Let2:= '@';
			ReadMouse;
			if Left then
			begin
				if (PointerX >= 400) and (PointerX <= 590)
				and (PointerY >= 292) and (PointerY <= 315)
				then
				begin
					repeat
						ReadMouse;
					until not Left;
					SavePointerX := PointerX;
					SavePointerY := PointerY;
					goto StartOfGame;
				end;
				case PointerX of
					0..36: Num2 := 1;
					37..73: Num2 := 2;
					74..109: Num2 := 3;
					110..145: Num2 := 4;
					146..181: Num2 := 5;
					182..217: Num2 := 6;
					218..253: Num2 := 7;
					254..289: Num2 := 8;
					else Num2 := 0;
				end;
				case PointerY of
					0..36: Let2 := 'A';
					37..73: Let2 := 'B';
					74..110: Let2 := 'C';
					111..146: Let2 := 'D';
					147..184: Let2 := 'E';
					185..220: Let2 := 'F';
					221..255: Let2 := 'G';
					256..292: Let2 := 'H';
					else Let2 := '@';
				end;
			end;
			if KeyPressed then C := ReadKey;
			if (C = #27) then
			begin
				CloseGraph;
				Halt(0);
			end;
		until ((Num2 in [1..8]) and (Let2 in ['A'..'H'])) or Right;
		repeat
			ReadMouse;
		until not Left;
		SavePointerX := PointerX;
		SavePointerY := PointerY;
		PointerOff;
		SetColor(White);
		SetTextStyle(SmallFont, HorizDir, 7);
		OutTextXY(380+TextWidth('To: '), 45+TextHeight('From:')+3, Int2Str(Num2)+Let2);
		Delay(150);
		if Right then
		begin
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(350, 0, 639, 200);
			RefreshBoard(Board);
			Continue;
		end;
		if (Abs(Num1-Num2) > 2) or (Abs(Ord(Let1)-Ord(Let2)) > 2) then
		begin
			SetColor(LightGreen);
			SetTextJustify(LeftText, TopText);
			SetTextStyle(SmallFont, HorizDir, 7);
			OutTextXY(410, 200, 'Invalid move.');
			Beep;
			Delay(1000);
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(410, 200, 410+TextWidth('Invalid move.'), 210+(TextHeight('H')*2));
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(350, 0, 600, 200);
			RefreshBoard(Board);
			Continue;
		end;
		Left := False; Center := False; Right := False;
		if CPoss and OneSquareAway(Num1, Let1, Num2, Let2) then
		begin
			SetTextStyle(SmallFont, HorizDir, 7);
			SetColor(LightGreen);
			SetTextJustify(CenterText, TopText);
			OutTextXY(490, 200, 'You must take one of');
			OutTextXY(490, 200+TextHeight('H'), 'the available captures.');
			Beep;
			Delay(1050);
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(350, 200, 410+TextWidth('the available captures.'), 210+(TextHeight('H')*2));
			Bar(340, 0, 600, 200);
			RefreshBoard(Board);
			Continue;
		end;
		Move(Board, Num1, Let1, Num2, Let2, Error, CaptPoss, Who, P1Pieces, P2Pieces);
		if Error then
		begin
			SetColor(LightGreen);
			SetTextJustify(LeftText, TopText);
			SetTextStyle(SmallFont, HorizDir, 7);
			OutTextXY(410, 200, 'Invalid move.');
			Beep;
			Delay(1000);
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(410, 200, 410+TextWidth('Invalid move.'), 210+(TextHeight('H')*2));
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(350, 0, 600, 200);
			RefreshBoard(Board);
			Continue;
		end;
		KingCheck(Board);
		if CaptPoss then
		begin
			SetColor(Black);
			SetFillStyle(EmptyFill, Black);
			Bar(340, 0, 600, 200);
			RefreshBoard(Board);
			Num1 := Num2; Let1 := Let2;
			SetColor(LightGreen);
			SetFillStyle(SolidFill, LightGreen);
			PieSlice(((Num1-1)*36)+18, ((Ord(Let1)-65)*36)+18, 0, 360, 4);
			SetColor(White);
			SetTextJustify(CenterText, CenterText);
			OutTextXY(470, 20, Who+' moves:');
			OutTextXY(380, 45, 'From: ');
			OutTextXY(380+TextWidth('From: '), 45, Int2Str(Num1)+Let1);
			goto CoordInput2;
		end;
		if (Who = Nam1) then Who := Nam2 else Who := Nam1;
		SetColor(Black);
		SetFillStyle(EmptyFill, Black);
		Bar(340, 0, 600, 200);
		RefreshBoard(Board);
	until (P1Pieces = 0) or (P2Pieces = 0);

	SetColor(LightCyan);
	if (P1Pieces = 0) then VictoryScreen(Nam2)
	else VictoryScreen(Nam1);
	DrawBoard;
	RefreshBoard(Board);
	SetTextJustify(LeftText, CenterText);
	SetTextStyle(SmallFont, HorizDir, 7);
	SetTextJustify(LeftText, CenterText);
	SetColor(White);
	OutTextXY(10, 400, Nam1+' is the    pieces.');
	OutTextXY(10, 440, Nam2+' is the    pieces.');
	SetColor(LightGreen);
	SetTextJustify(CenterText, CenterText);
	SetColor(Red);
	SetFillStyle(SolidFill, Red);
	PieSlice(TextWidth(Nam1+' is the  ')+10,400, 0, 360, 10);
	SetColor(LightGray);
	SetFillStyle(SolidFill, LightGray);
	PieSlice(TextWidth(Nam2+' is the  ')+10,440, 0, 360, 10);
	SetColor(LightGreen);
	SetTextStyle(TriplexFont, HorizDir, 4);
	OutTextXY(520, 400, 'QUIT');
	SetTextStyle(SmallFont, HorizDir, 4);
	OutTextXY(520, 425, '(ESC)');
	Rectangle(475, 387, 565, 435);
	SetTextStyle(SmallFont, HorizDir, 6);
	SetColor(LightRed);
	OutTextXY(500, 300, 'Click for New Game');
	Rectangle(400, 292, 590, 315);
	PointerOn;
	SetMouseGCursor(MouseTargetBox);
	PointerToXY(SavePointerX, SavePointerY);
	repeat
		ReadMouse;
		if ((PointerX >= 400) and (PointerX <= 590)
		and (PointerY >= 292) and (PointerY <= 315))
		or ((PointerX >= 475) and (PointerX <= 565)
		and (PointerY >= 387) and (PointerY <= 435))
		then
			SetMouseGCursor(MouseUpHand)
		else
			SetMouseGCursor(MouseTargetBox);
		if (PointerX >= 400) and (PointerX <= 590) and Left
		and (PointerY >= 292) and (PointerY <= 315)
		then
		begin
			repeat
				ReadMouse;
			until not Left;
			SavePointerX := PointerX;
			SavePointerY := PointerY;
			goto StartOfGame;
		end;
		if (PointerX >= 475) and (PointerX <= 565) and Left
		and (PointerY >= 387) and (PointerY <= 435) then
		begin
			CloseGraph;
			Halt(0);
		end;
		if KeyPressed then C := ReadKey;
		if (C = #27) then
		begin
			CloseGraph;
			Halt(0);
		end;
	until False;
	CloseGraph;
end.