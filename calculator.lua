--Подключаем модули графической библиотеки
local APPDIR = arg[0]:gsub("calculator.lua", "")--"./Lua/"

dofile(APPDIR.."frameLibrary.lua") --Библиотека функций
local MEMORY = 0 --Число в буфере

--Предварительно обозначим символы
local Elements = {
	["Plus"] = "+",
	["Minus"] = "-",
	["Proiz"] = "×",
	["Divd"] = "÷",
	["Sqrt"] = "√",
	["Perc"] = "%",
	["Result"] = "="
}

local colorScheme = {
	Dark = {
		Frame = "444444", 
		Text = "EEEEEE", 
		EditB = "404040", 
		EditT = "EEEEEE", 
		ButD = "333333", 
		ButL = "252525", 
		ButM = "EEEEEE",
		Green = "2e7d32", 
		Red = "b71c1c"
	},
	Light = {
		Frame = "EEEEEE", 
		Text = "444444", 
		EditB = "FFFFFF", 
		EditT = "333333", 
		ButD = "E4E4E4", 
		ButL = "DEDEDE", 
		ButM = "44EEEEEE",
		Green = "26c850", 
		Red = "df3939"
	},
}
local DefaultColorScheme = colorScheme.Dark

--Создаём основное окно
local mainFrame = createFrame(0, 0, 230, 304, "Калькулятор", "nores")
setAppIcon(mainFrame, APPDIR.."cicon.ico") --Устанавливаем иконку
mainFrame:Show() --Показываем окно
centerElement(mainFrame)
local shared = false --Перемнная, обозначающая, что калькулятор сложен/разложен

--Основной редактируемый лейбл/эдит (я ещё подумаю)
local edit = createEdit(5, 5, 177, 27, "0", "read", mainFrame)

---История рассчётов
local memoHistory = createEdit(230, 5, 225, 230, " История:\n", "mread", mainFrame)
setFont(memoHistory,"Open Sans", 9)
local clearHistory = createButton(230, 240, 225, 35, "Очистить", _, mainFrame)


--[[======================== СОЗДАНИЕ КНОПОЧЕК НА ФОРМЕ ========================]]
--Длина по 40, высота по 35
local butNum = {} --Цифровые клавиши
local but = {} --Символьные
local topBut = {} --Краска для символов

--Кнопка истории рассчётов
local butHistory = createButton(187, 5, 36, 27, "Log", _, mainFrame)

--Первый ряд кнопок
but[1] = createButton(5+2,		38+2, 40-4, 35-4, "MC", _, mainFrame)
but[2] = createButton(50+2,		38+2, 40-4, 35-4, "MR", _, mainFrame)
but[3] = createButton(95+2, 	38+2, 40-4, 35-4, "MS", _, mainFrame)
but[4] = createButton(140+2, 	38+2, 40-4, 35-4, "M+", _, mainFrame)
but[5] = createButton(185+2, 	38+2, 40-4, 35-4, "M-", _, mainFrame)

--Второй порядок кнопок
but[6]  	= createButton(5, 	80, 40, 35, "←", _, mainFrame)
but[7]  	= createButton(50,  80, 40, 35, "CE", _, mainFrame)
but[8]  	= createButton(95,  80, 40, 35, "C", _, mainFrame)
but.Negtv	= createButton(140, 80, 40, 35, "±", _, mainFrame)
but["Sqrt"] = createButton(185, 80, 40, 35, "√", _, mainFrame)

--Третий порядок кнопок
butNum[7] 	= createButton(5, 	120, 40, 35, "7", _, mainFrame)
butNum[8] 	= createButton(50, 	120, 40, 35, "8", _, mainFrame)
butNum[9] 	= createButton(95, 	120, 40, 35, "9", _, mainFrame)
but["Divd"] = createButton(140, 120, 40, 35, "/", _, mainFrame)
but["Perc"] = createButton(185, 120, 40, 35, "%", _, mainFrame)

--Третий порядок кнопок
butNum[4] 	= createButton(5, 	160, 40, 35, "4", _, mainFrame)
butNum[5] 	= createButton(50, 	160, 40, 35, "5", _, mainFrame)
butNum[6] 	= createButton(95, 	160, 40, 35, "6", _, mainFrame)
but["Proiz"]= createButton(140, 160, 40, 35, "*", _, mainFrame)
but["Revrs"]= createButton(185, 160, 40, 35, "1/x", _, mainFrame) --"x¯¹"

--Четвертый порядок кнопок
butNum[1]	= createButton(5, 	200, 40, 35, "1", _, mainFrame)
butNum[2] 	= createButton(50, 	200, 40, 35, "2", _, mainFrame)
butNum[3] 	= createButton(95, 	200, 40, 35, "3", _, mainFrame)
but["Minus"]= createButton(140, 200, 40, 35, "-", _, mainFrame)
but["Reslt"]= createButton(185, 200, 40, 75, "=", _, mainFrame)

--Последний порядок кнопок
butNum[0] 	= createButton(5, 	240, 85, 35, "0", _, mainFrame)
butNum[10] = createButton(95, 	240, 40, 35, ".", _, mainFrame)
but["Plus"] = createButton(140, 240, 40, 35, "+", _, mainFrame)


--Переменные, обозначающие рассчёт
local Calculation = {
	Number = {}, --Число, с которым производится операция
	Job = {} --Функция, которая выполняется для числа (сумма, разность етс)
}
local numeric = "0" --Сохраняющий номер

--Функции для рассчёта
--Добавить число в таблицу
function addNumber(num) 

	local id = #Calculation.Number+1 --Увеличить идентификатор на 1 больше размерности таблицы
	Calculation.Number[id] = num --Присвоить элементу с данным идентификатором значение числа
	--Обнулить сохраняющий номер
	numeric = "0" 
end
--Добавить функцию рассчёта
function addJob(vid) ---Аргументом функции является фраза, обозначающая операцию

	local id = #Calculation.Job+1 --Таким же образом рассчитываем идентификатор
	Calculation.Job[id] = vid --И устанавливаем аргумент для функции

end
--Функция рассчёта значения
function calculateResult()
	local id = 1 --Идентификатор для цикла (цикл по всей таблице Job)
	local result = Calculation.Number[id] or 0 --Результирующее значение, которое будет рассчитываться

	--Пока ещё существует рабочее значение
	while Calculation.Job[id] ~= nil do

		--Если функция сложения
		if Calculation.Job[id] == "Plus" then

			--То результат мы суммируем с новым числом (или 0, если такое значение отсутствует)
			result = result+(Calculation.Number[id+1] or 0)

		--Если отрицания
		elseif Calculation.Job[id] == "Minus" then

			--То от результата вычитаем новое число (или 0)
			result = result-(Calculation.Number[id+1] or 0)

		--Если произведение
		elseif Calculation.Job[id] == "Proiz" then

			--То результат умножаем на новое число (или на 1)
			result = result*(Calculation.Number[id+1] or 1)

		--Если деление
		elseif Calculation.Job[id] == "Divd" then

			--Результат делим на новое число (или на 1)
			result = result/(Calculation.Number[id+1] or 1)

		--Если рассчёт квадратного корня
		elseif Calculation.Job[id] == "Sqrt" then

			--То высчитываем корень из результата 
			result = math.sqrt(result) or 0

		--Если результат отрицательной степень (1/x)
		elseif Calculation.Job[id] == "Revrs" then

			--То высчитываем результат через заданную функцию
			result = result^(-1)

		elseif Calculation.Job[id] == "Perc" then

			result = ( result / 100) * (Calculation.Number[id+1] or 1) --)*100

		elseif Calculation.Job[id] == "Negtv" then

			result = result*(-1)

		end

		id = id+1 --Плюсуем идентификатор для цикла while

	end

	--Обнуляем
	clearResults()

	--По завершению цикла возвращаем результат
	return result
end
--Функция обнуления
function clearResults()

	--Обнуляем таблицу рассчёта
	Calculation = { 
		Number = {},
		Job = {}
	}
	--Обнуляем текст в строке
	setText(edit, "0")

	--Обнуляем число рассчёта
	numeric = "0"
end

function addHistoryElement(text)
	setText(memoHistory, getText(memoHistory).."\n "..text.."\n")
end

--События
local zeroClick = false --Ноль для десятичной дроби 
local sqrtClick = false --Нажаты ли квадратный корень или реверсивная функция
local SavingText = "0" --переменная сохранения текста

--События на наведение
--Двойной цикл для всех элементов-клавишь
for _, v in pairs({but, butNum, {butHistory, clearHistory}}) do for _, i in pairs(v) do
	--При наведении
	addEvent(i, "onMouseEnter", function()
		--Делаем темнее на 20 уровней (ну тип между 0 и 255)
		setDarker(i, 20)
	end)

end end

--И обратный цикл, на отведение
for _, v in pairs({but, butNum, {butHistory, clearHistory}}) do for _, i in pairs(v) do
	--При отведении
	addEvent(i, "onMouseLeave", function()
		--Добавляет светлость на 20 уровней
		setLighter(i, 20)
	end)

end end


for i = 1, 9 do
	--Событие нажатия
	addEvent(butNum[i], "onMouseDown", function()

		--Если был нажат квадратный корень или 1/x
		if sqrtClick then
			--Во имя исправления косяка, исключить это данное 
			return false
		end

		--Если есть инфинита, то обнуляем
		if getText(edit) == "∞" then 
			setText(edit, "") 
			numeric = ""
		end

		--Получаем текст
		local text = getText(edit)

		--Если исходное число 0
		if numeric == "0" then
			numeric = "" --То обнуляем число
			text = text:sub(1, text:len()-1) --Вырезаем текст
		end

		if zeroClick then --Если нажата десятичная дробь
			if tostring(numeric):find(".0") then --То если ноль найден перед точкой
				numeric = tostring(numeric):gsub(".0", ".") --Очищаем ноль
				text = text:sub(1, text:len()-1) --Вырезаем из текста
			end
			zeroClick = false --Отключаем десятичку.
		end

		--Дописываем число в номер и текст
		numeric = tostring(numeric..i)

		--Если в тексте найдена в конце скобка, то снести её
		if text:sub(text:len(), text:len()) == ")" then text = text:sub(1, text:len()-1) end
		--print('"'..text:sub(text:len(), text:len())..'"')
		text = text..i

		--Обновляем текст
		setText(edit, text)
		--Сохраняем текст
		SavingText = getText(edit)
	end)	
end

--Событие для символа 0
addEvent(butNum[0], "onMouseDown", function()

	--Если у нас символ бесконечности, то обнуляем
	if getText(edit) == "∞" then 
		setText(edit, "") 
		numeric = ""
	end

	--Если заданное число уже 0
	if tostring(numeric) == "0" then 
		return false --То прекратить событие
	end

	--В противном случае, если на десятичную точку не было нажато
	if not zeroClick then

		--Если был нажат квадратный корень
		if sqrtClick then 
			--Во имя ошибок, вернуть false на всё
			return false
		end

		local text = getText(edit)
		numeric = tostring(numeric.."0") --То добавляем символ в конце	

		--Если в тексте найдена в конце скобка, то снести её
		if text:sub(text:len(), text:len()) == ")" then text = text:sub(1, text:len()-1) end		
		text = text.."0" --И обновляем текст
		

		--Обновляем текст
		setText(edit, text)

	else --если нажато на десятичную точку
		zeroClick = false --То отменить её
	end

	--Обновить переменную сохранения текста
	SavingText = getText(edit)
end)

--Событие для символа точки
addEvent(butNum[10], "onMouseDown", function()
	--Если в номере уже есть точка
	if numeric:find("%.") then 
		return false --То закрыть выполнение данного события
	end
	--Если идёт рассчёт через скобку, точка будет лишней
	if sqrtClick then return false end

	--Устанавливаем значение
	numeric = tostring(numeric..".0")
	setText(edit, getText(edit)..".0")
	--Пересохраняем текст
	SavingText = getText(edit)
	--Устанавливаем переменную, обозначающую нажатие на точку как true
	zeroClick = true
end)

--События для действий
for _, v in pairs({"Plus", "Minus", "Proiz", "Divd", "Perc"}) do
	addEvent(but[v], "onMouseDown", function()

		--Добавляем в таблицу обработанный номер/цифру
		addNumber(tonumber(numeric))
		--Добавляем в работу собственно само действие
		addJob(v)

		--Обнуляем параметры единичной функции
		sqrtClick = false
		numeric = "0"

		--Обновляем текст
		setText(edit, getText(edit).." "..Elements[v].." 0")
		SavingText = getText(edit)
	
	end)
end
--Событие нажатия квадратного корня
addEvent(but.Sqrt, "onMouseDown", function()

	--Добавляем в таблицу обработанный номер/цифру
	addNumber(tonumber(numeric))
	--Добавляем в работу собственно само действие
	addJob("Sqrt")

	--Устанавливаем нажатость корня
	sqrtClick = true
	--Устанавливаем текст
	setText(edit, Elements.Sqrt.."("..getText(edit)..")")

	--Сохраним текст
	SavingText = getText(edit)

end)
--Событие нажатия клавиши 1/x
addEvent(but.Revrs, "onMouseDown", function()

	--Добавляем в таблицу обработанный номер/цифру
	addNumber(tonumber(numeric))
	--Добавляем в работу собственно само действие
	addJob("Revrs")

	--Устанавливаем нажатость деления
	sqrtClick = true
	--Устанавливаем текст
	setText(edit, "1/("..getText(edit)..")")

	--Сохраним текст
	SavingText = getText(edit)


end)

--Событие нажатия клавиши +-
addEvent(but.Negtv, "onMouseDown", function()

	--Добавляем в таблицу обработанный номер/цифру
	addNumber(tonumber(numeric))
	--Добавляем в работу собственно само действие
	addJob("Negtv")

	--Устанавливаем нажатость отрицания
	sqrtClick = true
	--Устанавливаем текст
	setText(edit, "-("..getText(edit)..")")

	--Сохраним текст
	SavingText = getText(edit)
end)
--Если это кнопка результата
addEvent(but.Reslt, "onMouseDown", function()
	
	--Добавить число в таблицу
	addNumber(tonumber(numeric))
	--Посчитать результат
	local res = calculateResult()
	--Если результат переходит в инфиниту, то заменить соответствующий текст символом
	if tostring(res) == "inf" or tostring(res) == "-nan" then res = "∞" end

	----------------------------
	if res == 666 then
		res = "Welcome to HELL"
	end
	----------------------------

	--Добавить элемент в историю
	addHistoryElement(SavingText.." = "..res)

	--Установить текст
	if res == "Welcome to HELL" then res = 666 end
	setText(edit, res)

	--Если заданный текст - таки инфинита, то превратить её рассчёт в ноль
	if res == "∞" then res = 0 end
	--Обновить число
	numeric = getText(edit)
	--Обнулить параметры
	zeroClick = false
	sqrtClick = false

end)

--События на клавиши удаления символов
addEvent(but[6], "onMouseDown", function()

	--Если активна скобочка, то не удалять
	if sqrtClick then return false end

	local ls = numeric:len() --Длина числа для удаления
	local text = getText(edit) --Текст
	local lt = text:len() --Длина текста
		
	--Если в числе последние 2 символа будут .0
	if numeric:sub(ls-1, ls) == ".0" then 

		--То уберём сразу два этих числа
		numeric = numeric:sub(1, ls-2)
		text = text:sub(1, lt-2)

	--Если их найдено не будет
	else

		--То вычтем по одному символу текста
		numeric = numeric:sub(1, ls-1)
		text = text:sub(1, lt-1)
	
		--Если мы очистили подчистую	
		if numeric == "" then
			--То оставим хотя бы нолик 
			numeric = "0" 
			text = text.."0"
		end

		--Если последний символ - это точка
		if numeric:sub(ls-1, ls) == "." then
			--То добавим к нему нолик, ведь проверка на наличие нолика уже была 
			numeric = numeric.."0" 
			text = text.."0"
		end

	end

	--Установим текст
	setText(edit, text)

end)

--Если нажмём на кнопку C, которая очистит только фрагмент выражения
addEvent(but[8], "onMouseDown", function()

	--Если активна скобочка, то не удалять
	if sqrtClick then return false end
	
	--Снова найдём размеры строк
	local ls = numeric:len()
	local text = getText(edit)
	local lt = text:len()

	numeric = "0"
	text = text:sub(0, lt-ls)

	setText(edit, text.."0")
end)

--и если нажмём на кнопку, которая чистит всё выражение сразу
addEvent(but[7], "onMouseDown", function()

	--Обнуляем все результаты и числа
	clearResults()
	numeric = "0"
	zeroClick = false
	sqrtClick = false
	setText(edit, "0")

end)

--Если нажать на загадочную клавишу S (история ввода)
addEvent(butHistory, "onMouseDown", function()

	--Если окно развернуто
	if shared then
		--То свернуть
		setSize(mainFrame, 230, 304)
	else
		--Иначе развернуть
		setSize(mainFrame, 230*2, 304)
	end
	--Переключить параметр развертности
	shared = not shared

end)

--Кнопка очистки истории
addEvent(clearHistory, "onMouseDown", function()

	--Просто обнулить текст
	setText(memoHistory, " История:\n")

end)

--Memory Clear
addEvent(but[1], "onMouseDown", function()
	MEMORY = 0
end)
--Memory Save
addEvent(but[3], "onMouseDown", function()
	MEMORY = tonumber(numeric)
end)
--Memory Read
addEvent(but[2], "onMouseDown", function()
	local text = getText(edit)
	local lnth = numeric:len()

	numeric = tostring(MEMORY)

	text = text:sub(1, text:len()-lnth)
	text = text..numeric

	setText(edit, text)

end)
--Memory add
addEvent(but[4], "onMouseDown", function()
	MEMORY = MEMORY+numeric
end)
--Memory remove
addEvent(but[5], "onMouseDown", function()
	MEMORY = MEMORY-numeric
end)

--Событие по нажатию символов на клавиатуре
addEvent(mainFrame, "onKey", function(key) 
	--Получим текстовую часть ключа (кнопку)
	key = getKey(key)

	--Циклим все кнопки
	for i = 0, 9 do
		--Если клавиша совпадает с параметром цикла
		if (key == tostring(i) or key == "num_"..tostring(i)) then

			--То вызвать событие нажатия на данной клавише
			executeEvent(butNum[i], "onMouseDown")
		end
	end

	--Если кнопка "стереть" - то стереть один символ - вызвать событие на кнопку со стрелкой
	if key == "backspace" then executeEvent(but[6], "onMouseDown") end
	--Если кнопка "удалить" - то обнулить актуальное число - вызвать событие на кнопку "C"
	if key == "delete" or key == "num_del" then executeEvent(but[8], "onMouseDown") end
	--Если кнопка "снести" - то обнулить всё выражение - вызвать событие на кнопку "CE"
	if isKeyPressed("shift") and (key == "delete" or key == "num_delete") then executeEvent(but[7], "onMouseDown") end

	--Теперь действия
	--Если сложение
	if key == "+" or key == "num_add" or (isKeyPressed("shift") and key == "=") then executeEvent(but.Plus, "onMouseDown") end
	--Если вычитание
	if key == "-" or key == "num_sub" then executeEvent(but.Minus, "onMouseDown") end
	--Если произведение
	if key == "*" or key == "num_mul" or (isKeyPressed("shift") and key == "8") then executeEvent(but.Proiz, "onMouseDown") end
	--Если деление
	if key == "/" or key == "num_div" then executeEvent(but.Divd, "onMouseDown") end
	--Если процент
	if isKeyPressed("shift") and key == "5" then executeEvent(but.Perc, "onMouseDown") end
	--Если отрицание
	if isKeyPressed("shift") and (key == "-" or key == "num_sub") then executeEvent(but.Negtv, "onMouseDown") end

	--Теперь результат
	if key == "enter" or key == "num_enter" or (key == "=" and not isKeyPressed("shift"))  then executeEvent(but.Reslt, "onMouseDown") end

	if key == "M" then
		if DefaultColorScheme == colorScheme.Dark then
			DefaultColorScheme = colorScheme.Light
		else
			DefaultColorScheme = colorScheme.Dark
		end
		
		setColorScheme(DefaultColorScheme.Frame, 
			DefaultColorScheme.Text, 
			DefaultColorScheme.EditB, 
			DefaultColorScheme.EditT, 
			DefaultColorScheme.ButD, 
			DefaultColorScheme.ButL, 
			DefaultColorScheme.ButM, 
			DefaultColorScheme.Green, 
			DefaultColorScheme.Red
		)

	end
	--Проверка ключей
	--print("\""..key.."\"")

end)

--Функции
--Смена цветовой схемы
--Цвет окна, основной цвет текста, задник эдитбокса, цвет текста эдитбокса, светлые кнопки, тёмные кнопки, текст цветных кнопок, зеленая кнопка, красная кнопка
function setColorScheme(framecol, text, editsBack, editsText, lightButton, darkButton, colButtons, green, red)
	
	setColor(mainFrame, framecol, text)
	local textEd = getText(memoHistory)
	setColor(memoHistory, editsBack, editsText)
	setText(memoHistory, textEd)

	setColor(butHistory, lightButton, text)

	for _, v in pairs(but) do setColor(v, lightButton, text) end
	for _, v in pairs(butNum) do setColor(v, darkButton, text) end
	setColor(but.Reslt, green, colButtons)
	setColor(clearHistory, red, colButtons)

	setColor(edit, editsBack, editsText)	
end

--покрасим
setColorScheme(DefaultColorScheme.Frame, 
	DefaultColorScheme.Text, 
	DefaultColorScheme.EditB, 
	DefaultColorScheme.EditT, 
	DefaultColorScheme.ButD, 
	DefaultColorScheme.ButL, 
	DefaultColorScheme.ButM, 
	DefaultColorScheme.Green, 
	DefaultColorScheme.Red)


--Обязательный пункт, его надо всегда в конец программы ставить
runApplication()