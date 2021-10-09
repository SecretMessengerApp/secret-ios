import argparse
import os
import glob
import sys
import re
import shutil
import sys

CHECK_DSYM = False
ENABLE_DELETE = True

def remove_trailing_string(content, trailing):
    """
    Strip trailing component `trailing` from `content` if it exists.
    """
    if content.endswith(trailing) and content != trailing:
        return content[:-len(trailing)]
    return content
 
def parse():
    path = './Carthage/Build/iOS'
    for name in glob.glob(os.path.join(path, '*.framework')):
        basename = os.path.basename(name)
        frameworkName = remove_trailing_string(basename, '.framework')
        # print(frameworkName)

        # Checking exists Framework sub directory
        target = os.path.join(name, 'Frameworks')
        if os.path.exists(target):
            print('Invalid framework as has Framework directory:', frameworkName)
            
            if ENABLE_DELETE:
                print('Delete', target)
                shutil.rmtree(target)
            sys.exit(1)

        # Checking exists of binary file
        target = os.path.join(name, frameworkName)
        if not os.path.exists(target):
            print('Invalid framework as no binary:', target)
            sys.exit(1)

        if CHECK_DSYM:
            # Checking dsym
            target = os.path.join(path, '{}.dSYM'.format(basename))

            if not frameworkName.startswith('Wire'):
                continue

            if not os.path.exists(target):
                print('Warn no dSYM for framework:', frameworkName)
                sys.exit(1)
                
    
if __name__ == '__main__':
    parse()
    print('OK, Checking Carthage Frameworks')
