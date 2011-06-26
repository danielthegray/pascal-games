unit Utils;

interface

uses DOS, Crt, Graph;
type
	AdapterType = (None, MDA, CGA, EGAMono, EGAColor,
						VGAMono, VGAColor, MCGAMono, MCGAColor);
const
	AdapterNames: array[AdapterType] of String =
			('None', 'MDA', 'CGA', 'EGAMono', 'EGAColor',
			 'VGAMono', 'VGAMono', 'MCGAMono', 'MCGAColor');
	Waves: FillPatternType =
				($94, $84, $48, $30, $00, $C1, $22, $14);
	Vertical: FillPatternType =
				($CC, $CC, $CC, $CC, $CC, $CC, $CC, $CC);
	Bricks: FillPatternType =
				($01, $82, $44, $28, $10, $20, $40, $80);
	Blocks: FillPatternType =
				($00, $3C, $42, $42, $42, $42, $3C, $00);
	Semitono1: FillPatternType =
				($CC, $33, $CC, $33, $CC, $33, $CC, $33);
	Semitono2: FillPatternType =
				($AA, $55, $AA, $55, $AA, $55, $AA, $55);

procedure ClearKeybBuffer;
function Spaces(I: Byte): String;
procedure CursorOff;
procedure CursorOn;
function Character(X,Y: Byte): Char;
function Color(X,Y: Byte): Byte;
function GetAdapterType: AdapterType;
function GetPoints: Integer;
procedure ChangeFont(NewFont: Byte; var Error: Boolean);
function FullReadKey(var Ch: Char; var Extend: Boolean;
							var Explor: Byte; var Camb: Byte): Boolean;
procedure Beep;
function Int2Str(I: Integer): String;
procedure ClearScr(Destiny: Pointer; ScreenSize: Integer; Attribute: Integer; ClearChar: Byte);
function TestBit(var Objct; BitNumber:Integer): Boolean;
procedure SetBit(var Objct; BitNumber:Integer);
procedure ClearBit(var Objct; BitNumber:Integer);

implementation

function GetAdapterType: AdapterType;
var
	Regs: Registers;
	Code: Byte;
begin
	with Regs do
	begin
		AH := $1A; { Tries to identify a VGA adapter }
		AL := $00; { It's necesary to make AH = 0 }
	end;
	Intr($10, Regs);
	if (Regs.AL = $1A) then { if a $1A code is returned in the register AL }
	begin { we know that we have a PS/2 video BIOS }
		case Regs.BL of { return code is stored in register BL }
			$00: GetAdapterType := None;
			$01: GetAdapterType := MDA;
			$02: GetAdapterType := CGA;
			$04: GetAdapterType := EGAColor;
			$05: GetAdapterType := EGAMono;
			$07: GetAdapterType := VGAMono;
			$08: GetAdapterType := VGAColor;
			$0A, $0C: GetAdapterType := MCGAColor;
			else GetAdapterType := CGA;
		end;
	end
	else
	begin { the presence of a EGA BIOS is confirmed: }
		with Regs do
		begin
			AH := $12;  { Choose the alternate service function }
			BX := $10;  { BX=$10 tells the BIOS to return the EGA information }
		end;
		Intr($10, Regs); { Call to BIOS VIDEO }
		if Regs.BX <> $10 then { unchanged BX means NO EGA }
		begin
			with Regs do
			begin
				AH := $12;  { Once we know that the alternate function exists }
				BX := $10;  { We call it again to see if it's an EGA color    }
			end;				{ or an EGA monochrome.                           }
			Intr($10, Regs);
			if (Regs.BH = 0) then GetAdapterType := EGAColor
				else GetAdapterType := EGAMono;
		end
		else { now we know that we have an EGA or MDA: }
		begin
			Intr($11, Regs);  { Equipment determination service }
			Code := (Regs.AL and $30) shr 4;
			case Code of
				1: GetAdapterType := CGA;
				2: GetAdapterType := CGA;
				3: GetAdapterType := MDA;
				else GetAdapterType := CGA;
			end;
		end;
	end;
end;

function GetPoints: Integer;
var
	Regs: Registers;
begin
	case GetAdapterType of
		CGA: GetPoints := 8;
		MDA: GetPoints := 14;
		EGAMono,   { These adapters can use any of the different heights for }
		EGAColor,  { the type, so it's necesary to ask the BIOS which one is }
		VGAMono,   { being used 															}
		VGAColor,
		MCGAMono,
		MCGAColor: begin
						 with Regs do
						 begin
							AH := $11; { Call to EGA/VGA information }
							AL := $30;
							BL := $00;
						 end;
						 Intr($10, Regs);
						 GetPoints := Regs.CX;
					  end;
	end;
end;

procedure CursorOn;
var
	Regs: Registers;
begin
	Mem[$40:$87] := Mem[$40:$87] or $01;
	with Regs do
	begin
		AX := $0100;
		CH := 6;
		CL := 7;
	end;
	Intr($10, Regs);
end;

procedure ClearKeybBuffer;
var
	Regs: Registers;
begin
	Regs.AH := $01;    { AH=1: Sees is a key has been pressed. }
	Intr($16, Regs);   { Interuption $16: keyboard sevices }
	if (Regs.Flags and $0040) = 0 then {If there are characters in the buffer }
		repeat
			Regs.AH := 0;      { Character ready; read it }
			Intr($16, Regs);   { Using AH=0, read character }
			Regs.AH := $01;    { Checking to see if a key was pressed }
			Intr($16, Regs);   { using AH=1                           }
		until (Regs.Flags and $0040) = 0;
end;

procedure CursorOff;
var
  Regs: Registers;
begin
  with Regs do
  begin
	 AX := $0100;
	 CX := $2000;
  end;
  Intr($10, Regs);
end;

procedure ChangeFont(NewFont: Byte; var Error: Boolean);
const
	AdapAnt: Set of AdapterType = [CGA, MDA]; {set of adapters that can't
															 change font size}
var
	CurrentAdapter: AdapterType;
	LegalFontSizes: Set of Byte;
	FontCode: Byte;
	Regs: Registers;
begin
	CurrentAdapter := GetAdapterType;
	case CurrentAdapter of
		CGA: LegalFontSizes := [8];
		MDA: LegalFontSizes := [14];
		EGAMono, EGAColor: LegalFontSizes := [8, 14];
		VGAMono, VGAColor: LegalFontSizes := [8, 14, 16];
		MCGAMono, MCGAColor: LegalFontSizes := [16];
	end;
	if not(NewFont in LegalFontSizes) then
	begin
		Error := True;
		Exit;
	end;
	if not ((CurrentAdapter in AdapAnt) and (GetPoints <> NewFont)) then
	begin
		case NewFont of
			8: FontCode := $12;
			14: FontCode := $11;
			16: FontCode := $10;
		end;
		with Regs do
		begin
			AH := $11; {EGA/VGA service of character generation}
			AL := FontCode; {Input the font code}
			BX := 0;
		end;
		Intr($10, Regs); {Call the video display interruption to the BIOS}
		{Supress the BIOS cursor emulation}
		Mem[$40:$87] := Mem[$40:$87] or $01;
		{Put the cursor back in place}
	end;
end;

function FullReadKey(var Ch: Char; var Extend: Boolean;
							var Explor: Byte; var Camb: Byte): Boolean;
var
	Regs: Registers;
	Ready: Boolean;
begin
	Extend := False; Explor := 0;
	Regs.AH := 0; {AH=0 means check to see if key was pressed}
	Intr($16, Regs); {Interruption $16: keyboard services}
	Ready := (Regs.Flags and $40) = 0;
	if Ready then
	begin
		Regs.AH := 0;  {Character ready; go read it}
		Intr($16, Regs);
		Ch := Chr(Regs.AL); {the character is returned in AL}
		Explor := Regs.AH; {and the code is returned in AH}
		Extend := (Ch = Chr(0));
	end;
	Regs.AH := $02; {AH=2: Read Shift/Alt/Ctrl status}
	Intr($16, Regs);
	Camb := Regs.AL;
	FullReadKey := Ready;
end;

procedure Beep;
begin
	Write(Chr(07));
end;

function Int2Str(I: Integer): String;
var
	S: String[11];
begin
	Str(I, S);
	Int2Str := S;
end;

procedure ClearScr(Destiny: Pointer; ScreenSize: Integer;
						 Attribute: Integer; ClearChar: Byte);
			 External;
{$L CLEARSCR.OBJ}

function Character(X,Y: Byte): Char;
type
	 Coord = record
					ASCII: Char;
					Color: Byte;
				end;
	 Position = array[0..0] of Coord;
var
	Screen: Position absolute $B800:$0000;
	Range: Word;
begin
	  Range := ((Y-1)*80)+X-1;
	  Character := Screen[Range].ASCII;
end;

function Color(X,Y: Byte): Byte;
type
	 Coord = record
					ASCII: Char;
					Color: Byte;
				end;
	 Position = array[0..0] of Coord;
var
	Screen: Position absolute $B800:$0000;
	Range: Word;
begin
	  Range := ((Y-1)*80)+X-1;
	  Color := Screen[Range].Color;
end;

function Spaces(I:Byte):String;
Var
  Zip: String;
Begin
  FillChar(Zip,i+1,' ');
  Zip[0] := Chr(i);
  Spaces := Zip;
End;

function TestBit(var Objct; BitNumber:Integer): Boolean;
var
	ObjctVar: Integer absolute Objct;
	Mask: Integer;
begin
	Mask := ObjctVar;
	Mask := Mask shr BitNumber;
	TestBit := Odd(Mask);
end;

procedure SetBit(var Objct; BitNumber:Integer);
var
	ObjctVar: Integer absolute Objct;
	Mask: Integer;
begin
	Mask := 1 shl BitNumber;
	ObjctVar := ObjctVar or Mask;
end;


procedure ClearBit(var Objct; BitNumber:Integer);
var
	ObjctVar: Integer absolute Objct;
	Mask: Integer;
begin
	Mask := not(1 shl BitNumber);
	ObjctVar := ObjctVar and Mask;
end;

end.