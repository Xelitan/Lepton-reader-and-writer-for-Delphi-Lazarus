# Lepton-reader-and-writer-for-Delphi-Lazarus
Lepton (MS) reader and writer for Delphi/Lazarus/Free Pascal

# Usage examples
```
Image1.Picture.LoadFromFile('test.lep');
```

Writing:
```
    H: TLeptonImage;
begin
  Image1.Picture.LoadFromFile('test.bmp');

  H := TLeptonImage.Create;
  H.Assign(Image1.Picture.Bitmap);
  H.SetLossyCompression(44);
  H.SaveToFile('test.lep');
  H.Free;
```

Packing and unpacking JPEGs:
```
InF := TFileStream.Create('input.jpg', fmOpenRead);
OutF := TFileStream.Create('output.lep', fmCreate);
EncodeLepton(InF, OutF);
```
and:
```
InF := TFileStream.Create('input.lep', fmOpenRead);
OutF := TFileStream.Create('output.jpg', fmCreate);
DecodeLepton(InF, OutF);
```

## This project uses lepton.dll from "Lepton JPEG Compression in Rust"

"Lepton" is a discontinued project by Dropbox. "Lepton JPEG Compression in Rust" is a continuation by Microsoft.
The DLL is licensed under Apache 2.0 license.
