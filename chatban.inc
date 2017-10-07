#if defined _chatban_included
  #endinput
#endif
#define _chatban_included

#pragma reqlib "chatban_v22"

native chatban_isbanned(id);

native chatban_getban_time_seconds(id);

native chatban_getban_time_minutes(id);

native chatban_getban_time_remain(id);
