import 'dart:ffi';

import 'package:core/core.dart';

final executorLibraryName = bool.fromEnvironment("DEBUG") ? "libexecutor_debug_${Abi.current()}.so" : "libexecutor_release_${Abi.current()}.so";
const executorModuleId = 2;
const executorModuleName = "executor";
const executorPackageName = "executor";

class ExecutorErrors {
  ExecutorErrors._();

  static const executorMemoryError = "[executor] out of memory";
  static const executorRingFullError = "[executor] ring is full";
  static executorError(int result) => SystemErrors.of(-result);
}

const executorErrorNotifierPost = 0;
const executorErrorRingFull = -1;

const executorStateStopped = 1 << 0;
const executorStateIdle = 1 << 1;
const executorStateWaking = 1 << 2;

const executorDartCallback = 1 << 0;
const executorNativeCallback = 1 << 1;
const executorDartCall = 1 << 2;
const executorNativeCall = 1 << 3;

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
