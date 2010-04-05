# -*- coding: utf-8 -*-
# Copyright (C) 2010 Bastian Kleineidam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
from patoolib import util

def extract_singlefile_standard (archive, encoding, cmd, **kwargs):
    """Standard routine to extract a singlefile archive (like gzip)."""
    cmdlist = [util.shell_quote(cmd)]
    if kwargs['verbose']:
        cmdlist.append('-v')
    outfile = util.get_single_outfile(kwargs['outdir'], archive)
    cmdlist.extend(['-c', '-d', '--', util.shell_quote(archive), '>',
        util.shell_quote(outfile)])
    # note that for shell calls the command must be a string
    return (" ".join(cmdlist), {'shell': True})


def test_singlefile_standard (archive, encoding, cmd, **kwargs):
    """Standard routine to test a singlefile archive (like gzip)."""
    cmdlist = [cmd]
    if kwargs['verbose']:
        cmdlist.append('-v')
    cmdlist.extend(['-t', '--', archive])
    return cmdlist


def create_singlefile_standard (archive, encoding, cmd, *args, **kwargs):
    """Standard routine to create a singlefile archive (like gzip)."""
    cmdlist = [util.shell_quote(cmd)]
    if kwargs['verbose']:
        cmdlist.append('-v')
    cmdlist.extend(['-c', '--'])
    cmdlist.extend([util.shell_quote(x) for x in args])
    cmdlist.extend(['>', util.shell_quote(archive)])
    # note that for shell calls the command must be a string
    return (" ".join(cmdlist), {'shell': True})
