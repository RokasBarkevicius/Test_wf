import logging
_logger = logging.getLogger(__name__)

a = 5
_logger.info(a)
b = 6
c = a*b +7
_logger.debug(
	"%s\nhello\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s" %(
	"C" * 100,
	"N" * 100,
	"C" * 100,
	"C" * 100,
	"B" * 100,
	"V" * 100,
	"C" * 100,
	"D" * 100,
	"H" * 100,
    )
)

print(f"{c}")