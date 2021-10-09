#!/usr/local/bin/python3

import os
import re
import argparse
from tempfile import mkstemp
from os import close
from shutil import move

PROJECT_FILE="Wire-iOS.xcodeproj/project.pbxproj"
CARTHAGE_FRAMEWORK_TEMPLATE="$(SRCROOT)/Carthage/Build/iOS/{}.framework"
LOCAL_FRAMEWORK_TEMPLATE="$(BUILT_PRODUCTS_DIR)/{}.framework"
LOCAL_FRAMEWORK_REGEX="\\$\\(BUILT_PRODUCTS_DIR\\)/(\\w+)\\.framework"

def toggleFramework(framework):
    template = '.+"(\$\(SRCROOT\)/Carthage/Build/iOS|\$\(BUILT_PRODUCTS_DIR\))/{}.framework.+'.format(framework)
    regex = re.compile(template)
    (fh, tmpFile) = mkstemp()

    replaced = False

    with open(tmpFile, 'w') as new_file:
        with open(PROJECT_FILE) as old_file:
            for line in old_file.readlines():
                result = regex.match(line)
                if result:
                    print('Replace framework', framework)
                    replaced = True
                    if 'Carthage' in result.group(1):
                        new_file.write(line.replace('$(SRCROOT)/Carthage/Build/iOS', '$(BUILT_PRODUCTS_DIR)'))
                    else:
                        new_file.write(line.replace('$(BUILT_PRODUCTS_DIR)', '$(SRCROOT)/Carthage/Build/iOS'))
                else:
                    new_file.write(line)

    close(fh)

    if replaced:
        move(tmpFile, PROJECT_FILE)
    else:
        print('Not found framework {}'.format(framework))


if __name__ == "__main__":
    if not os.path.isfile(PROJECT_FILE):
        print(PROJECT_FILE, "not found, please run from the project root directory")
        exit(1)

    parser = argparse.ArgumentParser()
    parser.add_argument("framework", default=None, nargs="?")
    args = parser.parse_args()

    if args.framework is None:
        print('Replaceing WireSyncEngine by default')
        args.framework = 'WireSyncEngine'
    
    toggleFramework(args.framework)

