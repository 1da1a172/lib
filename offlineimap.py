#! /usr/bin/env python2
"""Additional functions for offlineIMAP"""
from subprocess import check_output

def get_pass(entry):
    """Get the password from the entry in the passwordstore."""
    return check_output("pass show " + entry, shell=True).splitlines()[0]
