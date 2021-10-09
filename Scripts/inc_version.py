import re
from os import close
from shutil import move
from tempfile import mkstemp


def replace(file, pattern, func):
    (fh, tmpFile) = mkstemp()

    replaced = False
    with open(tmpFile, 'w') as newFile:
        with open(file) as oldFile:
            for line in oldFile.readlines():
                out = re.sub(pattern, func, line)
                newFile.write(out)
                if out != line:
                    replaced = True

    close(fh)

    if replaced:
        move(tmpFile, file)


def inc(matched):
    key = matched.group(1)
    val = matched.group(2)
    intValue = int(val)
    addedValue = intValue + 1
    return f'{key} = {addedValue}'


# enable auto inc 1, target number
def generate_func(auto, dst=''):
    def func(matched):
        key = matched.group(1)

        if not auto:
            out = dst
        else:
            val = matched.group(2)
            intValue = int(val)
            out = intValue + 1
        return f'{key} = {out}'

    return func


# Set version
def inc_version(auto, dst=''):
    file = './Wire-iOS/Resources/Configuration/Version.xcconfig'
    key = 'BUILD_NUMBER'
    pattern = fr'^({key}) = (\w+)'

    func = generate_func(auto, dst)
    replace(file, pattern, func)


# Parse config file
def parse(file):
    pattern = r'^(\w+) = (\w+)'
    info = {}

    with open(file) as fp:
        for line in fp.readlines():
            matched = re.match(pattern, line)
            if matched:
                key = matched.group(1)
                val = matched.group(2)
                info[key] = val

    return info


def read_version():
    file = './Wire-iOS/Resources/Configuration/Version.xcconfig'
    key = 'BUILD_NUMBER'
    result = parse(file)
    return result[key]


if __name__ == '__main__':
    # print(read_version())
    inc_version(True, 1)
