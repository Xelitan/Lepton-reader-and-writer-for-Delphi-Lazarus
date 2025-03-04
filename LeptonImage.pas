unit LeptonImage;

{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Description:	Reader and writer to Lepton images                            //
// Version:	0.1                                                           //
// Date:	04-MAR-2025                                                   //
// License:     MIT                                                           //
// Target:	Win64, Free Pascal, Delphi                                    //
// Copyright:	(c) 2025 Xelitan.com.                                         //
//		All rights reserved.                                          //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

interface

uses Classes, Graphics, SysUtils, Math, Types, Dialogs;

const LIB_LEPTON = 'lepton.dll';

  function WrapperDecompressImage(input_buffer: Pointer; input_buffer_size: UInt64;
    output_buffer: Pointer; output_buffer_size: UInt64; number_of_threads: Integer;
    result_size: PUInt64): Integer; cdecl; external LIB_LEPTON;
  function WrapperCompressImage(input_buffer: PByte; input_buffer_size: UInt64;
    output_buffer: PByte; output_buffer_size: UInt64; number_of_threads: Int32;
    result_size: PUInt64): Int32; cdecl; external LIB_LEPTON;


  { TLeptonImage }
type
  TLeptonImage = class(TGraphic)
  private
    FBmp: TBitmap;
    FCompression: Integer;
    procedure DecodeFromStream(Str: TStream);
    procedure EncodeToStream(Str: TStream);
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
  //    function GetEmpty: Boolean; virtual; abstract;
    function GetHeight: Integer; override;
    function GetTransparent: Boolean; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetTransparent(Value: Boolean); override;
    procedure SetWidth(Value: Integer);override;
  public
    procedure SetLossyCompression(Value: Cardinal);
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    constructor Create; override;
    destructor Destroy; override;
    function ToBitmap: TBitmap;
  end;

implementation

{ TLeptonImage }

procedure DecodeLepton(InStr, OutStr: TStream);
var InBuff, OutBuff: array of Byte;
    InSize, OutSize: UInt64;
    ResultSize: UInt64;
    NumberOfThreads: Integer;
    ResultCode: Integer;
begin
  NumberOfThreads := 1;

  InSize := InStr.Size;
  SetLength(InBuff, InSize);

  try
    InStr.Read(InBuff[0], InSize);

    OutSize := 3 * InSize;
    SetLength(OutBuff, OutSize);

    ResultCode := WrapperDecompressImage(@InBuff[0], InSize,
      @OutBuff[0], OutSize, NumberOfThreads, @ResultSize);

    if ResultCode = 0 then begin
      OutStr.Write(OutBuff[0], ResultSize);
    end
    else raise Exception.Create('Decompression failed');
  except
    raise Exception.Create('Decompression failed');
  end;
end;

procedure EncodeLepton(InStr, OutStr: TStream);
var InBuff, OutBuff: array of Byte;
    InSize, OutSize: UInt64;
    ResultSize: UInt64;
    NumberOfThreads: Integer;
    ResultCode: Integer;
begin
  NumberOfThreads := 1;

  InSize := InStr.Size;
  SetLength(InBuff, InSize);

  try
    InStr.Read(InBuff[0], InSize);

    OutSize := 3 * InSize;
    SetLength(OutBuff, OutSize);

    ResultCode := WrapperCompressImage(@InBuff[0], InSize,
      @OutBuff[0], OutSize, NumberOfThreads, @ResultSize);

    if ResultCode = 0 then begin
      OutStr.Write(OutBuff[0], ResultSize);
    end;
  except
    raise Exception.Create('Decompression failed');
  end;
end;

procedure TLeptonImage.DecodeFromStream(Str: TStream);
var Mem: TMemoryStream;
    Jpg: TJpegImage;
begin
  Mem := TMemoryStream.Create;
  DecodeLepton(Str, Mem);
  Mem.Position := 0;

  Jpg := TJpegImage.Create;
  Jpg.LoadFromStream(Mem);
  Mem.Free;

  FBmp.Assign(Jpg);
  Jpg.Free;
end;

procedure TLeptonImage.EncodeToStream(Str: TStream);
var Mem: TMemoryStream;
    Jpg: TJpegImage;
begin
  Mem := TMemoryStream.Create;

  Jpg := TJpegImage.Create;
  Jpg.Assign(FBmp);
  Jpg.CompressionQuality := FCompression;
  Jpg.Compress;
  Jpg.SaveToStream(Mem);
  Jpg.Free;

  Mem.Position := 0;
  EncodeLepton(Mem, Str);

  Mem.Free;
end;

procedure TLeptonImage.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  ACanvas.StretchDraw(Rect, FBmp);
end;

function TLeptonImage.GetHeight: Integer;
begin
  Result := FBmp.Height;
end;

function TLeptonImage.GetTransparent: Boolean;
begin
  Result := False;
end;

function TLeptonImage.GetWidth: Integer;
begin
  Result := FBmp.Width;
end;

procedure TLeptonImage.SetHeight(Value: Integer);
begin
  FBmp.Height := Value;
end;

procedure TLeptonImage.SetTransparent(Value: Boolean);
begin
  //
end;

procedure TLeptonImage.SetWidth(Value: Integer);
begin
  FBmp.Width := Value;
end;

procedure TLeptonImage.SetLossyCompression(Value: Cardinal);
begin
  FCompression := Value;
end;

procedure TLeptonImage.Assign(Source: TPersistent);
var Src: TGraphic;
begin
  if source is tgraphic then begin
    Src := Source as TGraphic;
    FBmp.SetSize(Src.Width, Src.Height);
    FBmp.Canvas.Draw(0,0, Src);
  end;
end;

procedure TLeptonImage.LoadFromStream(Stream: TStream);
begin
  DecodeFromStream(Stream);
end;

procedure TLeptonImage.SaveToStream(Stream: TStream);
begin
  EncodeToStream(Stream);
end;

constructor TLeptonImage.Create;
begin
  inherited Create;

  FBmp := TBitmap.Create;
  FBmp.PixelFormat := pf32bit;
  FBmp.SetSize(1,1);
end;

destructor TLeptonImage.Destroy;
begin
  FBmp.Free;
  inherited Destroy;
end;

function TLeptonImage.ToBitmap: TBitmap;
begin
  Result := FBmp;
end;

initialization
  TPicture.RegisterFileFormat('lep', 'Lepton Image', TLeptonImage);

finalization
  TPicture.UnregisterGraphicClass(TLeptonImage);

end.
