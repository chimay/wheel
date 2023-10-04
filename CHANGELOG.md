
# Version 3.8

Changes of keys :

- g:wheel_config.project_markers -> g:wheel_config.project.markers
- g:wheel_config.auto_chdir_project -> g:wheel_config.project.auto_chdir
- new key : g:wheel_config.storage.wheel.folder
- g:wheel_config.file -> g:wheel_config.storage.wheel.name
- g:wheel_config.autoread -> g:wheel_config.storage.wheel.autoread
- g:wheel_config.autowrite -> g:wheel_config.storage.wheel.autowrite
- g:wheel_config.session_dir -> g:wheel_config.storage.session.folder
- g:wheel_config.session_file -> g:wheel_config.storage.session.name
- g:wheel_config.autoread_session -> g:wheel_config.storage.session.autoread
- g:wheel_config.autowrite_session -> g:wheel_config.storage.session.autowrite
- g:wheel_config.backups -> g:wheel_config.storage.backups

# version 3.7

Manage as many sessions files as you want.

Load & store all sessions from a session directory.

Default session file has changed :

- vim : '~/.vim/wheel/session/default.vim'
- nvim : '~/.local/share/nvim/wheel/session/default.vim'

# 2023 may 26

Little change in config :

g:wheel_config.display.message -> g:wheel_config.display.dedibuf_msg
