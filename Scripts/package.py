# import asyncio
import subprocess
import argparse
# import yaml
import datetime
import os
import sys
import time
from inc_version import inc_version
from inc_version import read_version


ENABLE_VERBOSE = False
ENABLE_SIMULATE = False
ENABLE_UPLOAD = True
PACKAGE_TYPE = ''
UPDATE_DESC = ''
INC_VERSION = False


class Configuration:
    def __init__(self, scheme, incVersion=False, uploadIPA=False):
        self.scheme = scheme
        self.incVersion = incVersion
        self.uploadIPA = uploadIPA
        self.workspace = scheme + '.xcworkspace'

        self.archivePath = None
        self.ipaPath = None
        self.appName = 'Secret'

        self.setupArchivePath()
  
    def setupArchivePath(self):
        self.plistPath = 'Scripts/ExportOptions.plist'

        now = datetime.datetime.now()
        day = now.strftime('%Y-%m-%d')

        # archive path
        archiveTime = now.strftime('%Y-%-m-%-d, %-I.%M %p')
        # StickerDemo 2020-5-27, 2.53 PM.xcarchive
        archiveName = '{} {}.xcarchive'.format(self.scheme, archiveTime)
        archivePath = '~/Library/Developer/Xcode/Archives/{}/{}'.format(day, archiveName)
        self.archivePath = os.path.expanduser(archivePath)

        # ipa path
        ipaTime = now.strftime('%Y-%m-%d_%H.%M')
        ipaFilename = "{}_{}.ipa".format(self.appName, ipaTime)
        ipaPath = "./build/ipa/{}".format(ipaFilename)
        self.ipaPath = ipaPath

    def __str__(self):
        return '\n-----\nscheme: {}\nincVersion: {}\nuploadIPA: {}\n-----'.format(self.scheme, self.incVersion, self.uploadIPA)


def archive(config):
    ''' Archive. '''

    check_folder(config.archivePath)

    cmd = 'xcodebuild archive \
-scheme {} \
-quiet \
-project Wire-iOS.xcodeproj \
-configuration {} \
-sdk iphoneos \
-archivePath "{}"'.format(config.scheme, PACKAGE_TYPE, config.archivePath)

    if run(cmd):
        print('archive success')
    else:
        print('archive failed')
        sys.exit()


def exportIPA(config):
    ''' Export ipa file. '''

    check_folder('./build/ipa')
    output = './build/tmp'
    check_folder(output)
    cmd = 'xcodebuild -exportArchive -archivePath "{}" -exportPath {} -exportOptionsPlist {}'.format(config.archivePath, output, config.plistPath)

    if run(cmd):
        source = os.path.join(output, '{}.ipa'.format(config.scheme))
        dst = config.ipaPath
        run('cp {} {}'.format(source, dst))
        print('export ipa success')
    else:
        print('export ipa failed')
        sys.exit()


def uploadIPA(config):
    cmd = 'fir publish -c "{}" {}'.format(UPDATE_DESC or '这个人很懒，什么也没留下～', config.ipaPath)

    if run(cmd):
        print('upload success')
    else:
        print('upload failed')


def run(cmd):
    if ENABLE_SIMULATE:
        print('Execute command:', cmd)
        return True
    if ENABLE_VERBOSE:
        print('[run]', cmd)

    cp = subprocess.run(cmd, shell=True)
    return cp.returncode == 0


def main():
    startTime = time.perf_counter()
    parse_environment()

    if INC_VERSION:
        inc_version(True)

    scheme = "Wire-iOS"
    config = Configuration(scheme, False, False)
    archive(config)
    exportIPA(config)
    uploadIPA(config)

    costTime = time.perf_counter() - startTime
    print('Cost {:.2f} seconds'.format(costTime))


def check_folder(path):
    if not os.path.exists(path):
        try:
            os.makedirs(path)
        except OSError:
            print('Create directory {} failed'.format(path))
        else:
            print('Successfully created the directory {}'.format(path))


def parse_environment():
    global PACKAGE_TYPE
    global ENABLE_SIMULATE
    global ENABLE_VERBOSE
    global UPDATE_DESC
    global ENABLE_UPLOAD
    global INC_VERSION

    parser = argparse.ArgumentParser(description='Package for Secret')
    parser.add_argument('-t', '--type', dest='type', default='Debug', help='package type, Alpha or Release (default: Alpha)')
    parser.add_argument('-s', '--simulate', dest='simulate', action='store_true', help='simulate execute')
    parser.add_argument('-v', '--verbose', dest='verbose', action='store_true', help='verbose')
    parser.add_argument('-d', '--desc', dest='desc', nargs='?', help='update log')
    parser.add_argument('-u', '--upload', dest='upload', action='store_true', help='upload ipa')
    parser.add_argument('-i', '--increment', dest='increment', action='store_true', help='increment version')

    args = parser.parse_args()
    PACKAGE_TYPE = args.type
    ENABLE_SIMULATE = args.simulate
    ENABLE_VERBOSE = args.verbose
    UPDATE_DESC = args.desc
    ENABLE_UPLOAD = args.upload
    INC_VERSION = args.increment

    if not args.desc:
        with open('Scripts/build_log.txt') as fp:
            changelog = ''.join(fp.readlines())
            UPDATE_DESC = changelog


if __name__ == '__main__':
    version = read_version()
    input(f'Check Build Number({version}) & Check bundle_id in Release.xcconfig\nPress any key to continue.')
    main()
