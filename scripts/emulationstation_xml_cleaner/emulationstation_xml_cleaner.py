#!/usr/bin/env python
"""
This tool will clean up emulationstation gamelist.xml files.

Removes any entries in the XML where the file can not be found.
This happens if you scrape your games and then delete them.
If it's just a few games its not a problem, but over time it can
clutter your files and cause emulation station to create a lot
of errors in your log files and make startup take longer.
"""
# Changelog
# 1.0.0 -- February 2, 2017
#   Initial commit to GitHub
# 0.1.0
#   Made compliant with major Python linters
#     flake8 (pep8 & pyflakes)
#       Disabled E501 (line length)
#       Disabled E241 (whitespace after comma)
#     OpenStack Style Guide
#       Disabled H306 (alphabetize imports)
#     pep257
#     pycodestyle
#     pylint
#       Disabled C0301 (line length)
#       Disabled C0326 (whitespace after comma)
from __future__ import print_function
import os
import argparse
import logging
import xml.etree.ElementTree as ETREE


# Set up colors for logging
logging.addLevelName(logging.CRITICAL, "\033[1;31m%s\033[1;0m" % logging.getLevelName(logging.CRITICAL))
logging.addLevelName(logging.ERROR,    "\033[1;31m%s\033[1;0m" % logging.getLevelName(logging.ERROR))
logging.addLevelName(logging.WARNING,  "\033[1;34m%s\033[1;0m" % logging.getLevelName(logging.WARNING))
logging.addLevelName(logging.INFO,     "\033[1;35m%s\033[1;0m" % logging.getLevelName(logging.INFO))
logging.addLevelName(logging.DEBUG,    "\033[1;33m%s\033[1;0m" % logging.getLevelName(logging.DEBUG))


def check_file(file_to_check, roms_dir, dry_run):
    """Check a given file."""
    if os.path.isfile(file_to_check):
        counter_xml_checked = 0
        counter_xml_removed = 0
        try:
            xml_tree = ETREE.parse(file_to_check)
        except Exception as error:
            logging.critical("Could not open/parse a file, error follows:\n" + str(error))
            raise Exception(error)
        counter_xml_checked, counter_xml_removed, xml_tree = parse_xml(xml_tree, roms_dir, dry_run)
        try:
            if not dry_run:
                xml_tree.write(file_to_check)
        except Exception as error:
            logging.critical("Could not write to file, error follows:\n" + str(error))
            raise Exception(error)
        return counter_xml_checked, counter_xml_removed
    else:
        logging.critical("File '" + str(file_to_check) + "'not found, aborting")
        raise Exception("File '" + str(file_to_check) + "'not found, aborting")


def parse_xml(passed_xml_tree, roms_dir, dry_run):
    """Parse the XML of a given XML tree in memory."""
    counter_xml_checked = 0
    counter_xml_removed = 0
    dry_run_printed = False
    xml_tree_root = passed_xml_tree.getroot()
    for xml_tree_game in xml_tree_root.findall('game'):
        counter_xml_checked += 1
        # file_path = xml_tree_game.find('path').text
        file_path = os.path.join(roms_dir + xml_tree_game.find('path').text[1:])
        logging.debug('Checking if file exists: ' + str(file_path))
        if os.path.isfile(file_path):
            # ISSUE -- all paths are "./filename.ext"
            # ISSUE -- Need to check real dir...get system name...
            # ISSUE -- /home/pi/RetroPie/roms/<<SYSTEM>>/<<FILENAME>>.<<EXT>>
            logging.debug('    File exists.')
        else:
            logging.debug('    File does not exist, deleting XML entry.')
            if dry_run:
                if not dry_run_printed:
                    logging.debug('DRY RUN: Would have removed XML entries for:')
                    dry_run_printed = True
                logging.debug('      id: ' + str(xml_tree_game.get('id')) + '    name: ' + str(xml_tree_game.find('name').text))
            else:
                xml_tree_root.remove(xml_tree_game)
            counter_xml_removed += 1
    logging.info("    Total games checked: " + str(counter_xml_checked))
    if dry_run:
        logging.info("    Total games removed: 0  If not dry run would have removed " + str(counter_xml_removed))
    else:
        logging.info("    Total games removed: " + str(counter_xml_removed))
    return counter_xml_checked, counter_xml_removed, passed_xml_tree


def main():
    """The true main function."""
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='\033[1;33mClean out unused sections of the gamelist.xml usually remainders of trying to get games scraped properly.\033[1;0m'
        )
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--all-systems',    dest='all_systems',  action='store_true', default=True,                                                    help='Check all systems in default location')
    group.add_argument('--input-file',     dest='input_file',                        default=None,                                                    help='Single file to check')
    parser.add_argument('--gamelists-dir', dest='gamelist_dir',                      default='/opt/retropie/configs/all/emulationstation/gamelists/', help='Override default gamelists directory')
    parser.add_argument('--roms-dir',      dest='roms_dir',                          default='/home/pi/RetroPie/roms/',                               help='Override default roms directory, when using --input-file make this the system directory')
    parser.add_argument('--dry-run',       dest='dry_run',      action='store_true', default=False,                                                   help='Make no changes, only report')
    parser.add_argument('--debug',         dest='debug',        action='store_true', default=False,                                                   help='Enable debug output')
    args = parser.parse_args()
    if args.debug:
        logging.basicConfig(level=logging.DEBUG, format="[%(levelname)8s] %(message)s")
    else:
        logging.basicConfig(level=logging.INFO,  format="[%(levelname)8s] %(message)s")
    if args.input_file and not args.roms_dir:
        logging.critical("When using --input-file you must specify the system's rom directory")
        raise Exception("When using --input-file you must specify the system's rom directory")
    total_xml_files_checked = 0
    total_xml_entries_checked = 0
    total_xml_entries_removed = 0

    if args.all_systems and not args.input_file:
        try:
            for os_walk_root, os_walk_dirs, os_walk_files in os.walk(args.gamelist_dir, followlinks=True):  # hide error from unused os_walk_dirs # pylint: disable=W0612
                for filename in os_walk_files:
                    system_name = os_walk_root.split('/')[-1]
                    if str(filename) == 'gamelist.xml' and system_name != 'retropie':
                        logging.info("Checking " + system_name)
                        temp_xml_checked, temp_xml_removed = check_file(os.path.join(os_walk_root, filename), os.path.join(args.roms_dir, system_name), args.dry_run)
                        total_xml_entries_checked += temp_xml_checked
                        total_xml_entries_removed += temp_xml_removed
                        total_xml_files_checked += 1
        except EnvironmentError as error:
            logging.critical("Could not scan directory, error follows:\n" + error)
            raise Exception(error)
    else:
        total_xml_entries_checked, total_xml_entries_removed = check_file(args.input_file, args.roms_dir, args.dry_run)
        total_xml_files_checked += 1
    logging.info('Total stats:')
    logging.info('    XML files   checked: ' + str(total_xml_files_checked))
    logging.info('    XML entries checked: ' + str(total_xml_entries_checked))
    if args.dry_run:
        logging.info("    XML entries removed: 0  If not dry run would have removed " + str(total_xml_entries_removed))
    else:
        logging.info('    XML entries removed: ' + str(total_xml_entries_removed))
    return


if __name__ == '__main__':
    main()
