--Подключаем модули графической библиотеки
local APPDIR = ""--"./Lua/"

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

--Создаём основное окно
local mainFrame = createFrame(0, 0, 230, 304, "Калькулятор", "nores")
setAppIcon(mainFrame, APPDIR.."cicon.ico") --Устанавливаем иконку
mainFrame:Show() --Показываем окно
centerElement(mainFrame)
local shared = false --Перемнная, обозначающая, что калькулятор сложен/разложен

--Основной редактируемый лейбл/эдит (я ещё подумаю)
local edit = createEdit(5, 5, 177, 27, "0", "read", mainFrame)

---История рассчётов
local memoHistory = createEdit(230, 5, 225, 230, "История:\n", "mread", mainFrame)
local clearHistory = createButton(230, 240, 225, 35, "Очистить", _, mainFrame)


--[[======================== СОЗДАНИЕ КНОПОЧЕК НА ФОРМЕ ========================]]
--Длина по 40, высота по 35
local butNum = {} --Цифровые клавиши
local but = {} --Символьные

--Кнопка истории рассчётов
local butHistory = createButton(187, 5, 36, 27, "S", _, mainFrame)

--Первый ряд кнопок
local butMC = createButton(5+2,		38+2, 40-4, 35-4, "MC", _, mainFrame)
local butMR = createButton(50+2,	38+2, 40-4, 35-4, "MR", _, mainFrame)
local butMS = createButton(95+2, 	38+2, 40-4, 35-4, "MS", _, mainFrame)
local butMP = createButton(140+2, 	38+2, 40-4, 35-4, "M+", _, mainFrame)
local butMM = createButton(185+2, 	38+2, 40-4, 35-4, "M-", _, mainFrame)

--Второй порядок кнопок
local butRm  = createButton(5, 	 80, 40, 35, "←", _, mainFrame)
local butCl  = createButton(50,  80, 40, 35, "CE", _, mainFrame)
local butCc  = createButton(95,  80, 40, 35, "C", _, mainFrame)
but["Negtv"] = createButton(140, 80, 40, 35, "±", _, mainFrame)
but["Sqrt"]  = createButton(185, 80, 40, 35, "√", _, mainFrame)

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
local butPt = createButton(95, 	240, 40, 35, ".", _, mainFrame)
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

			result = ( result/(Calculation.Number[id+1] or 1) )*100

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
	setText(memoHistory, getText(memoHistory).."\n"..text.."\n")
end

--События
local zeroClick = false --Ноль для десятичной дроби 
local sqrtClick = false --Нажаты ли квадратный корень или реверсивная функция
local SavingText = "0" --переменная сохранения текста
for i = 1, 9 do
	--Событие нажатия
	addEvent(butNum[i], "onClick", function()

		--Если был нажат квадратный корень или 1/x
		if sqrtClick then
			--Во имя исправления косяка, исключить это данное 
			return false
		end

		--Если есть инфинита, то обнуляем
		if getText(edit) == "∞" then setText(edit, "0") end

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
addEvent(butNum[0], "onClick", function()

	--Если у нас символ бесконечности, то обнуляем
	if getText(edit) == "∞" then setText(edit, "0") end

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
addEvent(butPt, "onClick", function()
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
	addEvent(but[v], "onClick", function()

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
addEvent(but.Sqrt, "onClick", function()

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
addEvent(but.Revrs, "onClick", function()

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
addEvent(but.Negtv, "onClick", function()

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
addEvent(but.Reslt, "onClick", function()
	
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
addEvent(butRm, "onClick", function()

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
addEvent(butCc, "onClick", function()
	
	--Снова найдём размеры строк
	local ls = numeric:len()
	local text = getText(edit)
	local lt = text:len()

	numeric = "0"
	text = text:sub(0, lt-ls)

	setText(edit, text.."0")
end)

--и если нажмём на кнопку, которая чистит всё выражение сразу
addEvent(butCl, "onClick", function()

	--Обнуляем все результаты и числа
	clearResults()
	numeric = "0"
	setText(edit, "0")

end)

--Если нажать на загадочную клавишу S (история ввода)
addEvent(butHistory, "onClick", function()

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
addEvent(clearHistory, "onClick", function()

	--Просто обнулить текст
	setText(memoHistory, "История:\n")

end)

--Memory Clear
addEvent(butMC, "onClick", function()
	MEMORY = 0
end)
--Memory Save
addEvent(butMS, "onClick", function()
	MEMORY = tonumber(numeric)
end)
--Memory Read
addEvent(butMR, "onClick", function()
	local text = getText(edit)
	local lnth = numeric:len()

	numeric = tostring(MEMORY)

	text = text:sub(1, text:len()-lnth)
	text = text..numeric

	setText(edit, text)

end)
--Memory add
addEvent(butMP, "onClick", function()
	MEMORY = MEMORY+numeric
end)
--Memory remove
addEvent(butMM, "onClick", function()
	MEMORY = MEMORY-numeric
end)

--Событие по нажатию символов на клавиатуре
addEvent(mainFrame, "onKey", function(key) 
	--Получим текстовую часть ключа (кнопку)
	key = getKey(key)

	--Циклим все кнопки
	for i = 0, 9 do
		--Если клавиша совпадает с параметром цикла
		if (key == tostring(i) or key == "num_"..tostring(i)) and not isKeyPressed("shift") then

			--То вызвать событие нажатия на данной клавише
			executeEvent(butNum[i], "onClick")
		end
	end

	--Если кнопка "стереть" - то стереть один символ - вызвать событие на кнопку со стрелкой
	if key == "backspace" then executeEvent(butRm, "onClick") end
	--Если кнопка "удалить" - то обнулить актуальное число - вызвать событие на кнопку "C"
	if key == "delete" or key == "num_del" then executeEvent(butCc, "onClick") end
	--Если кнопка "снести" - то обнулить всё выражение - вызвать событие на кнопку "CE"
	if isKeyPressed("shift") and (key == "delete" or key == "num_delete") then executeEvent(butCl, "onClick") end

	--Теперь действия
	--Если сложение
	if key == "+" or key == "num_add" or (isKeyPressed("shift") and key == "=") then executeEvent(but.Plus, "onClick") end
	--Если вычитание
	if key == "-" or key == "num_sub" then executeEvent(but.Minus, "onClick") end
	--Если произведение
	if key == "*" or key == "num_mul" or (isKeyPressed("shift") and key == "8") then executeEvent(but.Proiz, "onClick") end
	--Если деление
	if key == "/" or key == "num_div" then executeEvent(but.Divd, "onClick") end
	--Если процент
	if isKeyPressed("shift") and key == "5" then executeEvent(but.Perc, "onClick") end
	--Если отрицание
	if isKeyPressed("shift") and (key == "-" or key == "num_sub") then executeEvent(but.Negtv, "onClick") end

	--Теперь результат
	if key == "enter" or key == "num_enter" or key == "=" then executeEvent(but.Reslt, "onClick") end

	--Проверка ключей
	--print("\""..key.."\"")

end)

--Обязательный пункт, его надо всегда в конец программы ставить
runApplication()