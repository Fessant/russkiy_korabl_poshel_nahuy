### russkiy_korabl_poshel_nahuy

# Орієнтовна вартість:
Як показала практика 1 інстанс який працює з ранку до 1 ночі по мордору, за місяць навалює приблизно на 100 $. Тобто 16 інстансів == 1600 $ на місяць. Обирайте за своїм бюджетом.

# Коротко як працює актуальний майстер:
1) У вас є файл links.txt можете його оновити перед використанням для атак на власний список адрес, або залишити список порожнім, тоді система візьме список з ремоуту і ви будете атакувати аткуальні цілі. Додатково - тепер система автоматично відслідковує оновлення списку і автоматично скачує та перезапускає процесс. Процесс в нескінченному циклі, тому вранці включили - а на ніч воно `само виключилось, дивись 1.1`.
   
   1.1) Додана можливість автоматичного вимикання. Достатньо виставити потрібний час в variables.tf - shutdown_hour. За замовченням стоїть 22 години, за умови що в московії +3 години UTC, це означає що ДДос автоматично припиниться, і сервера будуть погашені, о першій годині ночі за московією.
   
2) Адреси в файлі повинні бути построчно, у вигляді dns або `ip port` через спейс. Типу:

   `webmail.airport58.ru`
   
   `91.219.194.7 80`
   
   `93.219.194.7 22`
   
   2.2) IP адреси із серії "лоакльних" тепер відсіюються. До прикладу:
      `127.0.0.0 – 127.255.255.255     127.0.0.0 /8`
      `10.0.0.0 –  10.255.255.255      10.0.0.0 /8`
      `172.16.0.0 – 172. 31.255.255    172.16.0.0 /12`
      `192.168.0.0 – 192.168.255.255   192.168.0.0 /16`

3) Якщо в списку попадається `dns` ім'я, на приклад `webmail.airport58.ru` то скрипт копає його, знаходить всі наявні `ip` адреси і б'є по всім доступним.   
4) При запуску тераформу цей список попадає на кожну віртуалку де скрипт запускає докер з посиланням зі списку.
5) Одночасно працює 3 контейнери. кожен контейнер працює годину або поки не впаде, або поки не впаде сайт і контейнер сам зупиниться.
6) коли звільняється місце якогось контейнера, скрипт запускає новий з наступною по списку адресою.
8) Коли\якщо віртуалки подохли - оновлюєм список, або використовуємо той самий і запускаємо по новій.

# Для початку тобі треба:

0) Нову поштову адресу для АВС аккаунту на всяк випадок.
0.1) Поставити на комп `aws cli` для Windows в powershell `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
1) Номер телефону який не шкода на всяк випадок.
2) Віртуальна картка (гривнєва обов'язково бо під час війни доллар не продається і її неможливо поповнити) з лімітом грошей на ній. 3$ для старту достатньо.
3) АВС аккаунт, там створи ACCESS KEY, обов'язково збережи його, він показується один раз.
 
   3.1) Активуй зону Hong Kong (займає хвилин 5) Account > AWS Regions > Hong Kong - Enable
   
   3.1) Перейди в цей регіон

4) в сервісі KEY PAIRS створи .pem RSA ключ, збережи його собі десь. Назва ключа в АВС має співпадати з назвою ключа в коді в `main.tf => aws_spot_instance_request => key_name`
5) І постав на машину собі terraform
   
   5.1) В Windows powershell ранимо однією командою весь наступний виділений текст: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`
   
   5.2) Потім ранимо в терміналі `choco install terraform`

# Для ручного запуску:

1) Скачати цю репу
2) бути залогіненим в АВС в консолі\терміналі - `aws configure`
3) В папці з репою в терміналі запустити - `terraform init`
4) Додати в змінних `variables.tf` шлях до АВС .pem ключу
5) Додати\оновити за необхідності файл links.txt вебсайтами для атаки (беріть в будь якому ТГ каналі https://t.me/itarmyofukraine2022 або "ddos котики")
6) Запускаєш в терміналі в репі - `terraform apply` 
приблизний результат ![image](https://user-images.githubusercontent.com/24322276/155978270-46a9b635-8519-48f1-8a98-a6f216e1c61d.png)
7) Чекаєш на весь конфіг, та пишеш - `yes`
8) Якщо маслає довго - гуд. Якщо перестало то скоріше за все або адреса сайту невірна або сайт не відповідає.
приблизний результат того що все працює ![image](https://user-images.githubusercontent.com/24322276/155978537-84cbaa5d-c323-4ab4-a61e-571b6369872f.png)
9) Процесс атаки налаштований на одну годину. Після цього робимо `terraform destroy`, за бажанням\потребою змінюємо сайт для атаки, і знову `terraform apply`
10) Якщо `terraform destroy` більше 3х хвилин не закінчується, тоді ліземо на АВС сайт, обираємо `instances`, виділяємо всі та стопаємо їх:
![image](https://user-images.githubusercontent.com/24322276/155982236-15ad9379-7e06-4d97-b21d-8b34f5182b50.png)
11) Для того щоб глянути чи не завалився ще сайт можна законектитись на будь який зі своїх інстансів, глянути логи контейнера. Якщо массове `no connection! web server maybe down!` то або сайт ліг або закрились з ГонКонгу і треба перемикатись на щось інше.
12) Щоб підключитись на якусь віртуалку треба на АВС зайти в фічу `Instances` там клікаєш на будь яку яка `running` і там буде `connect`

# Як налаштувати на повністю автоматичну роботу за допомогою безкоштовного інстансу на AWS:

1) Login to your AWS account and create (launch) new EC2 instance
Name it, for example Master.
Choose all free options tier what possible
`amazon linux 2`
`t3.micro`
`choose your key`
`default vpc`
2) Wait for full initialization of incstance
3) Choose your C2 instance => security => click your security group name => Click: Edit inbounds rules => Add rule => Type - ssh, Source - my IP.
4) Connect to it
5) Copy aws_key.pem to this EC2 (log off - type EXIT in terminal. At your pc type in one line `scp -i "c:/war/aws_key.pem" c:/war/aws_key.pem  ec2-user@ec2-YOUR-EC2-IP-HERE.ap-east-1.compute.amazonaws.com:/tmp/` 
   5.1) WARNING: UNPROTECTED PRIVATE KEY FILE - problem? Execute next from this solution https://gist.github.com/jaskiratr/cfacb332bfdff2f63f535db7efb6df93:
      `icacls.exe aws_key.pem /reset`
      `icacls.exe aws_key.pem /grant:r "$($env:username):(r)"`
      `icacls.exe aws_key.pem /inheritance:r`
6) Login to the EC2 again.
7) cd /tmp && sudo yum -y install git
8) Download repo - git clone https://github.com/Fessant/russkiy_korabl_poshel_nahuy.git
9) cd /tmp/russkiy_korabl_poshel_nahuy
10) Install terraform
`sudo yum install -y yum-utils`
`sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`
`sudo yum -y install terraform`
11) Check succesfull start of terraform manually as usually
12) When everything will be fine add cron job:
Run: `crontab -e`
`INSERT`
paste in window in one line next: `00 06 * * * cd /tmp/russkiy_korabl_poshel_nahuy && terraform apply -var instance_count=16 -var pem_key_path=/tmp/aws_key.pem -auto-approve` 
then press `ESC` `:wq` `ENTER`
13) Ensure that crontab set properly. Run: `crontab -l`
Тепер ваш Мастер інстанс буде жити цілодобово, і кожен день о шостій ранку по серверу - `00 06 * * *` + 3 години по UTC, тобто о 9:00 по мордору, буде запускати 16 віртуалок з ДДОСом. Які в свою чергу о першій ночі по мордору будуть гаситися. І так по колу.

