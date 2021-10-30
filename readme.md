# Brainvr strelnice

Package to load, process and analyze data from vrecity shooting range task.

Current version only loads and processes the results log and does no extra processing.

## Output description

### Results log
The output has two parts, `stats` and `params`. Params contain a data.frame with all trial settings. Stats then report statistics for those trials.

#### Stats
Stats have fairly fell described columns, but new clarifications are needed.

Columns with `_avg` suffix are calculated form the trial data and not taken as reported by the software. E.g. averageEnemyReactionTime is Unity reported value which is generally a string with "s" suffix, whereas enemyReactionTimes_avg is a number calculated from the raw reported data.
