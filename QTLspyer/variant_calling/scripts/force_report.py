#!/usr/bin/env python3
import logging
import time
import os


def log_force_stop(log_name, log_file):
    """Enable logging."""
    
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
    logger = logging.getLogger(log_name)
    logger.error(f'[USER] Process was stopped by force!')


if __name__ == '__main__':
    os.chdir('..')
    log_force_stop(
        log_name='process_logger', log_file='/QTLspyer/log/sample_processing.log'
    )
