### russkiy_korabl_poshel_nahuy

# Коротко як працює актуальний майстер:
1) У вас є файл links.txt можете його оновити перед використанням.
2) При запуску тераформу цей список попадає на кожну віртуалку де скрипт запускає докер з посиланням зі списку.
3) Одночасно працює 4 контейнери. кожен контейнер працює годину або поки не впаде, або поки не впаде сайт і контейнер сам зупиниться.
4) коли звільняється місце якогось контейнера, скрипт запускає новий з наступною по списку адресою.
5) Коли\якщо віртуалки подохли - оновлюєм список, або використовуємо той самий і запускаємо по новій.

# Для початку тобі треба:

0) Нову поштову адресу для АВС аккаунту на всяк випадок.
0.1) Поставити на комп `aws cli` для Windows в powershell `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
1) Номер телефону який не шкода на всяк випадок.
2) Віртуальна картка (гривнєва обов'язково бо під час війни доллар не продається і її неможливо поповнити) з лімітом грошей на ній. 3$ для старту достатньо.
3) АВС аккаунт, там створи ACCESS KEY, обов'язково збережи його, він показується один раз.
 
   3.1) Активуй зону Hong Kong (займає хвилин 5) Account > AWS Regions > Hong Kong - Enable
   
   3.1) Перейди в цей регіон

4) в сервісі KEY PAIRS створи .pem RSA ключ, збережи його собі десь.
5) І постав на машину собі terraform
   
   5.1) В Windows powershell ранимо однією командою весь наступний виділений текст: `Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`
   
   5.2) Потім ранимо в терміналі `choco install terraform`

# Для запуску:

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
