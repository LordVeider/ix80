unit Typelib;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Библиотека типов

interface

const
  WM_CONTROLS = $0410;
  WM_REMCTRL  = $0411;
  WM_VALUE    = $0420;
  COLOR_HL    = -16777203{12639424};
  LOG_LINE    = '---------------------------------------------------------------------------------------------------------------';


type
  TNumSys = (SBIN, SDEC, SOCT, SHEX);                                           //Системы счисления

  TDataReg = (RB, RC, RD, RE, RH, RL, RM, RA, RW, RZ, RF);                      //Регистры
  TRegPair = (RPBC, RPDE, RPHL, RPSP);                                          //Регистровые пары

  TDataRegisters = array [TDataReg] of Int8;                                    //Регистры данных
  TRegisters = record
    DataRegisters: TDataRegisters;                                              //Регистры данных (8 bit)
    SP: Word;                                                                   //Указатель стека (16 bit)
    PC: Word;                                                                   //Счетчик команд  (16 bit)
    IR: Byte;                                                                   //Регистр команд  (8 bit)
  end;

  TFlag = (FS, FZ, FP, FAC, FCY);                                               //Флаги
  TFlagSet = set of TFlag;                                                      //Набор флагов
  TFlagArray = array [TFlag] of Byte;                                           //Массив флагов

  TMemoryCells = array [Word] of Int8;                                          //Массив ячеек памяти

  TOpCode = (OCAdd, OCSub, OCAnd, OCLor, OCXor);

  TCondition = (FCNZ, FCZ, FCNC, FCC, FCPO, FCPE, FCP, FCM);                    //Состояния

  TInstrGroup = (IGSystem, IGData, IGArithm, IGLogic, IGBranch);                        //Группы инструкций
  TInstrFormat = (IFOnly, IFRegCenter, IFRegEnd, IFRegDouble, IFRegPair, IFCondition);  //Форматы инструкций


implementation

end.
