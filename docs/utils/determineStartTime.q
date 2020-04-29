determineStartTime:{[tbl]
    mktOpenTime:"n"$09:30;
    startTimes:select from tbl where (differ;effectiveTime) fby orderId;
    startTimes:update startTime:mktOpenTime|time|mktOpenTime^effectiveTime from startTimes;
    startTimes:update ignore:(not null prev startTime)&time>prev startTime by orderId from startTimes;
    startTimes:select by orderId from startTimes where not ignore;
    select orderId,startTime from startTimes
  };

/ Case 1:
/   1. Order arrives before market open
/   2. Effective time is not specified
/   3. Effective time is never amended
tbl01:([] orderId:enlist 1;time:"n"$enlist 09:13; effectiveTime:enlist 0Nn);
exp01:([] orderId:enlist 1;startTime:"n"$enlist 09:30);
if[not exp01~determineStartTime[tbl01];'`"Case 1 failed"];

/ Case 2:
/   1. Order arrives before market open
/   2. Effective time is set to a time before market open
/   3. Effective time is never amended
tbl02:([] orderId:enlist 2;time:"n"$enlist 09:13; effectiveTime:"n"$enlist 09:25);
exp02:([] orderId:enlist 2;startTime:"n"$enlist 09:30);
if[not exp02~determineStartTime[tbl02];'`"Case 2 failed"];

/ Case 3:
/   1. Order arrives before market open
/   2. Effective time is set to a time after market open
/   3. Effective time is never amended
tbl03:([] orderId:enlist 3;time:"n"$enlist 09:13; effectiveTime:"n"$enlist 09:35);
exp03:([] orderId:enlist 3;startTime:"n"$enlist 09:35);
if[not exp03~determineStartTime[tbl03];'`"Case 3 failed"];

/ Case 4:
/   1. Order arrives after market open
/   2. Effective time is not specified
/   3. Effective time is never amended
tbl04:([] orderId:enlist 4;time:"n"$enlist 09:33; effectiveTime:0Nn);
exp04:([] orderId:enlist 4;startTime:"n"$enlist 09:33);
if[not exp04~determineStartTime[tbl04];'`"Case 4 failed"];

/ Case 5:
/   1. Order arrives after market open
/   2. Effective time is set to a time before market open
/   3. Effective time is never amended
tbl05:([] orderId:enlist 5;time:"n"$enlist 09:33; effectiveTime:"n"$enlist 09:25);
exp05:([] orderId:enlist 5;startTime:"n"$enlist 09:33);
if[not exp05~determineStartTime[tbl05];'`"Case 5 failed"];

/ Case 6:
/   1. Order arrives after market open
/   2. Effective time is set to a time after market open, but before arrival time
/   3. Effective time is never amended
tbl06:([] orderId:enlist 6;time:"n"$enlist 09:33; effectiveTime:"n"$enlist 09:32);
exp06:([] orderId:enlist 6;startTime:"n"$enlist 09:33);
if[not exp06~determineStartTime[tbl06];'`"Case 6 failed"];

/ Case 7:
/   1. Order arrives after market open
/   2. Effective time is set to a time after arrival time
/   3. Effective time is never amended
tbl07:([] orderId:enlist 7;time:"n"$enlist 09:33; effectiveTime:"n"$enlist 09:35);
exp07:([] orderId:enlist 7;startTime:"n"$enlist 09:35);
if[not exp07~determineStartTime[tbl07];'`"Case 7 failed"];

/ Case 8:
/   1. Order arrives before market open
/   2. Effective time is not specified initially
/   3. Effective time is amended before market open to a future time before market open
tbl08:([] orderId:8 8;time:"n"$09:13 09:25; effectiveTime:(0Nn;"n"$09:28));
exp08:([] orderId:enlist 8;startTime:"n"$enlist 09:30);
if[not exp08~determineStartTime[tbl08];'`"Case 8 failed"];

/ Case 9:
/   1. Order arrives before market open
/   2. Effective time is not specified initially
/   3. Effective time is amended before market open to a future time after market open
tbl09:([] orderId:9 9;time:"n"$09:13 09:25; effectiveTime:(0Nn;"n"$09:33));
exp09:([] orderId:enlist 9;startTime:"n"$enlist 09:33);
if[not exp09~determineStartTime[tbl09];'`"Case 9 failed"];

/ Case 10:
/   1. Order arrives before market open
/   2. Effective time is not specified initially
/   3. Effective time is amended after market open to a past time before market open
tbl10:([] orderId:10 10;time:"n"$09:13 09:33; effectiveTime:(0Nn;"n"$09:28));
exp10:([] orderId:enlist 10;startTime:"n"$enlist 09:30);
if[not exp10~determineStartTime[tbl10];'`"Case 10 failed"];

/ Case 11:
/   1. Order arrives before market open
/   2. Effective time is not specified initially
/   3. Effective time is amended after market open to a past time after market open
tbl11:([] orderId:11 11;time:"n"$09:13 09:33; effectiveTime:(0Nn;"n"$09:31));
exp11:([] orderId:enlist 11;startTime:"n"$enlist 09:30);
if[not exp11~determineStartTime[tbl11];'`"Case 11 failed"];

/ Case 12:
/   1. Order arrives before market open
/   2. Effective time is not specified initially
/   3. Effective time is amended after market open to a future time
tbl12:([] orderId:12 12;time:"n"$09:13 09:33; effectiveTime:(0Nn;"n"$09:35));
exp12:([] orderId:enlist 12;startTime:"n"$enlist 09:30);
if[not exp12~determineStartTime[tbl12];'`"Case 12 failed"];

/ Case 13:
/   1. Order arrives after market open
/   2. Effective time is not specified initially
/   3. Effective time is amended to a past time
tbl13:([] orderId:13 13;time:"n"$09:33 09:40; effectiveTime:(0Nn;"n"$09:35));
exp13:([] orderId:enlist 13;startTime:"n"$enlist 09:33);
if[not exp13~determineStartTime[tbl13];'`"Case 13 failed"];

/ Case 14:
/   1. Order arrives after market open
/   2. Effective time is not specified initially
/   3. Effective time is amended to a future time
tbl14:([] orderId:14 14;time:"n"$09:33 09:40; effectiveTime:(0Nn;"n"$09:45));
exp14:([] orderId:enlist 14;startTime:"n"$enlist 09:33);
if[not exp14~determineStartTime[tbl14];'`"Case 14 failed"];

/ Case 15:
/   1. Order arrives after market open
/   2. Effective time is set to a past time
/   3. Effective time is amended to a past time
tbl15:([] orderId:15 15;time:"n"$09:33 09:40; effectiveTime:"n"$(09:28;09:31));
exp15:([] orderId:enlist 15;startTime:"n"$enlist 09:33);
if[not exp15~determineStartTime[tbl15];'`"Case 15 failed"];

/ Case 16:
/   1. Order arrives after market open
/   2. Effective time is set to a past time
/   3. Effective time is amended to a future time
tbl16:([] orderId:16 16;time:"n"$09:33 09:40; effectiveTime:"n"$(09:28;09:45));
exp16:([] orderId:enlist 16;startTime:"n"$enlist 09:33);
if[not exp16~determineStartTime[tbl16];'`"Case 16 failed"];

/ Case 17:
/   1. Order arrives after market open
/   2. Effective time is set to a future time
/   3. Effective time is amended to a past time
tbl17:([] orderId:17 17;time:"n"$09:33 09:40; effectiveTime:"n"$(09:45;09:38));
exp17:([] orderId:enlist 17;startTime:"n"$enlist 09:40);
if[not exp17~determineStartTime[tbl17];'`"Case 17 failed"];

/ Case 18:
/   1. Order arrives after market open
/   2. Effective time is set to a future time
/   3. Effective time is amended to an earlier future time
tbl18:([] orderId:18 18;time:"n"$09:33 09:40; effectiveTime:"n"$(09:45;09:43));
exp18:([] orderId:enlist 18;startTime:"n"$enlist 09:43);
if[not exp18~determineStartTime[tbl18];'`"Case 18 failed"];

/ Case 19:
/   1. Order arrives after market open
/   2. Effective time is set to a future time
/   3. Effective time is removed
tbl19:([] orderId:19 19;time:"n"$09:33 09:40; effectiveTime:("n"$09:45;0Nn));
exp19:([] orderId:enlist 19;startTime:"n"$enlist 09:40);
if[not exp19~determineStartTime[tbl19];'`"Case 19 failed"];

/ Case 20:
/   1. Order arrives after market open
/   2. Effective time is set to a future time
/   3. Effective time is amend to a further future time
tbl20:([] orderId:20 20;time:"n"$09:33 09:40; effectiveTime:"n"$(09:45;09:50));
exp20:([] orderId:enlist 20;startTime:"n"$enlist 09:50);
if[not exp20~determineStartTime[tbl20];'`"Case 20 failed"];

/ Run all test cases combined
nCases:20;
datatbls:raze value each `$"tbl",/: -2#'"0",'string 1+til nCases;
expected:raze value each `$"exp",/: -2#'"0",'string 1+til nCases;
if[not expected~determineStartTime[datatbls];'`"Unit tests for determineStartTime failed"];
