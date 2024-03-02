import 'dart:ffi';

import 'package:core/core.dart';

final mediatorLibraryName = bool.fromEnvironment("DEBUG") ? "libmediator_debug_${Abi.current()}.so" : "libmediator_release_${Abi.current()}.so";
const mediatorPackageName = "mediator";

class MediatorErrors {
  MediatorErrors._();

  static const mediatorMemoryError = "[mediator] out of memory";
  static const mediatorRingFullError = "[mediator] ring is full";
  static mediatorError(int result) => systemError(-result);
}

const mediatorErrorNotifierPost = 0;
const mediatorErrorRingFull = -1;

const mediatorStateStopped = 1 << 0;
const mediatorStateIdle = 1 << 1;
const mediatorStateWaking = 1 << 2;

const mediatorDartCallback = 1 << 0;
const mediatorNativeCallback = 1 << 1;
const mediatorDartCall = 1 << 2;
const mediatorNativeCall = 1 << 3;

const ringSetupIopoll = 1 << 0;
const ringSetupSqpoll = 1 << 1;
const ringSetupSqAff = 1 << 2;
const ringSetupCqsize = 1 << 3;
const ringSetupClamp = 1 << 4;
const ringSetupAttachWq = 1 << 5;
const ringSetupRDisabled = 1 << 6;
const ringSetupSubmitAll = 1 << 7;
const ringSetupCoopTaskrun = 1 << 8;
const ringSetupTaskrunFlag = 1 << 9;
const ringSetupSqe128 = 1 << 10;
const ringSetupCqe32 = 1 << 11;
const ringSetupSingleIssuer = 1 << 12;
const ringSetupDeferTaskrun = 1 << 13;
