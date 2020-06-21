using Dance.Router


route("/../files/image.jpg", output_file_as_string; method=GET, endpoint=EP_STATIC)
route("/files/image.jpg", output_file_as_string; method=GET, endpoint=EP_STATIC)
static_dir("/static", "../sample/static")
