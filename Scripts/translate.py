#!/usr/bin/python

import asyncio
import aiohttp
import re
import os

SEP = '\\n'

async def translate(text, lang='zh-CN'):
    # zh-CN, zh-TW, ko 
    if len(text) == 0:
        print('Invalid input')
        return

    if lang not in ['zh-CN', 'zh-TW', 'ko']:
        print('Invalid language code')
        return

    headers = {'User-Agent': 'Mozilla/5.0'}
    url = 'https://translate.googleapis.com/translate_a/single'
    client = 'gtx'
    sl = 'auto'

    params = {
        'client': 'gtx',
        'sl': 'auto',
        'tl': lang,
        'dt': 't',
        'q': text
    }

    async with aiohttp.ClientSession() as session:
        async with session.get(url, params=params) as resp:
            dict = await resp.json()
            return(dict[0][0][0])

def extractContent(raw):
    output = []
    for line in raw.split('\n'):
        if len(line) == 0:
            continue

        result = re.match(r'\d+[、. ]+([^\n]+)', line)
        name = result.group(1)
        output.append(name)
    return output

def toChinese(source):
    return SEP.join(source)

def toEnglish(source):
    return SEP.join(source)

async def toTraditional(source):
    raw = SEP.join(source)
    output = await translate(raw, 'zh-TW')
    return output

async def toKorean(source):
    output = []
    for val in source:
        result = await translate(val, 'ko')
        output.append(result)
    return SEP.join(output)

async def toLanguage(source, code):
    output = []
    for val in source:
        result = await translate(val, code)
        output.append(result)
    return SEP.join(output)

def update_file(change, file):
    # result = await translate('how old are you')
    # print(result)
    file = 'Wire-iOS/Resources/{}.lproj/Localizable.strings'.format(file)
    output = []
    with open(file) as fp:
        for line in fp.readlines():
            if line.startswith('"new_version_info"'):
                s = '"new_version_info" = "{}";\n'.format(change)
                output.append(s)
            else:
                output.append(line)

    with open(file, 'w') as fp:
        result = ''.join(output)
        fp.write(result)


async def main():
    with open('./Scripts/update_log.txt') as fp:
        content = fp.read()
        (p1, p2) = content.split('\n\n')
        
    source_zh = extractContent(p1)
    source_en = extractContent(p2)

    print('\nchinese')
    output = toChinese(source_zh)
    update_file(output, 'zh-Hans')

    print('\nenglish')
    output = toEnglish(source_en)
    update_file(output, 'Base')

    print('\ntraditional')
    output = await toLanguage(source_zh, 'zh-TW')
    update_file(output, 'zh-Hant')

    print('\nkorean')
    output = await toLanguage(source_zh, 'ko')
    update_file(output, 'ko')

if __name__ == '__main__':
    asyncio.run(main())