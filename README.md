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
