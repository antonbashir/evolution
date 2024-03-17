import 'dart:ffi';

import 'package:core/core.dart';

final executorLibraryName = SystemEnvironment.debug ? "libexecutor_debug_${Abi.current()}.so" : "libexecutor_release_${Abi.current()}.so";
const executorModuleName = "executor";
const executorPackageName = "executor";

class ExecutorErrors {
  ExecutorErrors._();

  static const executorRingFullError = "[executor] ring is full";
  static executorError(int result) => SystemErrors.of(-result);
}

const maximumExecutors = 1 << 16;

const executorErrorNotifierPost = 0;
const executorErrorRingFull = -1;

const executorStatePaused = 1 << 0;
const executorStateIdle = 1 << 1;
const executorStateWaking = 1 << 2;
const executorStateStopping = 1 << 3;
const executorStateStopped = 1 << 4;

const executorCall = 1 << 0;
const executorCallback = 1 << 1;

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
