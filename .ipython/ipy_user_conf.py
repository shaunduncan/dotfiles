import IPython.ipapi

ip = IPython.ipapi.get()


def main():
    o = ip.options
    o.autoexec.append('%colors NoColor')
    o.autoexec.append('%autoindent 1')
    o.autoexec.append('%color_info 1')
    o.autoexec.append('%banner 0')

main()
