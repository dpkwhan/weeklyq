import os
import logging as logger
import shutil

from qpython import qconnection as qc
import pandas as pd

EXTENSION_NAME = '.xlsx'


def to_qstr(filename, items):
    [venue, date, time] = filename.split('_')[-3:]
    
    symbol_cols = [
        'sym',
        'primaryExchange',
        'auctionType',
        'mktImblSide',
        'totImblSide',
        'auctionIndicator',
        'freezeIndicator',
    ]
    long_cols = [
        'mktImblQty',
        'totImblQty',
        'pairedQty',
    ]
    float_cols = [
        'indicativePrice',
        'lowerCollar',
        'higherCollar',
        'auctionOnlyPrice',
        'bookClearingPrice',
        'referencePrice',
        'netChange',
    ]
    bool_cols = ['significantImbl']
    
    qstr = ''
    for item in items:
        dk = '`date`time`venue'
        dv = f'({date}d;"V"$"{time}";`{venue.upper()}'
        for k in item.keys():
            dk = f'{dk}`{k}'
            v = item[k]
            
            if k in symbol_cols:
                dv = f'{dv};`$"{v}"'
            elif k in long_cols:
                dv = f'{dv};{str(v)}j'
            elif k in float_cols:
                dv = f'{dv};{str(v)}f'
            elif k in bool_cols:
                b = '1b' if v == 'Y' else '0b'
                dv = f'{dv};{b}'
            else:
                print(k, v)
        dk = f'{dk}`snapshot'
        dv = f'{dv};`$"{filename}"'
        d = f'{dk}!{dv})'
        first_char = ';' if qstr else '('
        qstr = f'{qstr}{first_char}{d}'
        
    qstr = f'{qstr})'
    qstr = f'''
        if[not `imblfeed~key `imblfeed;imblfeed:()];
        imblfeed:imblfeed,{qstr};
    '''
    
    return qstr


def load_files(host, port, input_dir):
    qstr = '$[`imblfeed~key `imblfeed;exec snapshot from select distinct snapshot from imblfeed;()]'
    with qc.QConnection(host=host, port=port) as kdbc:
        res = kdbc(qstr)
        filenames = [f"{name.decode('ascii')}{EXTENSION_NAME}" for name in res]
        
        files_to_load = []
        for fname in os.listdir(input_dir):
            if fname.startswith('auctions') and fname.endswith(EXTENSION_NAME) and fname not in filenames:
                files_to_load.append(os.path.join(input_dir, fname))
        
        if len(files_to_load) == 0:
            logger.info('No new files to load')
        else:
            logger.info(f'Loading {len(files_to_load)} files')
            
        for afile in files_to_load:
            load_file(host, port, afile)


def load_file(host, port, infile):
    logger.info(f'Loading {infile} to kdb')
    
    df = pd.read_excel(infile)
    df.columns = [
        'sym',
        'primaryExchange',
        'auctionType',
        'mktImblSide',
        'mktImblQty',
        'totImblSide',
        'totImblQty',
        'pairedQty',
        'indicativePrice',
        'lowerCollar',
        'higherCollar',
        'auctionOnlyPrice',
        'bookClearingPrice',
        'referencePrice',
        'auctionIndicator',
        'freezeIndicator',
        'significantImbl',
        'netChange'
    ]
    basename = os.path.basename(infile)
    filename = os.path.splitext(basename)[0]
    data = df.to_dict('records')
    qstr = to_qstr(filename, data)
    with qc.QConnection(host=host, port=port) as kdbc:
        kdbc(qstr)


def move_files(host, port, src_dir, dst_dir):
    qstr = '$[`imblfeed~key `imblfeed;exec snapshot from select distinct snapshot from imblfeed where date>=.z.D-3;()]'
    with qc.QConnection(host=host, port=port) as kdbc:
        res = kdbc(qstr)
        filenames = [f"{name.decode('ascii')}{EXTENSION_NAME}" for name in res]

        for fname in os.listdir(src_dir):
            if fname in filenames:
                src_file = os.path.join(src_dir, fname)
                if os.path.exists(src_file):
                    shutil.move(src_file, dst_dir)
