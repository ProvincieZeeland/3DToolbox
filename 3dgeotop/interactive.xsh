# Username is much less of a thing inside containers
$PROMPT = '{env_name}{BOLD_GREEN}{hostname}{BOLD_BLUE} {cwd}{branch_color}{curr_branch: {}}{RESET} {BOLD_BLUE}{prompt_end}{RESET} '
$TITLE = '{current_job:{} | }{hostname}: {cwd} | xonsh'

# Don't store history, on the assumption that containers are ephemeral
$XONSH_HISTORY_BACKEND = 'dummy'


$XONTRIB_SH_SHELLS = ['bash', 'sh']  # default
xontrib load sh

xontrib load argcomplete

# ------------------------------------------------------------------------------
# Temporary fixes of known issues
# ------------------------------------------------------------------------------

# A few filters for different environments (python versions).

# https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1696
__import__('warnings').filterwarnings('ignore', 'There is no current event loop', DeprecationWarning, 'prompt_toolkit.eventloop.utils')

# workaround https://github.com/xonsh/xonsh/issues/4409
__import__('warnings').filterwarnings('ignore', 'There is no current event loop', DeprecationWarning, 'prompt_toolkit.application.application')

# workaround https://github.com/xonsh/xonsh/issues/4409
__import__('warnings').simplefilter('ignore', DeprecationWarning, 995)

