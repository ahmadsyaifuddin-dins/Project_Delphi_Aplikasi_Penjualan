{* rijndael-api-ref.c   v2.0   August '99 *}
(* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                ---------------------------------                *
 *                            DELPHI                               *
 *                         Rijndael API                            *
 *                ---------------------------------                *
 *                                                   December 2000 *
 *                                                                 *
 * Authors: Paulo Barreto                                          *
 *          Vincent Rijmen                                         *
 *                                                                 *
 * Delphi translation by Sergey Kirichenko (ksv@cheerful.com)      *
 * Home Page: http://rcolonel.tripod.com                           *
 * Adapted to FastReport: Alexander Tzyganenko                     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *)

unit rc_ApiRef;

{$I frx.inc}

interface

uses rc_AlgRef;

const
  MAXBC     = (256 div 32);
  MAXKC     = (256 div 32);
  MAXROUNDS = 14;

  DIR_ENCRYPT   = 0;    { Are we encrpyting? }
  DIR_DECRYPT   = 1;    { Are we decrpyting? }
  MODE_ECB      = 1;    { Are we ciphering in ECB mode? }
  MODE_CBC      = 2;    { Are we ciphering in CBC mode? }
  MODE_CFB1     = 3;    { Are we ciphering in 1-bit CFB mode? }
  rTRUE         = 1;    { integer(true) }
  rFALSE        = 0;    { integer(false) }
  BITSPERBLOCK  = 128;  { Default number of bits in a cipher block }

{ Error Codes - CHANGE POSSIBLE: inclusion of additional error codes }
  BAD_KEY_DIR         = -1;  { Key direction is invalid, e.g., unknown value }
  BAD_KEY_MAT         = -2;  { Key material not of correct length }
  BAD_KEY_INSTANCE    = -3;  { Key passed is not valid }
  BAD_CIPHER_MODE     = -4;  { Params struct passed to cipherInit invalid }
  BAD_CIPHER_STATE    = -5;  { Cipher in wrong state (e.g., not initialized) }
  BAD_CIPHER_INSTANCE = -7;

{  CHANGE POSSIBLE:  inclusion of algorithm specific defines  }
  MAX_KEY_SIZE  = 64;                   { # of ASCII char's needed to represent a key }
  MAX_IV_SIZE = (BITSPERBLOCK div 8);   { # bytes needed to represent an IV }

type
{ Typedef'ed data storage elements.  Add any algorithm specific
  parameters at the bottom of the structs as appropriate. }

  word8      = byte;        // unsigned 8-bit
  word16     = word;        // unsigned 16-bit
  word32     = longword;    // unsigned 32-bit
  TByteArray = array [0..MaxInt div sizeof(Byte)-1] of Byte;
  PByte      = ^TByteArray;

{ The structure for key information }
  PkeyInstance = ^keyInstance;
  keyInstance = packed record
    direction: Byte;    { Key used for encrypting or decrypting? }
    keyLen: integer;    { Length of the key }
    keyMaterial: array [0..MAX_KEY_SIZE+1-1] of char;  { Raw key data in ASCII, e.g., user input or KAT values }
    { The following parameters are algorithm dependent, replace or add as necessary }
    blockLen: integer;  { block length }
    keySched: TArrayRK; { key schedule }
  end;  {* keyInstance *}
  TkeyInstance = keyInstance;

{ The structure for cipher information }
  PcipherInstance = ^cipherInstance;
  cipherInstance = packed record
    mode: Byte;         // MODE_ECB, MODE_CBC, or MODE_CFB1
    IV: array [0..MAX_IV_SIZE-1] of Byte; // A possible Initialization Vector for ciphering
    { Add any algorithm specific parameters needed here }
    blockLen: integer;  // Sample: Handles non-128 bit block sizes (if available)
  end;  {* cipherInstance *}
  TcipherInstance = cipherInstance;

{ Function prototypes }
function makeKey(key: PkeyInstance; direction: Byte; keyLen: integer; keyMaterial: pchar): integer;
function cipherInit(cipher: PcipherInstance; mode: Byte; IV: pchar): integer;
{sergey has corrected it}
function blocksEnCrypt(cipher: PcipherInstance; key: PkeyInstance; input: PByte;
          inputLen: integer; outBuffer: PByte): integer;
{sergey has corrected it}
function blocksDeCrypt(cipher: PcipherInstance; key: PkeyInstance; input: PByte;
                      inputLen: integer; outBuffer: PByte): integer;
{ cipherUpdateRounds:

  Encrypts/Decrypts exactly one full block a specified number of rounds.
  Only used in the Intermediate Value Known Answer Test.

  Returns:
    TRUE - on success
    BAD_CIPHER_STATE - cipher in bad state (e.g., not initialized) }
function cipherUpdateRounds(cipher: PcipherInstance; key: PkeyInstance; input: PByte;
                      inputLen: integer; outBuffer: PByte; iRounds: integer): integer;

implementation

{ StrLCopy copies at most MaxLen characters from Source to Dest and returns Dest. }
function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function makeKey(key: PkeyInstance; direction: Byte; keyLen: integer; keyMaterial: pchar): integer;
var
  k: TArrayK;
  i, j, t: integer;
begin
  if not assigned(key) then
    begin
      result:= BAD_KEY_INSTANCE;
      exit;
    end;

  if ((direction = DIR_ENCRYPT) or (direction = DIR_DECRYPT)) then
    key.direction:= direction
  else
    begin
      result:= BAD_KEY_DIR;
      exit;
    end;

  if ((keyLen = 128) or (keyLen = 192) or (keyLen = 256)) then
    key.keyLen:= keyLen
  else
    begin
      result:= BAD_KEY_MAT;
      exit;
    end;

  if (keyMaterial^ <> #0) then
    StrLCopy(key.keyMaterial, keyMaterial, keyLen div 4);  // strncpy

  j := 0;
  { initialize key schedule: }
  for i:= 0 to (key.keyLen div 8)-1 do
    begin
      t:= integer(key.keyMaterial[2*i]);
      if ((t >= ord('0')) and (t <= ord('9'))) then
        j:= (t - ord('0')) shl 4
      else
        if ((t >= ord('a')) and (t <= ord('f'))) then
          j:= (t - ord('a') + 10) shl 4
        else
          if ((t >= ord('A')) and (t <= ord('F'))) then
            j:= (t - ord('A') + 10) shl 4
          else
            begin
              result:= BAD_KEY_MAT;
              exit;
            end;

      t:= integer(key.keyMaterial[2*i+1]);
      if ((t >= ord('0')) and (t <= ord('9'))) then
        j:= j xor (t - ord('0'))
      else
        if ((t >= ord('a')) and (t <= ord('f'))) then
          j:= j xor (t - ord('a') + 10)
        else
          if ((t >= ord('A')) and (t <= ord('F'))) then
            j:= j xor (t - ord('A') + 10)
          else
            begin
              result:= BAD_KEY_MAT;
              exit;
            end;

      k[i mod 4][i div 4]:= word8(j);
    end;
  rijndaelKeySched(k, key.keyLen, key.blockLen, key.keySched);
  result:= rTRUE;
end;

function cipherInit(cipher: PcipherInstance; mode: Byte; IV: pchar): integer;
var
  i, j, t: integer;
begin
  if ((mode = MODE_ECB) or (mode = MODE_CBC) or (mode = MODE_CFB1)) then
    cipher.mode:= mode
  else
    begin
      result:= BAD_CIPHER_MODE;
      exit;
    end;

  j := 0;
  
  if assigned(IV) then
    for i:= 0 to (cipher.blockLen div 8)-1 do
      begin
        t:= integer(IV[2*i]);
        if ((t >= ord('0')) and (t <= ord('9'))) then
          j:= (t - ord('0')) shl 4
        else
          if ((t >= ord('a')) and (t <= ord('f'))) then
            j:= (t - ord('a') + 10) shl 4
          else
            if ((t >= ord('A')) and (t <= ord('F'))) then
              j:= (t - ord('A') + 10) shl 4
            else
              begin
                result:= BAD_CIPHER_INSTANCE;
                exit;
              end;

        t:= integer(IV[2*i+1]);
        if ((t >= ord('0')) and (t <= ord('9'))) then
          j:= j xor (t - ord('0'))
        else
          if ((t >= ord('a')) and (t <= ord('f'))) then
            j:= j xor (t - ord('a') + 10)
          else
            if ((t >= ord('A')) and (t <= ord('F'))) then
              j:= j xor (t - ord('A') + 10)
            else
              begin
                result:= BAD_CIPHER_INSTANCE;
                exit;
              end;
         cipher.IV[i]:= Byte(j);
      end;
  result:= rTRUE;
end;

function blocksEnCrypt(cipher: PcipherInstance; key: PkeyInstance;
                      input: PByte; inputLen: integer; outBuffer: PByte): integer;
var
  i, j, t, numBlocks: integer;
  block: TArrayK;
begin
  { check parameter consistency: }
  if (not assigned(key)) or
      (key.direction <> DIR_ENCRYPT) or
      ((key.keyLen <> 128) and (key.keyLen <> 192) and (key.keyLen <> 256)) then
    begin
      result:= BAD_KEY_MAT;
      exit;
    end;

  if (not assigned(cipher)) or
     ((cipher.mode <> MODE_ECB) and (cipher.mode <> MODE_CBC) and (cipher.mode <> MODE_CFB1)) or
     ((cipher.blockLen <> 128) and (cipher.blockLen <> 192) and (cipher.blockLen <> 256)) then
    begin
      result:= BAD_CIPHER_STATE;
      exit;
    end;

  numBlocks:= inputLen div cipher.blockLen;
  case (cipher.mode) of
    MODE_ECB:
      for i:= 0 to numBlocks-1 do
        begin
          for j:= 0 to (cipher.blockLen div 32)-1 do
            for t:= 0 to 4-1 do
              { parse input stream into rectangular array }
              block[t][j]:= input[4*j+t] and $FF;
          rijndaelEncrypt(block, key.keyLen, cipher.blockLen, key.keySched);
          for j:= 0 to (cipher.blockLen div 32)-1 do
            { parse rectangular array into output ciphertext bytes }
            for t:= 0 to 4-1 do
              outBuffer[4*j+t]:= Byte(block[t][j]);
        end;
    MODE_CBC:
      begin
        for j:= 0 to (cipher.blockLen div 32)-1 do
          for t:= 0 to 4-1 do
            { parse initial value into rectangular array }
            block[t][j]:= cipher.IV[t+4*j] and $FF;
        for i:= 0 to numBlocks-1 do
          begin
            for j:= 0 to (cipher.blockLen div 32)-1 do
              for t:= 0 to 4-1 do
                { parse input stream into rectangular array and exor with
                  IV or the previous ciphertext }
//                block[t][j]:= block[t][j] xor (input[4*j+t] and $FF);                            {!original!}
                block[t][j]:= block[t][j] xor (input[(i*(cipher.blockLen div 8))+4*j+t] and $FF);  {!sergey made it!}
            rijndaelEncrypt(block, key.keyLen, cipher.blockLen, key.keySched);
            for j:= 0 to (cipher.blockLen div 32)-1 do
              { parse rectangular array into output ciphertext bytes }
              for t:= 0 to 4-1 do
//                outBuffer[4*j+t]:= Byte(block[t][j]);                                            {!original!}
                outBuffer[(i*(cipher.blockLen div 8))+4*j+t]:= Byte(block[t][j]);                  {!sergey made it!}
          end;
        end;
    else
      begin
        result:= BAD_CIPHER_STATE;
        exit
      end;
  end;
  result:= numBlocks*cipher.blockLen;
end;

function blocksDeCrypt(cipher: PcipherInstance; key: PkeyInstance; input: PByte;
                      inputLen: integer; outBuffer: PByte): integer;
var
  i, j, t, numBlocks: integer;
  block: TArrayK;
begin
  if (not assigned(cipher)) or
     (not assigned(key)) or
     (key.direction = DIR_ENCRYPT) or
     (cipher.blockLen <> key.blockLen) then
    begin
      result:= BAD_CIPHER_STATE;
      exit;
    end;

  { check parameter consistency: }
  if (not assigned(key)) or
     (key.direction <> DIR_DECRYPT) or
     ((key.keyLen <> 128) and (key.keyLen <> 192) and (key.keyLen <> 256)) then
    begin
      result:= BAD_KEY_MAT;
      exit;
    end;

  if (not assigned(cipher)) or
     ((cipher.mode <> MODE_ECB) and (cipher.mode <> MODE_CBC) and (cipher.mode <> MODE_CFB1)) or
     ((cipher.blockLen <> 128) and (cipher.blockLen <> 192) and (cipher.blockLen <> 256)) then
    begin
      result:= BAD_CIPHER_STATE;
      exit;
    end;

  numBlocks:= inputLen div cipher.blockLen;
  case (cipher.mode) of
    MODE_ECB:
      for i:= 0 to numBlocks-1 do
        begin
          for j:= 0 to (cipher.blockLen div 32)-1 do
            for t:= 0 to 4-1 do
              { parse input stream into rectangular array }
              block[t][j]:= input[4*j+t] and $FF;
          rijndaelDecrypt (block, key.keyLen, cipher.blockLen, key.keySched);
          for j:= 0 to (cipher.blockLen div 32)-1 do
            { parse rectangular array into output ciphertext bytes }
            for t:= 0 to 4-1 do
              outBuffer[4*j+t]:= Byte(block[t][j]);
        end;
    MODE_CBC:
      {! sergey has rearranged processing blocks and
        corrected exclusive-ORing operation !}

      begin
        { blocks after first }
        for i:= numBlocks-1 downto 1 do
          begin
            for j:= 0 to (cipher.blockLen div 32)-1 do
              for t:= 0 to 4-1 do
                { parse input stream into rectangular array }
                block[t][j]:= input[(i*(cipher.blockLen div 8))+ 4*j+ t] and $FF;
            rijndaelDecrypt(block, key.keyLen, cipher.blockLen, key.keySched);

            for j:= 0 to (cipher.blockLen div 32)-1 do
              { exor previous ciphertext block and parse rectangular array
                into output ciphertext bytes }
              for t:= 0 to 4-1 do
                outBuffer[(i*(cipher.blockLen div 8))+ 4*j+t]:= Byte(block[t][j] xor
                           input[(i-1)*(cipher.blockLen div 8)+ 4*j+ t]);
          end;

        { first block }
        for j:= 0 to (cipher.blockLen div 32)-1 do
          for t:= 0 to 4-1 do
            { parse input stream into rectangular array }
            block[t][j]:= input[4*j+t] and $FF;
        rijndaelDecrypt(block, key.keyLen, cipher.blockLen, key.keySched);

        for j:= 0 to (cipher.blockLen div 32)-1 do
          { exor the IV and parse rectangular array into output ciphertext bytes }
          for t:= 0 to 4-1 do
            outBuffer[4*j+t]:= Byte(block[t][j] xor cipher.IV[t+4*j]);
      end;
    else
      begin
        result:= BAD_CIPHER_STATE;
        exit;
      end;
  end;
  result:= numBlocks*cipher.blockLen;
end;

function cipherUpdateRounds(cipher: PcipherInstance; key: PkeyInstance; input: PByte;
                            inputLen: integer; outBuffer: PByte; iRounds: integer): integer;
var
  j, t: integer;
  block: TArrayK;
begin
  if (not assigned(cipher)) or
     (not assigned(key)) or
     (cipher.blockLen <> key.blockLen) then
    begin
      result:= BAD_CIPHER_STATE;
      exit;
    end;

  for j:= 0 to (cipher.blockLen div 32)-1 do
    for t:= 0 to 4-1 do
      { parse input stream into rectangular array }
      block[t][j]:= input[4*j+t] and $FF;

  case (key.direction) of
    DIR_ENCRYPT:
      rijndaelEncryptRound(block, key.keyLen, cipher.blockLen, key.keySched, irounds);
    DIR_DECRYPT:
      rijndaelDecryptRound(block, key.keyLen, cipher.blockLen, key.keySched, irounds);
    else
      begin
        result:= BAD_KEY_DIR;
        exit;
      end;
  end;

  for j:= 0 to (cipher.blockLen div 32)-1 do
    { parse rectangular array into output ciphertext bytes }
    for t:= 0 to 4-1 do
      outBuffer[4*j+t]:= Byte(block[t][j]);
  result:= rTRUE;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b