import json
import os
import argparse
import psutil
import time

import front_end as generator

current_dir = os.path.dirname(os.path.abspath(__file__))


if __name__ == '__main__':
    process = psutil.Process()
    start_time = time.perf_counter()

    parser = argparse.ArgumentParser()
    parser.add_argument('-process', '--process', help='过程名称')
    parser.add_argument('-lang', '--lang', help='生成合约的语言')
    args = parser.parse_args()

    file_name = args.process
    file_path = f'inputs/json/{file_name}.json'
    abs_path = os.path.join(current_dir, file_path)
    with open(abs_path, "r") as f:
        proc = json.load(f)
    generator.convert_bpmn_to_sol(proc, file_name, args.lang, True)

    end_time = time.perf_counter()
    memory_usage = process.memory_info().rss  # 单位为字节
    print("Memory usage:", memory_usage, "bytes")
    print("Execution Time:", (end_time - start_time) * 1e6, "ms")
