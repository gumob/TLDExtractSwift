#!/usr/bin/python
# -*- coding:utf-8 -*-

import os
import sys
import re

if __name__ == '__main__':

    # Variables
    src_dir = os.path.dirname(os.path.abspath(os.path.join(__file__, '..')))
    psl_file = os.path.abspath(os.path.join(src_dir, 'Resources/public_suffix_list.dat'))
    psl_url = 'https://publicsuffix.org/list/public_suffix_list.dat'

    try:
        # Python 3
        from urllib.request import urlopen
        response = urlopen(psl_url)
        psl_str = response.read().decode('utf-8')
    except ImportError:
        # Python 2
        from urllib import urlopen
        response = urlopen(psl_url)
        psl_str = response.read()

    # Remove comment
    psl_str = re.sub(r'//.*', '', psl_str)
    # Remove duplicated line breaks
    psl_str = re.sub(r'\n{2,}|^\n', '\n', psl_str)
    # Remove blank line from beginning and end
    psl_str = re.sub(r'^\n?|\n$\s{,0}', '', psl_str)

    # Add punycoded rules
    if sys.version_info[0] >= 3:
        # Python 3
        lines = psl_str.splitlines()
        insert_count = 0
        for index, line in enumerate(lines[:]):
            line_punycoded = line.encode('idna').decode('utf-8')
            if line != line_punycoded:
                # print("line", line, "line_punycoded", line_punycoded, type(line_punycoded))
                insert_at = index + insert_count + 1
                lines[insert_at:insert_at] = [line_punycoded]
                insert_count += 1
        psl_str = '\n'.join(lines)

    else:
        # Python 2
        lines = psl_str.splitlines()
        insert_count = 0
        for index, line in enumerate(lines[:]):
            line_punycoded = unicode(line, "utf-8").encode('idna').encode('ascii','replace')
            if line != line_punycoded:
                # print("line", line, "line_punycoded", line_punycoded, type(line_punycoded))
                insert_at = index + insert_count + 1
                lines[insert_at:insert_at] = [line_punycoded]
                insert_count += 1
        psl_str = '\n'.join(lines)

    # Save file
    with open(psl_file, mode='w') as f:
        f.write(psl_str)
        f.close()
