--Директория пакетов
package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
--Запуск модуля WXWidgets
wx = require("wx")

--Переменная, отвечающая за то, в какой директории на данный момент запускается программа
APPDIR = arg[0]:gsub("calculator.lua", "")

--Подключение модулей:
--1) Набор таблиц - таблица событий и таблица символов
dofile(APPDIR.."defaultTables.lua")
--2) Библиотека функций работы с графикой, ключами и событиями
dofile(APPDIR.."frameLibrary.lua")
--3) Нарисованное GUI-окно
dofile(APPDIR.."gui.lua")
--4) События для клавиш
dofile(APPDIR.."events.lua")


--Запускаем программу
runApplication()
