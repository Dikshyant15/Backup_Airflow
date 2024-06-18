from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.email import EmailOperator

# Define default arguments
default_args = {
    'owner': 'avyu',
    'depends_on_past': False,
    'start_date': datetime(2024, 6, 16),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=2),  # Retry every 2 minutes in case of failure
}

# Define DAG with cron scheduling
dag2 = DAG(
    'Automate_Hello_Mail',
    default_args=default_args,
    description='A simple DAG that sends an email every 10 minutes using cron scheduling',
    #schedule_interval='30 18 * * *',  # Cron
    schedule_interval=timedelta(seconds=10), 
    catchup=False, 
)

# Task to send email
send_email = EmailOperator(
    task_id='send_email',
    to=['khwaouns321@gmail.com'], 
    subject='Hello from Avyuthan',
    html_content='<p>Good Evening!<br/><br/>Have a blast!<br/><em>Yours Sincerely<br/>Avyuthan Shah<br/>[ARL]</em></p>',
    dag=dag2,
)

# Set task dependencies
send_email 