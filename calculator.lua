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
