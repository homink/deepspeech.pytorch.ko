import argparse
import os
import io
import shutil
import tarfile
import wget
import subprocess

from utils import create_manifest

parser = argparse.ArgumentParser(description='Processes nikl.')
parser.add_argument('--target-dir', default='./data/nikl_dataset', help='Path to save dataset')
parser.add_argument('--min-duration', default=1, type=int,
                    help='Prunes training samples shorter than the min duration (given in seconds, default 1)')
parser.add_argument('--max-duration', default=15, type=int,
                    help='Prunes training samples longer than the max duration (given in seconds, default 15)')
args = parser.parse_args()


def main():
    if not os.path.isdir(args.target_dir):
      os.makedirs(args.target_dir)
    train_path = args.target_dir + '/train/'
    test_path = args.target_dir + '/test/'

    subprocess.call(["local/clean_corpus.sh","$HOME/copora/NIKL",args.target_dir])
    subprocess.call(["local/data_prep.sh","$HOME/copora/NIKL",args.target_dir])

    print ('\n', 'Creating manifests...')
    create_manifest(train_path, 'nikl_train_manifest.csv', args.min_duration, args.max_duration)
    create_manifest(test_path, 'nikl_val_manifest.csv')


if __name__ == '__main__':
    main()
