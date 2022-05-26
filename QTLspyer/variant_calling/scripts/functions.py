"""Functions used in tools script"""
import time
import os
import json
import logging
import warnings


def enable_logging(log_name, log_file):
    """Enable logging."""
    try:
        os.remove(log_file)
    except FileNotFoundError:
        print('No logging file present, creating new one.')

    logger = logging.getLogger(log_name)
    logger.setLevel(logging.INFO)

    handler = logging.FileHandler(log_file)
    handler.setLevel(logging.INFO)
    handler.setFormatter(
        logging.Formatter(
            '%(asctime)s\t%(levelname)s\t%(message)s'
        )
    )
    logger.addHandler(handler)

    logger.info(f'Analysis started on: {time.strftime("%c")}')

    return logger


def write_result_to_debug(x, log):
    try:
        log.debug(f'{x}')
    except AttributeError:
        log.debug(f'{x}')

    return None


def vr(x, log):
    """Quick shortcut to view the result."""
    log.info(f""
             f"==============================================================================="
             f"")
    log.info(x)


def update_pickle(x, y):
    """
    Update pickle file with new samples (added or removed).

    :param x: Pickle file, e.g. `pickled_file`.
    :param y: Dictionary to write.
    :return: Side effect is a written dictionary to file.
    """
    with open(x, "w") as f:
        json.dump(y, f)


def interpret_result(log, so_logger, report, logger_mes, logger_error_mes, runtime_error_mes):
    """Interpret and report on return results of the process"""
    if report[0]:
        log.error(logger_error_mes)
        write_result_to_debug(report[2], log=log)
        vr(report[2], log=so_logger)
        raise RuntimeError(runtime_error_mes)
    else:
        log.info(logger_mes)
        write_result_to_debug(report[2], log=log)
        vr(report[2], log=so_logger)
