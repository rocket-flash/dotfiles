import atexit
import os
import readline


def _get_hist_file():
    if "PYTHONHISTFILE" in os.environ:
        history = os.environ["PYTHONHISTFILE"]
    elif "XDG_STATE_HOME" in os.environ:
        history = os.path.join(os.environ["XDG_STATE_HOME"], "python", "history")
    else:
        history = os.path.join("~", ".python_history")

    history = os.path.abspath(os.path.expanduser(history))
    _dir, _ = os.path.split(history)
    os.makedirs(_dir, exist_ok=True)

    return history


def _setup_history():
    hist_file = _get_hist_file()

    try:
        readline.read_history_file(hist_file)
        # default history len is -1 (infinite), which may grow unruly
        readline.set_history_length(10000)
    except FileNotFoundError:
        pass

    atexit.register(readline.write_history_file, hist_file)


_setup_history()
