# API w Swift dla aplikacji Na4Łapy

"Na4Łapy" to aplikacja pozwalająca przeglądać zdjęcia i opisy zwierząt znajdujących się pod opieką gdańskiego schroniska Promyk. Użytkownik może w prosty sposób dodawać psy i koty do listy ulubionych oraz przekazywać datki na zwierzęta w formie elektronicznych mikropłatności.

Zapraszamy na stronę http://na4lapy.org

## Instalacja dla systemu macOS

### Zainstaluj PostgreSQL

```shell
brew install postgresql
brew link postgresql
brew services start postgresql

// to stop 
brew services stop postgresql
```

### Podlinkuj katalog include ze swojego repozytorium homebrew zgodnie z poniższym wzorcem:

```shell
$ ls -l /usr/local/include
lrwxr-xr-x  1 root  wheel  54 27 gru 13:48 /usr/local/include -> /Users/YOUR_LOGIN/homebrew/Cellar/postgresql/9.6.1/include/
```

### Przygotuj bazę Na4lapy zgodnie z instrukcją

[TODO]

### Pobierz repozytorium

```shell
$ git clone https://github.com/na4lapy/Na4LapyAPI
```

### Zbuduj projekt dla XCode

```shell
$ cd Na4LapyAPI
$ swift package generate-xcodeproj
```

### Uruchom XCode i załaduj utworzony plik projektu

### Zmodyfikuj schemat zgodnie z instrukcją:

XCode -> Product -> Scheme -> Edit Scheme 

jako 'Executable' wybierz 'Na4lapyAPI'

### Skompiluj i uruchom projekt

### Aplikacja domyślnie słucha na porcie 8123, parametry połączenia można przekazać za pomocą zmiennych środowiskowych:

```shell
export N4L_API_DATABASE_USER="na4lapy"
export N4L_API_DATABASE_PASS="___PASS___"
```

### Domyślne parametry połączenia znajdują się w pliku Constants.swift

```swift
struct DBDefault {
    static let dbname = "na4lapyprod"
    static let user = "na4lapy"
    static let password = "na4pass"
    static let host = "127.0.0.1"
}
```

## Instalacja dla systemu Linux

### W systemie musi być zainstalowany Swift 3.0.x

### W systemie musi być zainstalowany PostgreSQL wraz z pakietami developerskimi

### Kompilacja:

```shell
$ cd Na4LapyAPI
$ swift build
```

W wyniku zostanie zbudowany plik '.build/debug/Server'

### Przykładowy skrypt uruchamiający

```shell
#!/bin/bash
export N4L_API_DATABASE_USER="na4lapy"
export N4L_API_DATABASE_PASS="___PASS___"

.build/debug/Server
```

## Deploy nowej wersji API 

Wszystkie operacje muszą być wykonywane w imieniu użytkownika 'na4lapy'.

Kod źródłowy znajduje się w katalogu /opt/Na4LapyAPI/
Aby pobrać najnowszą wersję należy wykonać polecenie 'git pull', oraz uruchomić testy i kompilację

```shell
$ cd /opt/Na4LapyAPI
$ git pull
$ swift test
$ swift build
```

Po poprawnie wykonanej kompilacji należy zmodyfikować numer wersji pakietu w pliku DEBIAN/control
Kolejnym krokiem jest powrót do katalogu domowego użytkownika 'na4lapy'

```shell
$ cd
$ pwd
/home/na4lapy
```

Będąc w tym katalogu należy uruchomić skrypt budujący pakiet:

```shell
$ /opt/Na4LapyAPI/scripts/dpkg-build.sh
dpkg-deb: building package `na4lapyapi' in `na4lapyapi_0.1-2.deb'.
```

Pakiet zostanie zbudowany w aktualnym katalogu, w jego nazwie będzie zawarta wersja wpisana w pliku DEBIAN/control

```shell
$ ls -l na4lapyapi_0.1-2.deb 
-rw-r--r-- 1 na4lapy na4lapy 1207138 Mar 29 00:40 na4lapyapi_0.1-2.deb
```

Następnie pakiet należy zainstalować:

```shell
$ sudo dpkg -i na4lapyapi_0.1-2.deb 
(Reading database ... 41757 files and directories currently installed.)
Preparing to unpack na4lapyapi_0.1-2.deb ...
Unpacking na4lapyapi (0.1-2) over (0.1-1) ...
Setting up na4lapyapi (0.1-2) ...
```

Po poprawnej instalacji pakietu proszę zrestartować serwer poleceniem systemctl 
Można się upewnić, że proces z serwerem pracuje.

```shell
$ sudo systemctl restart na4lapyapi
$ ps -ef | grep Server
na4lapy  17254     1  0 00:54 ?        00:00:00 /usr/local/na4lapyapi/Server
```

Dodatkowo możliwe są operacje zatrzymywania, uruchamiania oraz badania stanu serwera api:

```shell
$ sudo systemctl stop na4lapyapi
$ sudo systemctl start na4lapyapi
$ sudo systemctl status na4lapyapi
```

Logi serwera api dostępne są za pomocą polecenia:

```shell
$ sudo journalctl -fu na4lapyapi
```

