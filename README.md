# Multisensory SISL!

## Websites
### mTurk User Site 
http://cortical.csl.sri.com/experiments/sisl/sisl.html

### App Repo
https://github.com/Braincrypto/SISL-CLJS

Lots of important settings info is here:
https://github.com/Braincrypto/SISL-CLJS/blob/master/src/sisl_cljs/settings.cljs



## Input Info
- The input files (scenarios and trial lists) were generated by a script from Aled.
- All the input files are in the PPTFile directory

### Server Info
Input files exist here: /var/www/experiments/sisl

The PHP files that exist here are useful for archeological purposes!

## Data

- Note: We did not pull category (sequence v. noise v. practice) or the experimental condition (sound-mode changes) into the data structures, so we need to grab that from the inputs.
- Data are stored in mysql on the server (cortical.csl.sri.com).
- Make sure the directory /var/lib/mysql-files/webdasher/ is empty.
- Log into mysql 
- Run the following queries:

```
(select 'session_id', 'participant_id', 'date_time', 'time_stamp_ms', 'trial_row_id', 'event_type', 'event_value', 'cue_pos_x', 'cue_pos_y', 'cue_vy', 'cue_target_offset') UNION (select session_id, participant_id, date_time, time_stamp_ms, trial_row_id, event_type, event_value, cue_pos_x, cue_pos_y, cue_vy, cue_target_offset into outfile '/var/lib/mysql-files/webdasher/event_log.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM event_log);

(select 'session_id', 'participant_id', 'date_time', 'time_stamp_ms', 'event_type', 'event_value') UNION (select session_id, participant_id, date_time, time_stamp_ms, event_type, event_value into outfile '/var/lib/mysql-files/webdasher/input_log.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM input_log);

(select 'session_id', 'scenario_name', 'participant_id', 'start_time', 'finish_time', 'browser_info', 'machine_info', 'finish_tag') UNION (select id, scenario_name, participant_id, start_time, ifnull(finish_time, ''), browser_info, machine_info, ifnull(finish_tag, '') into outfile '/var/lib/mysql-files/webdasher/sessions.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM sessions);
```

This will produce CSV files in /var/lib/mysql-files/webdasher/ for each table.

Move the files to your user home directory, tar them up (preferably in a directory or their own), and then get the files onto Github.



