%%% @private
%%% @author     Max Lapshin <max@maxidoors.ru> [http://erlyvideo.org]
%%% @author     All those guys, that have found how to sign handshake from red5:
%%% @author Jacinto Shy II (jacinto.m.shy@ieee.org)
%%% @author Steven Zimmer (stevenlzimmer@gmail.com)
%%% @author Gavriloaie Eugen-Andrei <crtmpserver@gmail.com>
%%% @author Ari-Pekka Viitanen
%%% @author Paul Gregoire
%%% @author Tiago Jacobs 
%%% @copyright  2009 Max Lapshin
%%% @doc        RTMP handshake module
%%% @reference  See <a href="http://erlyvideo.org/rtmp" target="_top">http://erlyvideo.org/rtmp</a> for more information
%%% also good reference is http://red5.googlecode.com/svn/java/server/trunk/src/org/red5/server/net/rtmp/RTMPHandshake.java
%%% @end
%%%
%%%
%%% The MIT License
%%%
%%% Copyright (c) 2009 Max Lapshin
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in
%%% all copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%%% THE SOFTWARE.
%%%
%%%---------------------------------------------------------------------------------------
-module(rtmp_handshake).
-version(1.0).

-export([s1/0, s2/1, c1/0, c2/1]).

-define(HANDSHAKE, <<
16#01,16#86,16#4f,16#7f,16#00,16#00,16#00,16#00,16#6b,16#04,16#67,16#52,16#a2,16#70,16#5b,16#51,
16#a2,16#89,16#ca,16#cc,16#8e,16#70,16#f0,16#06,16#70,16#0e,16#d7,16#b3,16#73,16#7f,16#07,16#c1,
16#72,16#d6,16#cb,16#4c,16#c0,16#45,16#0f,16#f5,16#4f,16#ec,16#d0,16#2f,16#46,16#2b,16#76,16#10,
16#92,16#1b,16#0e,16#b6,16#ed,16#71,16#73,16#45,16#c1,16#c6,16#26,16#0c,16#69,16#59,16#7b,16#bb,
16#53,16#b9,16#10,16#4d,16#ea,16#c1,16#e7,16#7b,16#70,16#de,16#dc,16#f8,16#84,16#90,16#bf,16#80,
16#e8,16#85,16#b2,16#46,16#2c,16#78,16#a1,16#85,16#01,16#8f,16#8b,16#05,16#3f,16#a1,16#0c,16#1a,
16#78,16#70,16#8c,16#8e,16#77,16#67,16#bc,16#19,16#2f,16#ab,16#26,16#a1,16#7e,16#88,16#d8,16#ce,
16#24,16#63,16#21,16#75,16#3a,16#5a,16#6f,16#c2,16#a1,16#2d,16#4f,16#64,16#b7,16#7b,16#f7,16#ef,
16#da,16#45,16#b2,16#51,16#fd,16#cb,16#74,16#49,16#fd,16#63,16#8b,16#88,16#fb,16#de,16#5a,16#3b,
16#ab,16#7f,16#75,16#25,16#bb,16#35,16#51,16#03,16#81,16#12,16#ff,16#66,16#02,16#3d,16#88,16#dc,
16#66,16#a2,16#fb,16#09,16#24,16#9d,16#86,16#fd,16#c4,16#00,16#c2,16#8b,16#6f,16#b7,16#b2,16#15,
16#10,16#c0,16#1b,16#71,16#a8,16#3e,16#88,16#eb,16#7e,16#f3,16#b2,16#e3,16#e8,16#3c,16#00,16#9b,
16#26,16#ba,16#b4,16#5f,16#2c,16#36,16#f3,16#4a,16#59,16#09,16#1b,16#e5,16#00,16#9d,16#e4,16#66,
16#4d,16#05,16#66,16#d0,16#d1,16#d6,16#94,16#4f,16#64,16#a1,16#2e,16#8d,16#2f,16#b0,16#06,16#01,
16#b3,16#00,16#3d,16#77,16#cd,16#1b,16#dd,16#cc,16#bf,16#e9,16#cd,16#1a,16#6b,16#68,16#dd,16#1c,
16#7b,16#fd,16#2e,16#b1,16#8b,16#45,16#fd,16#5b,16#48,16#52,16#03,16#01,16#e8,16#f1,16#0f,16#e7,
16#27,16#fc,16#2a,16#52,16#7c,16#14,16#22,16#8b,16#74,16#bd,16#d9,16#97,16#63,16#ef,16#fa,16#a3,
16#d9,16#21,16#12,16#0b,16#04,16#62,16#02,16#98,16#41,16#f2,16#b4,16#c3,16#e3,16#e2,16#2b,16#2a,
16#ff,16#ca,16#b4,16#48,16#1e,16#82,16#50,16#90,16#94,16#37,16#24,16#7e,16#a1,16#03,16#1a,16#f0,
16#9f,16#2b,16#be,16#64,16#e5,16#53,16#b9,16#b6,16#43,16#8e,16#26,16#6c,16#63,16#72,16#8d,16#b7,
16#7c,16#b8,16#21,16#8f,16#bb,16#1c,16#2a,16#4e,16#c7,16#ec,16#a7,16#a9,16#bc,16#15,16#10,16#e9,
16#4c,16#46,16#a5,16#60,16#a9,16#71,16#41,16#dd,16#25,16#f5,16#c1,16#f6,16#bd,16#75,16#1f,16#b0,
16#15,16#e0,16#ed,16#c2,16#4b,16#ac,16#f1,16#c8,16#ef,16#a3,16#44,16#be,16#90,16#ab,16#77,16#28,
16#bf,16#c0,16#e0,16#63,16#af,16#d9,16#07,16#9d,16#93,16#16,16#90,16#7a,16#e2,16#b4,16#e8,16#e2,
16#3e,16#4b,16#18,16#5f,16#3e,16#87,16#09,16#be,16#36,16#d0,16#8f,16#7c,16#22,16#13,16#9f,16#c5,
16#78,16#e0,16#54,16#4c,16#a7,16#77,16#3f,16#df,16#87,16#4a,16#28,16#7b,16#47,16#80,16#6a,16#f0,
16#50,16#cc,16#de,16#4c,16#44,16#41,16#74,16#3d,16#03,16#37,16#8b,16#bf,16#79,16#5b,16#8c,16#b0,
16#2f,16#6e,16#9c,16#98,16#29,16#22,16#49,16#2f,16#c9,16#6d,16#f1,16#08,16#c4,16#4f,16#b1,16#91,
16#b3,16#ee,16#57,16#c1,16#17,16#5d,16#d0,16#e8,16#19,16#fb,16#9b,16#d6,16#a8,16#56,16#92,16#04,
16#4c,16#0e,16#e0,16#52,16#93,16#9a,16#ec,16#ed,16#f3,16#f7,16#ef,16#d7,16#33,16#e3,16#cd,16#c7,
16#4b,16#ac,16#b7,16#a9,16#a5,16#13,16#09,16#6c,16#94,16#49,16#72,16#03,16#f3,16#cf,16#15,16#31,
16#bc,16#b5,16#68,16#c2,16#49,16#e1,16#6e,16#7d,16#cb,16#4e,16#ec,16#fc,16#a7,16#b7,16#ed,16#1c,
16#02,16#49,16#0e,16#7f,16#25,16#eb,16#d1,16#81,16#81,16#c0,16#a7,16#49,16#32,16#16,16#11,16#31,
16#59,16#12,16#43,16#d3,16#a6,16#95,16#4a,16#c5,16#fe,16#df,16#14,16#da,16#a6,16#5a,16#c0,16#d5,
16#6a,16#af,16#b3,16#de,16#32,16#2a,16#13,16#03,16#d3,16#10,16#71,16#0b,16#c0,16#1e,16#cf,16#db,
16#aa,16#cc,16#a6,16#b5,16#65,16#2e,16#c4,16#0b,16#5c,16#a7,16#1c,16#8b,16#2d,16#7f,16#c0,16#4c,
16#4a,16#a4,16#0b,16#a0,16#60,16#c4,16#cf,16#b1,16#be,16#e4,16#e4,16#50,16#c9,16#cc,16#a0,16#e8,
16#79,16#12,16#c4,16#b4,16#70,16#f5,16#84,16#98,16#83,16#e2,16#a9,16#8f,16#ba,16#ff,16#88,16#a2,
16#21,16#ba,16#00,16#3d,16#c4,16#57,16#e6,16#6a,16#f4,16#dc,16#01,16#1e,16#ac,16#0a,16#cc,16#49,
16#af,16#9c,16#c7,16#cd,16#c1,16#14,16#6e,16#12,16#87,16#f8,16#22,16#eb,16#df,16#48,16#da,16#9f,
16#f2,16#8b,16#c1,16#d2,16#44,16#94,16#e4,16#3e,16#d0,16#85,16#56,16#e4,16#9a,16#fd,16#b9,16#b3,
16#35,16#38,16#1d,16#15,16#4d,16#28,16#ab,16#b0,16#17,16#c0,16#5b,16#09,16#86,16#07,16#fa,16#69,
16#da,16#65,16#b8,16#d9,16#8f,16#e6,16#a1,16#83,16#ab,16#07,16#98,16#3c,16#79,16#f4,16#59,16#08,
16#8f,16#83,16#77,16#bd,16#a1,16#a1,16#76,16#28,16#9c,16#0f,16#cc,16#dc,16#ce,16#1f,16#16,16#02,
16#47,16#98,16#37,16#96,16#87,16#b1,16#70,16#3a,16#ea,16#a4,16#65,16#77,16#98,16#12,16#27,16#23,
16#47,16#a8,16#1b,16#79,16#c0,16#ec,16#53,16#32,16#e6,16#c1,16#61,16#7b,16#a0,16#98,16#9f,16#fc,
16#8d,16#e8,16#5c,16#af,16#c6,16#bf,16#1f,16#d1,16#40,16#dc,16#28,16#81,16#34,16#68,16#b7,16#da,
16#10,16#f2,16#63,16#52,16#cb,16#e7,16#18,16#85,16#d5,16#99,16#33,16#ee,16#9a,16#28,16#fa,16#df,
16#6d,16#cb,16#c2,16#ce,16#9d,16#ed,16#9d,16#bd,16#fd,16#d7,16#0a,16#e4,16#89,16#d3,16#10,16#9b,
16#db,16#6f,16#d9,16#37,16#8b,16#79,16#9c,16#94,16#c2,16#44,16#31,16#9f,16#24,16#ef,16#21,16#1d,
16#5f,16#d6,16#f9,16#99,16#7b,16#ef,16#59,16#e6,16#d6,16#dd,16#6a,16#74,16#82,16#b8,16#c5,16#fb,
16#1d,16#e8,16#fc,16#67,16#4f,16#4d,16#b5,16#cf,16#a9,16#52,16#94,16#c5,16#b7,16#32,16#a0,16#45,
16#0a,16#35,16#44,16#59,16#1e,16#1c,16#64,16#89,16#51,16#80,16#7b,16#1f,16#02,16#77,16#81,16#fa,
16#e9,16#26,16#4c,16#5f,16#e2,16#0d,16#05,16#55,16#ee,16#71,16#71,16#fc,16#35,16#33,16#22,16#63,
16#f5,16#36,16#45,16#f6,16#2f,16#d0,16#13,16#b7,16#58,16#4f,16#35,16#19,16#59,16#0a,16#e5,16#f8,
16#8a,16#4c,16#59,16#32,16#bf,16#ca,16#b0,16#06,16#c2,16#6c,16#a9,16#48,16#5b,16#4c,16#76,16#24,
16#ae,16#9d,16#5b,16#7b,16#79,16#38,16#4e,16#9e,16#47,16#12,16#8a,16#c6,16#e0,16#04,16#37,16#72,
16#dd,16#af,16#3d,16#0d,16#68,16#7e,16#d8,16#80,16#7b,16#07,16#23,16#ce,16#40,16#4a,16#ed,16#83,
16#55,16#56,16#fd,16#db,16#95,16#b3,16#1c,16#33,16#f1,16#43,16#a8,16#0e,16#5e,16#67,16#d6,16#3a,
16#d0,16#89,16#5e,16#72,16#77,16#7f,16#10,16#3c,16#c4,16#7c,16#9a,16#a3,16#55,16#c5,16#d3,16#5b,
16#3a,16#ae,16#12,16#0c,16#71,16#73,16#a0,16#58,16#90,16#54,16#a8,16#1c,16#31,16#20,16#db,16#de,
16#dd,16#35,16#b1,16#09,16#a2,16#d0,16#6e,16#39,16#39,16#a5,16#0a,16#3d,16#8a,16#00,16#4b,16#95,
16#6f,16#8c,16#12,16#41,16#c6,16#46,16#10,16#5e,16#9d,16#50,16#85,16#0e,16#6b,16#81,16#a7,16#3b,
16#35,16#a6,16#38,16#f5,16#c2,16#ba,16#6c,16#02,16#da,16#27,16#29,16#6e,16#e9,16#54,16#41,16#a4,
16#94,16#75,16#e8,16#55,16#c0,16#e3,16#c2,16#91,16#8a,16#1d,16#fb,16#2b,16#ba,16#43,16#e7,16#45,
16#85,16#e8,16#13,16#07,16#1d,16#9c,16#37,16#a8,16#f3,16#ca,16#f4,16#19,16#77,16#c4,16#65,16#d6,
16#18,16#3e,16#60,16#08,16#74,16#49,16#ba,16#c8,16#86,16#37,16#8a,16#0f,16#79,16#91,16#53,16#20,
16#23,16#00,16#b9,16#c5,16#1b,16#01,16#dd,16#10,16#34,16#05,16#42,16#a0,16#64,16#ab,16#4d,16#51,
16#f4,16#53,16#35,16#18,16#de,16#20,16#1f,16#aa,16#e2,16#40,16#0d,16#6d,16#77,16#36,16#1f,16#ee,
16#3a,16#93,16#db,16#1d,16#d6,16#a0,16#23,16#cc,16#e6,16#a8,16#44,16#8e,16#ae,16#9c,16#d7,16#97,
16#6a,16#99,16#ee,16#40,16#15,16#d5,16#5a,16#6d,16#f6,16#9c,16#2c,16#52,16#cd,16#fa,16#f4,16#c8,
16#02,16#ee,16#f2,16#76,16#8b,16#49,16#6d,16#66,16#83,16#5f,16#be,16#05,16#8e,16#f2,16#27,16#73,
16#db,16#00,16#eb,16#9a,16#b4,16#bf,16#47,16#9a,16#bd,16#f1,16#4f,16#70,16#ed,16#33,16#ce,16#31,
16#9d,16#9f,16#95,16#80,16#9e,16#73,16#11,16#6c,16#03,16#7b,16#6e,16#62,16#9c,16#d0,16#aa,16#f6,
16#5d,16#e0,16#d8,16#96,16#94,16#46,16#d1,16#10,16#3c,16#1b,16#9d,16#40,16#dd,16#ab,16#ec,16#8a,
16#5b,16#1a,16#b6,16#19,16#57,16#99,16#09,16#e8,16#ec,16#82,16#dc,16#06,16#39,16#86,16#25,16#3b,
16#67,16#b5,16#17,16#c5,16#6e,16#6e,16#1c,16#6c,16#ea,16#be,16#b8,16#dd,16#68,16#f8,16#f3,16#18,
16#f2,16#3c,16#99,16#dc,16#a9,16#d3,16#b2,16#7a,16#40,16#70,16#4b,16#c2,16#d2,16#a7,16#b3,16#42,
16#19,16#ff,16#0b,16#df,16#07,16#0e,16#6b,16#8e,16#ef,16#63,16#92,16#d6,16#15,16#57,16#62,16#12,
16#99,16#96,16#96,16#a5,16#34,16#5a,16#2c,16#7c,16#f6,16#bc,16#16,16#b2,16#90,16#c3,16#11,16#5e,
16#ba,16#0e,16#e4,16#22,16#84,16#32,16#50,16#da,16#1e,16#37,16#06,16#5b,16#ef,16#69,16#b7,16#6f,
16#10,16#cb,16#dc,16#4d,16#fd,16#db,16#a3,16#ef,16#54,16#ea,16#da,16#55,16#ba,16#32,16#f4,16#86,
16#6b,16#b1,16#c8,16#fc,16#12,16#9a,16#fc,16#da,16#fd,16#2a,16#c2,16#7f,16#70,16#ce,16#34,16#38,
16#e6,16#6a,16#7d,16#33,16#a0,16#16,16#fb,16#fd,16#a7,16#df,16#2e,16#e3,16#5f,16#93,16#39,16#aa,
16#00,16#c7,16#38,16#2e,16#9c,16#f3,16#c4,16#12,16#46,16#cf,16#06,16#fe,16#0f,16#82,16#82,16#74,
16#00,16#71,16#f8,16#28,16#2f,16#9b,16#3f,16#9a,16#42,16#1b,16#3e,16#a6,16#0e,16#90,16#a7,16#45,
16#a6,16#cd,16#6e,16#88,16#94,16#08,16#3a,16#e5,16#56,16#36,16#77,16#68,16#2e,16#39,16#d3,16#45,
16#ee,16#89,16#f0,16#71,16#42,16#2d,16#e2,16#1b,16#f5,16#11,16#f0,16#ff,16#05,16#0c,16#78,16#a1,
16#65,16#cf,16#3c,16#9e,16#e3,16#37,16#72,16#3a,16#32,16#cb,16#1f,16#fd,16#9d,16#4a,16#0e,16#f7,
16#0b,16#2b,16#aa,16#57,16#2c,16#27,16#b3,16#a0,16#2a,16#0f,16#85,16#16,16#6c,16#e2,16#e0,16#a1,
16#48,16#8e,16#00,16#8d,16#6d,16#c8,16#10,16#fd,16#43,16#96,16#50,16#07,16#07,16#9a,16#bf,16#50,
16#62,16#76,16#3e,16#e1,16#f7,16#70,16#c1,16#b0,16#79,16#8e,16#61,16#e3,16#fb,16#05,16#5f,16#bb,
16#2d,16#76,16#69,16#89,16#f3,16#1e,16#62,16#f6,16#27,16#3d,16#3e,16#41,16#0f,16#f5,16#0f,16#c7,
16#f3,16#0e,16#3b,16#d5,16#ed,16#cf,16#ef,16#58,16#fa,16#39,16#df,16#75,16#85,16#2b,16#8b,16#aa,
16#08,16#72,16#52,16#a7,16#98,16#42,16#95,16#7b,16#b7,16#e7,16#10,16#fe,16#db,16#54,16#34,16#fb,
16#91,16#24,16#1c,16#07,16#fb,16#9c,16#ce,16#d0,16#46,16#cf,16#c4,16#9d,16#09,16#49,16#24,16#ec>>).

-define(GENUINE_FMS_KEY, <<"Genuine Adobe Flash Media Server 001",
                        16#f0,16#ee,16#c2,16#4a,16#80,16#68,16#be,16#e8,16#2e,16#00,16#d0,16#d1,
16#02,16#9e,16#7e,16#57,16#6e,16#ec,16#5d,16#2d,16#29,16#80,16#6f,16#ab,16#93,16#b8,16#e6,16#36,
16#cf,16#eb,16#31,16#ae>>).

-define(GENUINE_FP_KEY, <<"Genuine Adobe Flash Player 001",
          16#F0, 16#EE, 16#C2, 16#4A, 16#80, 16#68, 16#BE, 16#E8,
          16#2E, 16#00, 16#D0, 16#D1, 16#02, 16#9E, 16#7E, 16#57,
          16#6E, 16#EC, 16#5D, 16#2D, 16#29, 16#80, 16#6F, 16#AB,
          16#93, 16#B8, 16#E6, 16#36, 16#CF, 16#EB, 16#31, 16#AE>>).


-define(DH_MODULUS_BYTES, <<16#ff, 16#ff, 16#ff, 16#ff, 16#ff,
          		16#ff, 16#ff, 16#ff, 16#c9, 16#0f, 16#da, 16#a2, 16#21,
          		16#68, 16#c2, 16#34, 16#c4, 16#c6, 16#62, 16#8b, 16#80,
          		16#dc, 16#1c, 16#d1, 16#29, 16#02, 16#4e, 16#08, 16#8a,
          		16#67, 16#cc, 16#74, 16#02, 16#0b, 16#be, 16#a6, 16#3b,
          		16#13, 16#9b, 16#22, 16#51, 16#4a, 16#08, 16#79, 16#8e,
          		16#34, 16#04, 16#dd, 16#ef, 16#95, 16#19, 16#b3, 16#cd,
          		16#3a, 16#43, 16#1b, 16#30, 16#2b, 16#0a, 16#6d, 16#f2,
          		16#5f, 16#14, 16#37, 16#4f, 16#e1, 16#35, 16#6d, 16#6d,
          		16#51, 16#c2, 16#45, 16#e4, 16#85, 16#b5, 16#76, 16#62,
          		16#5e, 16#7e, 16#c6, 16#f4, 16#4c, 16#42, 16#e9, 16#a6,
          		16#37, 16#ed, 16#6b, 16#0b, 16#ff, 16#5c, 16#b6, 16#f4,
          		16#06, 16#b7, 16#ed, 16#ee, 16#38, 16#6b, 16#fb, 16#5a,
          		16#89, 16#9f, 16#a5, 16#ae, 16#9f, 16#24, 16#11, 16#7c,
          		16#4b, 16#1f, 16#e6, 16#49, 16#28, 16#66, 16#51, 16#ec,
          		16#e6, 16#53, 16#81, 16#ff, 16#ff, 16#ff, 16#ff, 16#ff,
          		16#ff, 16#ff, 16#ff>>).

s1() ->
	?HANDSHAKE.

c1() ->
  lists:duplicate(size(?HANDSHAKE), 0).

c2(_S2) ->
  c1().


flash_version(<<T:32, V1, V2, V3, V4, _/binary>>) ->
  {T, V1, V2, V3, V4}.

-type handshake_version() ::version1|version2.
-spec clientDigest(Handshake::binary(), handshake_version()) -> {First::binary(), Seed::binary(), Last::binary()}.
% Flash from 10.0.32.18
clientDigest(<<_:772/binary, P1, P2, P3, P4, _/binary>> = C1, version2) ->
	Offset = (P1+P2+P3+P4) rem 728 + 776,
	<<First:Offset/binary, Seed:32/binary, Last/binary>> = C1,
  {First, Seed, Last};


% Flash before 10.0.32.18
clientDigest(<<_:8/binary, P1, P2, P3, P4, _/binary>> = C1, version1) ->
	Offset = (P1+P2+P3+P4) rem 728 + 12,
	<<First:Offset/binary, Seed:32/binary, Last/binary>> = C1,
  {First, Seed, Last}.

-spec dhKey(Handshake::binary(), handshake_version()) -> {First::binary(), Seed::binary(), Last::binary()}.
dhKey(<<_:1532/binary, P1, P2, P3, P4, _/binary>> = C1, version1) ->
	Offset = (P1+P2+P3+P4) rem 632 + 772,
	<<First:Offset/binary, Seed:32/binary, Last/binary>> = C1,
  {First, Seed, Last};

dhKey(<<_:768/binary, P1, P2, P3, P4, _/binary>> = C1, version1) ->
	Offset = (P1+P2+P3+P4) rem 632 + 8,
	<<First:Offset/binary, Seed:32/binary, Last/binary>> = C1,
  {First, Seed, Last}.

-spec validateClientScheme(C1::binary()) -> handshake_version().
validateClientScheme(C1) ->
  case validateClientScheme(C1, version1) of
    true -> version1;
    false -> case validateClientScheme(C1, version2) of
      true -> version2
    end
  end.


-spec validateClientScheme(C1::binary(), Version::handshake_version()) -> boolean().
validateClientScheme(C1, Version) ->
  {First, ClientDigestBin, Last} = clientDigest(C1, Version),
  ClientDigest = binary_to_list(ClientDigestBin),
  <<Key:30/binary, _/binary>> = ?GENUINE_FP_KEY,
  GuessDigest = hmac256:digest(Key, <<First/binary, Last/binary>>),
  ClientDigest == GuessDigest.

% Special case for VLC
s2(<<_:32, 0:32, _:1528/binary>> = C1) ->
  C1;

s2(C1) ->
  Version = validateClientScheme(C1),
  io:format("Handshake version: ~p, ~p~n", [flash_version(C1), Version]),
  {_, ClientDigest, _} = clientDigest(C1, Version),
  ServerDigest = hmac256:digest(?GENUINE_FMS_KEY, ClientDigest),
  <<S2:1504/binary, _/binary>> = s1(),
  % S2 = <<0:32, 1,2,3,4>>,
  ServerSign = hmac256:digest(ServerDigest, S2),
  [S2, ServerSign].
