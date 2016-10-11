--Таблица с элементами
local Calculation = {
	Number 	= {}, 	--Таблица с числами, с которыми производятся операции
	Job 	= {} 	--Таблица с действиями, которые выполняется для чисел в таблице выше
}
local SavingNumber 			= "0" 	--Переменная, в которую будет сохранено текущее число
local isLogOpened 			= false --Переменная, отвечающая за то, открыта ли панель с историей счёта
local MEMORY 				= 0 	--Число в памяти для рассчёта через MC/MS/MR/M+/M-

--Функции для рассчёта
--Добавить число в таблицу
function addNumber(num) 

	local id 				= #Calculation.Number+1 --Создать переменную идентификатора, полученную увеличением длины таблицы на 1
	Calculation.Number[id] 	= num 					--Присвоить элементу с данным идентификатором в таблице значение числа
	SavingNumber 			= "0" 					--Обнулить сохраняющий номер
end

--Добавить функцию рассчёта
function addJob(job) --Аргументом функции является фраза, обозначающая операцию

	local id 				= #Calculation.Job+1 	--Таким же образом рассчитываем идентификатор для действия
	Calculation.Job[id] 	= job 					--И устанавливаем аргумент для функции

end

--Функция рассчёта значения
function calculateResult()
	local id = 1 --Идентификатор для цикла (цикл по всей таблице Job)
	local result = Calculation.Number[id] or 0 --Результирующее значение, которое будет рассчитываться

	--Пока ещё существует рабочее значение
	while Calculation.Job[id] 		~= nil do

		--Если функция сложения
		if Calculation.Job[id] 		== Symbols.Plus then

			--То результат мы суммируем с новым числом (или 0, если такое значение отсутствует)
			result = result+(Calculation.Number[id+1] or 0)

		--Если отрицания
		elseif Calculation.Job[id] 	== Symbols.Subs then

			--То от результата вычитаем новое число (или 0)
			result = result-(Calculation.Number[id+1] or 0)

		--Если произведение
		elseif Calculation.Job[id] 	== Symbols.Mply then

			--То результат умножаем на новое число (или на 1)
			result = result*(Calculation.Number[id+1] or 1)

		--Если деление
		elseif Calculation.Job[id] 	== Symbols.Divd then

			--Результат делим на новое число (или на 1)
			result = result/(Calculation.Number[id+1] or 1)

		--Если рассчёт квадратного корня
		elseif Calculation.Job[id] 	== Symbols.Sqrt then

			--То высчитываем корень из результата 
			result = math.sqrt(result) or 0

		--Если результат отрицательной степень (1/x)
		elseif Calculation.Job[id] 	== Symbols.Rvrs then

			--То высчитываем результат через заданную функцию
			result = result^(-1)

		elseif Calculation.Job[id] 	== Symbols.Perc then

			result = ( result / 100) * (Calculation.Number[id+1] or 1)

		elseif Calculation.Job[id] 	== Symbols.Negv then

			result = result*(-1)

		end

		if tostring(result) == "-0" then result = 0 end

		id = id+1 --Плюсуем идентификатор для цикла while

	end

	--Обнуляем
	clearResults()

	--По завершению цикла возвращаем результат
	return result
end
--Функция обнуления
function clearResults()

	--Обнуляем таблицу
	Calculation = { 
		Number = {},
		Job = {}
	}
	--Обнуляем текст в верхней строке калькулятора
	setText(ResultBox, "0")

	--Обнуляем сохраняющее число
	SavingNumber = "0"
end

local zeroClick = false --Переменная, отвечающая за то, чтобы ноль в десятичной дроби заменялся на число (12.0 -> 12.5)
local isUnaryOp = false --Переменная, которая будет являться проверкой на выполнение унарной операции (sqrt, 1/x, +-)

--Исполнение цикла для действий по нажатию на клавиши
for i, v in pairs(Buttons) do
	
	addEvent(v, "onMouseEnter", function()
		setAlpha(v, 0.7)
	end)
	addEvent(v, "onMouseLeave", function()
		setAlpha(v, 1)
	end)

	--Добавляется событие нажатия
	addEvent(v, "onMouseDown", function()

		--Переведём аргумент в строку
		i = tostring(i)
		--Если ключ цикла можно перевести в число (0-9)
		if tonumber(i) then

			--Если исполняется унарная операция, то закончить событие
			if isUnaryOp then return false end

			local text = getText(ResultBox)

			--Если есть символ бесконечности
			if text == Symbols.Inft then
			
				SavingNumber 	= "" 	--Обнуляем всё
				text 		 	= ""	--И переменную с текстом
				setText(ResultBox,"") 	--Включая текст
			
			--Если исходное число 0
			elseif SavingNumber == "0" then
			
				SavingNumber = "" 							--То обнуляем число
				text 		 = text:sub(1, text:len()-1)	--Вырезаем текст
			
			end

			--Если была нажата точка
			if zeroClick then 
				if tostring(SavingNumber):find(".0") then 	--То если ноль найден перед точкой

					SavingNumber = tostring(SavingNumber):gsub(".0", ".") 	--Очищаем ноль
					text 		 = text:sub(1, text:len()-1) 				--Вырезаем из текста
				end

				zeroClick = false --Удаляется параметр
			end

			--Сохраняется номер
			SavingNumber = tostring(SavingNumber..tonumber(i))
			setText(ResultBox, text..i) --Обновляется символ

		--Если нажатие не на число, то
		else

			--Если нажатие на точку
			if i == "." then

				if getText(ResultBox) == Symbols.Inft then			
					SavingNumber = 		"0" 	--Обнуляем всё
					setText(ResultBox,  "0") 	--Включая текст
				end
					
				--Если в числе уже есть точка, или совершается унарная операция, то закрыть событие
				if SavingNumber:find("%.") or isUnaryOp then return false end

				--Устанавливаем точку
				SavingNumber = SavingNumber..".0"
				setText(ResultBox, getText(ResultBox)..".0")

				--Обозначаем, что мы нажали на точку
				zeroClick = true

			--Если нажатие на математическое действие
			elseif 
				i == Symbols.Plus or 
				i == Symbols.Subs or 
				i == Symbols.Mply or 
				i == Symbols.Divd or 
				i == Symbols.Perc or 
				i == Symbols.Sqrt or 
				i == Symbols.Rvrs or 
				i == Symbols.Negv 
				then

					addNumber(tonumber(SavingNumber))
					addJob(i)

					--Заменить символ бесконечности
					setText(ResultBox, getText(ResultBox):gsub(Symbols.Inft, "0"))

					--Если операции унарные
					if i == Symbols.Sqrt or i == Symbols.Rvrs or i == Symbols.Negv then

						isUnaryOp 		= true --То соответственно сообщить об этом программе
						local startText = 
							i == Symbols.Sqrt and i.."(" 					or 
							i == Symbols.Rvrs and "1"..Symbols.Divd.."("	or
							i == Symbols.Negv and "-("  

						setText(ResultBox, startText..getText(ResultBox)..")")

					--Если не унарные
					else

						isUnaryOp 		= false --Сообщаем, что операция не унарная
						SavingNumber 	= "0"	--Обнуляем сохраняющий номер для новой операции

						--Обновляем текст
						setText(ResultBox, getText(ResultBox).." "..i.." 0")
					end

			--Если нажатие на клавишу Backspace
			elseif i == Symbols.Back then

				--Если унарная операция, то закрыть событие
				if isUnaryOp then return false end

				local ls = SavingNumber:len() --Длина числа для удаления
				local text = getText(ResultBox) --Текст
				local lt = text:len() --Длина текста
		
				--Если в числе последние 2 символа будут .0
				if SavingNumber:sub(ls-1, ls) == ".0" then 

					--То уберём сразу два этих числа
					SavingNumber = SavingNumber:sub(1, ls-2)
					text = text:sub(1, lt-2)

				--Если их найдено не будет
				else

					--То вычтем по одному символу текста
					SavingNumber = SavingNumber:sub(1, ls-1)
					text = text:sub(1, lt-1)
	
					--Если мы очистили подчистую	
					if SavingNumber == "" then
						--То оставим хотя бы нолик 
						SavingNumber = "0" 
						text = text.."0"
					end

					--Если последний символ - это точка
					if SavingNumber:sub(ls-1, ls) == "." then
						--То добавим к нему нолик, ведь проверка на наличие нолика уже была 
						SavingNumber = SavingNumber.."0" 
						text = text.."0"
					end

				end

				--Установим текст
				setText(ResultBox, text)

			--Если нажимаем СЕ, которая обнуляет введённое на данный момент число 
			elseif i == "CE" then

				--Если унарная операция, то закрыть событие
				if isUnaryOp then return false end

				local text 		= getText(ResultBox):sub(0, getText(ResultBox):len()-SavingNumber:len())
				SavingNumber	= "0"

				setText(ResultBox, text.."0")

			--Если мы нажали на С, которое чистит всё
			elseif i == "C" then

				--Обнуляем все результаты и числа
				clearResults()
				SavingNumber = "0"
				zeroClick = false
				isUnaryOp = false
				setText(ResultBox, "0")		

			--Если мы считаем результат
			elseif i == Symbols.Result then				

				local text = getText(ResultBox)
				
				--Добавить число в таблицу
				addNumber(tonumber(SavingNumber))

				--Посчитать результат
				local res = calculateResult()
				--Если результат переходит в бесконечность, то заменить соответствующий текст символом
				if tostring(res) == "inf" or tostring(res) == "-nan" then res = Symbols.Inft end

				----------------------------
				if res == 666 then
					res = "Welcome to HELL"
				end
				----------------------------

				--Добавить элемент в лог
				if text == Symbols.Inft then text = "0" end
				addLogRes(text.." = "..res)

				--Установить текст
				if res == "Welcome to HELL" then res = 666 end
				setText(ResultBox, res)

				--Если заданный текст - бесконечность, то превратить её в ноль
				if res == Symbols.Inft then res = 0 end
				--Обновить число
				SavingNumber = getText(ResultBox)
				--Обнулить параметры
				zeroClick = false
				isUnaryOp = false

			--Если клавиша лога
			elseif i == "Log" then

				isLogOpened = not isLogOpened
				if isLogOpened then 
					setSize(MainFrame, 230*2, 304)
				else
					setSize(MainFrame, 230, 304)
				end

			--Если клавиша - очистить историю
			elseif i == "ClearLog" then

				setText(LogBox, " История:\n")

			--Если MEMORY CLEAR
			elseif i == "MC" then
				MEMORY = 0
			--Если MEMORY SAVE	
			elseif i == "MS" then
				MEMORY = SavingNumber
			--Если MEMORY READ
			elseif i == "MR" then
				setText(ResultBox, 
					getText(ResultBox):sub(
						1, 
						-(tostring(SavingNumber):len()+1)
					)..MEMORY
				)
				SavingNumber = MEMORY
			elseif i == "M+" then
				MEMORY = MEMORY+SavingNumber
			elseif i == "M-" then
				MEMORY = MEMORY-SavingNumber
			end

		end
	end)
end

addEvent(MainFrame, "onKey", function(key) 
	--Получим текстовую часть ключа (полное название кнопки на клавиатуре)
	key = getKey(key)

	--Циклим все кнопки
	for i = 0, 9 do
		--Если клавиша совпадает с параметром цикла
		if (key == tostring(i) or key == "num_"..tostring(i)) and not isKeyPressed("shift") then

			--То вызвать событие нажатия на данной клавише
			executeEvent(Buttons[tostring(i)], "onMouseDown")
		end
	end

	--Если кнопка "стереть" - то стереть один символ - вызвать событие на кнопку со стрелкой
	if key == "backspace" then executeEvent(Buttons[Symbols.Back], "onMouseDown") end
	--Если кнопка "удалить" - то обнулить актуальное число - вызвать событие на кнопку "CE"
	if key == "delete" or key == "num_del" then executeEvent(Buttons.CE, "onMouseDown") end
	--Если кнопка "стереть всё" - то обнулить всё выражение - вызвать событие на кнопку "C"
	if isKeyPressed("shift") and (key == "delete" or key == "num_delete") then executeEvent(Buttons.C, "onMouseDown") end

	--Теперь действия
	--Если сложение
	if key == "+" or key == "num_add" or (isKeyPressed("shift") and key == "=") then executeEvent(Buttons[Symbols.Plus], "onMouseDown") end
	--Если вычитание
	if key == "-" or key == "num_sub" then executeEvent(Buttons[Symbols.Subs], "onMouseDown") end
	--Если произведение
	if key == "*" or key == "num_mul" or (isKeyPressed("shift") and key == "8") then executeEvent(Buttons[Symbols.Mply], "onMouseDown") end
	--Если деление
	if key == "/" or key == "num_div" then executeEvent(Buttons[Symbols.Divd], "onMouseDown") end
	--Если процент
	if isKeyPressed("shift") and key == "5" then executeEvent(Buttons[Symbols.Perc], "onMouseDown") end
	--Если отрицание
	if isKeyPressed("shift") and (key == "-" or key == "num_sub") then executeEvent(Buttons[Symbols.Negv], "onMouseDown") end
	if key == "." or key == "," then executeEvent(Buttons[Symbols.Dots], "onMouseDown") end

	--Теперь результат
	if key == "enter" or key == "num_enter" or (key == "=" and not isKeyPressed("shift"))  then executeEvent(Buttons[Symbols.Result], "onMouseDown") end

	--Клавиша для смены цветовой схемы
	if key == "M" then
		
		--Убираем альфаканал
		for _, v in pairs(Buttons) do
			setAlpha(v, 1)
		end

		--Если дефолт - тёмная 
		if DefaultColorScheme == colorScheme.Dark then
			--То сменить на светлую
			DefaultColorScheme = colorScheme.Light
		else
			--Иначе - на тёмную
			DefaultColorScheme = colorScheme.Dark
		end
		
		--Установить цветовую схему в зависимости от стандартной цветовой схемы
		setColorScheme(DefaultColorScheme)

	end

end)
