determineEndTime:{[tbl]
    mktEndTime:"n"$16:00;
    endTimes:select from tbl where (differ;expireTime) fby orderId;
    endTimes:update endTime:mktEndTime&mktEndTime^expireTime from endTimes;
    endTimes:select by orderId from endTimes;
    select orderId,endTime from endTimes
  };

/ Case 1:
/   1. Expire time is not specified
/   2. Expire time is never amended
tbl01:([] orderId:enlist 1;time:"n"$enlist 09:13; expireTime:enlist 0Nn);
exp01:([] orderId:enlist 1;endTime:"n"$enlist 16:00);
if[not exp01~determineEndTime[tbl01];'`"Case 1 failed"];

/ Case 2:
/   1. Expire time is set to a future time before market close
/   2. Expire time is never amended
tbl02:([] orderId:enlist 2;time:"n"$enlist 09:13; expireTime:enlist 15:45);
exp02:([] orderId:enlist 2;endTime:"n"$enlist 15:45);
if[not exp02~determineEndTime[tbl02];'`"Case 2 failed"];

/ Case 3:
/   1. Expire time is set to a future time after market close
/   2. Expire time is never amended
tbl03:([] orderId:enlist 3;time:"n"$enlist 09:13; expireTime:enlist 16:10);
exp03:([] orderId:enlist 3;endTime:"n"$enlist 16:00);
if[not exp03~determineEndTime[tbl03];'`"Case 3 failed"];

/ Case 4:
/   1. Expire time is not specified
/   2. Expire time is amended to a future time before market close
tbl04:([] orderId:4 4;time:"n"$09:13 14:30; expireTime:(0Nn;"n"$15:44));
exp04:([] orderId:enlist 4;endTime:"n"$enlist 15:44);
if[not exp04~determineEndTime[tbl04];'`"Case 4 failed"];

/ Case 5:
/   1. Expire time is not specified
/   2. Expire time is amended to a future time after market close
tbl05:([] orderId:5 5;time:"n"$09:13 14:30; expireTime:(0Nn;"n"$16:10));
exp05:([] orderId:enlist 5;endTime:"n"$enlist 16:00);
if[not exp05~determineEndTime[tbl05];'`"Case 5 failed"];

/ Case 6:
/   1. Expire time is set to a future time before market close
/   2. Expire time is amended to an earlier future time
tbl06:([] orderId:6 6;time:"n"$09:13 14:30; expireTime:"n"$15:45 15:30);
exp06:([] orderId:enlist 6;endTime:"n"$enlist 15:30);
if[not exp06~determineEndTime[tbl06];'`"Case 6 failed"];

/ Case 7:
/   1. Expire time is set to a future time before market close
/   2. Expire time is amended to a later future time before market close
tbl07:([] orderId:7 7;time:"n"$09:13 14:30; expireTime:"n"$15:45 15:55);
exp07:([] orderId:enlist 7;endTime:"n"$enlist 15:55);
if[not exp07~determineEndTime[tbl07];'`"Case 7 failed"];

/ Case 8:
/   1. Expire time is set to a future time before market close
/   2. Expire time is amended to a later future time after market close
tbl08:([] orderId:8 8;time:"n"$09:13 14:30; expireTime:"n"$15:45 16:55);
exp08:([] orderId:enlist 8;endTime:"n"$enlist 16:00);
if[not exp08~determineEndTime[tbl08];'`"Case 8 failed"];

/ Case 9:
/   1. Expire time is set to a future time after market close
/   2. Expire time is amended to an earlier future time before market close
tbl09:([] orderId:9 9;time:"n"$09:13 14:30; expireTime:"n"$16:45 15:55);
exp09:([] orderId:enlist 9;endTime:"n"$enlist 15:55);
if[not exp09~determineEndTime[tbl09];'`"Case 9 failed"];

/ Case 10:
/   1. Expire time is set to a future time after market close
/   2. Expire time is amended to a future time after market close
tbl10:([] orderId:10 10;time:"n"$09:13 14:30; expireTime:"n"$16:45 16:25);
exp10:([] orderId:enlist 10;endTime:"n"$enlist 16:00);
if[not exp10~determineEndTime[tbl10];'`"Case 10 failed"];

/ Case 11:
/   1. Expire time is set to a future time before market close
/   2. Expire time is removed
tbl11:([] orderId:11 11;time:"n"$09:13 14:30; expireTime:("n"$15:45;0Nn));
exp11:([] orderId:enlist 11;endTime:"n"$enlist 16:00);
if[not exp11~determineEndTime[tbl11];'`"Case 11 failed"];

/ Case 12:
/   1. Expire time is set to a future time after market close
/   2. Expire time is removed
tbl12:([] orderId:12 12;time:"n"$09:13 14:30; expireTime:("n"$16:45;0Nn));
exp12:([] orderId:enlist 12;endTime:"n"$enlist 16:00);
if[not exp12~determineEndTime[tbl12];'`"Case 12 failed"];

/ Run all test cases combined
nCases:12;
datatbls:raze value each `$"tbl",/: -2#'"0",'string 1+til nCases;
expected:raze value each `$"exp",/: -2#'"0",'string 1+til nCases;
if[not expected~determineEndTime[datatbls];'`"Unit tests for determineEndTime failed"];
