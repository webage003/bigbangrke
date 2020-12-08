#!/usr/bin/env python3

# standard library imports
import os, sys, shutil, argparse

# non standard imports
# don't require these as
# we provide an installation
# method
try:
    import yaml
    from git import Repo
except ModuleNotFoundError: pass

class bundle_Repos:

    def __init__(self):
        # main parser
        parser = argparse.ArgumentParser(description='Repository bundle tool for Umbrella.')
        subparsers = parser.add_subparsers(dest='command', required=True, help='Command to run.')

        # pip requirement parser
        pip_parser = subparsers.add_parser('pip', description='Print a list of pip requirements.')

        # bundle repos parser
        bundle_parser = subparsers.add_parser('bundle', description='Perform repository bundle functionality.')
        bundle_parser.add_argument('values', type=argparse.FileType('r'), help='Values yaml file (Ex: chart/values.yaml).')
        # TODO - Verify that this is a directory and it is writable
        bundle_parser.add_argument('repos', type=str, help='Repository artifact directory (Ex: airgap/repos/packages).')

        # store parsed args
        self.args = parser.parse_args()

    def bundle_repos(self, values):
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
                bundle_path = f'{self.args.repos}/{repo_name}.bundle'

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

                # clean repo path and bundle
                if os.path.exists(repo_dir):
                    print(f'Cleaning existing path {repo_dir}')
                    shutil.rmtree(repo_dir)
                if os.path.exists(f'{bundle_path}'):
                    print(f'Cleaning existing bundle {bundle_path}')
                    shutil.rmtree(bundle_path)
                os.mkdir(repo_dir)

                # clone repo
                print(f'Cloning {repo_url} to {repo_dir}')
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

                # create bundle
                print(f'Bundling repository for at HEAD')
                owd = os.getcwd()
                os.chdir(repo_dir)
                os.system(f'git bundle create ../{repo_name}.bundle HEAD')
                os.chdir(owd)

                # verify bundle
                print('Verifying that bundle exists')
                if not os.path.exists(f'{bundle_path}'):
                    print(f'Error: {bundle_path} does not exist')
                    sys.exit(1)

                # move back and delete repo
                print(f'Deleting repository {repo_dir}')
                shutil.rmtree(repo_dir)
               
                # print separator
                print('--')

    def run(self):
        # pip command
        if self.args.command == 'pip':
            # print pip requirements
            print('PyYAML gitpython')
        # bundle command
        elif self.args.command == 'bundle':
            # set top level and addon repositories
            top_level = yaml.load(self.args.values, Loader=yaml.FullLoader)
            addons = top_level['addons']
            # bundle repositories
            self.bundle_repos(top_level)
            self.bundle_repos(addons)    

# main invocation
if __name__ == '__main__':
    bundle_Repos().run()