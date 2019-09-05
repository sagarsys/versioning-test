import sys
import subprocess
import os

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

done = False
dev_types = ['feat', 'fix', 'chore', 'refactor', 'test', 'docs', 'build']
keyboard_interrupt_msg = '\nExiting script due to keyboard interrupt'

def __exit():
    print(bcolors.FAIL + keyboard_interrupt_msg + bcolors.ENDC)
    sys.exit()


def get_commit_message():
    global keyboard_interrupt_msg
    prompt_msg = 'Enter a commit message describing the development* \n'
    invalid_msg = 'Message is required, please insert a valid message'
    try:
        msg = input(bcolors.BOLD + bcolors.OKBLUE + prompt_msg + bcolors.ENDC)
        if msg == '':
            print(bcolors.FAIL + invalid_msg + bcolors.ENDC)
            return get_commit_message()
        return msg.lower()
    except(KeyboardInterrupt):
        __exit()

def input_choice(message):
    __choice = input(message)
    if __choice == '':
        return False
    try:
        return int(__choice)
    except ValueError:
        return False

def get_commit_type(intro = True):
    global dev_types
    global keyboard_interrupt_msg
    prompt_type = 'Enter the development type (feat, fix, chore, refactor, test, docs, build) *'
    invalid_choice_msg = 'Invalid choice, please select a number between 1 & ' + str(len(dev_types))
    i = 1
    if intro:
        print(bcolors.BOLD + bcolors.OKBLUE + prompt_type + bcolors.ENDC)
        for t in dev_types:
            print(str(i), t)
            i += 1
    try:
        type_choice = input_choice(bcolors.BOLD + bcolors.OKBLUE + 'Choose type [1-7]: ' + bcolors.ENDC)
        if not type_choice:
            print(bcolors.FAIL + invalid_choice_msg + bcolors.ENDC)
            return get_commit_type(False)
        type_choice -= 1
        try:
            selected_type = dev_types[type_choice]
            return selected_type
        except(IndexError):
            print(bcolors.FAIL + invalid_choice_msg + bcolors.ENDC)
            return get_commit_type(False)
    except(KeyboardInterrupt):
        __exit()


def get_commit_scope():
    prompt_scope = 'Enter an optional scope for the development [leave blank for no scope] \n'
    try:
        _scope = input(bcolors.BOLD + bcolors.OKBLUE + prompt_scope + bcolors.ENDC)
        return _scope if _scope ==  '' else _scope.lower()
    except(KeyboardInterrupt):
        print(bcolors.FAIL + keyboard_interrupt_msg + bcolors.ENDC)

def get_commit_desc():
    prompt_desc = 'Enter an optional description for the development [leave blank for no description] \n'
    try:
        _desc = input(bcolors.BOLD + bcolors.OKBLUE + prompt_desc + bcolors.ENDC)
        return _desc
    except(KeyboardInterrupt):
        __exit()

def get_confirmation():
    confirm_message = 'Confirm the commit message? [y/n] '
    try:
        confirm = input(bcolors.BOLD + bcolors.OKBLUE + confirm_message + bcolors.ENDC)
        if confirm == '':
            return get_confirmation()
        if confirm.lower() != 'y' and confirm.lower() != 'n':
            return get_confirmation()
        else:
            return confirm.lower()
    except(KeyboardInterrupt):
        __exit()

def prompt():
    global done
    intro_message = 'This script will help you write your commit message (using the conventional commit guidelines) for the development that you have done.'
    outro_message = 'Your commit message will be as follows:'
    final_message = ''
    print(bcolors.HEADER + intro_message + bcolors.ENDC)
    while not done:
        message = get_commit_message()
        _type = get_commit_type()
        scope = get_commit_scope()
        desc = get_commit_desc()

        final_message = ''
        if scope != '':
            final_message += _type + '(' + scope + '): ' + message
        else:
            final_message += _type + ': ' + message
        if desc != '':
            final_message += '\n' + desc

        print(bcolors.HEADER + outro_message + bcolors.ENDC)
        print(bcolors.OKGREEN + final_message + bcolors.ENDC)

        confirmation = get_confirmation()
        if confirmation == 'y':
            done = True
        else:
            print(bcolors.BOLD + bcolors.OKBLUE + 'Restarting... \n' + bcolors.ENDC)
    return final_message


def perform_git_actions(msg):
    currentDir = os.path.dirname(os.path.abspath(__file__))
    bashFile = currentDir + '/script.sh'
    return subprocess.check_call([bashFile, msg])

def upgrade_version():
    currentDir = os.path.dirname(os.path.abspath(__file__))
    nodeFile = currentDir + '/versioning.js'
    return subprocess.call(['node', nodeFile])


def main():
    message = prompt()
    exitCode = perform_git_actions(message)
    if (exitCode == 0):
        print(bcolors.OKGREEN + 'GIT repository updated successfully \nPerforming a release update' + bcolors.ENDC)
        upgrade_version()
    else:
        print(bcolors.FAIL + b.bcolors.BOLD + 'Failed to perform GIT actions \nExiting script' + bcolors.ENDC)
        sys.exit()

main()
