class_name Logger
extends Node
## A Node which manages logging to a log file.
##
## Loggers will run from _init() and are intended to be used as singletons in your project's
## 'autoruns'. This way they can be refrenced "globally" by name by checking the 'enable' box.
## In order to edit the settings, you will need to create a scene tree with at least a logger node,
## however it is recommended to create a scene tree with only your logger. You can change the
## "global" name of your logger by changing it's name in autoruns. To create multiple loggers with
## different settings, simply create multiple scene trees and add them each to 'autoruns'.


## A log level. These may be used to refer to a single level, or a level and all levels below it.
enum Level {
    ERROR, ## Log only errors. The error level also uses printerr() when outputting to console.
    WARNING, ## Log errors and warnings.
    INFO, ## Log info, and above
    VERBOSE, ## Log verbose, and above
    DEBUG ## Log debug, and above
}
## What style of time to use for the logged timestamp.
enum Time_Mode {
    MSEC, ## Will use the number of milliseconds since the application started.
    USEC, ## Will use the number of microseconds since the application started.
    SYSTEM ## Will use the date and time from the system.
}


@export_category("Logger")
## Path to store log files.
@export_dir var logging_path := "user://logs/"
## Format for the saved log's filename. Formats are available: [br]
##     {timestamp} is replaced by the time when the application is started. This time may be very [br]
##         slightly later than the actual application start time.
@export var filename_format := "{timestamp}.log"
## Also log to the console.
@export var log_to_console := true
## Format for each logged message. Formats are available: [br]
##     {timestamp} is replaced by the logged time using the time format. [br]
##     {label} is replaced by the label provided for that message, or the default label. [br]
##     {level} is replaced by the level text "Error", "Warn", "Info", "Verbose", or "Debug". [br]
##     {message} is replaced by the message.
@export var log_format := "{timestamp} [{label}] {level}: {message}"
## The maximum level to log messages. All lower levels will be included.
@export var log_level := Level.INFO
## The default label to use for logs if one isn't provided.
@export var default_label := "System"
## What style of time to use for the logged timestamp.
@export var time_mode := Time_Mode.MSEC

@export_group("Level Texts")
@export var error_level_text := "Error"
@export var warning_level_text := "Warning"
@export var info_level_text := "Info"
@export var verbose_level_text := "Verbose"
@export var debug_level_text := "Debug"


var _log_file: FileAccess
var _time := Time.get_datetime_string_from_system()


func _init():
    var args = Array(OS.get_cmdline_args())

    if args.find("-e") != -1:
        log_level = Level.ERROR
    if args.find("-w") != -1:
        log_level = Level.WARNING
    if args.find("-i") != -1:
        log_level = Level.INFO
    if args.find("-v") != -1:
        log_level = Level.VERBOSE
    if args.find("-d") != -1:
        log_level = Level.DEBUG
    if OS.is_stdout_verbose():
        log_level = Level.VERBOSE

    _open_log_file()


func error(message: String, label: String = default_label):
    write_log(message, label, Level.ERROR)


func warn(message: String, label: String = default_label):
    write_log(message, label, Level.WARNING)


func warning(message: String, label: String = default_label):
    warn(message, label)


func info(message: String, label: String = default_label):
    write_log(message, label, Level.INFO)


func debug(message: String, label: String = default_label):
    write_log(message, label, Level.DEBUG)


func verbose(message: String, label: String = default_label):
    write_log(message, label, Level.VERBOSE)


func write_log(message: String, label: String = default_label, level: Level = Level.INFO):
    if _log_file == null:
        printerr("Log file lost? Trying to find it again...")
        if !_open_log_file:
            return

    var time

    match time_mode:
        Time_Mode.MSEC:
            time = Time.get_ticks_msec()
        Time_Mode.USEC:
            time = Time.get_ticks_usec()
        Time_Mode.SYSTEM:
            time = Time.get_datetime_string_from_system()
        _:
            time = Time.get_ticks_msec()

    var level_string

    match level:
        Level.ERROR:
            level_string = error_level_text
        Level.WARNING:
            level_string = warning_level_text
        Level.INFO:
            level_string = info_level_text
        Level.VERBOSE:
            level_string = verbose_level_text
        Level.DEBUG:
            level_string = debug_level_text

    var log_line = log_format.format(
        {
            "timestamp": time,
            "label": label,
            "level": level_string,
            "message": message
        }
    )

    _log_file.store_line(log_line)

    if log_to_console:
        if level == Level.ERROR:
            printerr(log_line)
        elif level <= log_level:
            print(log_line)

func _open_log_file() -> bool:
    var log_file_path = logging_path + filename_format.format({"timestamp": _time})

    _log_file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)

    if _log_file == null:
        printerr("Logger could not open log file!")
        return false

    return true
