

## Lua / Love2d in vscode

- Koihik.vscode-lua-format
   - Uses LuaFormatter: https://github.com/Koihik/LuaFormatter 
- trixnz.vscode-lua
- pixelbyte-studios.pixelbyte-love2d

### settings.json
    "vscode-lua-format.configPath": "/Users/dcrosby/.luaformatter",
    "[lua]": {
        "editor.defaultFormatter": "Koihik.vscode-lua-format",
        "editor.formatOnSave": true,
    },
    "lua.targetVersion": "5.3"


### ~/.luaformatter
luaformatter Docs: https://github.com/Koihik/LuaFormatter/blob/master/docs/Style-Config.md

#### My personal ~/.luaformatter
use_tab: false
column_limit: 120
indent_width: 2
tab_width: 2
continuation_indent_width: 4
spaces_before_call: 1
keep_simple_control_block_one_line: false
keep_simple_function_one_line: false
align_args: true
break_after_functioncall_lp: false
break_before_functioncall_rp: false
align_parameter: true
chop_down_parameter: false
break_after_functiondef_lp: false
break_before_functiondef_rp: false
align_table_field: true
break_after_table_lb: true
break_before_table_rb: true
chop_down_table: true
chop_down_kv_table: true
table_sep: ","
extra_sep_at_table_end: true
break_after_operator: true
double_quote_to_single_quote: false
single_quote_to_double_quote: false


#### Defaults from github
column_limit: 80
indent_width: 4
use_tab: false
tab_width: 4
continuation_indent_width: 4
spaces_before_call: 1
keep_simple_control_block_one_line: true
keep_simple_function_one_line: true
align_args: true
break_after_functioncall_lp: false
break_before_functioncall_rp: false
align_parameter: true
chop_down_parameter: false
break_after_functiondef_lp: false
break_before_functiondef_rp: false
align_table_field: true
break_after_table_lb: true
break_before_table_rb: true
chop_down_table: false
chop_down_kv_table: true
table_sep: ","
extra_sep_at_table_end: false
break_after_operator: true
double_quote_to_single_quote: false
single_quote_to_double_quote: false

