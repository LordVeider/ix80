unit Typelib;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//���������� �����

interface

const
  WM_CONTROLS = $0410;
  HL_COLOR = -16777203;
  LOG_NEW = #13#10;
  LOG_LINE = '--------------------------------------------------------------------------------';


type
  TNumSys = (SBIN, SDEC, SOCT, SHEX);                                           //������� ���������

  TDataReg = (RB, RC, RD, RE, RH, RL, RM, RA, RW, RZ, RF);                      //��������
  TRegPair = (RPBC, RPDE, RPHL, RPSP);                                          //����������� ����

  TDataRegisters = array [TDataReg] of Int8;
  TRegisters = record
    DataRegisters: TDataRegisters;                                              //�������� ������ (8 bit)
    SP: Word;                                                                   //��������� ����� (16 bit)
    PC: Word;                                                                   //������� ������  (16 bit)
    IR: Byte;                                                                   //������� ������  (8 bit)
  end;

  TFlag = (FS, FZ, FAC, FP, FCY);                                               //�����
  TFlagSet = set of TFlag;
  TFlagArray = array [TFlag] of Byte;

  TMemoryCells = array [Word] of Int8;

  TOpCode = (OCSumm, OCAnd, OCLor, OCXor);

  TCondition = (FCNZ, FCZ, FCNC, FCC, FCPO, FCPE, FCP, FCM);                    //���������

  TInstrGroup = (IGSystem, IGData, IGArithm, IGLogic, IGBranch);                        //������ ����������
  TInstrFormat = (IFOnly, IFRegCenter, IFRegEnd, IFRegDouble, IFRegPair, IFCondition);  //������� ����������


implementation

end.
