import 'dart:ffi';

const inline = pragma("vm:prefer-inline");
const neverInline = pragma("vm:never-inline");

const coreModuleId = 0;
const coreModuleName = "core";
const corePackageName = "core";
final coreLibraryName = bool.fromEnvironment("DEBUG") ? "libcore_debug_${Abi.current()}.so" : "libcore_release_${Abi.current()}.so";

const empty = "";
const unknown = "unknown";
const newLine = "\n";
const slash = "/";
const dot = ".";
const star = "*";
const dash = "-";
const equalSpaced = " = ";
const openingBracket = "{";
const closingBracket = "}";
const comma = ",";
const parentDirectorySymbol = '..';
const currentDirectorySymbol = './';
const packageConfigJsonFile = "package_config.json";
const pubspecYamlFile = 'pubspec.yaml';
const pubspecYmlFile = 'pubspec.yml';

const int64MaxValue = 9223372036854775807;
const int32MaxValue = 2147483647;
const soFileExtension = "so";
const nativeDirectory = "native";

const modules_maximum = 64;

const printLevelPanic = 0;
const printLevelError = 1;
const printLevelWarning = 2;
const printLevelInformation = 3;
const printLevelTrace = 4;

const printLevelPanicLabel = "(panic)";
const printLevelErrorLabel = "(error)";
const printLevelWarningLabel = "(warning)";
const printLevelInformationLabel = "(information)";
const printLevelTraceLabel = "(trace)";

const printExceptionLabel = "(exception)";

const printSystemExceptionTag = "system";

const printErrorStackPart = "Error stack:";
const printCatchStackPart = "Catch stack:";

enum LibraryPackageMode {
  shared,
  static,
}

class CoreErrors {
  CoreErrors._();

  static String systemLibraryLoadError(path) => "Unable to load library ${path}";
  static const nonLinuxError = "You should use Linux";
  static const unableToFindProjectRoot = "Unable to find project root";
  static moduleAlreadyLoaded(int id) => "Module was already loaded: $id";
  static moduleNotLoaded(int id) => "Module was not loaded: $id";
  static moduleNotFound(int id) => "Module was not found: $id";
  static moduleDependenciesNotFound(List<String> dependencies) => "Module dependencies were not found: ${dependencies}";
}

class TupleErrors {
  TupleErrors._();

  static const maxStringLength = 'Max string length is 4294967295';
  static const maxBinaryLength = 'Max binary length is 4294967295';
  static const maxListLength = 'Max list length is 4294967295';
  static const maxMapLength = 'Max map length is 4294967295';
  static unknownType(Type type) => "Unknown type: ${type}";
  static notBool(dynamic value) => 'Byte $value is not declare bool';
  static notInt(dynamic value) => "Byte $value is not declare int";
  static notDouble(dynamic value) => "Byte $value is not declare double";
  static notString(dynamic bytes) => "Byte $bytes is not declare string";
  static notBinary(dynamic bytes) => "Byte $bytes is not declare binary";
  static notList(dynamic bytes) => "Byte $bytes is not declare list";
  static notMap(dynamic bytes) => "Byte $bytes is not declare map";
}

class SourcesDirectories {
  const SourcesDirectories._();

  static const assets = "/assets";
  static const package = "/package";
  static const dotDartTool = ".dart_tool";
}

class PackageConfigFields {
  PackageConfigFields._();

  static const rootUri = 'rootUri';
  static const name = 'name';
  static const packages = 'packages';
}

class SystemError {
  final int code;
  final String message;

  SystemError(this.code, this.message);

  @override
  String toString() => message;
}

class SystemErrors {
  SystemErrors._();

  static final EPERM = SystemError(1, "Operation not permitted");
  static final ENOENT = SystemError(2, "No such file or directory");
  static final ESRCH = SystemError(3, "No such process");
  static final EINTR = SystemError(4, "Interrupted system call");
  static final EIO = SystemError(5, "Input/output error");
  static final ENXIO = SystemError(6, "No such device or address");
  static final E2BIG = SystemError(7, "Argument list too long");
  static final ENOEXEC = SystemError(8, "Exec format error");
  static final EBADF = SystemError(9, "Bad file descriptor");
  static final ECHILD = SystemError(10, "No child processes");
  static final EAGAIN = SystemError(11, "Resource temporarily unavailable");
  static final ENOMEM = SystemError(12, "Cannot allocate memory");
  static final EACCES = SystemError(13, "Permission denied");
  static final EFAULT = SystemError(14, "Bad address");
  static final ENOTBLK = SystemError(15, "Block device required");
  static final EBUSY = SystemError(16, "Device or resource busy");
  static final EEXIST = SystemError(17, "File exists");
  static final EXDEV = SystemError(18, "Invalid cross-device link");
  static final ENODEV = SystemError(19, "No such device");
  static final ENOTDIR = SystemError(20, "Not a directory");
  static final EISDIR = SystemError(21, "Is a directory");
  static final EINVAL = SystemError(22, "Invalid argument");
  static final ENFILE = SystemError(23, "Too many open files in system");
  static final EMFILE = SystemError(24, "Too many open files");
  static final ENOTTY = SystemError(25, "Inappropriate ioctl for device");
  static final ETXTBSY = SystemError(26, "Text file busy");
  static final EFBIG = SystemError(27, "File too large");
  static final ENOSPC = SystemError(28, "No space left on device");
  static final ESPIPE = SystemError(29, "Illegal seek");
  static final EROFS = SystemError(30, "Read-only file system");
  static final EMLINK = SystemError(31, "Too many links");
  static final EPIPE = SystemError(32, "Broken pipe");
  static final EDOM = SystemError(33, "Numerical argument out of domain");
  static final ERANGE = SystemError(34, "Numerical result out of range");
  static final EDEADLK = SystemError(35, "Resource deadlock avoided");
  static final ENAMETOOLONG = SystemError(36, "File name too long");
  static final ENOLCK = SystemError(37, "No locks available");
  static final ENOSYS = SystemError(38, "Function not implemented");
  static final ENOTEMPTY = SystemError(39, "Directory not empty");
  static final ELOOP = SystemError(40, "Too many levels of symbolic links");
  static final EWOULDBLOCK = SystemError(11, "Resource temporarily unavailable");
  static final ENOMSG = SystemError(42, "No message of desired type");
  static final EIDRM = SystemError(43, "Identifier removed");
  static final ECHRNG = SystemError(44, "Channel number out of range");
  static final EL2NSYNC = SystemError(45, "Level 2 not synchronized");
  static final EL3HLT = SystemError(46, "Level 3 halted");
  static final EL3RST = SystemError(47, "Level 3 reset");
  static final ELNRNG = SystemError(48, "Link number out of range");
  static final EUNATCH = SystemError(49, "Protocol driver not attached");
  static final ENOCSI = SystemError(50, "No CSI structure available");
  static final EL2HLT = SystemError(51, "Level 2 halted");
  static final EBADE = SystemError(52, "Invalid exchange");
  static final EBADR = SystemError(53, "Invalid request descriptor");
  static final EXFULL = SystemError(54, "Exchange full");
  static final ENOANO = SystemError(55, "No anode");
  static final EBADRQC = SystemError(56, "Invalid request code");
  static final EBADSLT = SystemError(57, "Invalid slot");
  static final EDEADLOCK = SystemError(35, "Resource deadlock avoided");
  static final EBFONT = SystemError(59, "Bad font file format");
  static final ENOSTR = SystemError(60, "Device not a stream");
  static final ENODATA = SystemError(61, "No data available");
  static final ETIME = SystemError(62, "Timer expired");
  static final ENOSR = SystemError(63, "Out of streams resources");
  static final ENONET = SystemError(64, "Machine is not on the network");
  static final ENOPKG = SystemError(65, "Package not installed");
  static final EREMOTE = SystemError(66, "Object is remote");
  static final ENOLINK = SystemError(67, "Link has been severed");
  static final EADV = SystemError(68, "Advertise error");
  static final ESRMNT = SystemError(69, "Srmount error");
  static final ECOMM = SystemError(70, "Communication error on send");
  static final EPROTO = SystemError(71, "Protocol error");
  static final EMULTIHOP = SystemError(72, "Multihop attempted");
  static final EDOTDOT = SystemError(73, "RFS specific error");
  static final EBADMSG = SystemError(74, "Bad message");
  static final EOVERFLOW = SystemError(75, "Value too large for defined data type");
  static final ENOTUNIQ = SystemError(76, "Name not unique on network");
  static final EBADFD = SystemError(77, "File descriptor in bad state");
  static final EREMCHG = SystemError(78, "Remote address changed");
  static final ELIBACC = SystemError(79, "Can not access a needed shared library");
  static final ELIBBAD = SystemError(80, "Accessing a corrupted shared library");
  static final ELIBSCN = SystemError(81, ".lib section in a.out corrupted");
  static final ELIBMAX = SystemError(82, "Attempting to link in too many shared libraries");
  static final ELIBEXEC = SystemError(83, "Cannot exec a shared library directly");
  static final EILSEQ = SystemError(84, "Invalid or incomplete multibyte or wide character");
  static final ERESTART = SystemError(85, "Interrupted system call should be restarted");
  static final ESTRPIPE = SystemError(86, "Streams pipe error");
  static final EUSERS = SystemError(87, "Too many users");
  static final ENOTSOCK = SystemError(88, "Socket operation on non-socket");
  static final EDESTADDRREQ = SystemError(89, "Destination address required");
  static final EMSGSIZE = SystemError(90, "Message too long");
  static final EPROTOTYPE = SystemError(91, "Protocol wrong type for socket");
  static final ENOPROTOOPT = SystemError(92, "Protocol not available");
  static final EPROTONOSUPPORT = SystemError(93, "Protocol not supported");
  static final ESOCKTNOSUPPORT = SystemError(94, "Socket type not supported");
  static final EOPNOTSUPP = SystemError(95, "Operation not supported");
  static final EPFNOSUPPORT = SystemError(96, "Protocol family not supported");
  static final EAFNOSUPPORT = SystemError(97, "Address family not supported by protocol");
  static final EADDRINUSE = SystemError(98, "Address already in use");
  static final EADDRNOTAVAIL = SystemError(99, "Cannot assign requested address");
  static final ENETDOWN = SystemError(100, "Network is down");
  static final ENETUNREACH = SystemError(101, "Network is unreachable");
  static final ENETRESET = SystemError(102, "Network dropped connection on reset");
  static final ECONNABORTED = SystemError(103, "Software caused connection abort");
  static final ECONNRESET = SystemError(104, "Connection reset by peer");
  static final ENOBUFS = SystemError(105, "No buffer space available");
  static final EISCONN = SystemError(106, "Transport endpoint is already connected");
  static final ENOTCONN = SystemError(107, "Transport endpoint is not connected");
  static final ESHUTDOWN = SystemError(108, "Cannot send after transport endpoint shutdown");
  static final ETOOMANYREFS = SystemError(109, "Too many references: cannot splice");
  static final ETIMEDOUT = SystemError(110, "Connection timed out");
  static final ECONNREFUSED = SystemError(111, "Connection refused");
  static final EHOSTDOWN = SystemError(112, "Host is down");
  static final EHOSTUNREACH = SystemError(113, "No route to host");
  static final EALREADY = SystemError(114, "Operation already in progress");
  static final EINPROGRESS = SystemError(115, "Operation now in progress");
  static final ESTALE = SystemError(116, "Stale file handle");
  static final EUCLEAN = SystemError(117, "Structure needs cleaning");
  static final ENOTNAM = SystemError(118, "Not a XENIX named type file");
  static final ENAVAIL = SystemError(119, "No XENIX semaphores available");
  static final EISNAM = SystemError(120, "Is a named type file");
  static final EREMOTEIO = SystemError(121, "Remote I/O error");
  static final EDQUOT = SystemError(122, "Disk quota exceeded");
  static final ENOMEDIUM = SystemError(123, "No medium found");
  static final EMEDIUMTYPE = SystemError(124, "Wrong medium type");
  static final ECANCELED = SystemError(125, "Operation canceled");
  static final ENOKEY = SystemError(126, "Required key not available");
  static final EKEYEXPIRED = SystemError(127, "Key has expired");
  static final EKEYREVOKED = SystemError(128, "Key has been revoked");
  static final EKEYREJECTED = SystemError(129, "Key was rejected by service");
  static final EOWNERDEAD = SystemError(130, "Owner died");
  static final ENOTRECOVERABLE = SystemError(131, "State not recoverable");
  static final ERFKILL = SystemError(132, "Operation not possible due to RF-kill");
  static final EHWPOISON = SystemError(133, "Memory page has hardware error");
  static final ENOTSUP = SystemError(95, "Operation not supported");

  static final _errors = <int, SystemError>{
    EPERM.code: EPERM,
    ENOENT.code: ENOENT,
    ESRCH.code: ESRCH,
    EINTR.code: EINTR,
    EIO.code: EIO,
    ENXIO.code: ENXIO,
    E2BIG.code: E2BIG,
    ENOEXEC.code: ENOEXEC,
    EBADF.code: EBADF,
    ECHILD.code: ECHILD,
    EAGAIN.code: EAGAIN,
    ENOMEM.code: ENOMEM,
    EACCES.code: EACCES,
    EFAULT.code: EFAULT,
    ENOTBLK.code: ENOTBLK,
    EBUSY.code: EBUSY,
    EEXIST.code: EEXIST,
    EXDEV.code: EXDEV,
    ENODEV.code: ENODEV,
    ENOTDIR.code: ENOTDIR,
    EISDIR.code: EISDIR,
    EINVAL.code: EINVAL,
    ENFILE.code: ENFILE,
    EMFILE.code: EMFILE,
    ENOTTY.code: ENOTTY,
    ETXTBSY.code: ETXTBSY,
    EFBIG.code: EFBIG,
    ENOSPC.code: ENOSPC,
    ESPIPE.code: ESPIPE,
    EROFS.code: EROFS,
    EMLINK.code: EMLINK,
    EPIPE.code: EPIPE,
    EDOM.code: EDOM,
    ERANGE.code: ERANGE,
    EDEADLK.code: EDEADLK,
    ENAMETOOLONG.code: ENAMETOOLONG,
    ENOLCK.code: ENOLCK,
    ENOSYS.code: ENOSYS,
    ENOTEMPTY.code: ENOTEMPTY,
    ELOOP.code: ELOOP,
    EWOULDBLOCK.code: EWOULDBLOCK,
    ENOMSG.code: ENOMSG,
    EIDRM.code: EIDRM,
    ECHRNG.code: ECHRNG,
    EL2NSYNC.code: EL2NSYNC,
    EL3HLT.code: EL3HLT,
    EL3RST.code: EL3RST,
    ELNRNG.code: ELNRNG,
    EUNATCH.code: EUNATCH,
    ENOCSI.code: ENOCSI,
    EL2HLT.code: EL2HLT,
    EBADE.code: EBADE,
    EBADR.code: EBADR,
    EXFULL.code: EXFULL,
    ENOANO.code: ENOANO,
    EBADRQC.code: EBADRQC,
    EBADSLT.code: EBADSLT,
    EDEADLOCK.code: EDEADLOCK,
    EBFONT.code: EBFONT,
    ENOSTR.code: ENOSTR,
    ENODATA.code: ENODATA,
    ETIME.code: ETIME,
    ENOSR.code: ENOSR,
    ENONET.code: ENONET,
    ENOPKG.code: ENOPKG,
    EREMOTE.code: EREMOTE,
    ENOLINK.code: ENOLINK,
    EADV.code: EADV,
    ESRMNT.code: ESRMNT,
    ECOMM.code: ECOMM,
    EPROTO.code: EPROTO,
    EMULTIHOP.code: EMULTIHOP,
    EDOTDOT.code: EDOTDOT,
    EBADMSG.code: EBADMSG,
    EOVERFLOW.code: EOVERFLOW,
    ENOTUNIQ.code: ENOTUNIQ,
    EBADFD.code: EBADFD,
    EREMCHG.code: EREMCHG,
    ELIBACC.code: ELIBACC,
    ELIBBAD.code: ELIBBAD,
    ELIBSCN.code: ELIBSCN,
    ELIBMAX.code: ELIBMAX,
    ELIBEXEC.code: ELIBEXEC,
    EILSEQ.code: EILSEQ,
    ERESTART.code: ERESTART,
    ESTRPIPE.code: ESTRPIPE,
    EUSERS.code: EUSERS,
    ENOTSOCK.code: ENOTSOCK,
    EDESTADDRREQ.code: EDESTADDRREQ,
    EMSGSIZE.code: EMSGSIZE,
    EPROTOTYPE.code: EPROTOTYPE,
    ENOPROTOOPT.code: ENOPROTOOPT,
    EPROTONOSUPPORT.code: EPROTONOSUPPORT,
    ESOCKTNOSUPPORT.code: ESOCKTNOSUPPORT,
    EOPNOTSUPP.code: EOPNOTSUPP,
    EPFNOSUPPORT.code: EPFNOSUPPORT,
    EAFNOSUPPORT.code: EAFNOSUPPORT,
    EADDRINUSE.code: EADDRINUSE,
    EADDRNOTAVAIL.code: EADDRNOTAVAIL,
    ENETDOWN.code: ENETDOWN,
    ENETUNREACH.code: ENETUNREACH,
    ENETRESET.code: ENETRESET,
    ECONNABORTED.code: ECONNABORTED,
    ECONNRESET.code: ECONNRESET,
    ENOBUFS.code: ENOBUFS,
    EISCONN.code: EISCONN,
    ENOTCONN.code: ENOTCONN,
    ESHUTDOWN.code: ESHUTDOWN,
    ETOOMANYREFS.code: ETOOMANYREFS,
    ETIMEDOUT.code: ETIMEDOUT,
    ECONNREFUSED.code: ECONNREFUSED,
    EHOSTDOWN.code: EHOSTDOWN,
    EHOSTUNREACH.code: EHOSTUNREACH,
    EALREADY.code: EALREADY,
    EINPROGRESS.code: EINPROGRESS,
    ESTALE.code: ESTALE,
    EUCLEAN.code: EUCLEAN,
    ENOTNAM.code: ENOTNAM,
    ENAVAIL.code: ENAVAIL,
    EISNAM.code: EISNAM,
    EREMOTEIO.code: EREMOTEIO,
    EDQUOT.code: EDQUOT,
    ENOMEDIUM.code: ENOMEDIUM,
    EMEDIUMTYPE.code: EMEDIUMTYPE,
    ECANCELED.code: ECANCELED,
    ENOKEY.code: ENOKEY,
    EKEYEXPIRED.code: EKEYEXPIRED,
    EKEYREVOKED.code: EKEYREVOKED,
    EKEYREJECTED.code: EKEYREJECTED,
    EOWNERDEAD.code: EOWNERDEAD,
    ENOTRECOVERABLE.code: ENOTRECOVERABLE,
    ERFKILL.code: ERFKILL,
    EHWPOISON.code: EHWPOISON,
    ENOTSUP.code: ENOTSUP,
  };

  static SystemError of(int code) {
    if (_errors[code] == null) throw UnimplementedError("Unknown system error code: $code");
    return _errors[code]!;
  }
}
