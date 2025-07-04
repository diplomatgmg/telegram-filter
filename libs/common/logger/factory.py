import logging
import sys

from common.logger.config import log_config


__all__ = ["get_logger"]


_is_logging_configured = False


LOG_FORMAT = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"
LOG_DATE_FORMAT = "%d.%m.%Y %H:%M:%S"


def get_logger(name: str) -> logging.Logger:
    _configure_base_logger()

    logger = logging.getLogger(name)

    if logger.hasHandlers():
        return logger

    logger.setLevel(log_config.level.value)

    console_formatter = logging.Formatter(
        fmt=LOG_FORMAT,
        datefmt=LOG_DATE_FORMAT,
    )
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(console_formatter)
    console_handler.setLevel(log_config.level.value)

    logger.addHandler(console_handler)

    return logger


def _configure_base_logger() -> None:
    """
    Изменяет конфигурацию базового логгера для всех модулей, использующих logging
    """
    global _is_logging_configured  # noqa: PLW0602

    if _is_logging_configured:
        return

    logging.basicConfig(
        level=log_config.level.value,
        format=LOG_FORMAT,
        datefmt=LOG_DATE_FORMAT,
    )
