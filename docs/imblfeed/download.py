import os
import os.path
from time import localtime, strptime, strftime, sleep
import logging as logger

from dotenv import load_dotenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec

from dpkw.utils.core.logging import init_logger
from dpkw.imblfeed.kdbloader import load_files, move_files


def process_single_exchange(wd, mic):
    seconds_to_sleep = 1

    # Find the link to auction imbalance feed and click it
    link = wd.find_element_by_xpath(f'//a[@href="#/{mic}/auctions"]')
    wd.execute_script("arguments[0].click();", link)

    # Wait until the table is fully loaded
    ag_count_xpath = '//span[@data-e2e-tag="agCountTo"]'
    WebDriverWait(wd, 60).until(ec.presence_of_element_located((By.XPATH, ag_count_xpath)))

    # Find and click export to Excel
    # sleep(seconds_to_sleep)
    excel_xpath = '//button[@title="export to excel"]'
    WebDriverWait(wd, 60).until(ec.presence_of_element_located((By.XPATH, excel_xpath)))
    wd.find_element_by_xpath(excel_xpath).click()

    # Update the file name to download
    sleep(seconds_to_sleep)
    hidden_cols_xpath = '//input[@name="fileName"]'
    WebDriverWait(wd, 60).until(ec.presence_of_element_located((By.XPATH, hidden_cols_xpath)))
    timestamp = strftime('%Y%m%d_%H%M%S', localtime())
    file_name = f'_imbalance_feed_{mic}_{timestamp}'
    wd.find_element_by_xpath(hidden_cols_xpath).send_keys(file_name)

    # Click to select hidden columns
    # sleep(seconds_to_sleep)
    wd.find_element_by_xpath('//div[@data-e2e-tag="allColumns"]').click()

    # Click to download the EXCEL file
    logger.info(f'Downloading {file_name}')
    download_link = wd.find_elements_by_xpath('//button[@type="submit"]')[-1]
    if download_link.get_attribute('data-disabled') == 'true':
        logger.info(f'Exporting to EXCEL is disabled for {mic}. Skipping...')
        return
    download_link.click()
    sleep(seconds_to_sleep)


def load_and_move_files():
    imblfeed_host = os.getenv('NYSE_IMBL_KDB_HOST')
    imblfeed_port = int(os.getenv('NYSE_IMBL_KDB_PORT'))
    download_dir = f"{os.path.expanduser('~')}/Downloads"

    # Retrieve the directory to store imbalance feed
    # Create the directory if it doesn't exist.
    imblfeed_dir = os.getenv('NYSE_IMBL_DST_DIR')
    if not os.path.exists(imblfeed_dir):
        os.makedirs(imblfeed_dir)

    load_files(imblfeed_host, imblfeed_port, download_dir)
    move_files(imblfeed_host, imblfeed_port, download_dir, imblfeed_dir)


def launch(username, password):
    url = 'https://cdm.nyse.com/#/login'
    options = webdriver.ChromeOptions()

    if os.path.exists('C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'):
        options.binary_location = 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe'
    elif os.path.exists('C:/Program Files/Google/Chrome/Application/chrome.exe'):
        options.binary_location = 'C:/Program Files/Google/Chrome/Application/chrome.exe'

    chrome_driver_binary = "C:/Install/chromedriver/chromedriver"
    driver = webdriver.Chrome(chrome_driver_binary, options=options)
    driver.get(url)

    # Wait until the username and password input box is ready
    WebDriverWait(driver, 60).until(ec.presence_of_element_located((By.ID, "username")))
    
    # Type in username and password
    ubox = driver.find_element_by_id('username')
    pbox = driver.find_element_by_id('password')
    ubox.send_keys(username)
    pbox.send_keys(password)
    driver.find_element_by_id('launch').click()

    # Wait until the page if loaded
    WebDriverWait(driver, 1200).until(ec.presence_of_element_located((By.XPATH, '//li[@data-title="XASE"]')))
    
    yyyymmdd = strftime('%Y%m%d', localtime())
    datetime_format = '%Y%m%d %H:%M:%S'
    open_auction_time = strptime(f'{yyyymmdd} 09:35:00', datetime_format)
    close_imbl_start_time = strptime(f'{yyyymmdd} 14:55:00', datetime_format)
    close_auction_time = strptime(f'{yyyymmdd} 16:05:00', datetime_format)

    while True:
        if open_auction_time < localtime() < close_imbl_start_time:
            sleep(5)
            continue

        for exchange in ['xase', 'arcx', 'xnys']:
            process_single_exchange(driver, exchange)

        # Load data to kdb
        sleep(1)
        load_and_move_files()

        if localtime() > close_auction_time:
            logger.info('Exit after market close')
            break


if __name__ == '__main__':
    # Config the logging
    init_logger()

    # Load environment variables
    load_dotenv()

    # Download the imbalance feed
    email = os.getenv('NYSE_USERNAME')
    passw = os.getenv('NYSE_PASSWORD')
    launch(email, passw)
