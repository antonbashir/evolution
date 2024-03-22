import 'dart:ffi';

import 'package:core/core.dart';

final executorLibraryName = SystemEnvironment.debug ? "libexecutor_debug_${Abi.current()}.so" : "libexecutor_release_${Abi.current()}.so";
const executorModuleName = "executor";

const maximumExecutors = 1 << 16;

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

const ringIosqeFixedFile = 1 << 0;
const ringIosqeIoDrain = 1 << 1;
const ringIosqeIoLink = 1 << 2;
const ringIosqeIoHardlink = 1 << 3;
const ringIosqeAsync = 1 << 4;
const ringIosqeBufferSelect = 1 << 5;
const ringIosqeCqeSkipSuccess = 1 << 6;
