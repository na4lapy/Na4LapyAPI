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
$ git clone https://github.com/na4lapy/na4lapy-api
```

### Zbuduj projekt dla XCode

```shell
$ cd Na4lapyAPI
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
$ cd na4lapy-api-swift
$ swift build
```

### Przykładowy skrypt uruchamiający

```shell
#!/bin/bash
export N4L_API_DATABASE_USER="na4lapy"
export N4L_API_DATABASE_PASS="___PASS___"

.build/debug/Na4lapyAPI
```
