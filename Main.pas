UNIT Main;                                                                                          {
                            * _ * _ * _ * _ * _ * _ * _ * _ * _ * _ *
                             |                                     |
                            *            TESTING BENCH :            *
                             |    Canvas.Pixels[]  vs  GetpPix     |
                            *                                       *
                             |       CARIBENSILA   Août 2010       |
                            *        http://www.delphifr.com        *
                             |_   _   _   _   _   _   _   _   _   _|
                            *   *   *   *   *   *   *   *   *   *   *                               }
INTERFACE

uses
	Windows, ExtCtrls, ComCtrls, StdCtrls, Graphics, Controls, Classes, Forms, SysUtils, Dialogs;

type
  TForm1 = class(TForm)
    pnlPixels       : TPanel;      
    pnlGetpPix2     : TPanel;
    pnlTools        : TPanel;
    pnlSource       : TPanel;
    pnlOptions1     : TPanel;
    pnlOptions2     : TPanel;
    pnlOptions3     : TPanel;
    pnlOptions4     : TPanel;
    pnlScore        : TPanel;
    lblTitrePixels  : TLabel;
    lblTitreGetpPix2: TLabel;
    lblTitreSource  : TLabel;
    lblBMPWidth     : TLabel;
    lblPixelFormat  : TLabel;
    lblConditions   : TLabel;
    lblTimePixels   : TLabel;
    lblTimeGetpPix  : TLabel;
    lblWidth        : TLabel;
    lblIterations   : TLabel;
    lblTest1        : TLabel;
    lblTest2        : TLabel;
    lblRatio        : TLabel;
    imgSource       : TImage;
    imgPixels       : TImage;
    imgGetpPix      : TImage;
    imgNew          : TImage;
    btnTestPixels   : TButton;
    btnTestGetpPix  : TButton;
    rbt24bit        : TRadioButton;
    rbt32bit        : TRadioButton;
    rbtOptimal      : TRadioButton;
    rbtPractical    : TRadioButton;
    UpDownWidth     : TUpDown;
    shpPixelsBar    : TShape;
    shpGetpPixBar   : TShape;
    edtIterations   : TEdit;
    procedure FormCreate           (Sender: TObject);
    procedure edtIterationsExit    (Sender: TObject);
    procedure Conditions           (Sender: TObject);
    procedure Distribute           (Sender: TObject);
    procedure SetPixelFormat       (Sender: TObject);
    procedure UpDownWidthClick     (Sender: TObject ; Button : TUDBtnType);
    procedure edtIterationsKeyPress(Sender: TObject ; var Key: Char      );
  end;

var
  Form1: TForm1;



IMPLEMENTATION
{$R *.dfm}


const   TIMEUNIT   = 20;         //Unité de mesure d'affichage du meilleur temps.


var     LoopsCount : Integer; //Nombre d'itérations dans chaque boucle du time-test.


                                                                                                    {
____________________________________________________________________________________________________
__ GESTION DE L'INTERFACE __________________________________________________________________________}



procedure TForm1.FormCreate(Sender: TObject);
	begin
  with imgSource.Picture.Bitmap do if not (PixelFormat=pf24bit) then PixelFormat := pf24bit;
  LoopsCount                 := StrToInt(edtIterations.Text);
  btnTestPixels .Tag         := High(Integer); //Contiendra le meilleur temps obtenu.
  btnTestGetpPix.Tag         := High(Integer);//Contiendra le meilleur temps obtenu.
  Application.HintPause      := 100;
  Application.HintHidePause  := 4000;
  Application.HintColor      := clYellow;
end;                                    



          {Mise à zéro des scores déjà obtenu quand les conditions de test ont changé.}
procedure Initialize;
	begin
  with Form1 do begin
  	imgPixels .Picture.Bitmap.Canvas.Brush.Color := clGray;
    imgPixels .Picture.Bitmap.Canvas.Brush.Style := bsDiagCross;
    imgGetpPix.Picture.Bitmap.Canvas.Brush.Color := clGray;
    imgGetpPix.Picture.Bitmap.Canvas.Brush.Style := bsDiagCross;
    imgPixels .Picture.Bitmap.Canvas.FillRect(imgPixels .Picture.Bitmap.Canvas.ClipRect);
    imgGetpPix.Picture.Bitmap.Canvas.FillRect(imgGetpPix.Picture.Bitmap.Canvas.ClipRect);
  	lblTimePixels .Caption   := '';
    lblTimeGetpPix.Caption   := '';
    lblRatio      .Caption   := '';
    shpPixelsBar  .Width     := 0 ;
    shpGetpPixBar .Width     := 0 ;
    btnTestPixels .Tag       := High(Integer); //Le tag contiendra le meilleur temps obtenu.
    btnTestGetpPix.Tag       := High(Integer);//Le tag contiendra le meilleur temps obtenu.
  end;
end;



          {Modifie la largeur du Bitmap source afin de vérifier l'efficacité
           du nouvel algo pour les pf24bit de largeur non multiple de 4.    }
procedure TForm1.UpDownWidthClick(Sender: TObject; Button: TUDBtnType);
	var
      		BMP   : TBitmap;
	begin
  with imgSource do if Button  = btNext then Width := Width+1 else Width := Width-1;
  BMP := TBitmap.Create;
  try
  	with BMP do begin
    	Width  := imgSource.Width ;
    	Height := imgSource.Height;
      if rbt24bit.Checked then PixelFormat := pf24bit;
      if rbt32bit.Checked then PixelFormat := pf32bit;
    	Canvas.StretchDraw(Canvas.ClipRect, imgSource.Picture.Bitmap);
    	imgSource.Picture.Assign(BMP);
  		lblBMPWidth.Caption := Format( 'Bitmap . Width  =  %.0n pixels.', [imgSource.Width/1] );
    end;
  finally BMP.free; end;
  Initialize;
end;



          {Evénement OnClick des RadioBoutons rbt24bit et rbt32bit.}
procedure TForm1.SetPixelFormat(Sender: TObject);
	begin
  if (Sender as TComponent).Tag = 24 then imgSource.Picture.Bitmap.PixelFormat := pf24bit;
  if (Sender as TComponent).Tag = 32 then imgSource.Picture.Bitmap.PixelFormat := pf32bit;
  Initialize;
end;



          {Evénement OnClick des RadioBoutons rbtOptimal et rbtPractical.}
procedure TForm1.Conditions(Sender: TObject);
	begin
  Initialize;
end;



          {Gestion du changement du nombre d'itérations par test.}
procedure TForm1.edtIterationsKeyPress(Sender: TObject; var Key: Char);
	begin
  If not(Key in ['0'..'9',#8]) then Key := #0;
end;

procedure TForm1.edtIterationsExit(Sender: TObject);
	begin
  with edtIterations do begin
  	if (Text = '') or (StrToInt(Text) = 0) then begin
   		 Text := IntToStr(LoopsCount);
    	 Exit ;
  	end;
  	if LoopsCount <> StrToInt(Text) then begin
    	 LoopsCount := StrToInt(Text);
    	 Initialize ;
  	end;
  end;
end;



          {MAJ des scores.}
procedure DisplayTime(aTicks: Cardinal; alblTime: TLabel; ashpBar: TShape; aBtn: TButton);
	begin
  beep;
  if aTicks = 0 then begin
  	ShowMessage('         Le temps écoulé (=0) n''est pas significatif.'#13#10'Il est conseillé d''augmenter le Nbre d''itérations par test.');
    Exit;
  end;
  aBtn.Tag       := aTicks; //On stocke le meilleur temps obtenu dans le Tag du bouton.
  ashpBar.Width  := Round(aTicks/TIMEUNIT);
  if ashpBar.Width=0 then ashpBar.Width := 1; //Taille minima.
  if Form1.rbtOptimal.Checked
    then alblTime.Caption := Format('Meilleur temps =  %.0n ms  (conditions optimales).', [ aTicks/1 ])
      else alblTime.Caption := Format('Meilleur temps =  %.0n ms  (les conditions de test ne sont pas optimales).', [ aTicks/1 ]);
  if (Form1.btnTestPixels.Tag <> High(Integer)) and (Form1.btnTestGetpPix.Tag <> High(Integer))
  	then Form1.lblRatio.Caption := Format('TEST1 / TEST2 = %.0n', [ (Form1.btnTestPixels.Tag div Form1.btnTestGetpPix.Tag)/1 ])
end;



                                                                                                    {
____________________________________________________________________________________________________
__ LA ROUTINE GETpPIX ______________________________________________________________________________}




function GetpPix(aX, aY, aBytesPerPix, aMemLineSize, aScan0: Integer): pRGBTriple;
	begin
  Inc( aScan0, aY * aMemLineSize );  //Incrémente aScan0 du nombre d'octets d'une ligne-mémoire * Y (NB: aMemLineSize est en fait le plus souvent négatif(Bottom-Up DIB)).
  Inc( aScan0, aX * aBytesPerPix ); //Incrémente aScan0 du nombre d'octets d'un pixel * X.
  Result :=   pRGBTriple( aScan0 );//Transtype  aScan0 en pRGBTriple pour avoir accès aux composantes-couleur.
end;



                                                                                                    {
____________________________________________________________________________________________________
__ ROUTINES POUR CONDITIONS DE TESTS PRATIQUES _____________________________________________________
                                               Les procédures transforment l'image-source en niveaux
                                               de gris. Le temps global obtenu inclue donc ce temps
                                               de calcul, le rendant peu significatif.              }



          {Routine utilisant Canvas.Pixels[] et transformant l'image source en niveaux de gris.}
procedure PracticalTestPixels(Sender: TObject);
	var
					Start : Cardinal;
          Ticks : Cardinal;
          BMP   : TBitmap ;
          i     : Integer ;
          X,Y   : Integer ;
          Grey  : TColor  ;
          Color : TColor  ;
	begin
  Screen.Cursor := crHourGlass;
	BMP := TBitmap.Create;
	try
		BMP.Assign(Form1.imgSource.Picture.Graphic); //On travaille en mémoire.

		Start := GetTickCount;
		for i := 1 to LoopsCount do begin
  		for Y := 0 to BMP.Height-1 do begin
    		for X := 0 to BMP.Width-1    do begin
        	Color := BMP.Canvas.Pixels[X,Y];
        	Grey  := ((Color and $ff) shl 1 + ((Color and $ff00) shr 8) * 5 + (Color and $ff0000) shr 16) shr 3; //Transtype TColor en RGB et calcule le gris selon : (R*2 + G*5 + B) div 8.
					BMP.Canvas.Pixels[X,Y] :=  (Grey Shl 16) Or (Grey Shl 8) Or (Grey); //Transtype RGB en TColor.
      	end;
    	end;
    end;
    Ticks := GetTickCount - Start;

  	Form1.imgPixels.Picture.Graphic := BMP;
    if Integer(Ticks) < Form1.btnTestPixels.Tag  //On change l'affichage des résultats si nécessaire.
      then DisplayTime(Ticks, Form1.lblTimePixels, Form1.shpPixelsBar, Form1.btnTestPixels);
	finally  BMP.Free;  end;
  Screen.Cursor := crDefault;
end;



          {Routine utilisant le nouvel algorithme et transformant l'image source en niveaux de gris.}
procedure PracticalTestGetpPix(Sender: TObject);
	var
          Start      : Cardinal;
          Ticks      : Cardinal;
          BMP        : TBitmap ;
          Scan0      : Integer ;   //Valeur, en Integer, de la 1ère adresse de ScanLine.
          MemLineSize: Integer ;  //Taille d'une ligne de pixels en mémoire (en octets).
          BytesPerPix: Integer ; //Format des pixels (en octets).
          i          : Integer ;
          X,Y        : Integer ;
          Grey       : Integer ;
	begin
  Screen.Cursor      := crHourGlass;
	BMP := TBitmap.Create;
	try
		BMP.Assign(Form1.imgSource.Picture.Graphic); //On travaille en mémoire.
    {Initialisation des paramètres de GetpPix().}
    Scan0            := Integer(BMP.ScanLine[0]);           //Pointe sur la 1ère ligne du Bitmap.
	  MemLineSize      := Integer(BMP.ScanLine[1]) - Scan0;  //MemLineSize sera le plus souvent <0 permettant ainsi de décrémenter l'adresse du pointeur de ligne-mémoire (Y).
    BytesPerPix      := Abs( MemLineSize div BMP.Width ); //BytesPerPix permettra d'incrémenter l'adresse du pointeur pRGBTriple en fonction de sa position dans la ligne (X).
    
		Start := GetTickCount;
		for i := 1 to LoopsCount do begin
  		for Y := 0 to BMP.Height-1 do begin
    		for X := 0 to BMP.Width-1  do   begin
  				with GetpPix(X, Y, BytesPerPix, MemLineSize, Scan0)^ do begin        //Renvoie un pointeur pRGBTriple.
               Grey      := (rgbtRed shl 1 + rgbtGreen * 5 + rgbtBlue) shr 3; //(R*2 + G*5 + B) div 8 (gris avec correction de luminance optimisée).
        			 rgbtRed   := Grey;
          		 rgbtGreen := Grey;
               rgbtBlue  := Grey;
          end;
        end;
      end;
    end;
    Ticks := GetTickCount - Start;

  	Form1.imgGetpPix.Picture.Graphic := BMP;
    if Integer(Ticks) < Form1.btnTestGetpPix.Tag //On change l'affichage des résultats si nécessaire.
      then DisplayTime(Ticks, Form1.lblTimeGetpPix, Form1.shpGetpPixBar, Form1.btnTestGetpPix);
  finally  BMP.Free;  end;
  Screen.Cursor := crDefault;
end;


                                                                                                    {
____________________________________________________________________________________________________
__ ROUTINES POUR CONDITIONS OPTIMALES DE TEST ______________________________________________________
                                               Les procédures ne font qu'accéder aux données des
                                               pixels. Le temps global obtenu n'est donc mesuré que
                                               pour cette action et reflète donc bien les performances
                                               des algos.                                           }



          {Routine utilisant Canvas.Pixels[] mais n'effectuant aucun
           traitement afin de ne mesurer que le temps d''accès aux pixels.}
procedure OptimalTestPixels(Sender: TObject);
	var
					Start : Cardinal;
          Ticks : Cardinal;
          BMP   : TBitmap ;
          i     : Integer ;
          X,Y   : Integer ;
	begin
  Screen.Cursor := crHourGlass;
	BMP := TBitmap.Create;
	try
		BMP.Assign(Form1.imgSource.Picture.Graphic); //On travaille en mémoire.

		Start := GetTickCount;
		for i := 1 to LoopsCount do begin
  		for Y := 0 to BMP.Height-1 do begin
    		for X := 0 to BMP.Width-1    do begin
        	BMP.Canvas.Pixels[X,Y]; //Juste un accès au pixel, sans traitement numérique, afin de ne mesurer QUE le temps d'accès.
                                 //NB: La valeur renvoyée n'est qu'un TColor et nécéssitera le plus souvent un transtypage en RGB !
      	end;
    	end;
    end;
    Ticks := GetTickCount - Start;

  	Form1.imgPixels.Picture.Graphic := BMP;
    if Integer(Ticks) < Form1.btnTestPixels.Tag //On change l'affichage des résultats si nécessaire.
      then DisplayTime(Ticks, Form1.lblTimePixels, Form1.shpPixelsBar, Form1.btnTestPixels);
	finally  BMP.Free;  end;
  Screen.Cursor := crDefault;
end;



          {Routine utilisant le nouvel algorithme mais n'effectuant aucun
           traitement afin de ne mesurer que le temps d'accès aux pixels.}
procedure OptimalTestGetpPix(Sender: TObject);
	var
          Start      : Cardinal;
          Ticks      : Cardinal;
          BMP        : TBitmap ;
          Scan0      : Integer ;   //Valeur, en Integer, de la 1ère adresse de ScanLine.
          MemLineSize: Integer ;  //Taille d'une ligne de pixels en mémoire (en octets).
          BytesPerPix: Integer ; //Format des pixels (en octets).
          i          : Integer ;
          X,Y        : Integer ;
	begin
  Screen.Cursor      := crHourGlass;
	BMP := TBitmap.Create;
	try
		BMP.Assign(Form1.imgSource.Picture.Graphic); //On travaille en mémoire.
    {Initialisation des paramètres de GetpPix().}
    Scan0            := Integer(BMP.ScanLine[0]);           //Pointe sur la 1ère ligne du Bitmap.
	  MemLineSize      := Integer(BMP.ScanLine[1]) - Scan0;  //MemLineSize sera le plus souvent <0 permettant ainsi de décrémenter l'adresse du pointeur de ligne-mémoire (Y).
    BytesPerPix      := Abs( MemLineSize div BMP.Width ); //BytesPerPix permettra d'incrémenter l'adresse du pointeur pRGBTriple en fonction de sa position dans la ligne (X).
    
		Start := GetTickCount;
		for i := 1 to LoopsCount do begin
  		for Y := 0 to BMP.Height-1 do begin
    		for X := 0 to BMP.Width-1  do   begin
  				GetpPix(X, Y, BytesPerPix, MemLineSize, Scan0); //Juste un accès au pixel, sans traitement numérique, afin de ne mesurer QUE le temps d'accès.
                                                         //NB: C'est un pointeur sur RGB !
        end;
      end;
    end;
    Ticks := GetTickCount - Start;

  	Form1.imgGetpPix.Picture.Graphic := BMP;
    if Integer(Ticks) < Form1.btnTestGetpPix.Tag  //On change l'affichage des résultats si nécessaire.
      then DisplayTime(Ticks, Form1.lblTimeGetpPix, Form1.shpGetpPixBar, Form1.btnTestGetpPix);
  finally  BMP.Free;  end;
  Screen.Cursor := crDefault;
end;


                                                                                                    {
____________________________________________________________________________________________________
__ DISPATCHING _____________________________________________________________________________________}



          {Evénement OnClick des Boutons btnTestPixels et btnTestGetpPix.
           Distribue les actions à effectuer en fonction des options sélectionnées.}
procedure TForm1.Distribute(Sender: TObject);
	begin

  if ( (Sender as TButton).Name = 'btnTestPixels' ) and ( rbtOptimal.Checked   )
   then OptimalTestPixels   (Sender);

  if ( (Sender as TButton).Name = 'btnTestPixels' ) and ( rbtPractical.Checked )
   then PracticalTestPixels (Sender);

  if ( (Sender as TButton).Name = 'btnTestGetpPix') and ( rbtOptimal.Checked   )
   then OptimalTestGetpPix  (Sender);

  if ( (Sender as TButton).Name = 'btnTestGetpPix') and ( rbtPractical.Checked )
   then PracticalTestGetpPix(Sender);

end;



END.
