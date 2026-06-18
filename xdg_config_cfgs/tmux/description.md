# tmux 配置与命令说明

## 1. tmux 配置文件是什么

`~/.tmux.conf` 本质上是一组 tmux 命令。

同一条命令可以通过几种方式执行：

| 执行方式 | 示例 | 用途 |
|---|---|---|
| 写进配置文件 | `set -g mouse on` | 长期生效 |
| shell 中执行 | `tmux set -g mouse on` | 临时修改当前 tmux server |
| tmux 命令行执行 | `prefix + :` 后输入 `set -g mouse on` | 临时交互修改 |
| 绑定快捷键 | `bind-key R source-file ~/.tmux.conf` | 做成快捷操作 |

例如：

    bind-key R source-file ~/.tmux.conf \; display-message "tmux.conf reloaded"

含义：

按 `prefix + R` 重新加载 `~/.tmux.conf`，并显示提示消息。

---

## 2. `set` / `set-option`

`set` 是 `set-option` 的别名。

常见写法：

    set -g mouse on

等价于：

    set-option -g mouse on

作用是设置 tmux option。

默认不带 `-s` / `-w` / `-p` 时，通常设置的是 session option。

---

## 3. `setw` / `set-window-option`

`setw` 是 `set-window-option` 的别名。

老写法：

    setw -g mode-keys vi

等价于：

    set-window-option -g mode-keys vi

现代更统一的写法：

    set -w -g mode-keys vi

也就是：

| 写法 | 含义 |
|---|---|
| `setw -g mode-keys vi` | 设置全局 window option |
| `set-window-option -g mode-keys vi` | 同上 |
| `set -w -g mode-keys vi` | 同上，现代统一风格 |

---

## 4. `set-option` 参数说明

形式：

    set-option [-aFgopqsuUw] [-t target-pane] option [value]

短写：

    set [-aFgopqsuUw] [-t target-pane] option [value]

| 参数 | 含义 |
|---|---|
| `-a` | append，追加到已有值后面 |
| `-F` | 对 value 做 tmux format 展开 |
| `-g` | global，设置全局 option |
| `-o` | only if unset，仅当 option 未设置时才设置 |
| `-p` | 设置 pane option |
| `-q` | quiet，静默模式，忽略部分错误 |
| `-s` | 设置 server option |
| `-u` | unset，取消当前层级设置 |
| `-U` | unset 更深层覆盖，常用于 pane/window option |
| `-w` | 设置 window option |
| `-t` | 指定目标 pane / window / session |

示例：

    set -g mouse on
    set -s escape-time 0
    set -w -g mode-keys vi
    set -p synchronize-panes on
    set -as terminal-features 'xterm*:extkeys'
    set -gu default-command

---

## 5. `setw` 参数说明

`setw` 是 `set-window-option` 的别名。

形式：

    set-window-option [-aFgoqu] [-t target-window] option [value]

短写：

    setw [-aFgoqu] [-t target-window] option [value]

| 参数 | 含义 |
|---|---|
| `-a` | 追加 window option |
| `-F` | 对 value 做 format 展开 |
| `-g` | 设置 global window option |
| `-o` | 仅当 option 未设置时才设置 |
| `-q` | 静默模式 |
| `-u` | unset，取消 window option |
| `-t` | 指定目标 window |

示例：

    setw -g mode-keys vi
    setw -g monitor-activity off
    setw -g pane-base-index 1

推荐改成统一风格：

    set -w -g mode-keys vi
    set -w -g monitor-activity off
    set -w -g pane-base-index 1

---

## 6. `setenv` / `set-environment`

`setenv` 是 `set-environment` 的别名。

作用是设置 tmux 维护的环境变量。

示例：

    setenv -g EDITOR nvim
    setenv -g VISUAL nvim
    setenv -gu SSH_AUTH_SOCK

注意：

`setenv` 设置的是环境变量，不是 tmux option。

所以这些适合用 `setenv`：

| 变量 | 用途 |
|---|---|
| `EDITOR` | 默认编辑器 |
| `VISUAL` | 可视化编辑器 |
| `PATH` | 命令搜索路径 |
| `SSH_AUTH_SOCK` | SSH agent socket |

这些不能用 `setenv` 设置：

| 配置 | 应该使用 |
|---|---|
| `mouse` | `set -g mouse on` |
| `prefix` | `set -g prefix C-f` |
| `mode-keys` | `set -w -g mode-keys vi` |
| `escape-time` | `set -s escape-time 0` |

---

## 7. `set-hook`

`set-hook` 用来设置 tmux hook。

hook 可以理解为事件回调：

> 当某个 tmux 事件发生时，自动执行一条 tmux 命令。

形式：

    set-hook [-agpRuw] [-t target-pane] hook-name [command]

| 参数 | 含义 |
|---|---|
| `-a` | append，追加 hook |
| `-g` | 设置 global hook |
| `-p` | 设置 pane 级 hook |
| `-R` | 立即运行 hook |
| `-u` | unset，取消 hook |
| `-w` | 设置 window 级 hook |
| `-t` | 指定目标 pane / window / session |

示例：

    set-hook -g after-split-window "select-layout even-vertical"
    set-hook -ag after-new-window "display-message 'new window created'"
    set-hook -gu after-new-window
    set-hook -R after-new-window

---

## 8. `after-*` hook

tmux 支持大量 `after-*` hook。

规则是：

    after-<tmux-command>

比如：

| tmux 命令 | after hook |
|---|---|
| `new-window` | `after-new-window` |
| `split-window` | `after-split-window` |
| `kill-pane` | `after-kill-pane` |
| `rename-window` | `after-rename-window` |
| `select-pane` | `after-select-pane` |
| `source-file` | `after-source-file` |

示例：

    set-hook -g after-split-window "select-layout even-vertical"

含义：

每次执行 `split-window` 后，自动执行 `select-layout even-vertical`。

### 8.1 如何列出当前 tmux 支持的所有动作

在 shell 中执行：

    tmux list-commands

只看命令名：

    tmux list-commands | awk '{print $1}'

生成所有理论上的 `after-*` hook 名称：

    tmux list-commands | awk '{print "after-" $1}'

---

## 9. 常见 tmux 动作列表

这些动作都可以作为 `after-*` 的来源。

### 9.1 client / session 相关

| 动作 |
|---|
| `attach-session` |
| `detach-client` |
| `has-session` |
| `kill-server` |
| `kill-session` |
| `list-clients` |
| `list-commands` |
| `list-sessions` |
| `lock-client` |
| `lock-session` |
| `new-session` |
| `refresh-client` |
| `rename-session` |
| `show-messages` |
| `source-file` |
| `start-server` |
| `suspend-client` |
| `switch-client` |

### 9.2 window / pane 相关

| 动作 |
|---|
| `break-pane` |
| `capture-pane` |
| `choose-client` |
| `choose-tree` |
| `display-panes` |
| `find-window` |
| `join-pane` |
| `kill-pane` |
| `kill-window` |
| `last-pane` |
| `last-window` |
| `link-window` |
| `list-panes` |
| `list-windows` |
| `move-pane` |
| `move-window` |
| `new-window` |
| `next-layout` |
| `next-window` |
| `pipe-pane` |
| `previous-layout` |
| `previous-window` |
| `resize-pane` |
| `resize-window` |
| `respawn-pane` |
| `respawn-window` |
| `rotate-window` |
| `select-layout` |
| `select-pane` |
| `select-window` |
| `split-window` |
| `swap-pane` |
| `swap-window` |
| `unlink-window` |

### 9.3 key binding 相关

| 动作 |
|---|
| `bind-key` |
| `list-keys` |
| `send-keys` |
| `send-prefix` |
| `unbind-key` |

### 9.4 option / hook / environment 相关

| 动作 |
|---|
| `set-option` |
| `show-options` |
| `set-hook` |
| `show-hooks` |
| `set-environment` |
| `show-environment` |

### 9.5 buffer / copy-mode 相关

| 动作 |
|---|
| `choose-buffer` |
| `clear-prompt-history` |
| `copy-mode` |
| `delete-buffer` |
| `list-buffers` |
| `load-buffer` |
| `paste-buffer` |
| `save-buffer` |
| `set-buffer` |
| `show-buffer` |

### 9.6 shell / prompt / popup 相关

| 动作 |
|---|
| `command-prompt` |
| `confirm-before` |
| `display-menu` |
| `display-message` |
| `display-popup` |
| `if-shell` |
| `run-shell` |
| `wait-for` |

---

## 10. `before-*` hook

当前 tmux 没有通用 `before-*` hook 机制。

所以通常不要写：

    set-hook -g before-split-window "display-message before"

如果想实现 before 效果，可以用命令序列：

    bind-key | display-message "before split" \; split-window -h

含义：

按 `prefix + |` 时，先显示消息，再执行水平分屏。

---

## 11. 独立 hook

这些 hook 不需要 `after-` 前缀。

### 11.1 alert 相关

| hook | 触发条件 |
|---|---|
| `alert-activity` | 窗口有 activity |
| `alert-bell` | 窗口收到 bell |
| `alert-silence` | 窗口静默达到 monitor-silence 条件 |

常配合：

    set -w -g monitor-activity on
    set -w -g monitor-bell on
    set -w -g monitor-silence 30

### 11.2 client 相关

| hook |
|---|
| `client-active` |
| `client-attached` |
| `client-detached` |
| `client-focus-in` |
| `client-focus-out` |
| `client-resized` |
| `client-session-changed` |
| `client-light-theme` |
| `client-dark-theme` |

### 11.3 command 相关

| hook | 触发条件 |
|---|---|
| `command-error` | tmux 命令执行失败 |

### 11.4 pane 相关

| hook |
|---|
| `pane-died` |
| `pane-exited` |
| `pane-focus-in` |
| `pane-focus-out` |
| `pane-set-clipboard` |
| `pane-mode-changed` |

### 11.5 session 相关

| hook |
|---|
| `session-created` |
| `session-closed` |
| `session-renamed` |
| `session-changed` |
| `session-window-changed` |
| `sessions-changed` |

### 11.6 window 相关

| hook |
|---|
| `window-layout-changed` |
| `window-linked` |
| `window-renamed` |
| `window-resized` |
| `window-unlinked` |
| `window-add` |
| `window-close` |
| `window-pane-changed` |

### 11.7 paste buffer 相关

| hook |
|---|
| `paste-buffer-changed` |
| `paste-buffer-deleted` |

---

## 12. `show` / `show-options`

`show` 是 `show-options` 的别名。

作用是查看 tmux option。

示例：

    tmux show -g mouse
    tmux show -s escape-time
    tmux show -w -g mode-keys
    tmux show -p synchronize-panes

注意：

`show` 类命令可以写进 `.tmux.conf`，因为 `.tmux.conf` 本质上会执行 tmux 命令。

但是一般不应该写进去，因为它只是查询，不会形成配置效果。

更适合在 shell 里调试时使用。

---

## 13. 统一风格建议

建议统一使用现代 `set` 风格，不混用 `setw`、`set-window-option`、`set-option`。

推荐：

    set -s escape-time 0
    set -g mouse on
    set -w -g mode-keys vi
    set -w -g pane-base-index 1
    set -as terminal-features 'xterm*:extkeys'
    set -gu default-command

不推荐混用：

    set -g mouse on
    setw -g mode-keys vi
    set-option -g prefix C-f
    set-window-option -g pane-base-index 1

这种统一风格的好处：

1. 所有配置都从 `set` 出发。
2. `-s` / `-w` / `-p` 明确表达作用域。
3. 不依赖老别名 `setw`。
4. 后续维护时更容易判断 option 属于 server、session、window 还是 pane。

