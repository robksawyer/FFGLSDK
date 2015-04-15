
{*******************************************************}
{                                                       }
{       Delphi Runtime Library                          }
{       OLE 2 Interface Unit                            }
{                                                       }
{       Copyright (c) 1996,97 Borland International     }
{                                                       }
{*******************************************************}

unit OLE2;

{ WEAKPACKAGEUNIT}

interface

uses Windows;

const
  MEMCTX_TASK	   = 1;
  MEMCTX_SHARED	   = 2;
  MEMCTX_MACSYSTEM = 3;
  MEMCTX_UNKNOWN   = -1;
  MEMCTX_SAME	   = -2;

  ROTFLAGS_REGISTRATIONKEEPSALIVE = 1;

  CLSCTX_INPROC_SERVER	 = 1;
  CLSCTX_INPROC_HANDLER	 = 2;
  CLSCTX_LOCAL_SERVER	 = 4;
  CLSCTX_INPROC_SERVER16 = 8;

  CLSCTX_ALL    = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER or
                  CLSCTX_LOCAL_SERVER;
  CLSCTX_INPROC = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER;
  CLSCTX_SERVER = CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER;

  MSHLFLAGS_NORMAL	= 0;
  MSHLFLAGS_TABLESTRONG	= 1;
  MSHLFLAGS_TABLEWEAK	= 2;

  MSHCTX_LOCAL	          = 0;
  MSHCTX_NOSHAREDMEM	  = 1;
  MSHCTX_DIFFERENTMACHINE = 2;
  MSHCTX_INPROC	          = 3;

  DVASPECT_CONTENT   = 1;
  DVASPECT_THUMBNAIL = 2;
  DVASPECT_ICON	     = 4;
  DVASPECT_DOCPRINT  = 8;

  STGC_DEFAULT	                          = 0;
  STGC_OVERWRITE	                  = 1;
  STGC_ONLYIFCURRENT	                  = 2;
  STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE = 4;

  STGMOVE_MOVE = 0;
  STGMOVE_COPY = 1;

  STATFLAG_DEFAULT = 0;
  STATFLAG_NONAME  = 1;

  BIND_MAYBOTHERUSER	 = 1;
  BIND_JUSTTESTEXISTENCE = 2;

  MKSYS_NONE	         = 0;
  MKSYS_GENERICCOMPOSITE = 1;
  MKSYS_FILEMONIKER	 = 2;
  MKSYS_ANTIMONIKER	 = 3;
  MKSYS_ITEMMONIKER	 = 4;
  MKSYS_POINTERMONIKER	 = 5;

  MKRREDUCE_ONE	        = 3 shl 16;
  MKRREDUCE_TOUSER	= 2 shl 16;
  MKRREDUCE_THROUGHUSER	= 1 shl 16;
  MKRREDUCE_ALL	        = 0;

  STGTY_STORAGE	  = 1;
  STGTY_STREAM	  = 2;
  STGTY_LOCKBYTES = 3;
  STGTY_PROPERTY  = 4;

  STREAM_SEEK_SET = 0;
  STREAM_SEEK_CUR = 1;
  STREAM_SEEK_END = 2;

  LOCK_WRITE	 = 1;
  LOCK_EXCLUSIVE = 2;
  LOCK_ONLYONCE	 = 4;

  ADVF_NODATA	         = 1;
  ADVF_PRIMEFIRST	 = 2;
  ADVF_ONLYONCE	         = 4;
  ADVF_DATAONSTOP	 = 64;
  ADVFCACHE_NOHANDLER	 = 8;
  ADVFCACHE_FORCEBUILTIN = 16;
  ADVFCACHE_ONSAVE	 = 32;

  TYMED_HGLOBAL	 = 1;
  TYMED_FILE     = 2;
  TYMED_ISTREAM  = 4;
  TYMED_ISTORAGE = 8;
  TYMED_GDI	 = 16;
  TYMED_MFPICT	 = 32;
  TYMED_ENHMF	 = 64;
  TYMED_NULL	 = 0;

  DATADIR_GET = 1;
  DATADIR_SET = 2;

  CALLTYPE_TOPLEVEL	        = 1;
  CALLTYPE_NESTED	        = 2;
  CALLTYPE_ASYNC	        = 3;
  CALLTYPE_TOPLEVEL_CALLPENDING	= 4;
  CALLTYPE_ASYNC_CALLPENDING	= 5;

  SERVERCALL_ISHANDLED	= 0;
  SERVERCALL_REJECTED	= 1;
  SERVERCALL_RETRYLATER	= 2;

  PENDINGTYPE_TOPLEVEL = 1;
  PENDINGTYPE_NESTED   = 2;

  PENDINGMSG_CANCELCALL	    = 0;
  PENDINGMSG_WAITNOPROCESS  = 1;
  PENDINGMSG_WAITDEFPROCESS = 2;

  REGCLS_SINGLEUSE      = 0;
  REGCLS_MULTIPLEUSE    = 1;
  REGCLS_MULTI_SEPARATE = 2;

  MARSHALINTERFACE_MIN = 500;

  CWCSTORAGENAME = 32;

  STGM_DIRECT           = $00000000;
  STGM_TRANSACTED       = $00010000;
  STGM_SIMPLE           = $08000000;

  STGM_READ             = $00000000;
  STGM_WRITE            = $00000001;
  STGM_READWRITE        = $00000002;

  STGM_SHARE_DENY_NONE  = $00000040;
  STGM_SHARE_DENY_READ  = $00000030;
  STGM_SHARE_DENY_WRITE = $00000020;
  STGM_SHARE_EXCLUSIVE  = $00000010;

  STGM_PRIORITY         = $00040000;
  STGM_DELETEONRELEASE  = $04000000;

  STGM_CREATE           = $00001000;
  STGM_CONVERT          = $00020000;
  STGM_FAILIFTHERE      = $00000000;

  FADF_AUTO      = $0001;  { array is allocated on the stack }
  FADF_STATIC    = $0002;  { array is staticly allocated }
  FADF_EMBEDDED  = $0004;  { array is embedded in a structure }
  FADF_FIXEDSIZE = $0010;  { array may not be resized or reallocated }
  FADF_BSTR      = $0100;  { an array of BSTRs }
  FADF_UNKNOWN   = $0200;  { an array of IUnknown }
  FADF_DISPATCH  = $0400;  { an array of IDispatch }
  FADF_VARIANT   = $0800;  { an array of VARIANTs }
  FADF_RESERVED  = $F0E8;  { bits reserved for future use }

{ VARENUM usage key,

    [V] - may appear in a VARIANT
    [T] - may appear in a TYPEDESC
    [P] - may appear in an OLE property set
    [S] - may appear in a Safe Array }

  VT_EMPTY           = 0;   { [V]   [P]  nothing                     }
  VT_NULL            = 1;   { [V]        SQL style Null              }
  VT_I2              = 2;   { [V][T][P]  2 byte signed int           }
  VT_I4              = 3;   { [V][T][P]  4 byte signed int           }
  VT_R4              = 4;   { [V][T][P]  4 byte real                 }
  VT_R8              = 5;   { [V][T][P]  8 byte real                 }
  VT_CY              = 6;   { [V][T][P]  currency                    }
  VT_DATE            = 7;   { [V][T][P]  date                        }
  VT_BSTR            = 8;   { [V][T][P]  binary string               }
  VT_DISPATCH        = 9;   { [V][T]     IDispatch FAR*              }
  VT_ERROR           = 10;  { [V][T]     SCODE                       }
  VT_BOOL            = 11;  { [V][T][P]  True=-1, False=0            }
  VT_VARIANT         = 12;  { [V][T][P]  VARIANT FAR*                }
  VT_UNKNOWN         = 13;  { [V][T]     IUnknown FAR*               }

  VT_I1              = 16;  {    [T]     signed char                 }
  VT_UI1             = 17;  {    [T]     unsigned char               }
  VT_UI2             = 18;  {    [T]     unsigned short              }
  VT_UI4             = 19;  {    [T]     unsigned short              }
  VT_I8              = 20;  {    [T][P]  signed 64-bit int           }
  VT_UI8             = 21;  {    [T]     unsigned 64-bit int         }
  VT_INT             = 22;  {    [T]     signed machine int          }
  VT_UINT            = 23;  {    [T]     unsigned machine int        }
  VT_VOID            = 24;  {    [T]     C style void                }
  VT_HRESULT         = 25;  {    [T]                                 }
  VT_PTR             = 26;  {    [T]     pointer type                }
  VT_SAFEARRAY       = 27;  {    [T]     (use VT_ARRAY in VARIANT)   }
  VT_CARRAY          = 28;  {    [T]     C style array               }
  VT_USERDEFINED     = 29;  {    [T]     user defined type          }
  VT_LPSTR           = 30;  {    [T][P]  null terminated string      }
  VT_LPWSTR          = 31;  {    [T][P]  wide null terminated string }

  VT_FILETIME        = 64;  {       [P]  FILETIME                    }
  VT_BLOB            = 65;  {       [P]  Length prefixed bytes       }
  VT_STREAM          = 66;  {       [P]  Name of the stream follows  }
  VT_STORAGE         = 67;  {       [P]  Name of the storage follows }
  VT_STREAMED_OBJECT = 68;  {       [P]  Stream contains an object   }
  VT_STORED_OBJECT   = 69;  {       [P]  Storage contains an object  }
  VT_BLOB_OBJECT     = 70;  {       [P]  Blob contains an object     }
  VT_CF              = 71;  {       [P]  Clipboard format            }
  VT_CLSID           = 72;  {       [P]  A Class ID                  }

  VT_VECTOR       = $1000;  {       [P]  simple counted array        }
  VT_ARRAY        = $2000;  { [V]        SAFEARRAY*                  }
  VT_BYREF        = $4000;  { [V]                                    }
  VT_RESERVED     = $8000;

  TKIND_ENUM      = 0;
  TKIND_RECORD    = 1;
  TKIND_MODULE    = 2;
  TKIND_INTERFACE = 3;
  TKIND_DISPATCH  = 4;
  TKIND_COCLASS   = 5;
  TKIND_ALIAS     = 6;
  TKIND_UNION     = 7;
  TKIND_MAX       = 8;

  CC_CDECL     = 1;
  CC_PASCAL    = 2;
  CC_MACPASCAL = 3;
  CC_STDCALL   = 4;
  CC_RESERVED  = 5;
  CC_SYSCALL   = 6;
  CC_MPWCDECL  = 7;
  CC_MPWPASCAL = 8;
  CC_MAX       = 9;

  FUNC_VIRTUAL     = 0;
  FUNC_PUREVIRTUAL = 1;
  FUNC_NONVIRTUAL  = 2;
  FUNC_STATIC      = 3;
  FUNC_DISPATCH    = 4;

  INVOKE_FUNC           = 1;
  INVOKE_PROPERTYGET    = 2;
  INVOKE_PROPERTYPUT    = 4;
  INVOKE_PROPERTYPUTREF = 8;

  VAR_PERINSTANCE = 0;
  VAR_STATIC      = 1;
  VAR_CONST       = 2;
  VAR_DISPATCH    = 3;

  IMPLTYPEFLAG_FDEFAULT    = 1;
  IMPLTYPEFLAG_FSOURCE     = 2;
  IMPLTYPEFLAG_FRESTRICTED = 4;

  TYPEFLAG_FAPPOBJECT	  = $0001;
  TYPEFLAG_FCANCREATE	  = $0002;
  TYPEFLAG_FLICENSED	  = $0004;
  TYPEFLAG_FPREDECLID	  = $0008;
  TYPEFLAG_FHIDDEN	  = $0010;
  TYPEFLAG_FCONTROL	  = $0020;
  TYPEFLAG_FDUAL	  = $0040;
  TYPEFLAG_FNONEXTENSIBLE = $0080;
  TYPEFLAG_FOLEAUTOMATION = $0100;

  FUNCFLAG_FRESTRICTED	= $0001;
  FUNCFLAG_FSOURCE	= $0002;
  FUNCFLAG_FBINDABLE	= $0004;
  FUNCFLAG_FREQUESTEDIT	= $0008;
  FUNCFLAG_FDISPLAYBIND	= $0010;
  FUNCFLAG_FDEFAULTBIND	= $0020;
  FUNCFLAG_FHIDDEN	= $0040;

  VARFLAG_FREADONLY    = $0001;
  VARFLAG_FSOURCE      = $0002;
  VARFLAG_FBINDABLE    = $0004;
  VARFLAG_FREQUESTEDIT = $0008;
  VARFLAG_FDISPLAYBIND = $0010;
  VARFLAG_FDEFAULTBIND = $0020;
  VARFLAG_FHIDDEN      = $0040;

  DISPID_VALUE       = 0;
  DISPID_UNKNOWN     = -1;
  DISPID_PROPERTYPUT = -3;
  DISPID_NEWENUM     = -4;
  DISPID_EVALUATE    = -5;
  DISPID_CONSTRUCTOR = -6;
  DISPID_DESTRUCTOR  = -7;
  DISPID_COLLECT     = -8;

  DESCKIND_NONE = 0;
  DESCKIND_FUNCDESC = 1;
  DESCKIND_VARDESC = 2;
  DESCKIND_TYPECOMP = 3;
  DESCKIND_IMPLICITAPPOBJ = 4;
  DESCKIND_MAX = 5;

  SYS_WIN16 = 0;
  SYS_WIN32 = 1;
  SYS_MAC   = 2;

  LIBFLAG_FRESTRICTED = 1;
  LIBFLAG_FCONTROL    = 2;
  LIBFLAG_FHIDDEN     = 4;

  STDOLE_MAJORVERNUM = 1;
  STDOLE_MINORVERNUM = 0;

  STDOLE_LCID = 0;

  VARIANT_NOVALUEPROP = 1;

  VAR_TIMEVALUEONLY = 1;
  VAR_DATEVALUEONLY = 2;

  MEMBERID_NIL = DISPID_UNKNOWN;

  ID_DEFAULTINST = -2;

  IDLFLAG_NONE    = 0;
  IDLFLAG_FIN     = 1;
  IDLFLAG_FOUT    = 2;
  IDLFLAG_FLCID   = 4;
  IDLFLAG_FRETVAL = 8;

  DISPATCH_METHOD         = 1;
  DISPATCH_PROPERTYGET    = 2;
  DISPATCH_PROPERTYPUT    = 4;
  DISPATCH_PROPERTYPUTREF = 8;

  OLEIVERB_PRIMARY          = 0;
  OLEIVERB_SHOW             = -1;
  OLEIVERB_OPEN             = -2;
  OLEIVERB_HIDE             = -3;
  OLEIVERB_UIACTIVATE       = -4;
  OLEIVERB_INPLACEACTIVATE  = -5;
  OLEIVERB_DISCARDUNDOSTATE = -6;

  EMBDHLP_INPROC_HANDLER = $00000000;
  EMBDHLP_INPROC_SERVER  = $00000001;
  EMBDHLP_CREATENOW      = $00000000;
  EMBDHLP_DELAYCREATE    = $00010000;

  UPDFCACHE_NODATACACHE = 1;
  UPDFCACHE_ONSAVECACHE = 2;
  UPDFCACHE_ONSTOPCACHE = 4;
  UPDFCACHE_NORMALCACHE = 8;
  UPDFCACHE_IFBLANK     = $10;
  UPDFCACHE_ONLYIFBLANK = $80000000;

  UPDFCACHE_IFBLANKORONSAVECACHE = UPDFCACHE_IFBLANK or UPDFCACHE_ONSAVECACHE;
  UPDFCACHE_ALL                  = not UPDFCACHE_ONLYIFBLANK;
  UPDFCACHE_ALLBUTNODATACACHE    = UPDFCACHE_ALL and not UPDFCACHE_NODATACACHE;

  DISCARDCACHE_SAVEIFDIRTY = 0;
  DISCARDCACHE_NOSAVE      = 1;

  OLEGETMONIKER_ONLYIFTHERE = 1;
  OLEGETMONIKER_FORCEASSIGN = 2;
  OLEGETMONIKER_UNASSIGN    = 3;
  OLEGETMONIKER_TEMPFORUSER = 4;

  OLEWHICHMK_CONTAINER = 1;
  OLEWHICHMK_OBJREL    = 2;
  OLEWHICHMK_OBJFULL   = 3;

  USERCLASSTYPE_FULL    = 1;
  USERCLASSTYPE_SHORT   = 2;
  USERCLASSTYPE_APPNAME = 3;

  OLEMISC_RECOMPOSEONRESIZE	       = 1;
  OLEMISC_ONLYICONIC	               = 2;
  OLEMISC_INSERTNOTREPLACE	       = 4;
  OLEMISC_STATIC	               = 8;
  OLEMISC_CANTLINKINSIDE	       = 16;
  OLEMISC_CANLINKBYOLE1	               = 32;
  OLEMISC_ISLINKOBJECT	               = 64;
  OLEMISC_INSIDEOUT	               = 128;
  OLEMISC_ACTIVATEWHENVISIBLE	       = 256;
  OLEMISC_RENDERINGISDEVICEINDEPENDENT = 512;

  OLECLOSE_SAVEIFDIRTY = 0;
  OLECLOSE_NOSAVE      = 1;
  OLECLOSE_PROMPTSAVE  = 2;

  OLERENDER_NONE   = 0;
  OLERENDER_DRAW   = 1;
  OLERENDER_FORMAT = 2;
  OLERENDER_ASIS   = 3;

  OLEUPDATE_ALWAYS = 1;
  OLEUPDATE_ONCALL = 3;

  OLELINKBIND_EVENIFCLASSDIFF = 1;

  BINDSPEED_INDEFINITE = 1;
  BINDSPEED_MODERATE   = 2;
  BINDSPEED_IMMEDIATE  = 3;

  OLECONTF_EMBEDDINGS	 = 1;
  OLECONTF_LINKS	 = 2;
  OLECONTF_OTHERS	 = 4;
  OLECONTF_ONLYUSER	 = 8;
  OLECONTF_ONLYIFRUNNING = 16;

  DROPEFFECT_NONE   = 0;
  DROPEFFECT_COPY   = 1;
  DROPEFFECT_MOVE   = 2;
  DROPEFFECT_LINK   = 4;
  DROPEFFECT_SCROLL = $80000000;

  DD_DEFSCROLLINSET    = 11;
  DD_DEFSCROLLDELAY    = 50;
  DD_DEFSCROLLINTERVAL = 50;
  DD_DEFDRAGDELAY      = 200;
  DD_DEFDRAGMINDIST    = 2;

  OLEVERBATTRIB_NEVERDIRTIES    = 1;
  OLEVERBATTRIB_ONCONTAINERMENU = 2;

type

{ Result code }

  HResult = Longint;

  PResultList = ^TResultList;
  TResultList = array[0..65535] of HResult;

{ OLE character and string types }

  TOleChar = WideChar;
  POleStr = PWideChar;

  POleStrList = ^TOleStrList;
  TOleStrList = array[0..65535] of POleStr;

{ 64-bit large integer }

  Largeint = Comp;

{ Globally unique ID }

  PGUID = ^TGUID;
  TGUID = record
    D1: Longint;
    D2: Word;
    D3: Word;
    D4: array[0..7] of Byte;
  end;

{ Interface ID }

  PIID = PGUID;
  TIID = TGUID;

{ Class ID }

  PCLSID = PGUID;
  TCLSID = TGUID;

{ Object ID }

  PObjectID = ^TObjectID;
  TObjectID = record
    Lineage: TGUID;
    Uniquifier: Longint;
  end;

{ Locale ID }

  TLCID = Longint;

{ Forward declarations }

  IStream = class;
  IRunningObjectTable = class;
  IEnumString = class;
  IMoniker = class;
  IAdviseSink = class;
  IDispatch = class;
  ITypeInfo = class;
  ITypeComp = class;
  ITypeLib = class;
  IEnumOleVerb = class;
  IOleInPlaceActiveObject = class;

{ IUnknown interface }

  IUnknown = class
  public
    function QueryInterface(const iid: TIID; var obj): HResult; virtual; stdcall; abstract;
    function AddRef: Longint; virtual; stdcall; abstract;
    function Release: Longint; virtual; stdcall; abstract;
  end;

{ IClassFactory interface }

  IClassFactory = class(IUnknown)
  public
    function CreateInstance(unkOuter: IUnknown; const iid: TIID;
      var obj): HResult; virtual; stdcall; abstract;
    function LockServer(fLock: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IMarshal interface }

  IMarshal = class(IUnknown)
  public
    function GetUnmarshalClass(const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
      var cid: TCLSID): HResult; virtual; stdcall; abstract;
    function GetMarshalSizeMax(const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
      var size: Longint): HResult; virtual; stdcall; abstract;
    function MarshalInterface(stm: IStream; const iid: TIID; pv: Pointer;
      dwDestContext: Longint; pvDestContext: Pointer;
      mshlflags: Longint): HResult; virtual; stdcall; abstract;
    function UnmarshalInterface(stm: IStream; const iid: TIID;
      var pv): HResult; virtual; stdcall; abstract;
    function ReleaseMarshalData(stm: IStream): HResult;
      virtual; stdcall; abstract;
    function DisconnectObject(dwReserved: Longint): HResult;
      virtual; stdcall; abstract;
  end;

{ IMalloc interface }

  IMalloc = class(IUnknown)
  public
    function Alloc(cb: Longint): Pointer; virtual; stdcall; abstract;
    function Realloc(pv: Pointer; cb: Longint): Pointer; virtual; stdcall; abstract;
    procedure Free(pv: Pointer); virtual; stdcall; abstract;
    function GetSize(pv: Pointer): Longint; virtual; stdcall; abstract;
    function DidAlloc(pv: Pointer): Integer; virtual; stdcall; abstract;
    procedure HeapMinimize; virtual; stdcall; abstract;
  end;

{ IMallocSpy interface }

  IMallocSpy = class(IUnknown)
  public
    function PreAlloc(cbRequest: Longint): Longint; virtual; stdcall; abstract;
    function PostAlloc(pActual: Pointer): Pointer; virtual; stdcall; abstract;
    function PreFree(pRequest: Pointer; fSpyed: BOOL): Pointer; virtual; stdcall; abstract;
    procedure PostFree(fSpyed: BOOL); virtual; stdcall; abstract;
    function PreRealloc(pRequest: Pointer; cbRequest: Longint;
      var ppNewRequest: Pointer; fSpyed: BOOL): Longint; virtual; stdcall; abstract;
    function PostRealloc(pActual: Pointer; fSpyed: BOOL): Pointer; virtual; stdcall; abstract;
    function PreGetSize(pRequest: Pointer; fSpyed: BOOL): Pointer; virtual; stdcall; abstract;
    function PostGetSize(pActual: Pointer; fSpyed: BOOL): Longint; virtual; stdcall; abstract;
    function PostDidAlloc(pRequest: Pointer; fSpyed: BOOL; fActual: Integer): Integer; virtual; stdcall; abstract;
    procedure PreHeapMinimize; virtual; stdcall; abstract;
    procedure PostHeapMinimize; virtual; stdcall; abstract;
  end;

{ IStdMarshalInfo interface }

  IStdMarshalInfo = class(IUnknown)
  public
    function GetClassForHandler(dwDestContext: Longint; pvDestContext: Pointer;
      var clsid: TCLSID): HResult; virtual; stdcall; abstract;
  end;

{ IExternalConnection interface }

  IExternalConnection = class(IUnknown)
  public
    function AddConnection(extconn: Longint; reserved: Longint): Longint;
      virtual; stdcall; abstract;
    function ReleaseConnection(extconn: Longint; reserved: Longint;
      fLastReleaseCloses: BOOL): Longint; virtual; stdcall; abstract;
  end;

{ IWeakRef interface }

  IWeakRef = class(IUnknown)
  public
    function ChangeWeakCount(delta: Longint): Longint; virtual; stdcall; abstract;
    function ReleaseKeepAlive(unkReleased: IUnknown;
      reserved: Longint): Longint; virtual; stdcall; abstract;
  end;

{ IEnumUnknown interface }

  IEnumUnknown = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enm: IEnumUnknown): HResult; virtual; stdcall; abstract;
  end;

{ IBindCtx interface }

  PBindOpts = ^TBindOpts;
  TBindOpts = record
    cbStruct: Longint;
    grfFlags: Longint;
    grfMode: Longint;
    dwTickCountDeadline: Longint;
  end;

  IBindCtx = class(IUnknown)
  public
    function RegisterObjectBound(unk: IUnknown): HResult; virtual; stdcall; abstract;
    function RevokeObjectBound(unk: IUnknown): HResult; virtual; stdcall; abstract;
    function ReleaseBoundObjects: HResult; virtual; stdcall; abstract;
    function SetBindOptions(var bindopts: TBindOpts): HResult; virtual; stdcall; abstract;
    function GetBindOptions(var bindopts: TBindOpts): HResult; virtual; stdcall; abstract;
    function GetRunningObjectTable(var rot: IRunningObjectTable): HResult;
      virtual; stdcall; abstract;
    function RegisterObjectParam(pszKey: POleStr; unk: IUnknown): HResult;
      virtual; stdcall; abstract;
    function GetObjectParam(pszKey: POleStr; var unk: IUnknown): HResult;
      virtual; stdcall; abstract;
    function EnumObjectParam(var enum: IEnumString): HResult; virtual; stdcall; abstract;
    function RevokeObjectParam(pszKey: POleStr): HResult; virtual; stdcall; abstract;
  end;

{ IEnumMoniker interface }

  IEnumMoniker = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enm: IEnumMoniker): HResult; virtual; stdcall; abstract;
  end;

{ IRunnableObject interface }

  IRunnableObject = class(IUnknown)
  public
    function GetRunningClass(var clsid: TCLSID): HResult; virtual; stdcall; abstract;
    function Run(bc: IBindCtx): HResult; virtual; stdcall; abstract;
    function IsRunning: BOOL; virtual; stdcall; abstract;
    function LockRunning(fLock: BOOL; fLastUnlockCloses: BOOL): HResult;
      virtual; stdcall; abstract;
    function SetContainedObject(fContained: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IRunningObjectTable interface }

  IRunningObjectTable = class(IUnknown)
  public
    function Register(grfFlags: Longint; var unkObject: IUnknown;
      mkObjectName: IMoniker; var dwRegister: Longint): HResult; virtual; stdcall; abstract;
    function Revoke(dwRegister: Longint): HResult; virtual; stdcall; abstract;
    function IsRunning(mkObjectName: IMoniker): HResult; virtual; stdcall; abstract;
    function GetObject(mkObjectName: IMoniker;
      var unkObject: IUnknown): HResult; virtual; stdcall; abstract;
    function NoteChangeTime(dwRegister: Longint;
      var filetime: TFileTime): HResult; virtual; stdcall; abstract;
    function GetTimeOfLastChange(mkObjectName: IMoniker;
      var filetime: TFileTime): HResult; virtual; stdcall; abstract;
    function EnumRunning(var enumMoniker: IEnumMoniker): HResult; virtual; stdcall; abstract;
  end;

{ IPersist interface }

  IPersist = class(IUnknown)
  public
    function GetClassID(var classID: TCLSID): HResult; virtual; stdcall; abstract;
  end;

{ IPersistStream interface }

  IPersistStream = class(IPersist)
  public
    function IsDirty: HResult; virtual; stdcall; abstract;
    function Load(stm: IStream): HResult; virtual; stdcall; abstract;
    function Save(stm: IStream; fClearDirty: BOOL): HResult; virtual; stdcall; abstract;
    function GetSizeMax(var cbSize: Largeint): HResult; virtual; stdcall; abstract;
  end;

{ IMoniker interface }

  IMoniker = class(IPersistStream)
  public
    function BindToObject(bc: IBindCtx; mkToLeft: IMoniker;
      const iidResult: TIID; var vResult): HResult; virtual; stdcall; abstract;
    function BindToStorage(bc: IBindCtx; mkToLeft: IMoniker;
      const iid: TIID; var vObj): HResult; virtual; stdcall; abstract;
    function Reduce(bc: IBindCtx; dwReduceHowFar: Longint;
      var mkToLeft: IMoniker; var mkReduced: IMoniker): HResult; virtual; stdcall; abstract;
    function ComposeWith(mkRight: IMoniker; fOnlyIfNotGeneric: BOOL;
      var mkComposite: IMoniker): HResult; virtual; stdcall; abstract;
    function Enum(fForward: BOOL; var enumMoniker: IEnumMoniker): HResult;
      virtual; stdcall; abstract;
    function IsEqual(mkOtherMoniker: IMoniker): HResult; virtual; stdcall; abstract;
    function Hash(var dwHash: Longint): HResult; virtual; stdcall; abstract;
    function IsRunning(bc: IBindCtx; mkToLeft: IMoniker;
      mkNewlyRunning: IMoniker): HResult; virtual; stdcall; abstract;
    function GetTimeOfLastChange(bc: IBindCtx; mkToLeft: IMoniker;
      var filetime: TFileTime): HResult; virtual; stdcall; abstract;
    function Inverse(var mk: IMoniker): HResult; virtual; stdcall; abstract;
    function CommonPrefixWith(mkOther: IMoniker;
      var mkPrefix: IMoniker): HResult; virtual; stdcall; abstract;
    function RelativePathTo(mkOther: IMoniker;
      var mkRelPath: IMoniker): HResult; virtual; stdcall; abstract;
    function GetDisplayName(bc: IBindCtx; mkToLeft: IMoniker;
      var pszDisplayName: POleStr): HResult; virtual; stdcall; abstract;
    function ParseDisplayName(bc: IBindCtx; mkToLeft: IMoniker;
      pszDisplayName: POleStr; var chEaten: Longint;
      var mkOut: IMoniker): HResult; virtual; stdcall; abstract;
    function IsSystemMoniker(var dwMksys: Longint): HResult; virtual; stdcall; abstract;
  end;

{ IEnumString interface }

  IEnumString = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enm: IEnumString): HResult; virtual; stdcall; abstract;
  end;

{ IStream interface }

  PStatStg = ^TStatStg;
  TStatStg = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;

  IStream = class(IUnknown)
  public
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
      virtual; stdcall; abstract;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
      virtual; stdcall; abstract;
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      var libNewPosition: Largeint): HResult; virtual; stdcall; abstract;
    function SetSize(libNewSize: Largeint): HResult; virtual; stdcall; abstract;
    function CopyTo(stm: IStream; cb: Largeint; var cbRead: Largeint;
      var cbWritten: Largeint): HResult; virtual; stdcall; abstract;
    function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall; abstract;
    function Revert: HResult; virtual; stdcall; abstract;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall; abstract;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall; abstract;
    function Stat(var statstg: TStatStg; grfStatFlag: Longint): HResult;
      virtual; stdcall; abstract;
    function Clone(var stm: IStream): HResult; virtual; stdcall; abstract;
  end;

{ IEnumStatStg interface }

  IEnumStatStg = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enm: IEnumStatStg): HResult; virtual; stdcall; abstract;
  end;

{ IStorage interface }

  TSNB = ^POleStr;

  IStorage = class(IUnknown)
  public
    function CreateStream(pwcsName: POleStr; grfMode: Longint; reserved1: Longint;
      reserved2: Longint; var stm: IStream): HResult; virtual; stdcall; abstract;
    function OpenStream(pwcsName: POleStr; reserved1: Pointer; grfMode: Longint;
      reserved2: Longint; var stm: IStream): HResult; virtual; stdcall; abstract;
    function CreateStorage(pwcsName: POleStr; grfMode: Longint;
      dwStgFmt: Longint; reserved2: Longint; var stg: IStorage): HResult;
      virtual; stdcall; abstract;
    function OpenStorage(pwcsName: POleStr; stgPriority: IStorage;
      grfMode: Longint; snbExclude: TSNB; reserved: Longint;
      var stg: IStorage): HResult; virtual; stdcall; abstract;
    function CopyTo(ciidExclude: Longint; rgiidExclude: PIID;
      snbExclude: TSNB; stgDest: IStorage): HResult; virtual; stdcall; abstract;
    function MoveElementTo(pwcsName: POleStr; stgDest: IStorage;
      pwcsNewName: POleStr; grfFlags: Longint): HResult; virtual; stdcall; abstract;
    function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall; abstract;
    function Revert: HResult; virtual; stdcall; abstract;
    function EnumElements(reserved1: Longint; reserved2: Pointer; reserved3: Longint;
      var enm: IEnumStatStg): HResult; virtual; stdcall; abstract;
    function DestroyElement(pwcsName: POleStr): HResult; virtual; stdcall; abstract;
    function RenameElement(pwcsOldName: POleStr;
      pwcsNewName: POleStr): HResult; virtual; stdcall; abstract;
    function SetElementTimes(pwcsName: POleStr; const ctime: TFileTime;
      const atime: TFileTime; const mtime: TFileTime): HResult;
      virtual; stdcall; abstract;
    function SetClass(const clsid: TCLSID): HResult; virtual; stdcall; abstract;
    function SetStateBits(grfStateBits: Longint; grfMask: Longint): HResult;
      virtual; stdcall; abstract;
    function Stat(var statstg: TStatStg; grfStatFlag: Longint): HResult;
      virtual; stdcall; abstract;
  end;

{ IPersistFile interface }

  IPersistFile = class(IPersist)
  public
    function IsDirty: HResult; virtual; stdcall; abstract;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult;
      virtual; stdcall; abstract;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
      virtual; stdcall; abstract;
    function SaveCompleted(pszFileName: POleStr): HResult;
      virtual; stdcall; abstract;
    function GetCurFile(var pszFileName: POleStr): HResult;
      virtual; stdcall; abstract;
  end;

{ IPersistStorage interface }

  IPersistStorage = class(IPersist)
  public
    function IsDirty: HResult; virtual; stdcall; abstract;
    function InitNew(stg: IStorage): HResult; virtual; stdcall; abstract;
    function Load(stg: IStorage): HResult; virtual; stdcall; abstract;
    function Save(stgSave: IStorage; fSameAsLoad: BOOL): HResult;
      virtual; stdcall; abstract;
    function SaveCompleted(stgNew: IStorage): HResult; virtual; stdcall; abstract;
    function HandsOffStorage: HResult; virtual; stdcall; abstract;
  end;

{ ILockBytes interface }

  ILockBytes = class(IUnknown)
  public
    function ReadAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbRead: PLongint): HResult; virtual; stdcall; abstract;
    function WriteAt(ulOffset: Largeint; pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; virtual; stdcall; abstract;
    function Flush: HResult; virtual; stdcall; abstract;
    function SetSize(cb: Largeint): HResult; virtual; stdcall; abstract;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall; abstract;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall; abstract;
    function Stat(var statstg: TStatStg; grfStatFlag: Longint): HResult;
      virtual; stdcall; abstract;
  end;

{ IEnumFormatEtc interface }

  PDVTargetDevice = ^TDVTargetDevice;
  TDVTargetDevice = record
    tdSize: Longint;
    tdDriverNameOffset: Word;
    tdDeviceNameOffset: Word;
    tdPortNameOffset: Word;
    tdExtDevmodeOffset: Word;
    tdData: record end;
  end;

  PClipFormat = ^TClipFormat;
  TClipFormat = Word;

  PFormatEtc = ^TFormatEtc;
  TFormatEtc = record
    cfFormat: TClipFormat;
    ptd: PDVTargetDevice;
    dwAspect: Longint;
    lindex: Longint;
    tymed: Longint;
  end;

  IEnumFormatEtc = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enum: IEnumFormatEtc): HResult; virtual; stdcall; abstract;
  end;

{ IEnumStatData interface }

  PStatData = ^TStatData;
  TStatData = record
    formatetc: TFormatEtc;
    advf: Longint;
    advSink: IAdviseSink;
    dwConnection: Longint;
  end;

  IEnumStatData = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enum: IEnumStatData): HResult; virtual; stdcall; abstract;
  end;

{ IRootStorage interface }

  IRootStorage = class(IUnknown)
  public
    function SwitchToFile(pszFile: POleStr): HResult; virtual; stdcall; abstract;
  end;

{ IAdviseSink interface }

  PRemStgMedium = ^TRemStgMedium;
  TRemStgMedium = record
    tymed: Longint;
    dwHandleType: Longint;
    pData: Longint;
    pUnkForRelease: Longint;
    cbData: Longint;
    data: record end;
  end;

  PStgMedium = ^TStgMedium;
  TStgMedium = record
    tymed: Longint;
    case Integer of
      0: (hBitmap: HBitmap; unkForRelease: IUnknown);
      1: (hMetaFilePict: THandle);
      2: (hEnhMetaFile: THandle);
      3: (hGlobal: HGlobal);
      4: (lpszFileName: POleStr);
      5: (stm: IStream);
      6: (stg: IStorage);
  end;

  IAdviseSink = class(IUnknown)
  public
    procedure OnDataChange(var formatetc: TFormatEtc; var stgmed: TStgMedium);
      virtual; stdcall; abstract;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint);
      virtual; stdcall; abstract;
    procedure OnRename(mk: IMoniker); virtual; stdcall; abstract;
    procedure OnSave; virtual; stdcall; abstract;
    procedure OnClose; virtual; stdcall; abstract;
  end;

{ IAdviseSink2 interface }

  IAdviseSink2 = class(IAdviseSink)
  public
    procedure OnLinkSrcChange(mk: IMoniker); virtual; stdcall; abstract;
  end;

{ IDataObject interface }

  IDataObject = class(IUnknown)
  public
    function GetData(var formatetcIn: TFormatEtc; var medium: TStgMedium):
      HResult; virtual; stdcall; abstract;
    function GetDataHere(var formatetc: TFormatEtc; var medium: TStgMedium):
      HResult; virtual; stdcall; abstract;
    function QueryGetData(var formatetc: TFormatEtc): HResult;
      virtual; stdcall; abstract;
    function GetCanonicalFormatEtc(var formatetc: TFormatEtc;
      var formatetcOut: TFormatEtc): HResult; virtual; stdcall; abstract;
    function SetData(var formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; virtual; stdcall; abstract;
    function EnumFormatEtc(dwDirection: Longint; var enumFormatEtc:
      IEnumFormatEtc): HResult; virtual; stdcall; abstract;
    function DAdvise(var formatetc: TFormatEtc; advf: Longint;
      advSink: IAdviseSink; var dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function DUnadvise(dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function EnumDAdvise(var enumAdvise: IEnumStatData): HResult;
      virtual; stdcall; abstract;
  end;

{ IDataAdviseHolder interface }

  IDataAdviseHolder = class(IUnknown)
  public
    function Advise(dataObject: IDataObject; var fetc: TFormatEtc;
      advf: Longint; advise: IAdviseSink; var pdwConnection: Longint): HResult;
      virtual; stdcall; abstract;
    function Unadvise(dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function EnumAdvise(var enumAdvise: IEnumStatData): HResult; virtual; stdcall; abstract;
    function SendOnDataChange(dataObject: IDataObject; dwReserved: Longint;
      advf: Longint): HResult; virtual; stdcall; abstract;
  end;

{ IMessageFilter interface }

  PInterfaceInfo = ^TInterfaceInfo;
  TInterfaceInfo = record
    unk: IUnknown;
    iid: TIID;
    wMethod: Word;
  end;

  IMessageFilter = class(IUnknown)
  public
    function HandleInComingCall(dwCallType: Longint; htaskCaller: HTask;
      dwTickCount: Longint; lpInterfaceInfo: PInterfaceInfo): Longint;
      virtual; stdcall; abstract;
    function RetryRejectedCall(htaskCallee: HTask; dwTickCount: Longint;
      dwRejectType: Longint): Longint; virtual; stdcall; abstract;
    function MessagePending(htaskCallee: HTask; dwTickCount: Longint;
      dwPendingType: Longint): Longint; virtual; stdcall; abstract;
  end;

{ IRpcChannelBuffer interface }

  TRpcOleDataRep = Longint;

  PRpcOleMessage = ^TRpcOleMessage;
  TRpcOleMessage = record
    reserved1: Pointer;
    dataRepresentation: TRpcOleDataRep;
    Buffer: Pointer;
    cbBuffer: Longint;
    iMethod: Longint;
    reserved2: array[0..4] of Pointer;
    rpcFlags: Longint;
  end;

  IRpcChannelBuffer = class(IUnknown)
  public
    function GetBuffer(var message: TRpcOleMessage; iid: TIID): HResult;
      virtual; stdcall; abstract;
    function SendReceive(var message: TRpcOleMessage;
      var status: Longint): HResult; virtual; stdcall; abstract;
    function FreeBuffer(var message: TRpcOleMessage): HResult;
      virtual; stdcall; abstract;
    function GetDestCtx(var dwDestContext: Longint;
      var pvDestContext): HResult; virtual; stdcall; abstract;
    function IsConnected: HResult; virtual; stdcall; abstract;
  end;

{ IRpcProxyBuffer interface }

  IRpcProxyBuffer = class(IUnknown)
  public
    function Connect(rpcChannelBuffer: IRpcChannelBuffer): HResult;
      virtual; stdcall; abstract;
    procedure Disconnect; virtual; stdcall; abstract;
  end;

{ IRpcStubBuffer interface }

  IRpcStubBuffer = class(IUnknown)
  public
    function Connect(unkServer: IUnknown): HResult; virtual; stdcall; abstract;
    procedure Disconnect; virtual; stdcall; abstract;
    function Invoke(var rpcmsg: TRpcOleMessage; rpcChannelBuffer:
      IRpcChannelBuffer): HResult; virtual; stdcall; abstract;
    function IsIIDSupported(const iid: TIID): IRpcStubBuffer;
      virtual; stdcall; abstract;
    function CountRefs: Longint; virtual; stdcall; abstract;
    function DebugServerQueryInterface(var pv): HResult;
      virtual; stdcall; abstract;
    procedure DebugServerRelease(pv: Pointer); virtual; stdcall; abstract;
  end;

{ IPSFactoryBuffer interface }

  IPSFactoryBuffer = class(IUnknown)
  public
    function CreateProxy(unkOuter: IUnknown; const iid: TIID;
      var proxy: IRpcProxyBuffer; var pv): HResult; virtual; stdcall; abstract;
    function CreateStub(const iid: TIID; unkServer: IUnknown;
      var stub: IRpcStubBuffer): HResult; virtual; stdcall; abstract;
  end;

{ Automation types }

  PBStr = ^TBStr;
  TBStr = POleStr;

  PBStrList = ^TBStrList;
  TBStrList = array[0..65535] of TBStr;

  PBlob = ^TBlob;
  TBlob = record
    cbSize: Longint;
    pBlobData: Pointer;
  end;

  PClipData = ^TClipData;
  TClipData = record
    cbSize: Longint;
    ulClipFmt: Longint;
    pClipData: Pointer;
  end;

  PSafeArrayBound = ^TSafeArrayBound;
  TSafeArrayBound = record
    cElements: Longint;
    lLbound: Longint;
  end;

  PSafeArray = ^TSafeArray;
  TSafeArray = record
    cDims: Word;
    fFeatures: Word;
    cbElements: Longint;
    cLocks: Longint;
    pvData: Pointer;
    rgsabound: array[0..0] of TSafeArrayBound;
  end;

  TOleDate = Double;

  TCurrency = Comp;

  TOleBool = WordBool;

  TVarType = Word;

  PVariantArg = ^TVariantArg;
  TVariantArg = record
    vt: TVarType;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      VT_UI1:                  (bVal: Byte);
      VT_I2:                   (iVal: Smallint);
      VT_I4:                   (lVal: Longint);
      VT_R4:                   (fltVal: Single);
      VT_R8:                   (dblVal: Double);
      VT_BOOL:                 (vbool: TOleBool);
      VT_ERROR:                (scode: HResult);
      VT_CY:                   (cyVal: TCurrency);
      VT_DATE:                 (date: TOleDate);
      VT_BSTR:                 (bstrVal: TBStr);
      VT_UNKNOWN:              (unkVal: IUnknown);
      VT_DISPATCH:             (dispVal: IDispatch);
      VT_ARRAY:                (parray: PSafeArray);
      VT_BYREF or VT_UI1:      (pbVal: ^Byte);
      VT_BYREF or VT_I2:       (piVal: ^Smallint);
      VT_BYREF or VT_I4:       (plVal: ^Longint);
      VT_BYREF or VT_R4:       (pfltVal: ^Single);
      VT_BYREF or VT_R8:       (pdblVal: ^Double);
      VT_BYREF or VT_BOOL:     (pbool: ^TOleBool);
      VT_BYREF or VT_ERROR:    (pscode: ^HResult);
      VT_BYREF or VT_CY:       (pcyVal: ^TCurrency);
      VT_BYREF or VT_DATE:     (pdate: ^TOleDate);
      VT_BYREF or VT_BSTR:     (pbstrVal: PBStr);
      VT_BYREF or VT_UNKNOWN:  (punkVal: ^IUnknown);
      VT_BYREF or VT_DISPATCH: (pdispVal: ^IDispatch);
      VT_BYREF or VT_ARRAY:    (pparray: ^PSafeArray);
      VT_BYREF or VT_VARIANT:  (pvarVal: PVariant);
      VT_BYREF:                (byRef: Pointer);
  end;

  PVariantArgList = ^TVariantArgList;
  TVariantArgList = array[0..65535] of TVariantArg;

  TDispID = Longint;

  PDispIDList = ^TDispIDList;
  TDispIDList = array[0..65535] of TDispID;

  TMemberID = Longint;

  PMemberIDList = ^TMemberIDList;
  TMemberIDList = array[0..65535] of TMemberID;

  TPropID = Longint;

  HRefType = Longint;

  TTypeKind = Longint;

  PArrayDesc = ^TArrayDesc;

  PTypeDesc= ^TTypeDesc;
  TTypeDesc = record
    case Integer of
      VT_PTR:         (ptdesc: PTypeDesc; vt: TVarType);
      VT_CARRAY:      (padesc: PArrayDesc);
      VT_USERDEFINED: (hreftype: HRefType);
  end;

  TArrayDesc = record
    tdescElem: TTypeDesc;
    cDims: Word;
    rgbounds: array[0..0] of TSafeArrayBound;
  end;

  PIDLDesc = ^TIDLDesc;
  TIDLDesc = record
    dwReserved: Longint;
    wIDLFlags: Word;
  end;

  PElemDesc = ^TElemDesc;
  TElemDesc = record
    tdesc: TTypeDesc;
    idldesc: TIDLDesc;
  end;

  PElemDescList = ^TElemDescList;
  TElemDescList = array[0..65535] of TElemDesc;

  PTypeAttr = ^TTypeAttr;
  TTypeAttr = record
    guid: TGUID;
    lcid: TLCID;
    dwReserved: Longint;
    memidConstructor: TMemberID;
    memidDestructor: TMemberID;
    lpstrSchema: POleStr;
    cbSizeInstance: Longint;
    typekind: TTypeKind;
    cFuncs: Word;
    cVars: Word;
    cImplTypes: Word;
    cbSizeVft: Word;
    cbAlignment: Word;
    wTypeFlags: Word;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    tdescAlias: TTypeDesc;
    idldescType: TIDLDesc;
  end;

  PDispParams = ^TDispParams;
  TDispParams = record
    rgvarg: PVariantArgList;
    rgdispidNamedArgs: PDispIDList;
    cArgs: Longint;
    cNamedArgs: Longint;
  end;

  PExcepInfo = ^TExcepInfo;

  TFNDeferredFillIn = function(ExInfo: PExcepInfo): HResult stdcall;

  TExcepInfo = record
    wCode: Word;
    wReserved: Word;
    bstrSource: TBStr;
    bstrDescription: TBStr;
    bstrHelpFile: TBStr;
    dwHelpContext: Longint;
    pvReserved: Pointer;
    pfnDeferredFillIn: TFNDeferredFillIn;
    scode: HResult;
  end;

  TFuncKind = Longint;
  TInvokeKind = Longint;
  TCallConv = Longint;

  PFuncDesc = ^TFuncDesc;
  TFuncDesc = record
    memid: TMemberID;
    lprgscode: PResultList;
    lprgelemdescParam: PElemDescList;
    funckind: TFuncKind;
    invkind: TInvokeKind;
    callconv: TCallConv;
    cParams: Smallint;
    cParamsOpt: Smallint;
    oVft: Smallint;
    cScodes: Smallint;
    elemdescFunc: TElemDesc;
    wFuncFlags: Word;
  end;

  TVarKind = Longint;

  PVarDesc = ^TVarDesc;
  TVarDesc = record
    memid: TMemberID;
    lpstrSchema: POleStr;
    case Integer of
      VAR_PERINSTANCE: (
        oInst: Longint;
        elemdescVar: TElemDesc;
        wVarFlags: Word;
        varkind: TVarKind);
      VAR_CONST: (
        lpvarValue: PVariant);
  end;

{ ICreateTypeInfo interface }

  ICreateTypeInfo = class(IUnknown)
  public
    function SetGuid(const guid: TGUID): HResult; virtual; stdcall; abstract;
    function SetTypeFlags(uTypeFlags: Integer): HResult; virtual; stdcall; abstract;
    function SetDocString(pstrDoc: POleStr): HResult; virtual; stdcall; abstract;
    function SetHelpContext(dwHelpContext: Longint): HResult; virtual; stdcall; abstract;
    function SetVersion(wMajorVerNum: Word; wMinorVerNum: Word): HResult;
      virtual; stdcall; abstract;
    function AddRefTypeInfo(tinfo: ITypeInfo; var reftype: HRefType): HResult;
      virtual; stdcall; abstract;
    function AddFuncDesc(index: Integer; var funcdesc: TFuncDesc): HResult;
      virtual; stdcall; abstract;
    function AddImplType(index: Integer; reftype: HRefType): HResult;
      virtual; stdcall; abstract;
    function SetImplTypeFlags(index: Integer; impltypeflags: Integer): HResult;
      virtual; stdcall; abstract;
    function SetAlignment(cbAlignment: Word): HResult; virtual; stdcall; abstract;
    function SetSchema(lpstrSchema: POleStr): HResult; virtual; stdcall; abstract;
    function AddVarDesc(index: Integer; var vardesc: TVarDesc): HResult;
      virtual; stdcall; abstract;
    function SetFuncAndParamNames(index: Integer; rgszNames: POleStrList;
      cNames: Integer): HResult; virtual; stdcall; abstract;
    function SetVarName(index: Integer; szName: POleStr): HResult; virtual; stdcall; abstract;
    function SetTypeDescAlias(var descAlias: TTypeDesc): HResult; virtual; stdcall; abstract;
    function DefineFuncAsDllEntry(index: Integer; szDllName: POleStr;
      szProcName: POleStr): HResult; virtual; stdcall; abstract;
    function SetFuncDocString(index: Integer; szDocString: POleStr): HResult;
      virtual; stdcall; abstract;
    function SetVarDocString(index: Integer; szDocString: POleStr): HResult;
      virtual; stdcall; abstract;
    function SetFuncHelpContext(index: Integer; dwHelpContext: Longint): HResult;
      virtual; stdcall; abstract;
    function SetVarHelpContext(index: Integer; dwHelpContext: Longint): HResult;
      virtual; stdcall; abstract;
    function SetMops(index: Integer; bstrMops: TBStr): HResult; virtual; stdcall; abstract;
    function SetTypeIdldesc(var idldesc: TIDLDesc): HResult; virtual; stdcall; abstract;
    function LayOut: HResult; virtual; stdcall; abstract;
  end;

{ ICreateTypeLib interface }

  ICreateTypeLib = class(IUnknown)
  public
    function CreateTypeInfo(szName: POleStr; tkind: TTypeKind;
      var ictinfo: ICreateTypeInfo): HResult; virtual; stdcall; abstract;
    function SetName(szName: POleStr): HResult; virtual; stdcall; abstract;
    function SetVersion(wMajorVerNum: Word; wMinorVerNum: Word): HResult; virtual; stdcall; abstract;
    function SetGuid(const guid: TGUID): HResult; virtual; stdcall; abstract;
    function SetDocString(szDoc: POleStr): HResult; virtual; stdcall; abstract;
    function SetHelpFileName(szHelpFileName: POleStr): HResult; virtual; stdcall; abstract;
    function SetHelpContext(dwHelpContext: Longint): HResult; virtual; stdcall; abstract;
    function SetLcid(lcid: TLCID): HResult; virtual; stdcall; abstract;
    function SetLibFlags(uLibFlags: Integer): HResult; virtual; stdcall; abstract;
    function SaveAllChanges: HResult; virtual; stdcall; abstract;
  end;

{ IDispatch interface }

  IDispatch = class(IUnknown)
  public
    function GetTypeInfoCount(var ctinfo: Integer): HResult; virtual; stdcall; abstract;
    function GetTypeInfo(itinfo: Integer; lcid: TLCID; var tinfo: ITypeInfo): HResult; virtual; stdcall; abstract;
    function GetIDsOfNames(const iid: TIID; rgszNames: POleStrList;
      cNames: Integer; lcid: TLCID; rgdispid: PDispIDList): HResult; virtual; stdcall; abstract;
    function Invoke(dispIDMember: TDispID; const iid: TIID; lcid: TLCID;
      flags: Word; var dispParams: TDispParams; varResult: PVariant;
      excepInfo: PExcepInfo; argErr: PInteger): HResult; virtual; stdcall; abstract;
  end;

{ IEnumVariant interface }

  IEnumVariant = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      var pceltFetched: Longint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enum: IEnumVariant): HResult; virtual; stdcall; abstract;
  end;

{ ITypeComp interface }

  TDescKind = Longint;

  PBindPtr = ^TBindPtr;
  TBindPtr = record
    case Integer of
      0: (lpfuncdesc: PFuncDesc);
      1: (lpvardesc: PVarDesc);
      2: (lptcomp: ITypeComp);
  end;

  ITypeComp = class(IUnknown)
  public
    function Bind(szName: POleStr; lHashVal: Longint; wflags: Word;
      var tinfo: ITypeInfo; var desckind: TDescKind;
      var bindptr: TBindPtr): HResult; virtual; stdcall; abstract;
    function BindType(szName: POleStr; lHashVal: Longint;
      var tinfo: ITypeInfo; var tcomp: ITypeComp): HResult;
      virtual; stdcall; abstract;
  end;

{ ITypeInfo interface }

  ITypeInfo = class(IUnknown)
  public
    function GetTypeAttr(var ptypeattr: PTypeAttr): HResult; virtual; stdcall; abstract;
    function GetTypeComp(var tcomp: ITypeComp): HResult; virtual; stdcall; abstract;
    function GetFuncDesc(index: Integer; var pfuncdesc: PFuncDesc): HResult;
      virtual; stdcall; abstract;
    function GetVarDesc(index: Integer; var pvardesc: PVarDesc): HResult;
      virtual; stdcall; abstract;
    function GetNames(memid: TMemberID; rgbstrNames: PBStrList;
      cMaxNames: Integer; var cNames: Integer): HResult; virtual; stdcall; abstract;
    function GetRefTypeOfImplType(index: Integer; var reftype: HRefType): HResult;
      virtual; stdcall; abstract;
    function GetImplTypeFlags(index: Integer; var impltypeflags: Integer): HResult;
      virtual; stdcall; abstract;
    function GetIDsOfNames(rgpszNames: POleStrList; cNames: Integer;
      rgmemid: PMemberIDList): HResult; virtual; stdcall; abstract;
    function Invoke(pvInstance: Pointer; memid: TMemberID; flags: Word;
      var dispParams: TDispParams; varResult: PVariant;
      excepInfo: PExcepInfo; argErr: PInteger): HResult; virtual; stdcall; abstract;
    function GetDocumentation(memid: TMemberID; pbstrName: PBStr;
      pbstrDocString: PBStr; pdwHelpContext: PLongint;
      pbstrHelpFile: PBStr): HResult; virtual; stdcall; abstract;
    function GetDllEntry(memid: TMemberID; invkind: TInvokeKind;
      var bstrDllName: TBStr; var bstrName: TBStr; var wOrdinal: Word): HResult;
      virtual; stdcall; abstract;
    function GetRefTypeInfo(reftype: HRefType; var tinfo: ITypeInfo): HResult;
      virtual; stdcall; abstract;
    function AddressOfMember(memid: TMemberID; invkind: TInvokeKind;
      var ppv: Pointer): HResult; virtual; stdcall; abstract;
    function CreateInstance(unkOuter: IUnknown; const iid: TIID;
      var vObj): HResult; virtual; stdcall; abstract;
    function GetMops(memid: TMemberID; var bstrMops: TBStr): HResult;
      virtual; stdcall; abstract;
    function GetContainingTypeLib(var tlib: ITypeLib; var pindex: Integer): HResult;
      virtual; stdcall; abstract;
    procedure ReleaseTypeAttr(ptypeattr: PTypeAttr); virtual; stdcall; abstract;
    procedure ReleaseFuncDesc(pfuncdesc: PFuncDesc); virtual; stdcall; abstract;
    procedure ReleaseVarDesc(pvardesc: PVarDesc); virtual; stdcall; abstract;
  end;

{ ITypeLib interface }

  TSysKind = Longint;

  PTLibAttr = ^TTLibAttr;
  TTLibAttr = record
    guid: TGUID;
    lcid: TLCID;
    syskind: TSysKind;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    wLibFlags: Word;
  end;

  PTypeInfoList = ^TTypeInfoList;
  TTypeInfoList = array[0..65535] of ITypeInfo;

  ITypeLib = class(IUnknown)
  public
    function GetTypeInfoCount: Integer; virtual; stdcall; abstract;
    function GetTypeInfo(index: Integer; var tinfo: ITypeInfo): HResult; virtual; stdcall; abstract;
    function GetTypeInfoType(index: Integer; var tkind: TTypeKind): HResult;
      virtual; stdcall; abstract;
    function GetTypeInfoOfGuid(const guid: TGUID; var tinfo: ITypeInfo): HResult;
      virtual; stdcall; abstract;
    function GetLibAttr(var ptlibattr: PTLibAttr): HResult; virtual; stdcall; abstract;
    function GetTypeComp(var tcomp: ITypeComp): HResult; virtual; stdcall; abstract;
    function GetDocumentation(index: Integer; pbstrName: PBStr;
      pbstrDocString: PBStr; pdwHelpContext: PLongint;
      pbstrHelpFile: PBStr): HResult; virtual; stdcall; abstract;
    function IsName(szNameBuf: POleStr; lHashVal: Longint; var fName: BOOL): HResult;
      virtual; stdcall; abstract;
    function FindName(szNameBuf: POleStr; lHashVal: Longint;
      rgptinfo: PTypeInfoList; rgmemid: PMemberIDList;
      var pcFound: Word): HResult; virtual; stdcall; abstract;
    procedure ReleaseTLibAttr(ptlibattr: PTLibAttr); virtual; stdcall; abstract;
  end;

{ IErrorInfo interface }

  IErrorInfo = class(IUnknown)
  public
    function GetGUID(var guid: TGUID): HResult; virtual; stdcall; abstract;
    function GetSource(var bstrSource: TBStr): HResult; virtual; stdcall; abstract;
    function GetDescription(var bstrDescription: TBStr): HResult; virtual; stdcall; abstract;
    function GetHelpFile(var bstrHelpFile: TBStr): HResult; virtual; stdcall; abstract;
    function GetHelpContext(var dwHelpContext: Longint): HResult; virtual; stdcall; abstract;
  end;

{ ICreateErrorInfo interface }

  ICreateErrorInfo = class(IUnknown)
  public
    function SetGUID(const guid: TGUID): HResult; virtual; stdcall; abstract;
    function SetSource(szSource: POleStr): HResult; virtual; stdcall; abstract;
    function SetDescription(szDescription: POleStr): HResult; virtual; stdcall; abstract;
    function SetHelpFile(szHelpFile: POleStr): HResult; virtual; stdcall; abstract;
    function SetHelpContext(dwHelpContext: Longint): HResult; virtual; stdcall; abstract;
  end;

{ ISupportErrorInfo interface }

  ISupportErrorInfo = class(IUnknown)
  public
    function InterfaceSupportsErrorInfo(const iid: TIID): HResult; virtual; stdcall; abstract;
  end;

{ IDispatch implementation support }

  PParamData = ^TParamData;
  TParamData = record
    szName: POleStr;
    vt: TVarType;
  end;

  PParamDataList = ^TParamDataList;
  TParamDataList = array[0..65535] of TParamData;

  PMethodData = ^TMethodData;
  TMethodData = record
    szName: POleStr;
    ppdata: PParamDataList;
    dispid: TDispID;
    iMeth: Integer;
    cc: TCallConv;
    cArgs: Integer;
    wFlags: Word;
    vtReturn: TVarType;
  end;

  PMethodDataList = ^TMethodDataList;
  TMethodDataList = array[0..65535] of TMethodData;

  PInterfaceData = ^TInterfaceData;
  TInterfaceData = record
    pmethdata: PMethodDataList;
    cMembers: Integer;
  end;

{ IOleAdviseHolder interface }

  IOleAdviseHolder = class(IUnknown)
  public
    function Advise(advise: IAdviseSink; var dwConnection: Longint): HResult;
      virtual; stdcall; abstract;
    function Unadvise(dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function EnumAdvise(var enumAdvise: IEnumStatData): HResult; virtual; stdcall; abstract;
    function SendOnRename(mk: IMoniker): HResult; virtual; stdcall; abstract;
    function SendOnSave: HResult; virtual; stdcall; abstract;
    function SendOnClose: HResult; virtual; stdcall; abstract;
  end;

{ IOleCache interface }

  IOleCache = class(IUnknown)
  public
    function Cache(var formatetc: TFormatEtc; advf: Longint;
      var dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function Uncache(dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function EnumCache(var enumStatData: IEnumStatData): HResult;
      virtual; stdcall; abstract;
    function InitCache(dataObject: IDataObject): HResult; virtual; stdcall; abstract;
    function SetData(var formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IOleCache2 interface }

  IOleCache2 = class(IOleCache)
  public
    function UpdateCache(dataObject: IDataObject; grfUpdf: Longint;
      pReserved: Pointer): HResult; virtual; stdcall; abstract;
    function DiscardCache(dwDiscardOptions: Longint): HResult; virtual; stdcall; abstract;
  end;

{ IOleCacheControl interface }

  IOleCacheControl = class(IUnknown)
  public
    function OnRun(dataObject: IDataObject): HResult; virtual; stdcall; abstract;
    function OnStop: HResult; virtual; stdcall; abstract;
  end;

{ IParseDisplayName interface }

  IParseDisplayName = class(IUnknown)
  public
    function ParseDisplayName(bc: IBindCtx; pszDisplayName: POleStr;
      var chEaten: Longint; var mkOut: IMoniker): HResult; virtual; stdcall; abstract;
  end;

{ IOleContainer interface }

  IOleContainer = class(IParseDisplayName)
  public
    function EnumObjects(grfFlags: Longint; var enum: IEnumUnknown): HResult;
      virtual; stdcall; abstract;
    function LockContainer(fLock: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IOleClientSite interface }

  IOleClientSite = class(IUnknown)
  public
    function SaveObject: HResult; virtual; stdcall; abstract;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      var mk: IMoniker): HResult; virtual; stdcall; abstract;
    function GetContainer(var container: IOleContainer): HResult; virtual; stdcall; abstract;
    function ShowObject: HResult; virtual; stdcall; abstract;
    function OnShowWindow(fShow: BOOL): HResult; virtual; stdcall; abstract;
    function RequestNewObjectLayout: HResult; virtual; stdcall; abstract;
  end;

{ IOleObject interface }

  IOleObject = class(IUnknown)
  public
    function SetClientSite(clientSite: IOleClientSite): HResult;
      virtual; stdcall; abstract;
    function GetClientSite(var clientSite: IOleClientSite): HResult;
      virtual; stdcall; abstract;
    function SetHostNames(szContainerApp: POleStr;
      szContainerObj: POleStr): HResult; virtual; stdcall; abstract;
    function Close(dwSaveOption: Longint): HResult; virtual; stdcall; abstract;
    function SetMoniker(dwWhichMoniker: Longint; mk: IMoniker): HResult;
      virtual; stdcall; abstract;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      var mk: IMoniker): HResult; virtual; stdcall; abstract;
    function InitFromData(dataObject: IDataObject; fCreation: BOOL;
      dwReserved: Longint): HResult; virtual; stdcall; abstract;
    function GetClipboardData(dwReserved: Longint;
      var dataObject: IDataObject): HResult; virtual; stdcall; abstract;
    function DoVerb(iVerb: Longint; msg: PMsg; activeSite: IOleClientSite;
      lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
      virtual; stdcall; abstract;
    function EnumVerbs(var enumOleVerb: IEnumOleVerb): HResult; virtual; stdcall; abstract;
    function Update: HResult; virtual; stdcall; abstract;
    function IsUpToDate: HResult; virtual; stdcall; abstract;
    function GetUserClassID(var clsid: TCLSID): HResult; virtual; stdcall; abstract;
    function GetUserType(dwFormOfType: Longint; var pszUserType: POleStr): HResult;
      virtual; stdcall; abstract;
    function SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
      virtual; stdcall; abstract;
    function GetExtent(dwDrawAspect: Longint; var size: TPoint): HResult;
      virtual; stdcall; abstract;
    function Advise(advSink: IAdviseSink; var dwConnection: Longint): HResult;
      virtual; stdcall; abstract;
    function Unadvise(dwConnection: Longint): HResult; virtual; stdcall; abstract;
    function EnumAdvise(var enumAdvise: IEnumStatData): HResult; virtual; stdcall; abstract;
    function GetMiscStatus(dwAspect: Longint; var dwStatus: Longint): HResult;
      virtual; stdcall; abstract;
    function SetColorScheme(var logpal: TLogPalette): HResult; virtual; stdcall; abstract;
  end;

{ OLE types }

  PObjectDescriptor = ^TObjectDescriptor;
  TObjectDescriptor = record
    cbSize: Longint;
    clsid: TCLSID;
    dwDrawAspect: Longint;
    size: TPoint;
    point: TPoint;
    dwStatus: Longint;
    dwFullUserTypeName: Longint;
    dwSrcOfCopy: Longint;
  end;

  PLinkSrcDescriptor = PObjectDescriptor;
  TLinkSrcDescriptor = TObjectDescriptor;

{ IOleWindow interface }

  IOleWindow = class(IUnknown)
  public
    function GetWindow(var wnd: HWnd): HResult; virtual; stdcall; abstract;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IOleLink interface }

  IOleLink = class(IUnknown)
  public
    function SetUpdateOptions(dwUpdateOpt: Longint): HResult;
      virtual; stdcall; abstract;
    function GetUpdateOptions(var dwUpdateOpt: Longint): HResult; virtual; stdcall; abstract;
    function SetSourceMoniker(mk: IMoniker; const clsid: TCLSID): HResult;
      virtual; stdcall; abstract;
    function GetSourceMoniker(var mk: IMoniker): HResult; virtual; stdcall; abstract;
    function SetSourceDisplayName(pszDisplayName: POleStr): HResult;
      virtual; stdcall; abstract;
    function GetSourceDisplayName(var pszDisplayName: POleStr): HResult;
      virtual; stdcall; abstract;
    function BindToSource(bindflags: Longint; bc: IBindCtx): HResult;
      virtual; stdcall; abstract;
    function BindIfRunning: HResult; virtual; stdcall; abstract;
    function GetBoundSource(var unk: IUnknown): HResult; virtual; stdcall; abstract;
    function UnbindSource: HResult; virtual; stdcall; abstract;
    function Update(bc: IBindCtx): HResult; virtual; stdcall; abstract;
  end;

{ IOleItemContainer interface }

  IOleItemContainer = class(IOleContainer)
  public
    function GetObject(pszItem: POleStr; dwSpeedNeeded: Longint;
      bc: IBindCtx; const iid: TIID; var vObject): HResult; virtual; stdcall; abstract;
    function GetObjectStorage(pszItem: POleStr; bc: IBindCtx;
      const iid: TIID; var vStorage): HResult; virtual; stdcall; abstract;
    function IsRunning(pszItem: POleStr): HResult; virtual; stdcall; abstract;
  end;

{ IOleInPlaceUIWindow interface }

  IOleInPlaceUIWindow = class(IOleWindow)
  public
    function GetBorder(var rectBorder: TRect): HResult; virtual; stdcall; abstract;
    function RequestBorderSpace(const borderwidths: TRect): HResult; virtual; stdcall; abstract;
    function SetBorderSpace(pborderwidths: PRect): HResult; virtual; stdcall; abstract;
    function SetActiveObject(activeObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; virtual; stdcall; abstract;
  end;

{ IOleInPlaceActiveObject interface }

  IOleInPlaceActiveObject = class(IOleWindow)
  public
    function TranslateAccelerator(var msg: TMsg): HResult; virtual; stdcall; abstract;
    function OnFrameWindowActivate(fActivate: BOOL): HResult; virtual; stdcall; abstract;
    function OnDocWindowActivate(fActivate: BOOL): HResult; virtual; stdcall; abstract;
    function ResizeBorder(const rcBorder: TRect; uiWindow: IOleInPlaceUIWindow;
      fFrameWindow: BOOL): HResult; virtual; stdcall; abstract;
    function EnableModeless(fEnable: BOOL): HResult; virtual; stdcall; abstract;
  end;

{ IOleInPlaceFrame interface }

  POleInPlaceFrameInfo = ^TOleInPlaceFrameInfo;
  TOleInPlaceFrameInfo = record
    cb: Integer;
    fMDIApp: BOOL;
    hwndFrame: HWND;
    haccel: HAccel;
    cAccelEntries: Integer;
  end;

  POleMenuGroupWidths = ^TOleMenuGroupWidths;
  TOleMenuGroupWidths = record
    width: array[0..5] of Longint;
  end;

  IOleInPlaceFrame = class(IOleInPlaceUIWindow)
  public
    function InsertMenus(hmenuShared: HMenu;
      var menuWidths: TOleMenuGroupWidths): HResult; virtual; stdcall; abstract;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu;
      hwndActiveObject: HWnd): HResult; virtual; stdcall; abstract;
    function RemoveMenus(hmenuShared: HMenu): HResult; virtual; stdcall; abstract;
    function SetStatusText(pszStatusText: POleStr): HResult; virtual; stdcall; abstract;
    function EnableModeless(fEnable: BOOL): HResult; virtual; stdcall; abstract;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; virtual; stdcall; abstract;
  end;

{ IOleInPlaceObject interface }

  IOleInPlaceObject = class(IOleWindow)
  public
    function InPlaceDeactivate: HResult; virtual; stdcall; abstract;
    function UIDeactivate: HResult; virtual; stdcall; abstract;
    function SetObjectRects(const rcPosRect: TRect;
      const rcClipRect: TRect): HResult; virtual; stdcall; abstract;
    function ReactivateAndUndo: HResult; virtual; stdcall; abstract;
  end;

{ IOleInPlaceSite interface }

  IOleInPlaceSite = class(IOleWindow)
  public
    function CanInPlaceActivate: HResult; virtual; stdcall; abstract;
    function OnInPlaceActivate: HResult; virtual; stdcall; abstract;
    function OnUIActivate: HResult; virtual; stdcall; abstract;
    function GetWindowContext(var frame: IOleInPlaceFrame;
      var doc: IOleInPlaceUIWindow; var rcPosRect: TRect;
      var rcClipRect: TRect; var frameInfo: TOleInPlaceFrameInfo): HResult;
      virtual; stdcall; abstract;
    function Scroll(scrollExtent: TPoint): HResult; virtual; stdcall; abstract;
    function OnUIDeactivate(fUndoable: BOOL): HResult; virtual; stdcall; abstract;
    function OnInPlaceDeactivate: HResult; virtual; stdcall; abstract;
    function DiscardUndoState: HResult; virtual; stdcall; abstract;
    function DeactivateAndUndo: HResult; virtual; stdcall; abstract;
    function OnPosRectChange(const rcPosRect: TRect): HResult; virtual; stdcall; abstract;
  end;

{ IViewObject interface }

  TContinueFunc = function(dwContinue: Longint): BOOL stdcall;

  IViewObject = class(IUnknown)
  public
    function Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
      prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
      dwContinue: Longint): HResult; virtual; stdcall; abstract;
    function GetColorSet(dwDrawAspect: Longint; lindex: Longint;
      pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
      var colorSet: PLogPalette): HResult; virtual; stdcall; abstract;
    function Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      var dwFreeze: Longint): HResult; virtual; stdcall; abstract;
    function Unfreeze(dwFreeze: Longint): HResult; virtual; stdcall; abstract;
    function SetAdvise(aspects: Longint; advf: Longint;
      advSink: IAdviseSink): HResult; virtual; stdcall; abstract;
    function GetAdvise(pAspects: PLongint; pAdvf: PLongint;
      var advSink: IAdviseSink): HResult; virtual; stdcall; abstract;
  end;

{ IViewObject2 interface }

  IViewObject2 = class(IViewObject)
  public
    function GetExtent(dwDrawAspect: Longint; lindex: Longint;
      ptd: PDVTargetDevice; var size: TPoint): HResult; virtual; stdcall; abstract;
  end;

{ IDropSource interface }

  IDropSource = class(IUnknown)
  public
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; virtual; stdcall; abstract;
    function GiveFeedback(dwEffect: Longint): HResult; virtual; stdcall;  abstract;
  end;

{ IDropTarget interface }

  IDropTarget = class(IUnknown)
  public
    function DragEnter(dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; virtual; stdcall; abstract;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; virtual; stdcall; abstract;
    function DragLeave: HResult; virtual; stdcall; abstract;
    function Drop(dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; virtual; stdcall; abstract;
  end;

{ IEnumOleVerb interface }

  POleVerb = ^TOleVerb;
  TOleVerb = record
    lVerb: Longint;
    lpszVerbName: POleStr;
    fuFlags: Longint;
    grfAttribs: Longint;
  end;

  IEnumOleVerb = class(IUnknown)
  public
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; virtual; stdcall; abstract;
    function Skip(celt: Longint): HResult; virtual; stdcall; abstract;
    function Reset: HResult; virtual; stdcall; abstract;
    function Clone(var enm: IEnumOleVerb): HResult; virtual; stdcall; abstract;
  end;

  IOleDocumentView = class(IUnknown)
  public
    function SetInPlaceSite(Site: IOleInPlaceSite):HResult; virtual; stdcall; abstract;
    function GetInPlaceSite(var Site: IOleInPlaceSite):HResult; virtual; stdcall; abstract;
    function GetDocument(var P: IUnknown):HResult; virtual; stdcall; abstract;
    function SetRect(const View: TRECT):HResult; virtual; stdcall; abstract;
    function GetRect(var View: TRECT):HResult; virtual; stdcall; abstract;
    function SetRectComplex(const View, HScroll, VScroll, SizeBox):HResult; virtual; stdcall; abstract;
    function Show(fShow: BOOL):HResult; virtual; stdcall; abstract;
    function UIActivate(fUIActivate: BOOL):HResult; virtual; stdcall; abstract;
    function Open:HResult; virtual; stdcall; abstract;
    function CloseView(dwReserved: DWORD):HResult; virtual; stdcall; abstract;
    function SaveViewState(pstm: IStream):HResult; virtual; stdcall; abstract;
    function ApplyViewState(pstm: IStream):HResult; virtual; stdcall; abstract;
    function Clone(NewSite: IOleInPlaceSite; var NewView: IOleDocumentView):HResult; virtual; stdcall; abstract;
  end;

  IEnumOleDocumentViews = class(IUnknown)
  public
    function Next(Count: Longint; var View: IOleDocumentView; var Fetched: Longint):HResult; virtual; stdcall; abstract;
    function Skip(Count: Longint):HResult; virtual; stdcall; abstract;
    function Reset:HResult; virtual; stdcall; abstract;
    function Clone(var Enum: IEnumOleDocumentViews):HResult; virtual; stdcall; abstract;
  end;

  IOleDocument = class(IUnknown)
  public
    function CreateView(Site: IOleInPlaceSite; Stream: IStream; rsrvd: DWORD;
      var View: IOleDocumentView):HResult; virtual; stdcall; abstract;
    function GetDocMiscStatus(var Status: DWORD):HResult; virtual; stdcall; abstract;
    function EnumViews(var Enum: IEnumOleDocumentViews;
      var View: IOleDocumentView):HResult; virtual; stdcall; abstract;
  end;

  IOleDocumentSite = class(IUnknown)
  public
    function ActivateMe(View: IOleDocumentView): HRESULT; virtual; stdcall; abstract;
  end;


const

{ Standard GUIDs }

  GUID_NULL: TGUID = (
    D1:$00000000;D2:$0000;D3:$0000;D4:($00,$00,$00,$00,$00,$00,$00,$00));
  IID_IUnknown: TGUID = (
    D1:$00000000;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IClassFactory: TGUID = (
    D1:$00000001;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IMarshal: TGUID = (
    D1:$00000003;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IMalloc: TGUID = (
    D1:$00000002;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IStdMarshalInfo: TGUID = (
    D1:$00000018;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IExternalConnection: TGUID = (
    D1:$00000019;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumUnknown: TGUID = (
    D1:$00000100;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IBindCtx: TGUID = (
    D1:$0000000E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumMoniker: TGUID = (
    D1:$00000102;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRunnableObject: TGUID = (
    D1:$00000126;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRunningObjectTable: TGUID = (
    D1:$00000010;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IPersist: TGUID = (
    D1:$0000010C;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IPersistStream: TGUID = (
    D1:$00000109;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IMoniker: TGUID = (
    D1:$0000000F;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumString: TGUID = (
    D1:$00000101;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IStream: TGUID = (
    D1:$0000000C;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumStatStg: TGUID = (
    D1:$0000000D;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IStorage: TGUID = (
    D1:$0000000B;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IPersistFile: TGUID = (
    D1:$0000010B;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IPersistStorage: TGUID = (
    D1:$0000010A;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ILockBytes: TGUID = (
    D1:$0000000A;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumFormatEtc: TGUID = (
    D1:$00000103;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumStatData: TGUID = (
    D1:$00000105;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRootStorage: TGUID = (
    D1:$00000012;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IAdviseSink: TGUID = (
    D1:$0000010F;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IAdviseSink2: TGUID = (
    D1:$00000125;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDataObject: TGUID = (
    D1:$0000010E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDataAdviseHolder: TGUID = (
    D1:$00000110;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IMessageFilter: TGUID = (
    D1:$00000016;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ICreateTypeInfo: TGUID = (
    D1:$00020405;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ICreateTypeLib: TGUID = (
    D1:$00020406;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDispatch: TGUID = (
    D1:$00020400;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumVariant: TGUID = (
    D1:$00020404;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ITypeComp: TGUID = (
    D1:$00020403;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ITypeInfo: TGUID = (
    D1:$00020401;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_ITypeLib: TGUID = (
    D1:$00020402;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IErrorInfo: TGUID = (
    D1:$1CF2B120;D2:$547D;D3:$101B;D4:($8E,$65,$08,$00,$2B,$2B,$D1,$19));
  IID_ICreateErrorInfo: TGUID = (
    D1:$22F03340;D2:$547D;D3:$101B;D4:($8E,$65,$08,$00,$2B,$2B,$D1,$19));
  IID_IOleAdviseHolder: TGUID = (
    D1:$00000111;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleCache: TGUID = (
    D1:$0000011E;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleCache2: TGUID = (
    D1:$00000128;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleCacheControl: TGUID = (
    D1:$00000129;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IParseDisplayName: TGUID = (
    D1:$0000011A;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleContainer: TGUID = (
    D1:$0000011B;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleClientSite: TGUID = (
    D1:$00000118;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleObject: TGUID = (
    D1:$00000112;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleWindow: TGUID = (
    D1:$00000114;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleLink: TGUID = (
    D1:$0000011D;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleItemContainer: TGUID = (
    D1:$0000011C;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleInPlaceUIWindow: TGUID = (
    D1:$00000115;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleInPlaceActiveObject: TGUID = (
    D1:$00000117;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleInPlaceFrame: TGUID = (
    D1:$00000116;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleInPlaceObject: TGUID = (
    D1:$00000113;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleInPlaceSite: TGUID = (
    D1:$00000119;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IViewObject: TGUID = (
    D1:$0000010D;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IViewObject2: TGUID = (
    D1:$00000127;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDropSource: TGUID = (
    D1:$00000121;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDropTarget: TGUID = (
    D1:$00000122;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumOleVerb: TGUID = (
    D1:$00000104;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));

{ Additional GUIDs }

  IID_IRpcChannel: TGUID = (
    D1:$00000004;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRpcStub: TGUID = (
    D1:$00000005;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IStubManager: TGUID = (
    D1:$00000006;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IRpcProxy: TGUID = (
    D1:$00000007;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IProxyManager: TGUID = (
    D1:$00000008;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IPSFactory: TGUID = (
    D1:$00000009;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IInternalMoniker: TGUID = (
    D1:$00000011;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  CLSID_StdMarshal: TGUID = (
    D1:$00000017;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumGeneric: TGUID = (
    D1:$00000106;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumHolder: TGUID = (
    D1:$00000107;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IEnumCallback: TGUID = (
    D1:$00000108;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOleManager: TGUID = (
    D1:$0000011F;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IOlePresObj: TGUID = (
    D1:$00000120;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDebug: TGUID = (
    D1:$00000123;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IDebugStream: TGUID = (
    D1:$00000124;D2:$0000;D3:$0000;D4:($C0,$00,$00,$00,$00,$00,$00,$46));



{ HResult manipulation routines }

function Succeeded(Res: HResult): Boolean;
function Failed(Res: HResult): Boolean;
function ResultCode(Res: HResult): Integer;
function ResultFacility(Res: HResult): Integer;
function ResultSeverity(Res: HResult): Integer;
function MakeResult(Severity, Facility, Code: Integer): HResult;

{ GUID functions }

function IsEqualGUID(const guid1, guid2: TGUID): Boolean; stdcall;
function IsEqualIID(const iid1, iid2: TIID): Boolean; stdcall;
function IsEqualCLSID(const clsid1, clsid2: TCLSID): Boolean; stdcall;

{ Standard object API functions }

function CoBuildVersion: Longint; stdcall;

{ Init/Uninit }

function CoInitialize(pvReserved: Pointer): HResult; stdcall;
procedure CoUninitialize; stdcall;
function CoGetMalloc(dwMemContext: Longint; var malloc: IMalloc): HResult; stdcall;
function CoGetCurrentProcess: Longint; stdcall;
function CoRegisterMallocSpy(mallocSpy: IMallocSpy): HResult; stdcall;
function CoRevokeMallocSpy: HResult stdcall;
function CoCreateStandardMalloc(memctx: Longint; var malloc: IMalloc): HResult; stdcall;

{ Register, revoke, and get class objects }

function CoGetClassObject(const clsid: TCLSID; dwClsContext: Longint;
  pvReserved: Pointer; const iid: TIID; var pv): HResult; stdcall;
function CoRegisterClassObject(const clsid: TCLSID; unk: IUnknown;
  dwClsContext: Longint; flags: Longint; var dwRegister: Longint): HResult; stdcall;
function CoRevokeClassObject(dwRegister: Longint): HResult; stdcall;

{ Marshaling interface pointers }

function CoGetMarshalSizeMax(var ulSize: Longint; const iid: TIID;
  unk: IUnknown; dwDestContext: Longint; pvDestContext: Pointer;
  mshlflags: Longint): HResult; stdcall;
function CoMarshalInterface(stm: IStream; const iid: TIID; unk: IUnknown;
  dwDestContext: Longint; pvDestContext: Pointer;
  mshlflags: Longint): HResult; stdcall;
function CoUnmarshalInterface(stm: IStream; const iid: TIID;
  var pv): HResult; stdcall;
function CoMarshalHResult(stm: IStream; result: HResult): HResult; stdcall;
function CoUnmarshalHResult(stm: IStream; var result: HResult): HResult; stdcall;
function CoReleaseMarshalData(stm: IStream): HResult; stdcall;
function CoDisconnectObject(unk: IUnknown; dwReserved: Longint): HResult; stdcall;
function CoLockObjectExternal(unk: IUnknown; fLock: BOOL;
  fLastUnlockReleases: BOOL): HResult; stdcall;
function CoGetStandardMarshal(const iid: TIID; unk: IUnknown;
  dwDestContext: Longint; pvDestContext: Pointer; mshlflags: Longint;
  var marshal: IMarshal): HResult; stdcall;

function CoIsHandlerConnected(unk: IUnknown): BOOL; stdcall;
function CoHasStrongExternalConnections(unk: IUnknown): BOOL; stdcall;

{ Apartment model inter-thread interface passing helpers }

function CoMarshalInterThreadInterfaceInStream(const iid: TIID;
  unk: IUnknown; var stm: IStream): HResult; stdcall;
function CoGetInterfaceAndReleaseStream(stm: IStream; const iid: TIID;
  var pv): HResult; stdcall;
function CoCreateFreeThreadedMarshaler(unkOuter: IUnknown;
  var unkMarshal: IUnknown): HResult; stdcall;

{ DLL loading helpers; keeps track of ref counts and unloads all on exit }

function CoLoadLibrary(pszLibName: POleStr; bAutoFree: BOOL): THandle; stdcall;
procedure CoFreeLibrary(hInst: THandle); stdcall;
procedure CoFreeAllLibraries; stdcall;
procedure CoFreeUnusedLibraries; stdcall;

{ Helper for creating instances }

function CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown;
  dwClsContext: Longint; const iid: TIID; var pv): HResult; stdcall;

{ Other helpers }

function StringFromCLSID(const clsid: TCLSID; var psz: POleStr): HResult; stdcall;
function CLSIDFromString(psz: POleStr; var clsid: TCLSID): HResult; stdcall;
function StringFromIID(const iid: TIID; var psz: POleStr): HResult; stdcall;
function IIDFromString(psz: POleStr; var iid: TIID): HResult; stdcall;
function CoIsOle1Class(const clsid: TCLSID): BOOL; stdcall;
function ProgIDFromCLSID(const clsid: TCLSID; var pszProgID: POleStr): HResult; stdcall;
function CLSIDFromProgID(pszProgID: POleStr; var clsid: TCLSID): HResult; stdcall;
function StringFromGUID2(const guid: TGUID; psz: POleStr; cbMax: Integer): Integer; stdcall;

function CoCreateGuid(var guid: TGUID): HResult; stdcall;

function CoFileTimeToDosDateTime(var filetime: TFileTime; var dosDate: Word;
  var dosTime: Word): BOOL; stdcall;
function CoDosDateTimeToFileTime(nDosDate: Word; nDosTime: Word;
  var filetime: TFileTime): BOOL; stdcall;
function CoFileTimeNow(var filetime: TFileTime): HResult; stdcall;
function CoRegisterMessageFilter(messageFilter: IMessageFilter;
  var pMessageFilter: IMessageFilter): HResult; stdcall;

{ TreatAs APIs }

function CoGetTreatAsClass(const clsidOld: TCLSID; var clsidNew: TCLSID): HResult; stdcall;
function CoTreatAsClass(const clsidOld: TCLSID; const clsidNew: TCLSID): HResult; stdcall;

{ The server DLLs must define their DllGetClassObject and DllCanUnloadNow
  to match these; the typedefs are located here to ensure all are changed at
  the same time }

type
  TDLLGetClassObject = function(const clsid: TCLSID; const iid: TIID;
    var pv): HResult stdcall;
  TDLLCanUnloadNow = function: HResult stdcall;

{ Default memory allocation }

function CoTaskMemAlloc(cb: Longint): Pointer; stdcall;
function CoTaskMemRealloc(pv: Pointer; cb: Longint): Pointer; stdcall;
procedure CoTaskMemFree(pv: Pointer); stdcall;

{ DV APIs }

function CreateDataAdviseHolder(var DAHolder: IDataAdviseHolder): HResult; stdcall;
function CreateDataCache(unkOuter: IUnknown; const clsid: TCLSID;
  const iid: TIID; var pv): HResult; stdcall;

{ Storage API prototypes }

function StgCreateDocfile(pwcsName: POleStr; grfMode: Longint;
  reserved: Longint; var stgOpen: IStorage): HResult; stdcall;
function StgCreateDocfileOnILockBytes(lkbyt: ILockBytes; grfMode: Longint;
  reserved: Longint; var stgOpen: IStorage): HResult; stdcall;
function StgOpenStorage(pwcsName: POleStr; stgPriority: IStorage;
  grfMode: Longint; snbExclude: TSNB; reserved: Longint;
  var stgOpen: IStorage): HResult; stdcall;
function StgOpenStorageOnILockBytes(lkbyt: ILockBytes; stgPriority: IStorage;
  grfMode: Longint; snbExclude: TSNB; reserved: Longint;
  var stgOpen: IStorage): HResult; stdcall;
function StgIsStorageFile(pwcsName: POleStr): HResult; stdcall;
function StgIsStorageILockBytes(lkbyt: ILockBytes): HResult; stdcall;
function StgSetTimes(pszName: POleStr; const ctime: TFileTime;
  const atime: TFileTime; const mtime: TFileTime): HResult; stdcall;

{ Moniker APIs }

function BindMoniker(mk: IMoniker; grfOpt: Longint; const iidResult: TIID;
  var pvResult): HResult; stdcall;
function MkParseDisplayName(bc: IBindCtx; szUserName: POleStr;
  var chEaten: Longint; var mk: IMoniker): HResult; stdcall;
function MonikerRelativePathTo(mkSrc: IMoniker; mkDest: IMoniker;
  var mkRelPath: IMoniker; dwReserved: BOOL): HResult; stdcall;
function MonikerCommonPrefixWith(mkThis: IMoniker; mkOther: IMoniker;
  var mkCommon: IMoniker): HResult; stdcall;
function CreateBindCtx(reserved: Longint; var bc: IBindCtx): HResult; stdcall;
function CreateGenericComposite(mkFirst: IMoniker; mkRest: IMoniker;
  var mkComposite: IMoniker): HResult; stdcall;
function GetClassFile(szFilename: POleStr; var clsid: TCLSID): HResult; stdcall;
function CreateFileMoniker(pszPathName: POleStr; var mk: IMoniker): HResult; stdcall;
function CreateItemMoniker(pszDelim: POleStr; pszItem: POleStr;
  var mk: IMoniker): HResult; stdcall;
function CreateAntiMoniker(var mk: IMoniker): HResult; stdcall;
function CreatePointerMoniker(unk: IUnknown; var mk: IMoniker): HResult; stdcall;
function GetRunningObjectTable(reserved: Longint;
  var rot: IRunningObjectTable): HResult; stdcall;

{ TBStr API }

function SysAllocString(psz: POleStr): TBStr; stdcall;
function SysReAllocString(var bstr: TBStr; psz: POleStr): Integer; stdcall;
function SysAllocStringLen(psz: POleStr; len: Integer): TBStr; stdcall;
function SysReAllocStringLen(var bstr: TBStr; psz: POleStr;
  len: Integer): Integer; stdcall;
procedure SysFreeString(bstr: TBStr); stdcall;
function SysStringLen(bstr: TBStr): Integer; stdcall;
function SysStringByteLen(bstr: TBStr): Integer; stdcall;
function SysAllocStringByteLen(psz: PChar; len: Integer): TBStr; stdcall;

{ Time API }

function DosDateTimeToVariantTime(wDosDate, wDosTime: Word;
  var vtime: TOleDate): Integer; stdcall;
function VariantTimeToDosDateTime(vtime: TOleDate; var wDosDate,
  wDosTime: Word): Integer; stdcall;

{ SafeArray API }

function SafeArrayAllocDescriptor(cDims: Integer; var psaOut: PSafeArray): HResult; stdcall;
function SafeArrayAllocData(psa: PSafeArray): HResult; stdcall;
function SafeArrayCreate(vt: TVarType; cDims: Integer; const rgsabound): PSafeArray; stdcall;
function SafeArrayDestroyDescriptor(psa: PSafeArray): HResult; stdcall;
function SafeArrayDestroyData(psa: PSafeArray): HResult; stdcall;
function SafeArrayDestroy(psa: PSafeArray): HResult; stdcall;
function SafeArrayRedim(psa: PSafeArray; var saboundNew: TSafeArrayBound): HResult; stdcall;
function SafeArrayGetDim(psa: PSafeArray): Integer; stdcall;
function SafeArrayGetElemsize(psa: PSafeArray): Integer; stdcall;
function SafeArrayGetUBound(psa: PSafeArray; nDim: Integer; var lUbound: Longint): HResult; stdcall;
function SafeArrayGetLBound(psa: PSafeArray; nDim: Integer; var lLbound: Longint): HResult; stdcall;
function SafeArrayLock(psa: PSafeArray): HResult; stdcall;
function SafeArrayUnlock(psa: PSafeArray): HResult; stdcall;
function SafeArrayAccessData(psa: PSafeArray; var pvData: Pointer): HResult; stdcall;
function SafeArrayUnaccessData(psa: PSafeArray): HResult; stdcall;
function SafeArrayGetElement(psa: PSafeArray; const rgIndices; var pv): HResult; stdcall;
function SafeArrayPutElement(psa: PSafeArray; const rgIndices; const pv): HResult; stdcall;
function SafeArrayCopy(psa: PSafeArray; var psaOut: PSafeArray): HResult; stdcall;
function SafeArrayPtrOfIndex(psa: PSafeArray; var rgIndices; var pvData: Pointer): HResult; stdcall;

{ Variant API }

procedure VariantInit(var varg: Variant); stdcall;
function VariantClear(var varg: Variant): HResult; stdcall;
function VariantCopy(var vargDest: Variant; const vargSrc: Variant): HResult; stdcall;
function VariantCopyInd(var varDest: Variant; const vargSrc: Variant): HResult; stdcall;
function VariantChangeType(var vargDest: Variant; const vargSrc: Variant;
  wFlags: Word; vt: TVarType): HResult; stdcall;
function VariantChangeTypeEx(var vargDest: Variant; const vargSrc: Variant;
  lcid: TLCID; wFlags: Word; vt: TVarType): HResult; stdcall;

{ VarType coercion API }

{ Note: The routines that convert from a string are defined
  to take a POleStr rather than a TBStr because no allocation is
  required, and this makes the routines a bit more generic.
  They may of course still be passed a TBStr as the strIn param. }

{ Any of the coersion functions that converts either from or to a string
  takes an additional lcid and dwFlags arguments. The lcid argument allows
  locale specific parsing to occur.  The dwFlags allow additional function
  specific condition to occur.  All function that accept the dwFlags argument
  can include either 0 or LOCALE_NOUSEROVERRIDE flag. In addition, the
  VarDateFromStr functions also accepts the VAR_TIMEVALUEONLY and
  VAR_DATEVALUEONLY flags }

function VarUI1FromI2(sIn: Smallint; var bOut: Byte): HResult; stdcall;
function VarUI1FromI4(lIn: Longint; var bOut: Byte): HResult; stdcall;
function VarUI1FromR4(fltIn: Single; var bOut: Byte): HResult; stdcall;
function VarUI1FromR8(dblIn: Double; var bOut: Byte): HResult; stdcall;
function VarUI1FromCy(cyIn: TCurrency; var bOut: Byte): HResult; stdcall;
function VarUI1FromDate(dateIn: TOleDate; var bOut: Byte): HResult; stdcall;
function VarUI1FromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var bOut: Byte): HResult; stdcall;
function VarUI1FromDisp(dispIn: IDispatch; lcid: TLCID; var bOut: Byte): HResult; stdcall;
function VarUI1FromBool(boolIn: TOleBool; var bOut: Byte): HResult; stdcall;

function VarI2FromUI1(bIn: Byte; var sOut: Smallint): HResult; stdcall;
function VarI2FromI4(lIn: Longint; var sOut: Smallint): HResult; stdcall;
function VarI2FromR4(fltIn: Single; var sOut: Smallint): HResult; stdcall;
function VarI2FromR8(dblIn: Double; var sOut: Smallint): HResult; stdcall;
function VarI2FromCy(cyIn: TCurrency; var sOut: Smallint): HResult; stdcall;
function VarI2FromDate(dateIn: TOleDate; var sOut: Smallint): HResult; stdcall;
function VarI2FromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var sOut: Smallint): HResult; stdcall;
function VarI2FromDisp(dispIn: IDispatch; lcid: TLCID; var sOut: Smallint): HResult; stdcall;
function VarI2FromBool(boolIn: TOleBool; var sOut: Smallint): HResult; stdcall;

function VarI4FromUI1(bIn: Byte; var lOut: Longint): HResult; stdcall;
function VarI4FromI2(sIn: Smallint; var lOut: Longint): HResult; stdcall;
function VarI4FromR4(fltIn: Single; var lOut: Longint): HResult; stdcall;
function VarI4FromR8(dblIn: Double; var lOut: Longint): HResult; stdcall;
function VarI4FromCy(cyIn: TCurrency; var lOut: Longint): HResult; stdcall;
function VarI4FromDate(dateIn: TOleDate; var lOut: Longint): HResult; stdcall;
function VarI4FromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var lOut: Longint): HResult; stdcall;
function VarI4FromDisp(dispIn: IDispatch; lcid: TLCID; var lOut: Longint): HResult; stdcall;
function VarI4FromBool(boolIn: TOleBool; var lOut: Longint): HResult; stdcall;

function VarR4FromUI1(bIn: Byte; var fltOut: Single): HResult; stdcall;
function VarR4FromI2(sIn: Smallint; var fltOut: Single): HResult; stdcall;
function VarR4FromI4(lIn: Longint; var fltOut: Single): HResult; stdcall;
function VarR4FromR8(dblIn: Double; var fltOut: Single): HResult; stdcall;
function VarR4FromCy(cyIn: TCurrency; var fltOut: Single): HResult; stdcall;
function VarR4FromDate(dateIn: TOleDate; var fltOut: Single): HResult; stdcall;
function VarR4FromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var fltOut: Single): HResult; stdcall;
function VarR4FromDisp(dispIn: IDispatch; lcid: TLCID; var fltOut: Single): HResult; stdcall;
function VarR4FromBool(boolIn: TOleBool; var fltOut: Single): HResult; stdcall;

function VarR8FromUI1(bIn: Byte; var dblOut: Double): HResult; stdcall;
function VarR8FromI2(sIn: Smallint; var dblOut: Double): HResult; stdcall;
function VarR8FromI4(lIn: Longint; var dblOut: Double): HResult; stdcall;
function VarR8FromR4(fltIn: Single; var dblOut: Double): HResult; stdcall;
function VarR8FromCy(cyIn: TCurrency; var dblOut: Double): HResult; stdcall;
function VarR8FromDate(dateIn: TOleDate; var dblOut: Double): HResult; stdcall;
function VarR8FromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var dblOut: Double): HResult; stdcall;
function VarR8FromDisp(dispIn: IDispatch; lcid: TLCID; var dblOut: Double): HResult; stdcall;
function VarR8FromBool(boolIn: TOleBool; var dblOut: Double): HResult; stdcall;

function VarDateFromUI1(bIn: Byte; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromI2(sIn: Smallint; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromI4(lIn: Longint; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromR4(fltIn: Single; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromR8(dblIn: Double; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromCy(cyIn: TCurrency; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromDisp(dispIn: IDispatch; lcid: TLCID; var dateOut: TOleDate): HResult; stdcall;
function VarDateFromBool(boolIn: TOleBool; var dateOut: TOleDate): HResult; stdcall;

function VarCyFromUI1(bIn: Byte; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromI2(sIn: Smallint; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromI4(lIn: Longint; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromR4(fltIn: Single; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromR8(dblIn: Double; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromDate(dateIn: TOleDate; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromDisp(dispIn: IDispatch; lcid: TLCID; var cyOut: TCurrency): HResult; stdcall;
function VarCyFromBool(boolIn: TOleBool; var cyOut: TCurrency): HResult; stdcall;

function VarBStrFromUI1(bVal: Byte; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromI2(iVal: Smallint; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromI4(lIn: Longint; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromR4(fltIn: Single; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromR8(dblIn: Double; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromCy(cyIn: TCurrency; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromDate(dateIn: TOleDate; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromDisp(dispIn: IDispatch; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;
function VarBStrFromBool(boolIn: TOleBool; lcid: TLCID; dwFlags: Longint; var bstrOut: TBStr): HResult; stdcall;

function VarBoolFromUI1(bIn: Byte; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromI2(sIn: Smallint; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromI4(lIn: Longint; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromR4(fltIn: Single; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromR8(dblIn: Double; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromDate(dateIn: TOleDate; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromCy(cyIn: TCurrency; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromStr(strIn: TBStr; lcid: TLCID; dwFlags: Longint; var boolOut: TOleBool): HResult; stdcall;
function VarBoolFromDisp(dispIn: IDispatch; lcid: TLCID; var boolOut: TOleBool): HResult; stdcall;

{ TypeInfo API }

function LHashValOfNameSys(syskind: TSysKind; lcid: TLCID;
  szName: POleStr): Longint; stdcall;
function LHashValOfNameSysA(syskind: TSysKind; lcid: TLCID;
  szName: PChar): Longint; stdcall;

function LHashValOfName(lcid: TLCID; szName: POleStr): Longint;
function WHashValOfLHashVal(lhashval: Longint): Word;
function IsHashValCompatible(lhashval1, lhashval2: Longint): Boolean;

function LoadTypeLib(szFile: POleStr; var tlib: ITypeLib): HResult; stdcall;
function LoadRegTypeLib(const guid: TGUID; wVerMajor, wVerMinor: Word;
  lcid: TLCID; var tlib: ITypeLib): HResult; stdcall;
function QueryPathOfRegTypeLib(const guid: TGUID; wMaj, wMin: Word;
  lcid: TLCID; var bstrPathName: TBStr): HResult; stdcall;
function RegisterTypeLib(tlib: ITypeLib; szFullPath, szHelpDir: POleStr): HResult; stdcall;
function CreateTypeLib(syskind: TSysKind; szFile: POleStr;
  var ctlib: ICreateTypeLib): HResult; stdcall;

{ IDispatch implementation support }

function DispGetParam(var dispparams: TDispParams; position: Integer;
  vtTarg: TVarType; var varResult: Variant; var puArgErr: Integer): HResult; stdcall;
function DispGetIDsOfNames(tinfo: ITypeInfo; var rgszNames; cNames: Integer;
  var rgdispid): HResult; stdcall;
function DispInvoke(this: Pointer; tinfo: ITypeInfo; dispidMember: TDispID;
  wFlags: Word; var params: TDispParams; var varResult: Variant;
  var excepinfo: TExcepInfo; var puArgErr: Integer): HResult; stdcall;
function CreateDispTypeInfo(var idata: TInterfaceData; lcid: TLCID;
  var tinfo: ITypeInfo): HResult; stdcall;
function CreateStdDispatch(unkOuter: IUnknown; pvThis: Pointer;
  tinfo: ITypeInfo; var unkStdDisp: IUnknown): HResult; stdcall;

{ Active object registration API }

function RegisterActiveObject(unk: IUnknown; const clsid: TCLSID;
  dwFlags: Longint; var dwRegister: Longint): HResult; stdcall;
function RevokeActiveObject(dwRegister: Longint; pvReserved: Pointer): HResult; stdcall;
function GetActiveObject(const clsid: TCLSID; pvReserved: Pointer;
  var unk: IUnknown): HResult; stdcall;

{ ErrorInfo API }

function SetErrorInfo(dwReserved: Longint; errinfo: IErrorInfo): HResult; stdcall;
function GetErrorInfo(dwReserved: Longint; var errinfo: IErrorInfo): HResult; stdcall;
function CreateErrorInfo(var errinfo: ICreateErrorInfo): HResult; stdcall;

{ Misc API }

function OaBuildVersion: Longint; stdcall;

{ OLE API prototypes }

function OleBuildVersion: HResult; stdcall;

{ helper functions }

function ReadClassStg(stg: IStorage; var clsid: TCLSID): HResult; stdcall;
function WriteClassStg(stg: IStorage; const clsid: TIID): HResult; stdcall;
function ReadClassStm(stm: IStream; var clsid: TCLSID): HResult; stdcall;
function WriteClassStm(stm: IStream; const clsid: TIID): HResult; stdcall;
function WriteFmtUserTypeStg(stg: IStorage; cf: TClipFormat;
  pszUserType: POleStr): HResult; stdcall;
function ReadFmtUserTypeStg(stg: IStorage; var cf: TClipFormat;
  var pszUserType: POleStr): HResult; stdcall;

{ Initialization and termination }

function OleInitialize(pwReserved: Pointer): HResult; stdcall;
procedure OleUninitialize; stdcall;

{ APIs to query whether (Embedded/Linked) object can be created from
  the data object }

function OleQueryLinkFromData(srcDataObject: IDataObject): HResult; stdcall;
function OleQueryCreateFromData(srcDataObject: IDataObject): HResult; stdcall;

{ Object creation APIs }

function OleCreate(const clsid: TCLSID; const iid: TIID; renderopt: Longint;
  formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateLinkFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateStaticFromData(srcDataObj: IDataObject; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateLink(mkLinkSrc: IMoniker; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateLinkToFile(pszFileName: POleStr; const iid: TIID;
  renderopt: Longint; formatEtc: PFormatEtc; clientSite: IOleClientSite;
  stg: IStorage; var vObj): HResult; stdcall;
function OleCreateFromFile(const clsid: TCLSID; pszFileName: POleStr;
  const iid: TIID; renderopt: Longint; formatEtc: PFormatEtc;
  clientSite: IOleClientSite; stg: IStorage; var vObj): HResult; stdcall;
function OleLoad(stg: IStorage; const iid: TIID; clientSite: IOleClientSite;
  var vObj): HResult; stdcall;
function OleSave(ps: IPersistStorage; stg: IStorage; fSameAsLoad: BOOL): HResult; stdcall;
function OleLoadFromStream(stm: IStream; const iidInterface: TIID;
  var vObj): HResult; stdcall;
function OleSaveToStream(pstm: IPersistStream; stm: IStream): HResult; stdcall;
function OleSetContainedObject(unknown: IUnknown; fContained: BOOL): HResult; stdcall;
function OleNoteObjectVisible(unknown: IUnknown; fVisible: BOOL): HResult; stdcall;

{ DragDrop APIs }

function RegisterDragDrop(wnd: HWnd; dropTarget: IDropTarget): HResult; stdcall;
function RevokeDragDrop(wnd: HWnd): HResult; stdcall;
function DoDragDrop(dataObj: IDataObject; dropSource: IDropSource;
  dwOKEffects: Longint; var dwEffect: Longint): HResult; stdcall;

{ Clipboard APIs }

function OleSetClipboard(dataObj: IDataObject): HResult; stdcall;
function OleGetClipboard(var dataObj: IDataObject): HResult; stdcall;
function OleFlushClipboard: HResult; stdcall;
function OleIsCurrentClipboard(dataObj: IDataObject): HResult; stdcall;

{ In-place editing APIs }

function OleCreateMenuDescriptor(hmenuCombined: HMenu;
  var menuWidths: TOleMenuGroupWidths): HMenu; stdcall;
function OleSetMenuDescriptor(holemenu: HMenu; hwndFrame: HWnd;
  hwndActiveObject: HWnd; frame: IOleInPlaceFrame;
  activeObj: IOleInPlaceActiveObject): HResult; stdcall;
function OleDestroyMenuDescriptor(holemenu: HMenu): HResult; stdcall;
function OleTranslateAccelerator(frame: IOleInPlaceFrame;
  var frameInfo: TOleInPlaceFrameInfo; msg: PMsg): HResult; stdcall;

{ Helper APIs }

function OleDuplicateData(hSrc: THandle; cfFormat: TClipFormat;
  uiFlags: Integer): THandle; stdcall;
function OleDraw(unknown: IUnknown; dwAspect: Longint; hdcDraw: HDC;
  const rcBounds: TRect): HResult; stdcall;
function OleRun(unknown: IUnknown): HResult; stdcall;
function OleIsRunning(obj: IOleObject): BOOL; stdcall;
function OleLockRunning(unknown: IUnknown; fLock: BOOL;
  fLastUnlockCloses: BOOL): HResult; stdcall;
procedure ReleaseStgMedium(var medium: TStgMedium); stdcall;
function CreateOleAdviseHolder(var OAHolder: IOleAdviseHolder): HResult; stdcall;
function OleCreateDefaultHandler(const clsid: TCLSID; unkOuter: IUnknown;
  const iid: TIID; var vObj): HResult; stdcall;
function OleCreateEmbeddingHelper(const clsid: TCLSID; unkOuter: IUnknown;
  flags: Longint; cf: IClassFactory; const iid: TIID; var vObj): HResult; stdcall;
function IsAccelerator(accel: HAccel; cAccelEntries: Integer; msg: PMsg;
  var pwCmd: Word): BOOL; stdcall;

{ Icon extraction helper APIs }

function OleGetIconOfFile(pszPath: POleStr; fUseFileAsLabel: BOOL): HGlobal; stdcall;
function OleGetIconOfClass(const clsid: TCLSID; pszLabel: POleStr;
  fUseTypeAsLabel: BOOL): HGlobal; stdcall;
function OleMetafilePictFromIconAndLabel(icon: HIcon; pszLabel: POleStr;
  pszSourceFile: POleStr; iIconIndex: Integer): HGlobal; stdcall;

{ Registration database helper APIs }

function OleRegGetUserType(const clsid: TCLSID; dwFormOfType: Longint;
  var pszUserType: POleStr): HResult; stdcall;
function OleRegGetMiscStatus(const clsid: TCLSID; dwAspect: Longint;
  var dwStatus: Longint): HResult; stdcall;
function OleRegEnumFormatEtc(const clsid: TCLSID; dwDirection: Longint;
  var enum: IEnumFormatEtc): HResult; stdcall;
function OleRegEnumVerbs(const clsid: TCLSID;
  var enum: IEnumOleVerb): HResult; stdcall;

{ OLE 1.0 conversion APIs }

function OleConvertIStorageToOLESTREAM(stg: IStorage;
  polestm: Pointer): HResult; stdcall;
function OleConvertOLESTREAMToIStorage(polestm: Pointer; stg: IStorage;
  td: PDVTargetDevice): HResult; stdcall;
function OleConvertIStorageToOLESTREAMEx(stg: IStorage; cfFormat: TClipFormat;
  lWidth: Longint; lHeight: Longint; dwSize: Longint; var medium: TStgMedium;
  polestm: Pointer): HResult; stdcall;
function OleConvertOLESTREAMToIStorageEx(polestm: Pointer; stg: IStorage;
  var cfFormat: TClipFormat; var lWidth: Longint; var lHeight: Longint;
  var dwSize: Longint; var medium: TStgMedium): HResult; stdcall;

{ Storage utility APIs }

function GetHGlobalFromILockBytes(lkbyt: ILockBytes; var hglob: HGlobal): HResult; stdcall;
function CreateILockBytesOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL;
  var lkbyt: ILockBytes): HResult; stdcall;
function GetHGlobalFromStream(stm: IStream; var hglob: HGlobal): HResult; stdcall;
function CreateStreamOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL;
  var stm: IStream): HResult; stdcall;

{ ConvertTo APIs }

function OleDoAutoConvert(stg: IStorage; var clsidNew: TCLSID): HResult; stdcall;
function OleGetAutoConvert(const clsidOld: TCLSID; var clsidNew: TCLSID): HResult; stdcall;
function OleSetAutoConvert(const clsidOld: TCLSID; const clsidNew: TCLSID): HResult; stdcall;
function GetConvertStg(stg: IStorage): HResult; stdcall;
function SetConvertStg(stg: IStorage; fConvert: BOOL): HResult; stdcall;

implementation

const
  ole32    = 'ole32.dll';
  oleaut32 = 'oleaut32.dll';

{ Externals from ole32.dll }

function IsEqualGUID;                   external ole32 name 'IsEqualGUID';
function IsEqualIID;                    external ole32 name 'IsEqualGUID';
function IsEqualCLSID;                  external ole32 name 'IsEqualGUID';
function CoBuildVersion;                external ole32 name 'CoBuildVersion';
function CoInitialize;                  external ole32 name 'CoInitialize';
procedure CoUninitialize;               external ole32 name 'CoUninitialize';
function CoGetMalloc;                   external ole32 name 'CoGetMalloc';
function CoGetCurrentProcess;           external ole32 name 'CoGetCurrentProcess';
function CoRegisterMallocSpy;           external ole32 name 'CoRegisterMallocSpy';
function CoRevokeMallocSpy;             external ole32 name 'CoRevokeMallocSpy';
function CoCreateStandardMalloc;        external ole32 name 'CoCreateStandardMalloc';
function CoGetClassObject;              external ole32 name 'CoGetClassObject';
function CoRegisterClassObject;         external ole32 name 'CoRegisterClassObject';
function CoRevokeClassObject;           external ole32 name 'CoRevokeClassObject';
function CoGetMarshalSizeMax;           external ole32 name 'CoGetMarshalSizeMax';
function CoMarshalInterface;            external ole32 name 'CoMarshalInterface';
function CoUnmarshalInterface;          external ole32 name 'CoUnmarshalInterface';
function CoMarshalHResult;              external ole32 name 'CoMarshalHResult';
function CoUnmarshalHResult;            external ole32 name 'CoUnmarshalHResult';
function CoReleaseMarshalData;          external ole32 name 'CoReleaseMarshalData';
function CoDisconnectObject;            external ole32 name 'CoDisconnectObject';
function CoLockObjectExternal;          external ole32 name 'CoLockObjectExternal';
function CoGetStandardMarshal;          external ole32 name 'CoGetStandardMarshal';
function CoIsHandlerConnected;          external ole32 name 'CoIsHandlerConnected';
function CoHasStrongExternalConnections; external ole32 name 'CoHasStrongExternalConnections';
function CoMarshalInterThreadInterfaceInStream; external ole32 name 'CoMarshalInterThreadInterfaceInStream';
function CoGetInterfaceAndReleaseStream; external ole32 name 'CoGetInterfaceAndReleaseStream';
function CoCreateFreeThreadedMarshaler; external ole32 name 'CoCreateFreeThreadedMarshaler';
function CoLoadLibrary;                 external ole32 name 'CoLoadLibrary';
procedure CoFreeLibrary;                external ole32 name 'CoFreeLibrary';
procedure CoFreeAllLibraries;           external ole32 name 'CoFreeAllLibraries';
procedure CoFreeUnusedLibraries;        external ole32 name 'CoFreeUnusedLibraries';
function CoCreateInstance;              external ole32 name 'CoCreateInstance';
function StringFromCLSID;               external ole32 name 'StringFromCLSID';
function CLSIDFromString;               external ole32 name 'CLSIDFromString';
function StringFromIID;                 external ole32 name 'StringFromIID';
function IIDFromString;                 external ole32 name 'IIDFromString';
function CoIsOle1Class;                 external ole32 name 'CoIsOle1Class';
function ProgIDFromCLSID;               external ole32 name 'ProgIDFromCLSID';
function CLSIDFromProgID;               external ole32 name 'CLSIDFromProgID';
function StringFromGUID2;               external ole32 name 'StringFromGUID2';
function CoCreateGuid;                  external ole32 name 'CoCreateGuid';
function CoFileTimeToDosDateTime;       external ole32 name 'CoFileTimeToDosDateTime';
function CoDosDateTimeToFileTime;       external ole32 name 'CoDosDateTimeToFileTime';
function CoFileTimeNow;                 external ole32 name 'CoFileTimeNow';
function CoRegisterMessageFilter;       external ole32 name 'CoRegisterMessageFilter';
function CoGetTreatAsClass;             external ole32 name 'CoGetTreatAsClass';
function CoTreatAsClass;                external ole32 name 'CoTreatAsClass';
function CoTaskMemAlloc;                external ole32 name 'CoTaskMemAlloc';
function CoTaskMemRealloc;              external ole32 name 'CoTaskMemRealloc';
procedure CoTaskMemFree;                external ole32 name 'CoTaskMemFree';
function CreateDataAdviseHolder;        external ole32 name 'CreateDataAdviseHolder';
function CreateDataCache;               external ole32 name 'CreateDataCache';
function StgCreateDocfile;              external ole32 name 'StgCreateDocfile';
function StgCreateDocfileOnILockBytes;  external ole32 name 'StgCreateDocfileOnILockBytes';
function StgOpenStorage;                external ole32 name 'StgOpenStorage';
function StgOpenStorageOnILockBytes;    external ole32 name 'StgOpenStorageOnILockBytes';
function StgIsStorageFile;              external ole32 name 'StgIsStorageFile';
function StgIsStorageILockBytes;        external ole32 name 'StgIsStorageILockBytes';
function StgSetTimes;                   external ole32 name 'StgSetTimes';
function BindMoniker;                   external ole32 name 'BindMoniker';
function MkParseDisplayName;            external ole32 name 'MkParseDisplayName';
function MonikerRelativePathTo;         external ole32 name 'MonikerRelativePathTo';
function MonikerCommonPrefixWith;       external ole32 name 'MonikerCommonPrefixWith';
function CreateBindCtx;                 external ole32 name 'CreateBindCtx';
function CreateGenericComposite;        external ole32 name 'CreateGenericComposite';
function GetClassFile;                  external ole32 name 'GetClassFile';
function CreateFileMoniker;             external ole32 name 'CreateFileMoniker';
function CreateItemMoniker;             external ole32 name 'CreateItemMoniker';
function CreateAntiMoniker;             external ole32 name 'CreateAntiMoniker';
function CreatePointerMoniker;          external ole32 name 'CreatePointerMoniker';
function GetRunningObjectTable;         external ole32 name 'GetRunningObjectTable';
function OleBuildVersion;               external ole32 name 'OleBuildVersion';
function ReadClassStg;                  external ole32 name 'ReadClassStg';
function WriteClassStg;                 external ole32 name 'WriteClassStg';
function ReadClassStm;                  external ole32 name 'ReadClassStm';
function WriteClassStm;                 external ole32 name 'WriteClassStm';
function WriteFmtUserTypeStg;           external ole32 name 'WriteFmtUserTypeStg';
function ReadFmtUserTypeStg;            external ole32 name 'ReadFmtUserTypeStg';
function OleInitialize;                 external ole32 name 'OleInitialize';
procedure OleUninitialize;              external ole32 name 'OleUninitialize';
function OleQueryLinkFromData;          external ole32 name 'OleQueryLinkFromData';
function OleQueryCreateFromData;        external ole32 name 'OleQueryCreateFromData';
function OleCreate;                     external ole32 name 'OleCreate';
function OleCreateFromData;             external ole32 name 'OleCreateFromData';
function OleCreateLinkFromData;         external ole32 name 'OleCreateLinkFromData';
function OleCreateStaticFromData;       external ole32 name 'OleCreateStaticFromData';
function OleCreateLink;                 external ole32 name 'OleCreateLink';
function OleCreateLinkToFile;           external ole32 name 'OleCreateLinkToFile';
function OleCreateFromFile;             external ole32 name 'OleCreateFromFile';
function OleLoad;                       external ole32 name 'OleLoad';
function OleSave;                       external ole32 name 'OleSave';
function OleLoadFromStream;             external ole32 name 'OleLoadFromStream';
function OleSaveToStream;               external ole32 name 'OleSaveToStream';
function OleSetContainedObject;         external ole32 name 'OleSetContainedObject';
function OleNoteObjectVisible;          external ole32 name 'OleNoteObjectVisible';
function RegisterDragDrop;              external ole32 name 'RegisterDragDrop';
function RevokeDragDrop;                external ole32 name 'RevokeDragDrop';
function DoDragDrop;                    external ole32 name 'DoDragDrop';
function OleSetClipboard;               external ole32 name 'OleSetClipboard';
function OleGetClipboard;               external ole32 name 'OleGetClipboard';
function OleFlushClipboard ;            external ole32 name 'OleFlushClipboard';
function OleIsCurrentClipboard;         external ole32 name 'OleIsCurrentClipboard';
function OleCreateMenuDescriptor;       external ole32 name 'OleCreateMenuDescriptor';
function OleSetMenuDescriptor;          external ole32 name 'OleSetMenuDescriptor';
function OleDestroyMenuDescriptor;      external ole32 name 'OleDestroyMenuDescriptor';
function OleTranslateAccelerator;       external ole32 name 'OleTranslateAccelerator';
function OleDuplicateData;              external ole32 name 'OleDuplicateData';
function OleDraw;                       external ole32 name 'OleDraw';
function OleRun;                        external ole32 name 'OleRun';
function OleIsRunning;                  external ole32 name 'OleIsRunning';
function OleLockRunning;                external ole32 name 'OleLockRunning';
procedure ReleaseStgMedium;             external ole32 name 'ReleaseStgMedium';
function CreateOleAdviseHolder;         external ole32 name 'CreateOleAdviseHolder';
function OleCreateDefaultHandler;       external ole32 name 'OleCreateDefaultHandler';
function OleCreateEmbeddingHelper;      external ole32 name 'OleCreateEmbeddingHelper';
function IsAccelerator;                 external ole32 name 'IsAccelerator';
function OleGetIconOfFile;              external ole32 name 'OleGetIconOfFile';
function OleGetIconOfClass;             external ole32 name 'OleGetIconOfClass';
function OleMetafilePictFromIconAndLabel; external ole32 name 'OleMetafilePictFromIconAndLabel';
function OleRegGetUserType;             external ole32 name 'OleRegGetUserType';
function OleRegGetMiscStatus;           external ole32 name 'OleRegGetMiscStatus';
function OleRegEnumFormatEtc;           external ole32 name 'OleRegEnumFormatEtc';
function OleRegEnumVerbs;               external ole32 name 'OleRegEnumVerbs';
function OleConvertIStorageToOLESTREAM; external ole32 name 'OleConvertIStorageToOLESTREAM';
function OleConvertOLESTREAMToIStorage; external ole32 name 'OleConvertOLESTREAMToIStorage';
function OleConvertIStorageToOLESTREAMEx; external ole32 name 'OleConvertIStorageToOLESTREAMEx';
function OleConvertOLESTREAMToIStorageEx; external ole32 name 'OleConvertOLESTREAMToIStorageEx';
function GetHGlobalFromILockBytes;      external ole32 name 'GetHGlobalFromILockBytes';
function CreateILockBytesOnHGlobal;     external ole32 name 'CreateILockBytesOnHGlobal';
function GetHGlobalFromStream;          external ole32 name 'GetHGlobalFromStream';
function CreateStreamOnHGlobal;         external ole32 name 'CreateStreamOnHGlobal';
function OleDoAutoConvert;              external ole32 name 'OleDoAutoConvert';
function OleGetAutoConvert;             external ole32 name 'OleGetAutoConvert';
function OleSetAutoConvert;             external ole32 name 'OleSetAutoConvert';
function GetConvertStg;                 external ole32 name 'GetConvertStg';
function SetConvertStg;                 external ole32 name 'SetConvertStg';

{ Externals from oleaut32.dll }

function SysAllocString;                external oleaut32 name 'SysAllocString';
function SysReAllocString;              external oleaut32 name 'SysReAllocString';
function SysAllocStringLen;             external oleaut32 name 'SysAllocStringLen';
function SysReAllocStringLen;           external oleaut32 name 'SysReAllocStringLen';
procedure SysFreeString;                external oleaut32 name 'SysFreeString';
function SysStringLen;                  external oleaut32 name 'SysStringLen';
function SysStringByteLen;              external oleaut32 name 'SysStringByteLen';
function SysAllocStringByteLen;         external oleaut32 name 'SysAllocStringByteLen';
function DosDateTimeToVariantTime;      external oleaut32 name 'DosDateTimeToVariantTime';
function VariantTimeToDosDateTime;      external oleaut32 name 'VariantTimeToDosDateTime';
function SafeArrayAllocDescriptor;      external oleaut32 name 'SafeArrayAllocDescriptor';
function SafeArrayAllocData;            external oleaut32 name 'SafeArrayAllocData';
function SafeArrayCreate;               external oleaut32 name 'SafeArrayCreate';
function SafeArrayDestroyDescriptor;    external oleaut32 name 'SafeArrayDestroyDescriptor';
function SafeArrayDestroyData;          external oleaut32 name 'SafeArrayDestroyData';
function SafeArrayDestroy;              external oleaut32 name 'SafeArrayDestroy';
function SafeArrayRedim;                external oleaut32 name 'SafeArrayRedim';
function SafeArrayGetDim;               external oleaut32 name 'SafeArrayGetDim';
function SafeArrayGetElemsize;          external oleaut32 name 'SafeArrayGetElemsize';
function SafeArrayGetUBound;            external oleaut32 name 'SafeArrayGetUBound';
function SafeArrayGetLBound;            external oleaut32 name 'SafeArrayGetLBound';
function SafeArrayLock;                 external oleaut32 name 'SafeArrayLock';
function SafeArrayUnlock;               external oleaut32 name 'SafeArrayUnlock';
function SafeArrayAccessData;           external oleaut32 name 'SafeArrayAccessData';
function SafeArrayUnaccessData;         external oleaut32 name 'SafeArrayUnaccessData';
function SafeArrayGetElement;           external oleaut32 name 'SafeArrayGetElement';
function SafeArrayPutElement;           external oleaut32 name 'SafeArrayPutElement';
function SafeArrayCopy;                 external oleaut32 name 'SafeArrayCopy';
function SafeArrayPtrOfIndex;           external oleaut32 name 'SafeArrayPtrOfIndex';
procedure VariantInit;                  external oleaut32 name 'VariantInit';
function VariantClear;                  external oleaut32 name 'VariantClear';
function VariantCopy;                   external oleaut32 name 'VariantCopy';
function VariantCopyInd;                external oleaut32 name 'VariantCopyInd';
function VariantChangeType;             external oleaut32 name 'VariantChangeType';
function VariantChangeTypeEx;           external oleaut32 name 'VariantChangeTypeEx';
function VarUI1FromI2;                  external oleaut32 name 'VarUI1FromI2';
function VarUI1FromI4;                  external oleaut32 name 'VarUI1FromI4';
function VarUI1FromR4;                  external oleaut32 name 'VarUI1FromR4';
function VarUI1FromR8;                  external oleaut32 name 'VarUI1FromR8';
function VarUI1FromCy;                  external oleaut32 name 'VarUI1FromCy';
function VarUI1FromDate;                external oleaut32 name 'VarUI1FromDate';
function VarUI1FromStr;                 external oleaut32 name 'VarUI1FromStr';
function VarUI1FromDisp;                external oleaut32 name 'VarUI1FromDisp';
function VarUI1FromBool;                external oleaut32 name 'VarUI1FromBool';
function VarI2FromUI1;                  external oleaut32 name 'VarI2FromUI1';
function VarI2FromI4;                   external oleaut32 name 'VarI2FromI4';
function VarI2FromR4;                   external oleaut32 name 'VarI2FromR4';
function VarI2FromR8;                   external oleaut32 name 'VarI2FromR8';
function VarI2FromCy;                   external oleaut32 name 'VarI2FromCy';
function VarI2FromDate;                 external oleaut32 name 'VarI2FromDate';
function VarI2FromStr;                  external oleaut32 name 'VarI2FromStr';
function VarI2FromDisp;                 external oleaut32 name 'VarI2FromDisp';
function VarI2FromBool;                 external oleaut32 name 'VarI2FromBool';
function VarI4FromUI1;                  external oleaut32 name 'VarI4FromUI1';
function VarI4FromI2;                   external oleaut32 name 'VarI4FromI2';
function VarI4FromR4;                   external oleaut32 name 'VarI4FromR4';
function VarI4FromR8;                   external oleaut32 name 'VarI4FromR8';
function VarI4FromCy;                   external oleaut32 name 'VarI4FromCy';
function VarI4FromDate;                 external oleaut32 name 'VarI4FromDate';
function VarI4FromStr;                  external oleaut32 name 'VarI4FromStr';
function VarI4FromDisp;                 external oleaut32 name 'VarI4FromDisp';
function VarI4FromBool;                 external oleaut32 name 'VarI4FromBool';
function VarR4FromUI1;                  external oleaut32 name 'VarR4FromUI1';
function VarR4FromI2;                   external oleaut32 name 'VarR4FromI2';
function VarR4FromI4;                   external oleaut32 name 'VarR4FromI4';
function VarR4FromR8;                   external oleaut32 name 'VarR4FromR8';
function VarR4FromCy;                   external oleaut32 name 'VarR4FromCy';
function VarR4FromDate;                 external oleaut32 name 'VarR4FromDate';
function VarR4FromStr;                  external oleaut32 name 'VarR4FromStr';
function VarR4FromDisp;                 external oleaut32 name 'VarR4FromDisp';
function VarR4FromBool;                 external oleaut32 name 'VarR4FromBool';
function VarR8FromUI1;                  external oleaut32 name 'VarR8FromUI1';
function VarR8FromI2;                   external oleaut32 name 'VarR8FromI2';
function VarR8FromI4;                   external oleaut32 name 'VarR8FromI4';
function VarR8FromR4;                   external oleaut32 name 'VarR8FromR4';
function VarR8FromCy;                   external oleaut32 name 'VarR8FromCy';
function VarR8FromDate;                 external oleaut32 name 'VarR8FromDate';
function VarR8FromStr;                  external oleaut32 name 'VarR8FromStr';
function VarR8FromDisp;                 external oleaut32 name 'VarR8FromDisp';
function VarR8FromBool;                 external oleaut32 name 'VarR8FromBool';
function VarDateFromUI1;                external oleaut32 name 'VarDateFromUI1';
function VarDateFromI2;                 external oleaut32 name 'VarDateFromI2';
function VarDateFromI4;                 external oleaut32 name 'VarDateFromI4';
function VarDateFromR4;                 external oleaut32 name 'VarDateFromR4';
function VarDateFromR8;                 external oleaut32 name 'VarDateFromR8';
function VarDateFromCy;                 external oleaut32 name 'VarDateFromCy';
function VarDateFromStr;                external oleaut32 name 'VarDateFromStr';
function VarDateFromDisp;               external oleaut32 name 'VarDateFromDisp';
function VarDateFromBool;               external oleaut32 name 'VarDateFromBool';
function VarCyFromUI1;                  external oleaut32 name 'VarCyFromUI1';
function VarCyFromI2;                   external oleaut32 name 'VarCyFromI2';
function VarCyFromI4;                   external oleaut32 name 'VarCyFromI4';
function VarCyFromR4;                   external oleaut32 name 'VarCyFromR4';
function VarCyFromR8;                   external oleaut32 name 'VarCyFromR8';
function VarCyFromDate;                 external oleaut32 name 'VarCyFromDate';
function VarCyFromStr;                  external oleaut32 name 'VarCyFromStr';
function VarCyFromDisp;                 external oleaut32 name 'VarCyFromDisp';
function VarCyFromBool;                 external oleaut32 name 'VarCyFromBool';
function VarBStrFromUI1;                external oleaut32 name 'VarBStrFromUI1';
function VarBStrFromI2;                 external oleaut32 name 'VarBStrFromI2';
function VarBStrFromI4;                 external oleaut32 name 'VarBStrFromI4';
function VarBStrFromR4;                 external oleaut32 name 'VarBStrFromR4';
function VarBStrFromR8;                 external oleaut32 name 'VarBStrFromR8';
function VarBStrFromCy;                 external oleaut32 name 'VarBStrFromCy';
function VarBStrFromDate;               external oleaut32 name 'VarBStrFromDate';
function VarBStrFromDisp;               external oleaut32 name 'VarBStrFromDisp';
function VarBStrFromBool;               external oleaut32 name 'VarBStrFromBool';
function VarBoolFromUI1;                external oleaut32 name 'VarBoolFromUI1';
function VarBoolFromI2;                 external oleaut32 name 'VarBoolFromI2';
function VarBoolFromI4;                 external oleaut32 name 'VarBoolFromI4';
function VarBoolFromR4;                 external oleaut32 name 'VarBoolFromR4';
function VarBoolFromR8;                 external oleaut32 name 'VarBoolFromR8';
function VarBoolFromDate;               external oleaut32 name 'VarBoolFromDate';
function VarBoolFromCy;                 external oleaut32 name 'VarBoolFromCy';
function VarBoolFromStr;                external oleaut32 name 'VarBoolFromStr';
function VarBoolFromDisp;               external oleaut32 name 'VarBoolFromDisp';
function LHashValOfNameSys;             external oleaut32 name 'LHashValOfNameSys';
function LHashValOfNameSysA;            external oleaut32 name 'LHashValOfNameSysA';
function LoadTypeLib;                   external oleaut32 name 'LoadTypeLib';
function LoadRegTypeLib;                external oleaut32 name 'LoadRegTypeLib';
function QueryPathOfRegTypeLib;         external oleaut32 name 'QueryPathOfRegTypeLib';
function RegisterTypeLib;               external oleaut32 name 'RegisterTypeLib';
function CreateTypeLib;                 external oleaut32 name 'CreateTypeLib';
function DispGetParam;                  external oleaut32 name 'DispGetParam';
function DispGetIDsOfNames;             external oleaut32 name 'DispGetIDsOfNames';
function DispInvoke;                    external oleaut32 name 'DispInvoke';
function CreateDispTypeInfo;            external oleaut32 name 'CreateDispTypeInfo';
function CreateStdDispatch;             external oleaut32 name 'CreateStdDispatch';
function RegisterActiveObject;          external oleaut32 name 'RegisterActiveObject';
function RevokeActiveObject;            external oleaut32 name 'RevokeActiveObject';
function GetActiveObject;               external oleaut32 name 'GetActiveObject';
function SetErrorInfo;                  external oleaut32 name 'SetErrorInfo';
function GetErrorInfo;                  external oleaut32 name 'GetErrorInfo';
function CreateErrorInfo;               external oleaut32 name 'CreateErrorInfo';
function OaBuildVersion;                external oleaut32 name 'OaBuildVersion';

{ Helper functions }

function Succeeded(Res: HResult): Boolean;
begin
  Result := Res >= 0;
end;

function Failed(Res: HResult): Boolean;
begin
  Result := Res < 0;
end;

function ResultCode(Res: HResult): Integer;
begin
  Result := Res and $0000FFFF;
end;

function ResultFacility(Res: HResult): Integer;
begin
  Result := (Res shr 16) and $00001FFF;
end;

function ResultSeverity(Res: HResult): Integer;
begin
  Result := Res shr 31;
end;

function MakeResult(Severity, Facility, Code: Integer): HResult;
begin
  Result := (Severity shl 31) or (Facility shl 16) or Code;
end;

function LHashValOfName(lcid: TLCID; szName: POleStr): Longint;
begin
  Result := LHashValOfNameSys(SYS_WIN32, lcid, szName);
end;

function WHashValOfLHashVal(lhashval: Longint): Word;
begin
  Result := lhashval and $0000FFFF;
end;

function IsHashValCompatible(lhashval1, lhashval2: Longint): Boolean;
begin
  Result := lhashval1 and $00FF0000 = lhashval2 and $00FF0000;
end;

end.
