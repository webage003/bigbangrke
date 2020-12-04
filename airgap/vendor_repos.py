#!/usr/bin/env python3

import os
import sys
import yaml
import argparse
import shutil
from git import Repo

class Vendor_Repos:

    def __init__(self):
        parser = argparse.ArgumentParser(description='Repository vendor tool for Umbrella.')
        parser.add_argument('values', type=argparse.FileType('r'), help='Values yaml file (Ex: chart/values.yaml).')
        # TODO - Verify that this is a directory and it is writable
        parser.add_argument('repos', type=str, default='Repository artifact directory (Ex: airgap/repos/packages).')
        self.args = parser.parse_args()

    def vendor_repos(self, values):
        # loop over provided values
        for key, value in values.items():
            # make sure they specify a repo
            if type(value) is dict and 'git' in value:

                # obtain repo information
                repo_url = value['git']['repo']
                repo_name = os.path.splitext(os.path.basename(repo_url))[0]
                repo_dir = f'{self.args.repos}/{repo_name}'
                repo_tag = value['git']['tag'] if 'tag' in value['git'] else None
                repo_branch = value['git']['branch'] if 'branch' in value['git'] else None

                # determine tag vs branch
                repo_refspec = None
                if repo_tag is not None: repo_refspec = 'tag'
                elif repo_branch is not None: repo_refspec = 'branch'
                if repo_refspec is None:
                    print('Error: Unable to determine repository refspec type')
                    sys.exit(1)

                # print debug information
                print(f'Repo URL: {repo_url}')
                print(f'Repo Dir: {repo_dir}')
                print(f'Repo Refspec: {repo_refspec}')
                print(f'Repo Tag: {repo_tag}')
                print(f'Repo Branch: {repo_branch}')

                # clean repo path
                if os.path.exists(repo_dir):
                    print(f'Cleaning existing path {repo_dir}')
                    shutil.rmtree(repo_dir)
                os.mkdir(repo_dir)

                # clone repo
                repo = Repo.clone_from(repo_url, repo_dir)

                # handle provided branch
                if repo_refspec == 'branch':
                    print(f'Checking out branch {repo_branch}')
                    repo.git.checkout(repo_branch)
                    repo.git.reset('--hard')
                # handle provided tag
                else:
                    print(f'Checking out tag {repo_tag}')
                    repo.git.reset('--hard', repo_tag)

                # delete .git content
                print(f'Deleting {repo_dir}/.git')
                shutil.rmtree(f'{repo_dir}/.git')

                # tar these up, upload to s3 after josh is done with that

                # no need to template out release process for umbrella
                # every tagged commit in main / master (default) runs release job
                # repos-x.y.z.tar.gz

                # Chart.yaml verison and git commit tag should always line up

                # print separator
                print('--')

    def run(self):
        # set top level and addon repositories
        top_level = yaml.load(self.args.values, Loader=yaml.FullLoader)
        addons = top_level['addons']
        # vendor repositories
        self.vendor_repos(top_level)
        self.vendor_repos(addons)    

# main invocation
if __name__ == '__main__':
    Vendor_Repos().run()